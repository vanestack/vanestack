import 'package:drift/drift.dart' hide Index;
import 'package:vanestack_common/vanestack_common.dart';

@DataClassName('CollectionData')
class Collections extends Table {
  TextColumn get name => text()();
  TextColumn get type => text().withDefault(const Constant('base'))();
  TextColumn get listRule => text().nullable()();
  TextColumn get createRule => text().nullable()();
  TextColumn get updateRule => text().nullable()();
  TextColumn get deleteRule => text().nullable()();
  TextColumn get viewRule => text().nullable()();
  TextColumn get viewQuery => text().nullable()();
  TextColumn get attributes => text()
      .map(Collections.attributesConverter)
      .withDefault(const Constant('[]'))();
  TextColumn get indexes => text()
      .map(Collections.indexesConverter)
      .withDefault(const Constant('[]'))();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();

  @override
  String? get tableName => '_collections';

  @override
  Set<Column<Object>>? get primaryKey => {name};

  static JsonTypeConverter2<List<Attribute>, String, Object?>
  attributesConverter = TypeConverter.json2(
    fromJson: (json) => (json as List?) != null
        ? json!.map((e) => AttributeMapper.fromJson(e)).toList()
        : [],
    toJson: (attributes) => attributes.map((e) => e.toJson()).toList(),
  );

  static JsonTypeConverter2<List<Index>, String, Object?> indexesConverter =
      TypeConverter.json2(
        fromJson: (json) => (json as List?) != null
            ? json!.map((e) => IndexMapper.fromJson(e)).toList()
            : [],
        toJson: (indexes) => indexes.map((e) => e.toJson()).toList(),
      );
}
