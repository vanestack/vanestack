import 'package:drift/drift.dart';
import 'package:vanestack_common/vanestack_common.dart';

import '../database/database.dart';
import '../utils/filter_parser.dart';
import '../utils/order_clause_parser.dart';
import 'context.dart';

/// Service class for log operations.
///
/// Can be used by:
/// - HTTP endpoints
/// - CLI commands
/// - Public API (`vanestack.logs.list()`, etc.)
class LogsService {
  final ServiceContext context;

  LogsService(this.context);

  AppDatabase get db => context.database;

  /// Lists logs with optional filtering, ordering, and pagination.
  Future<ListAppLogsResult> list({
    String? filter,
    String? orderBy,
    int limit = 10,
    int offset = 0,
  }) async {
    String? whereClause;
    List<Object?>? paramValues;
    if (filter != null) {
      (whereClause, paramValues) = FilterParser(
        filter,
        allowedFields: {
          'id',
          'level',
          'source',
          'message',
          'user_id',
          'created_at',
        },
      ).parse();

      if (whereClause.isNotEmpty) {
        whereClause = ' WHERE $whereClause';
      } else {
        whereClause = null;
      }
    }

    String? orderClause;
    if (orderBy != null) {
      final (sql, _) = OrderClauseParser(orderBy).parse();
      orderClause = sql.isNotEmpty ? ' $sql, id DESC' : null;
    }
    orderClause ??= ' ORDER BY id DESC';

    final result = await db
        .customSelect(
          'SELECT * from _logs${whereClause ?? ''}$orderClause LIMIT ? OFFSET ?',
          variables: [
            ...?paramValues?.map((value) => Variable(value)),
            Variable<int>(limit),
            Variable<int>(offset),
          ],
        )
        .get();

    final count = await db
        .customSelect(
          'SELECT COUNT(*) as count from _logs${whereClause ?? ''}',
          variables: [...?paramValues?.map((value) => Variable(value))],
        )
        .getSingle()
        .then((row) => row.read<int>('count'));

    final logs = await Future.wait([
      ...result.map((row) => db.logs.mapFromRow(row)),
    ]);

    return ListAppLogsResult(logs: logs, count: count);
  }

  /// Deletes logs older than the specified retention period.
  Future<int> cleanup({int retentionDays = 30}) async {
    if (retentionDays <= 0) return 0;

    final cutoff = DateTime.now().subtract(Duration(days: retentionDays));
    return db.logs.deleteWhere(
      (t) => t.createdAt.isSmallerThanValue(cutoff),
    );
  }
}
