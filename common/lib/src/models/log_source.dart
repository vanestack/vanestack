import 'package:dart_mappable/dart_mappable.dart';

part 'log_source.mapper.dart';

@MappableEnum()
enum LogSource { server, auth, users, database, storage, realtime, collections, http, custom }
