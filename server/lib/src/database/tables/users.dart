import 'package:drift/drift.dart';

@DataClassName('DbUser')
class Users extends Table {
  TextColumn get id => text()();
  TextColumn get email => text().unique()();
  TextColumn get name => text().nullable()();
  BoolColumn get superUser => boolean().withDefault(const Constant(false))();
  TextColumn get passwordHash => text().nullable()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column<Object>>? get primaryKey => {id};

  @override
  String? get tableName => '_users';
}
