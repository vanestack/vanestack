import 'dart:io' as io;

import 'package:vanestack_common/vanestack_common.dart';
import 'package:drift/drift.dart' hide Index;
import 'package:drift/native.dart';
import 'package:postgres/postgres.dart' as pg;

import 'concurrent_pg_database.dart';

import 'package:sqlite3/sqlite3.dart';
import 'package:uuid/uuid.dart';

import '../utils/env.dart';
import '../utils/random_name.dart';
import 'tables/buckets.dart';
import 'tables/collections.dart';
import 'tables/external_auths.dart';
import 'tables/files.dart';
import 'tables/logs.dart';
import 'tables/oauth_states.dart';
import 'tables/otps.dart';
import 'tables/refresh_tokens.dart';
import 'tables/reset_password_tokens.dart';
import 'tables/settings.dart';
import 'tables/users.dart';

part 'database.g.dart';

@DriftDatabase(
  tables: [
    Users,
    RefreshTokens,
    ResetPasswordTokens,
    Logs,
    Collections,
    AppSettings,
    Otps,
    Files,
    Buckets,
    OauthStates,
    ExternalAuths,
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase([QueryExecutor? executor, String path = './database.sqlite'])
    : super(executor ?? _openConnection(path));

  @override
  int get schemaVersion => 7;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (m) async {
      if (executor.dialect == SqlDialect.postgres) {
        await customStatement(_postgresRandomUuidV7FunctionSql);
        await customStatement(_postgresStrftimeFunctionSql);
      }
      await m.createAll();
      appSettings.insertOne(
        AppSettingsCompanion.insert(
          appName: generateRandomName(),
          oauthProviders: const OAuthProviderList(),
        ),
      );
    },
    onUpgrade: (m, from, to) async {
      if (executor.dialect == SqlDialect.postgres) {
        // Idempotent; ensures existing postgres DBs get the helpers after upgrade.
        await customStatement(_postgresRandomUuidV7FunctionSql);
        await customStatement(_postgresStrftimeFunctionSql);
      }

      if (from < 2) {
        await m.createTable(oauthStates);
      }

      if (from < 3) {
        await m.addColumn(oauthStates, oauthStates.redirectUrl);
      }

      if (from < 5) {
        await m.addColumn(collections, collections.type);
        await m.addColumn(collections, collections.viewQuery);
      }

      if (from < 6) {
        await m.deleteTable('_logs');
        await m.createTable(logs);
      }

      if (from < 7) {
        await m.createTable(externalAuths);
      }
    },
  );

  /// Opens an [AppDatabase] using the backend selected by [env].
  ///
  /// Dispatches on [Environment.databaseBackend]:
  /// - [DatabaseBackend.sqlite] opens a file at [Environment.sqlitePath].
  /// - [DatabaseBackend.postgres] opens [Environment.postgresUrl]
  ///   (required, else throws).
  factory AppDatabase.fromEnv(Environment env) {
    switch (env.databaseBackend) {
      case DatabaseBackend.sqlite:
        return AppDatabase(null, env.sqlitePath);
      case DatabaseBackend.postgres:
        final url = env.postgresUrl;
        if (url == null || url.isEmpty) {
          throw StateError(
            'VANESTACK_DATABASE=postgres requires VANESTACK_POSTGRES_URL to be set.',
          );
        }
        return AppDatabase(postgresExecutor(url));
    }
  }

  static QueryExecutor _openConnection(String path) {
    return NativeDatabase.createInBackground(io.File(path), setup: setup);
  }

  /// Translates `?` placeholders to `$N` when running against postgres.
  ///
  /// drift_postgres passes custom SQL through without any substitution, so
  /// any hand-written query that uses `?` must be adapted before hitting
  /// the driver. On sqlite this is a no-op.
  ///
  /// The adapter skips `?` characters that appear inside single-quoted
  /// string literals (`'O''Reilly'`) — our generated SQL never embeds a
  /// literal `?` elsewhere.
  String adaptPlaceholders(String sql) {
    if (executor.dialect != SqlDialect.postgres) return sql;

    final buf = StringBuffer();
    var i = 0;
    var idx = 1;
    while (i < sql.length) {
      final ch = sql[i];
      if (ch == "'") {
        buf.write(ch);
        i++;
        while (i < sql.length) {
          final c = sql[i];
          buf.write(c);
          i++;
          if (c == "'") {
            if (i < sql.length && sql[i] == "'") {
              buf.write(sql[i]);
              i++;
              continue;
            }
            break;
          }
        }
        continue;
      }
      if (ch == '?') {
        buf.write('\$');
        buf.write(idx++);
        i++;
        continue;
      }
      buf.write(ch);
      i++;
    }
    return buf.toString();
  }

  /// Builds a Postgres [QueryExecutor] from a connection URL such as
  /// `postgres://user:pass@host:5432/db?sslmode=require`.
  static QueryExecutor postgresExecutor(String url) {
    final uri = Uri.parse(url);
    if (uri.scheme != 'postgres' && uri.scheme != 'postgresql') {
      throw ArgumentError.value(
        url,
        'url',
        'Expected a postgres:// or postgresql:// URL.',
      );
    }

    final userInfo = uri.userInfo.split(':');
    final username = userInfo.isNotEmpty && userInfo.first.isNotEmpty
        ? Uri.decodeComponent(userInfo.first)
        : null;
    final password = userInfo.length > 1
        ? Uri.decodeComponent(userInfo.sublist(1).join(':'))
        : null;
    final database = uri.pathSegments.isNotEmpty
        ? uri.pathSegments.first
        : (throw ArgumentError.value(
            url,
            'url',
            'Postgres URL is missing a database name.',
          ));

    final sslMode = switch (uri.queryParameters['sslmode']) {
      'disable' => pg.SslMode.disable,
      'require' => pg.SslMode.require,
      'verify-full' => pg.SslMode.verifyFull,
      _ => pg.SslMode.require,
    };

    final pool = pg.Pool.withEndpoints(
      [
        pg.Endpoint(
          host: uri.host.isEmpty ? 'localhost' : uri.host,
          port: uri.hasPort ? uri.port : 5432,
          database: database,
          username: username,
          password: password,
        ),
      ],
      settings: pg.PoolSettings(
        maxConnectionCount: 5,
        sslMode: sslMode,
        applicationName: 'vanestack',
      ),
    );

    return ConcurrentPgDatabase.pool(pool);
  }

  static void setup(Database database) {
    database.execute('pragma journal_mode = WAL;');
    database.execute('pragma synchronous = NORMAL;');
    database.execute('pragma cache_size = -8000;');
    database.execute('pragma busy_timeout = 5000;');
    database.execute('pragma temp_store = memory;');
    database.createFunction(
      functionName: 'random_uuid_v7',
      directOnly: false,
      argumentCount: AllowedArgumentCount(0),
      function: (_) {
        return const Uuid().v7();
      },
    );
  }
}

