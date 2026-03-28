import 'package:dart_mappable/dart_mappable.dart';

import '../../vanestack_common.dart';
import '../mappers/datetime.dart';

part 'collection.mapper.dart';

enum CollectionType { base, view }

@MappableClass(
  discriminatorKey: 'type',
  includeCustomMappers: [SecondsDateTimeMapper()],
)
sealed class Collection with CollectionMappable {
  final String name;
  final List<Attribute> attributes;
  final String? listRule;
  final String? viewRule;
  final DateTime createdAt;
  final DateTime updatedAt;

  CollectionType get type;

  Collection({
    required this.name,
    this.attributes = const [],
    this.listRule,
    this.viewRule,
    required this.createdAt,
    required this.updatedAt,
  });
}

@MappableClass(discriminatorValue: 'base')
class BaseCollection extends Collection with BaseCollectionMappable {
  final List<Index> indexes;
  final String? createRule;
  final String? updateRule;
  final String? deleteRule;

  @override
  CollectionType get type => CollectionType.base;

  BaseCollection({
    required super.name,
    super.attributes = const [],
    this.indexes = const [],
    super.listRule,
    super.viewRule,
    this.createRule,
    this.updateRule,
    this.deleteRule,
    required super.createdAt,
    required super.updatedAt,
  });
}

@MappableClass(discriminatorValue: 'view')
class ViewCollection extends Collection with ViewCollectionMappable {
  final String viewQuery;

  @override
  CollectionType get type => CollectionType.view;

  ViewCollection({
    required super.name,
    super.attributes = const [],
    super.listRule,
    super.viewRule,
    required this.viewQuery,
    required super.createdAt,
    required super.updatedAt,
  });
}
