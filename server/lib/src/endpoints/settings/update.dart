import 'dart:async';

import 'package:vanestack_common/vanestack_common.dart';
import 'package:shelf/shelf.dart';

import '../../../tools/route.dart';
import '../../utils/extensions.dart';
import '../../utils/http_method.dart';

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
