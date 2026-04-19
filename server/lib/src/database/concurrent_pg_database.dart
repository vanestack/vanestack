// A drift database for Postgres that lets pool connections run queries in
// parallel.
//
// Upstream `drift_postgres` sets `isSequential: true` on `DelegatedDatabase`
// and uses `NoTransactionDelegate`. Together those mean every query — even
// on a `Pool` — goes through a process-wide lock, and `BEGIN`/`COMMIT` are
// issued as raw statements that the pool may route to different connections.
// Both behaviors make sense for sqlite but defeat Postgres pooling.
//
// This fork flips `isSequential: false` and swaps in a
// `SupportedTransactionDelegate` that forwards `transaction(...)` blocks to
// `Pool.runTx`, which pins one connection for the duration of the
// transaction. The result: concurrent single-statement ops on the pool, and
// `AppDatabase.transaction(() => ...)` still works.
//
// Keep in sync with `drift_postgres/lib/src/pg_database.dart` when upgrading.

import 'dart:async';

import 'package:collection/collection.dart';
import 'package:drift/backends.dart';
import 'package:postgres/postgres.dart';

class ConcurrentPgDatabase extends DelegatedDatabase {
  ConcurrentPgDatabase.pool(
    Pool pool, {
    bool logStatements = false,
    bool enableMigrations = true,
  }) : super(
          _PgDelegate(pool, enableMigrations),
          isSequential: false,
          logStatements: logStatements,
        );

  @override
  SqlDialect get dialect => SqlDialect.postgres;
}

class _PgDelegate extends DatabaseDelegate {
  _PgDelegate(this._pool, this.enableMigrations);

  final Pool _pool;
  final bool enableMigrations;

  @override
  TransactionDelegate get transactionDelegate =>
      _PoolTransactionDelegate(_pool);

  @override
  late DbVersionDelegate versionDelegate;

  bool _opened = false;

  @override
  Future<bool> get isOpen => Future.value(_opened && _pool.isOpen);

  @override
  Future<void> open(QueryExecutorUser user) async {
    if (enableMigrations) {
      final pgVersionDelegate = _PgVersionDelegate(_pool);
      await pgVersionDelegate.init();
      versionDelegate = pgVersionDelegate;
    } else {
      versionDelegate = NoVersionDelegate();
    }
    _opened = true;
  }

  @override
  Future<void> runBatched(BatchedStatements statements) async {
    // Non-transactional batches are rare; route through the pool one-by-one so
    // each call can grab an available connection.
    for (final instantation in statements.arguments) {
      final sql = statements.statements[instantation.statementIndex];
      await runCustom(sql, instantation.arguments);
    }
  }

  Future<int> _runWithArgs(String statement, List<Object?> args) async {
    final pgArgs = _BoundArguments.ofDartArgs(args);
    final result = await _pool.execute(
      Sql(statement, types: pgArgs.types),
      parameters: pgArgs.parameters,
    );
    return result.affectedRows;
  }

  @override
  Future<void> runCustom(String statement, List<Object?> args) async {
    await _runWithArgs(statement, args);
  }

  @override
  Future<int> runInsert(String statement, List<Object?> args) async {
    final pgArgs = _BoundArguments.ofDartArgs(args);
    final result = await _pool.execute(
      Sql(statement, types: pgArgs.types),
      parameters: pgArgs.parameters,
    );
    return result.firstOrNull?[0] as int? ?? 0;
  }

  @override
  Future<int> runUpdate(String statement, List<Object?> args) async {
    return _runWithArgs(statement, args);
  }

  @override
  Future<QueryResult> runSelect(String statement, List<Object?> args) async {
    final pgArgs = _BoundArguments.ofDartArgs(args);
    final result = await _pool.execute(
      Sql(statement, types: pgArgs.types),
      parameters: pgArgs.parameters,
    );

    return QueryResult(
      [for (final pgColumn in result.schema.columns) pgColumn.columnName ?? ''],
      result,
    );
  }

  @override
  Future<void> close() async {
    // Owner of the pool is responsible for closing it; we just mark closed.
    _opened = false;
  }
}

class _PoolTransactionDelegate extends SupportedTransactionDelegate {
  _PoolTransactionDelegate(this._pool);

  final Pool _pool;

  // Transactions run on a pinned connection, so drift-level queries outside
  // the transaction may continue on other pool connections in parallel.
  @override
  bool get managesLockInternally => true;

  @override
  FutureOr<void> startTransaction(Future Function(QueryDelegate) run) async {
    await _pool.runTx((tx) async {
      await run(_TxQueryDelegate(tx));
    });
  }
}

