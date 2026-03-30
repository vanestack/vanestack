import 'package:drift/drift.dart' hide Index;
import 'package:vanestack_common/vanestack_common.dart';

@UseRowClass(Bucket)
class Buckets extends Table {
  TextColumn get name => text()();
  TextColumn get listRule => text().nullable()();
  TextColumn get createRule => text().nullable()();
  TextColumn get updateRule => text().nullable()();
  TextColumn get deleteRule => text().nullable()();
  TextColumn get viewRule => text().nullable()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();

  @override
  String? get tableName => '_buckets';

  @override
  Set<Column<Object>>? get primaryKey => {name};
}
