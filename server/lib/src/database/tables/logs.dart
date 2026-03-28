import 'package:vanestack_common/vanestack_common.dart';
import 'package:drift/drift.dart';

@UseRowClass(AppLog)
class Logs extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get level => textEnum<LogLevel>()();
  TextColumn get source => textEnum<LogSource>()();
  TextColumn get customSource => text().nullable()();
  TextColumn get message => text()();
  TextColumn get context => text().nullable()();
  TextColumn get userId => text().nullable()();
  TextColumn get error => text().nullable()();
  TextColumn get stackTrace => text().nullable()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();

  @override
  String? get tableName => '_logs';
}
