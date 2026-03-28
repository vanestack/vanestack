import 'package:vanestack_common/vanestack_common.dart';
import 'package:dart_mappable/dart_mappable.dart';

import '../mappers/datetime.dart';

part 'settings.mapper.dart';

@MappableClass(includeCustomMappers: [SecondsDateTimeMapper()])
class Settings with SettingsMappable {
  final int id;
  final String appName;
  final String siteUrl;
  final List<String> redirectUrls;
  final S3Settings? s3;
  final MailSettings? mail;
  final OAuthProviderList oauthProviders;
  final DateTime createdAt;
  final DateTime updatedAt;

  Settings({
    required this.id,
    required this.appName,
    required this.siteUrl,
    this.redirectUrls = const [],
    this.s3,
    this.mail,
    this.oauthProviders = const OAuthProviderList(),
    required this.createdAt,
    required this.updatedAt,
  });
}
