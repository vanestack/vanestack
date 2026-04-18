import 'package:drift/drift.dart';

class RefreshTokens extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get userId => text()();
  TextColumn get refreshToken => text().unique()();
  TextColumn get accessToken => text()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get expiresAt => dateTime().clientDefault(
    () => DateTime.now().add(const Duration(days: 7)),
  )();

  @override
  String? get tableName => '_refresh_tokens';
}
