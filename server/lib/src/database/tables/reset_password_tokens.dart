import 'package:drift/drift.dart';

class ResetPasswordTokens extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get userId => text()();
  TextColumn get token => text()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get expiresAt => dateTime().withDefault(
    currentDateAndTime.modify(DateTimeModifier.minutes(30)),
  )();

  @override
  String? get tableName => '_reset_password_tokens';
}
