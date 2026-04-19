import 'dart:async';

import 'package:drift/drift.dart';
import 'package:shelf/shelf.dart';
import 'package:vanestack_annotation/vanestack_annotation.dart';
import 'package:vanestack_common/vanestack_common.dart';

import '../../utils/extensions.dart';
import '../../utils/tables.dart';

@Route(path: '/v1/stats', method: HttpMethod.get, requireSuperUserAuth: true)
FutureOr<DashboardStats> stats(Request request) async {
  final db = request.database;
  final isPg = db.executor.dialect == SqlDialect.postgres;

  // Dialect-specific fragments.
  final falseLit = isPg ? 'false' : '0';
  final nullBig = isPg ? 'NULL::bigint' : 'NULL';
  final nullText = isPg ? 'NULL::text' : 'NULL';
  final dayExpr = isPg
      ? "to_char(to_timestamp(created_at), 'YYYY-MM-DD')"
      : "DATE(created_at, 'unixepoch')";

  // Dates for the log metrics.
  final now = DateTime.now();
  final todayStart = DateTime(now.year, now.month, now.day);
  final sevenDaysAgo = todayStart.subtract(const Duration(days: 6));
  final todayEpoch = todayStart.millisecondsSinceEpoch ~/ 1000;
  final sevenDaysEpoch = sevenDaysAgo.millisecondsSinceEpoch ~/ 1000;

  // Collection counts are inlined as one UNION ALL branch per collection.
  // Names come from the trusted cache, but guard against injection by
  // re-validating the identifier before interpolating into raw SQL.
  final collectionNames = request.collectionsCache.names
      .where(isValidIdentifier)
      .toList();
  final collBranches = [
    for (final n in collectionNames)
      "SELECT 'coll' AS metric, '$n' AS label, COUNT(*) AS v, $nullBig AS v2 FROM \"$n\"",
  ];

  final branches = <String>[
    "SELECT 'users' AS metric, $nullText AS label, COUNT(*) AS v, $nullBig AS v2 FROM _users WHERE super_user = $falseLit",
    "SELECT 'files', $nullText, COUNT(*), COALESCE(SUM(size), 0) FROM _files",
    "SELECT 'logs_total', $nullText, COUNT(*), $nullBig FROM _logs WHERE source = 'http'",
    "SELECT 'logs_today', $nullText, COUNT(*), $nullBig FROM _logs WHERE source = 'http' AND created_at >= ?",
    "SELECT 'logs_level', level, COUNT(*), $nullBig FROM _logs WHERE source = 'http' GROUP BY level",
    "SELECT 'logs_day', $dayExpr, COUNT(*), $nullBig FROM _logs WHERE source = 'http' AND created_at >= ? GROUP BY $dayExpr",
    ...collBranches,
  ];

  final sql = branches.join('\nUNION ALL ');

  final rows = await db
      .customSelect(
        db.adaptPlaceholders(sql),
        variables: [Variable<int>(todayEpoch), Variable<int>(sevenDaysEpoch)],
      )
      .get();

  var totalUsers = 0;
  var totalFiles = 0;
  var totalStorageBytes = 0;
  var totalRequests = 0;
  var requestsToday = 0;
  var totalDocuments = 0;
  final statusBreakdown = <String, int>{};
  final perDayMap = <String, int>{};

  for (final row in rows) {
    final metric = row.read<String>('metric');
    final value = row.read<int>('v');
    switch (metric) {
      case 'users':
        totalUsers = value;
      case 'files':
        totalFiles = value;
        totalStorageBytes = row.read<int>('v2');
      case 'logs_total':
        totalRequests = value;
      case 'logs_today':
        requestsToday = value;
      case 'logs_level':
        final level = row.read<String>('label');
        final key = switch (level) {
          'info' => '2xx',
          'warn' => '4xx',
          'error' => '5xx',
          _ => level,
        };
        statusBreakdown[key] = (statusBreakdown[key] ?? 0) + value;
      case 'logs_day':
        perDayMap[row.read<String>('label')] = value;
      case 'coll':
        totalDocuments += value;
    }
  }

  // Fill in missing days with 0 so the chart always shows a 7-day window.
  final requestsPerDay = <RequestPoint>[
    for (var i = 0; i < 7; i++)
      () {
        final date = sevenDaysAgo.add(Duration(days: i));
        final key =
            '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
        return RequestPoint(date: date, count: perDayMap[key] ?? 0);
      }(),
  ];

  return DashboardStats(
    totalUsers: totalUsers,
    totalDocuments: totalDocuments,
    totalFiles: totalFiles,
    totalStorageBytes: totalStorageBytes,
    totalRequests: totalRequests,
    requestsToday: requestsToday,
    statusBreakdown: statusBreakdown,
    requestsPerDay: requestsPerDay,
  );
}
