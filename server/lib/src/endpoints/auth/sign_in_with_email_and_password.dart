import 'dart:async';

import 'package:vanestack_common/vanestack_common.dart';
import 'package:shelf/shelf.dart';

import '../../../tools/route.dart';
import '../../utils/extensions.dart';
import '../../utils/http_method.dart';

@Route(path: '/v1/auth/sign-in-email-password', method: HttpMethod.post)
FutureOr<AuthResponse> signInWithEmailAndPassword(
  Request request,
  String email,
  String password,
) {
  return request.auth.signInWithEmailAndPassword(
    email: email,
    password: password,
  );
}
