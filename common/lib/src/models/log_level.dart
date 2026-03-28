import 'package:dart_mappable/dart_mappable.dart';

part 'log_level.mapper.dart';

@MappableEnum()
enum LogLevel { debug, info, warn, error, none }
