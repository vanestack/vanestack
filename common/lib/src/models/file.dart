import 'package:dart_mappable/dart_mappable.dart';

import '../mappers/datetime.dart';

part 'file.mapper.dart';

@MappableClass(includeCustomMappers: [SecondsDateTimeMapper()])
class File with FileMappable {
  final String id;
  final String path;
  final String bucket;
  final String mimeType;
  final Map<String, Object?>? metadata;
  final int size;
  final DateTime createdAt;
  final DateTime updatedAt;

  File({
    required this.id,
    required this.bucket,
    required this.mimeType,
    required this.path,
    this.metadata,
    required this.size,
    required this.createdAt,
    required this.updatedAt,
  });
}
