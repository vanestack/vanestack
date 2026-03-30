import 'dart:async';

import 'package:shelf/shelf.dart';
import 'package:vanestack_annotation/vanestack_annotation.dart';

import '../../utils/extensions.dart';

@Route(path: '/v1/auth/reset-password', method: HttpMethod.post)
FutureOr<void> resetPassword(
  Request request,
  String token,
  String newPassword,
) {
  return request.auth.resetPassword(token: token, newPassword: newPassword);
}
