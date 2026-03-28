import 'package:vanestack_common/src/models/resource.dart';
import 'package:dart_mappable/dart_mappable.dart';

import '../mappers/datetime.dart';

part 'document.mapper.dart';

@MappableClass(includeCustomMappers: [SecondsDateTimeMapper()])
class Document with DocumentMappable, Resource {
  @override
  final String id;

  final String collection;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final Map<String, Object?> data;

  Document({
    required this.id,
    required this.collection,
    this.createdAt,
    this.updatedAt,
    this.data = const {},
  });
}
