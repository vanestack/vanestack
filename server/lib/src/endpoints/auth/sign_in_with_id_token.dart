import 'dart:async';

import 'package:shelf/shelf.dart';
import 'package:vanestack_annotation/vanestack_annotation.dart';
import 'package:vanestack_common/vanestack_common.dart';

import '../../utils/extensions.dart';

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
