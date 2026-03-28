import 'dart:async';

import 'package:vanestack_common/vanestack_common.dart';
import 'package:shelf/shelf.dart';

import '../../../tools/route.dart';
import '../../utils/extensions.dart';
import '../../utils/http_method.dart';

@Route(path: '/v1/auth/sign-in-with-id-token', method: HttpMethod.post)
FutureOr<AuthResponse> signInWithIdToken(
  Request request,
  IdTokenAuthProvider provider,
  String idToken,
  String? nonce,
) async {
  final settings = await request.settings();

  return request.auth.signInWithIdToken(
    provider: provider,
    idToken: idToken,
    nonce: nonce,
    settings: settings,
  );
}
