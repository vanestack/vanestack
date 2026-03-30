import 'dart:async';

import 'package:shelf/shelf.dart';
import 'package:vanestack_annotation/vanestack_annotation.dart';
import 'package:vanestack_common/vanestack_common.dart';

import '../../utils/extensions.dart';

@Route(
  path: '/v1/settings',
  method: HttpMethod.patch,
  requireSuperUserAuth: true,
)
FutureOr<Settings> update(
  Request request,
  String? appName,
  String? siteUrl,
  List<String>? redirectUrls,
  S3Settings? s3,
  MailSettings? mail,
  OAuthProviderList? oauthProviders,
) {
  return request.settingsService.update(
    appName: appName,
    siteUrl: siteUrl,
    redirectUrls: redirectUrls,
    s3: s3,
    mail: mail,
    oauthProviders: oauthProviders,
  );
}
