import 'package:drift/drift.dart';

class ExternalAuths extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get userId => text()();
  TextColumn get provider => text()();
  TextColumn get providerId => text()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();

  @override
  List<Set<Column<Object>>>? get uniqueKeys => [
    {provider, providerId},
  ];

  @override
  String? get tableName => '_external_auths';
}
