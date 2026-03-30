import 'dart:async';

import 'package:shelf/shelf.dart';
import 'package:vanestack_annotation/vanestack_annotation.dart';
import 'package:vanestack_common/vanestack_common.dart';

import '../../utils/extensions.dart';

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