/// Routes drift queries issued inside `db.transaction(...)` to a single
/// `TxSession` that `Pool.runTx` pins for us.
class _TxQueryDelegate extends QueryDelegate {
  _TxQueryDelegate(this._tx);

  final TxSession _tx;

  @override
  Future<QueryResult> runSelect(String statement, List<Object?> args) async {
    final pgArgs = _BoundArguments.ofDartArgs(args);
    final result = await _tx.execute(
      Sql(statement, types: pgArgs.types),
      parameters: pgArgs.parameters,
    );
    return QueryResult(
      [for (final col in result.schema.columns) col.columnName ?? ''],
      result,
    );
  }

  @override
  Future<int> runInsert(String statement, List<Object?> args) async {
    final pgArgs = _BoundArguments.ofDartArgs(args);
    final result = await _tx.execute(
      Sql(statement, types: pgArgs.types),
      parameters: pgArgs.parameters,
    );
    return result.firstOrNull?[0] as int? ?? 0;
  }

  @override
  Future<int> runUpdate(String statement, List<Object?> args) async {
    final pgArgs = _BoundArguments.ofDartArgs(args);
    final result = await _tx.execute(
      Sql(statement, types: pgArgs.types),
      parameters: pgArgs.parameters,
    );
    return result.affectedRows;
  }

  @override
  Future<void> runCustom(String statement, List<Object?> args) async {
    final pgArgs = _BoundArguments.ofDartArgs(args);
    await _tx.execute(
      Sql(statement, types: pgArgs.types),
      parameters: pgArgs.parameters,
    );
  }

  @override
  Future<void> runBatched(BatchedStatements statements) async {
    final prepared =
        List<Statement?>.filled(statements.statements.length, null);
    try {
      for (final inst in statements.arguments) {
        final pgArgs = _BoundArguments.ofDartArgs(inst.arguments);
        final idx = inst.statementIndex;
        var stmt = prepared[idx];
        if (stmt == null) {
          final sql = statements.statements[idx];
          stmt = prepared[idx] = await _tx.prepare(Sql(sql, types: pgArgs.types));
        }
        await stmt.run(pgArgs.parameters);
      }
    } finally {
      for (final stmt in prepared) {
        await stmt?.dispose();
      }
    }
  }
}

class _BoundArguments {
  final List<Type> types;
  final List<TypedValue> parameters;

  _BoundArguments(this.parameters)
      : types = parameters.map((p) => p.type).toList(growable: false);

  factory _BoundArguments.ofDartArgs(List<Object?> args) {
    final parameters = List<TypedValue>.generate(
      args.length,
      (i) {
        final value = args[i];
        return switch (value) {
          TypedValue() => value,
          null => TypedValue(Type.unspecified, null),
          int() => TypedValue(Type.bigInteger, value),
          String() => TypedValue(Type.text, value),
          bool() => TypedValue(Type.boolean, value),
          double() => TypedValue(Type.double, value),
          List<int>() => TypedValue(Type.byteArray, value),
          BigInt() => TypedValue(Type.bigInteger, value.rangeCheckedToInt()),
          _ => throw ArgumentError.value(value, 'value', 'Unsupported type'),
        };
      },
      growable: false,
    );

    return _BoundArguments(parameters);
  }
}

class _PgVersionDelegate extends DynamicVersionDelegate {
  final Session database;

  _PgVersionDelegate(this.database);

  @override
  Future<int> get schemaVersion async {
    final result = await database.execute(Sql('SELECT version FROM __schema'));
    return result[0][0] as int;
  }

  Future init() async {
    await database.execute(Sql('CREATE TABLE IF NOT EXISTS __schema ('
        'version integer NOT NULL DEFAULT 0)'));

    final count = await database.execute(Sql('SELECT COUNT(*) FROM __schema'));
    if (count[0][0] as int == 0) {
      await database.execute(Sql('INSERT INTO __schema (version) VALUES (0)'));
    }
  }

  @override
  Future<void> setSchemaVersion(int version) async {
    await database.execute(
      Sql(r'UPDATE __schema SET version = $1', types: [Type.integer]),
      parameters: [TypedValue(Type.integer, version)],
    );
  }
}

extension on BigInt {
  static final _bigIntMinValue64 = BigInt.parse('-9223372036854775808');
  static final _bigIntMaxValue64 = BigInt.parse('9223372036854775807');

  int rangeCheckedToInt() {
    assert(!identical(0, 0.0));

    if (this < _bigIntMinValue64 || this > _bigIntMaxValue64) {
      throw ArgumentError.value(
        this,
        'this',
        'Should be in signed 64bit range ($_bigIntMinValue64..=$_bigIntMaxValue64)',
      );
    }

    return toInt();
  }
}
