import 'package:dart_mappable/dart_mappable.dart';

import 'app_log.dart';

part 'list_app_logs_result.mapper.dart';

@MappableClass()
class ListAppLogsResult with ListAppLogsResultMappable {
  final List<AppLog> logs;
  final int count;

  ListAppLogsResult({required this.logs, required this.count});
}