/// Installs a `strftime(fmt, ts)` shim that mirrors sqlite's behavior for the
/// format specifiers drift emits when storing datetimes as integers.
///
/// Drift's integer datetime mode renders defaults as
/// `CAST(strftime('%s', CURRENT_TIMESTAMP) AS INTEGER)` unchanged across
/// dialects, so providing this shim lets the unmodified generated schema run
/// against postgres. Accepts both `timestamptz` and `timestamp` inputs via
/// overload pair.
const _postgresStrftimeFunctionSql = r'''
CREATE OR REPLACE FUNCTION strftime(fmt text, ts timestamptz)
RETURNS text AS $$
BEGIN
  RETURN CASE fmt
    WHEN '%s' THEN EXTRACT(EPOCH FROM ts)::bigint::text
    WHEN '%Y' THEN to_char(ts, 'YYYY')
    WHEN '%m' THEN to_char(ts, 'MM')
    WHEN '%d' THEN to_char(ts, 'DD')
    WHEN '%H' THEN to_char(ts, 'HH24')
    WHEN '%M' THEN to_char(ts, 'MI')
    WHEN '%S' THEN to_char(ts, 'SS')
    ELSE to_char(ts, fmt)
  END;
END;
$$ LANGUAGE plpgsql IMMUTABLE;
''';

/// Installs a `random_uuid_v7()` plpgsql helper so postgres-backed
/// collection DDL (`DEFAULT (random_uuid_v7())`) works the same as on sqlite.
///
/// Returns a lower-case dashed UUIDv7 string. Uses `gen_random_uuid()` from
/// core (pg 13+) as the random source — no `pgcrypto` extension required.
const _postgresRandomUuidV7FunctionSql = r'''
CREATE OR REPLACE FUNCTION random_uuid_v7() RETURNS text AS $$
DECLARE
  ts_ms  bigint;
  bytes  bytea;
  hex    text;
BEGIN
  ts_ms := (extract(epoch from clock_timestamp()) * 1000)::bigint;
  -- Use gen_random_uuid() as a portable source of 16 random bytes.
  bytes := decode(replace(gen_random_uuid()::text, '-', ''), 'hex');
  bytes := set_byte(bytes, 0, ((ts_ms >> 40) & 255)::int);
  bytes := set_byte(bytes, 1, ((ts_ms >> 32) & 255)::int);
  bytes := set_byte(bytes, 2, ((ts_ms >> 24) & 255)::int);
  bytes := set_byte(bytes, 3, ((ts_ms >> 16) & 255)::int);
  bytes := set_byte(bytes, 4, ((ts_ms >>  8) & 255)::int);
  bytes := set_byte(bytes, 5, ( ts_ms        & 255)::int);
  bytes := set_byte(bytes, 6, ((get_byte(bytes, 6) & 15) | 112));
  bytes := set_byte(bytes, 8, ((get_byte(bytes, 8) & 63) | 128));
  hex := encode(bytes, 'hex');
  RETURN substring(hex,  1,  8) || '-' ||
         substring(hex,  9,  4) || '-' ||
         substring(hex, 13,  4) || '-' ||
         substring(hex, 17,  4) || '-' ||
         substring(hex, 21, 12);
END;
$$ LANGUAGE plpgsql VOLATILE;
''';
