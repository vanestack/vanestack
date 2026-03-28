import 'dart:convert';

import 'package:vanestack_common/vanestack_common.dart';
import 'package:drift/drift.dart' hide Index;
import 'package:uuid/uuid.dart';

@DataClassName('DbFile', implementing: [Resource])
class Files extends Table {
  TextColumn get id => text().clientDefault(() => const Uuid().v7())();
  TextColumn get path => text()();
  TextColumn get bucket => text()();
  BoolColumn get isLocal => boolean()();
  IntColumn get size => integer()();
  TextColumn get mimeType => text()();
  TextColumn get metadata => text().map(const MapConverter()).nullable()();
  TextColumn get downloadToken => text()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();

  @override
  String? get tableName => '_files';

  @override
  Set<Column<Object>>? get primaryKey => {id};
}

class MapConverter extends TypeConverter<Map<String, Object?>, String>
    with
        JsonTypeConverter2<Map<String, Object?>, String, Map<String, Object?>> {
  const MapConverter();

  @override
  Map<String, Object?> fromSql(String fromDb) {
    return fromJson(jsonDecode(fromDb) as Map<String, dynamic>);
  }

  @override
  String toSql(Map<String, Object?> value) {
    return jsonEncode(toJson(value));
  }

  @override
  Map<String, Object?> fromJson(Map<String, Object?> json) {
    return json;
  }

  @override
  Map<String, Object?> toJson(Map<String, Object?> value) {
    return value;
  }
}
