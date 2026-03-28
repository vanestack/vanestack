import 'dart:async';

import 'package:shelf/shelf.dart';

import '../../../tools/route.dart';
import '../../utils/extensions.dart';
import '../../utils/http_method.dart';

@Route(path: '/v1/auth/oauth2/<provider>', method: HttpMethod.post)
FutureOr<String> oauth2(
  Request request,
  String provider,
  String? redirectUrl,
) async {
  final settings = await request.settings();

  return request.auth.getOAuthUrl(
    provider: provider,
    settings: settings,
    redirectUrl: redirectUrl,
  );
}
