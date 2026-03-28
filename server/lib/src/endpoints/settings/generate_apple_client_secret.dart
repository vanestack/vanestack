import 'dart:async';

import 'package:shelf/shelf.dart';

import '../../../tools/route.dart';
import '../../utils/extensions.dart';
import '../../utils/http_method.dart';

@Route(
  path: '/v1/settings/generate-apple-client-secret',
  method: HttpMethod.post,
  requireSuperUserAuth: true,
)
FutureOr<String> generateAppleClientSecret(
  Request request,
  String clientId,
  String teamId,
  String keyId,
  String privateKey,
  int duration,
) {
  return request.settingsService.generateAppleClientSecret(
    clientId: clientId,
    teamId: teamId,
    keyId: keyId,
    privateKey: privateKey,
    duration: duration,
  );
}
