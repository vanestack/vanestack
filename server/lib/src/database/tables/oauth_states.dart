import 'package:drift/drift.dart';

class OauthStates extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get state => text().unique()();
  TextColumn get provider => text()();
  TextColumn get redirectUrl => text()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get expiresAt => dateTime().clientDefault(
    () => DateTime.now().add(const Duration(minutes: 10)),
  )();

  @override
  String? get tableName => '_oauth_states';
}
