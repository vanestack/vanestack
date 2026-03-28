import 'package:dart_mappable/dart_mappable.dart';
import '../mappers/datetime.dart';

part 'dashboard_stats.mapper.dart';

@MappableClass(includeCustomMappers: [SecondsDateTimeMapper()])
class RequestPoint with RequestPointMappable {
  final DateTime date;
  final int count;

  RequestPoint({required this.date, required this.count});
}

@MappableClass()
class DashboardStats with DashboardStatsMappable {
  final int totalUsers;
  final int totalDocuments;
  final int totalFiles;
  final int totalStorageBytes;
  final int totalRequests;
  final int requestsToday;
  final Map<String, int> statusBreakdown;
  final List<RequestPoint> requestsPerDay;

  DashboardStats({
    required this.totalUsers,
    required this.totalDocuments,
    required this.totalFiles,
    required this.totalStorageBytes,
    required this.totalRequests,
    required this.requestsToday,
    required this.statusBreakdown,
    required this.requestsPerDay,
  });
}
