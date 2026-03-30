import 'dart:async';

import 'package:drift/drift.dart';
import 'package:shelf/shelf.dart';
import 'package:vanestack_annotation/vanestack_annotation.dart';
import 'package:vanestack_common/vanestack_common.dart';

import '../../utils/extensions.dart';

@Route(path: '/v1/stats', method: HttpMethod.get, requireSuperUserAuth: true)
FutureOr<DashboardStats> stats(Request request) async {
  final db = request.database;

  // Count non-superuser users
  final totalUsers =
      await (db.users.selectOnly()
            ..where(db.users.superUser.equals(false))
            ..addColumns([db.users.id.count()]))
          .map((row) => row.read(db.users.id.count())!)
          .getSingle();

  // Count documents across all collection tables
  final collectionNames =
      await (db.collections.selectOnly()..addColumns([db.collections.name]))
          .map((row) => row.read(db.collections.name)!)
          .get();

  var totalDocuments = 0;
  for (final name in collectionNames) {
    final result = await db
        .customSelect('SELECT COUNT(*) as cnt FROM "$name"')
        .getSingle();
    totalDocuments += result.read<int>('cnt');
  }

  // Count files and sum sizes
  final fileCountExpr = db.files.id.count();
  final fileSizeExpr = db.files.size.sum();
  final fileResult =
      await (db.files.selectOnly()..addColumns([fileCountExpr, fileSizeExpr]))
          .map(
            (row) => (
              count: row.read(fileCountExpr)!,
              size: row.read(fileSizeExpr) ?? 0,
            ),
          )
          .getSingle();

  // Count HTTP logs (total)
  final totalRequests =
      await (db.logs.selectOnly()
            ..where(db.logs.source.equalsValue(LogSource.http))
            ..addColumns([db.logs.id.count()]))
          .map((row) => row.read(db.logs.id.count())!)
          .getSingle();

  // Count HTTP logs created today
  final now = DateTime.now();
  final todayStart = DateTime(now.year, now.month, now.day);
  final requestsToday =
      await (db.logs.selectOnly()
            ..where(db.logs.source.equalsValue(LogSource.http))
            ..where(db.logs.createdAt.isBiggerOrEqualValue(todayStart))
            ..addColumns([db.logs.id.count()]))
          .map((row) => row.read(db.logs.id.count())!)
          .getSingle();

  // Status breakdown from HTTP logs grouped by level
  // info -> 2xx, warn -> 4xx, error -> 5xx
  final statusRows = await db
      .customSelect(
        "SELECT level, COUNT(*) as cnt FROM _logs WHERE source = 'http' GROUP BY level",
      )
      .get();

  final statusBreakdown = <String, int>{};
  for (final row in statusRows) {
    final level = row.read<String>('level');
    final count = row.read<int>('cnt');
    final key = switch (level) {
      'info' => '2xx',
      'warn' => '4xx',
      'error' => '5xx',
      _ => level,
    };
    statusBreakdown[key] = (statusBreakdown[key] ?? 0) + count;
  }

  // Requests per day for last 7 days
  final sevenDaysAgo = todayStart.subtract(const Duration(days: 6));

  final day = db.logs.createdAt.date;
  final cnt = db.logs.id.count();
  final perDayRows =
      await (db.logs.selectOnly()
            ..addColumns([day, cnt])
            ..where(
              Expression.and([
                db.logs.source.equals('http'),
                db.logs.createdAt.isBiggerOrEqualValue(sevenDaysAgo),
              ]),
            )
            ..groupBy([day])
            ..orderBy([OrderingTerm.asc(day)]))
          .get();

  final requestsPerDay = <RequestPoint>[];
  final perDayMap = <String, int>{};
  for (final row in perDayRows) {
    final key = row.read(day);
    final value = row.read(cnt);
    if (key == null || value == null) continue;
    perDayMap[row.read(day)!] = row.read(cnt)!;
  }

  // Fill in missing days with 0
  for (var i = 0; i < 7; i++) {
    final date = sevenDaysAgo.add(Duration(days: i));
    final key =
        '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
    requestsPerDay.add(RequestPoint(date: date, count: perDayMap[key] ?? 0));
  }

  return DashboardStats(
    totalUsers: totalUsers,
    totalDocuments: totalDocuments,
    totalFiles: fileResult.count,
    totalStorageBytes: fileResult.size,
    totalRequests: totalRequests,
    requestsToday: requestsToday,
    statusBreakdown: statusBreakdown,
    requestsPerDay: requestsPerDay,
  );
}
