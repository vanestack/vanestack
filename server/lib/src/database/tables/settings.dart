import 'dart:convert';

import 'package:vanestack_common/vanestack_common.dart';
import 'package:drift/drift.dart';

@UseRowClass(Settings)
class AppSettings extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get appName => text()();
  TextColumn get siteUrl =>
      text().withDefault(Constant('http://localhost:8080'))();
  TextColumn get redirectUrls =>
      text().map(const RedirectUrlsConverter()).withDefault(Constant('[]'))();
  TextColumn get oauthProviders =>
      text().map(const OAuthProviderListConverter())();
  TextColumn get s3 => text().map(const S3SettingsConverter()).nullable()();
  TextColumn get mail => text().map(const MailSettingsConverter()).nullable()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();

  @override
  String? get tableName => '_app_settings';
}

class MailSettingsConverter extends TypeConverter<MailSettings, String>
    with JsonTypeConverter2<MailSettings, String, Map<String, Object?>> {
  const MailSettingsConverter();

  @override
  MailSettings fromSql(String fromDb) {
    return fromJson(jsonDecode(fromDb) as Map<String, dynamic>);
  }

  @override
  String toSql(MailSettings value) {
    return jsonEncode(toJson(value));
  }

  @override
  MailSettings fromJson(Map<String, Object?> json) {
    return MailSettingsMapper.fromJson(json);
  }

  @override
  Map<String, Object?> toJson(MailSettings value) {
    return value.toJson();
  }
}

class OAuthProviderListConverter
    extends TypeConverter<OAuthProviderList, String>
    with JsonTypeConverter2<OAuthProviderList, String, Map<String, Object?>> {
  const OAuthProviderListConverter();

  @override
  OAuthProviderList fromSql(String fromDb) {
    return fromJson(jsonDecode(fromDb) as Map<String, dynamic>);
  }

  @override
  String toSql(OAuthProviderList value) {
    return jsonEncode(toJson(value));
  }

  @override
  OAuthProviderList fromJson(Map<String, Object?> json) {
    return OAuthProviderListMapper.fromJson(json);
  }

  @override
  Map<String, Object?> toJson(OAuthProviderList value) {
    return value.toJson();
  }
}

class S3SettingsConverter extends TypeConverter<S3Settings, String>
    with JsonTypeConverter2<S3Settings, String, Map<String, Object?>> {
  const S3SettingsConverter();

  @override
  S3Settings fromSql(String fromDb) {
    return fromJson(jsonDecode(fromDb) as Map<String, dynamic>);
  }

  @override
  String toSql(S3Settings value) {
    return jsonEncode(toJson(value));
  }

  @override
  S3Settings fromJson(Map<String, Object?> json) {
    return S3SettingsMapper.fromJson(json);
  }

  @override
  Map<String, Object?> toJson(S3Settings value) {
    return value.toJson();
  }
}

class RedirectUrlsConverter extends TypeConverter<List<String>, String> {
  const RedirectUrlsConverter();

  @override
  List<String> fromSql(String fromDb) {
    final List<dynamic> decoded = jsonDecode(fromDb) as List<dynamic>;
    return decoded.map((e) => e as String).toList();
  }

  @override
  String toSql(List<String> value) {
    return jsonEncode(value);
  }
}
