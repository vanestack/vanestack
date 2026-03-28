import 'package:dart_mappable/dart_mappable.dart';

import '../mappers/datetime.dart';
import 'log_level.dart';
import 'log_source.dart';

part 'app_log.mapper.dart';

@MappableClass(includeCustomMappers: [SecondsDateTimeMapper()])
class AppLog with AppLogMappable {
  final int id;
  final LogLevel level;
  final LogSource source;
  final String? customSource;
  final String message;
  final String? context;
  final String? userId;
  final String? error;
  final String? stackTrace;
  final DateTime createdAt;

  /// Display name for the source — uses [customSource] when source is [LogSource.custom].
  String get sourceName => source == LogSource.custom ? (customSource ?? 'custom') : source.name;

  AppLog({
    required this.id,
    required this.level,
    required this.source,
    this.customSource,
    required this.message,
    this.context,
    this.userId,
    this.error,
    this.stackTrace,
    required this.createdAt,
  });
}
