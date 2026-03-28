import 'package:dart_mappable/dart_mappable.dart';

import '../mappers/datetime.dart';

part 'bucket.mapper.dart';

@MappableClass(includeCustomMappers: [SecondsDateTimeMapper()])
class Bucket with BucketMappable {
  final String name;
  final String? listRule;
  final String? createRule;
  final String? updateRule;
  final String? viewRule;
  final String? deleteRule;
  final DateTime createdAt;
  final DateTime updatedAt;

  Bucket({
    required this.name,
    this.listRule,
    this.viewRule,
    this.createRule,
    this.deleteRule,
    this.updateRule,
    required this.createdAt,
    required this.updatedAt,
  });
}
