import 'dart:async';

import 'package:shelf/shelf.dart';

import '../../../tools/route.dart';
import '../../utils/extensions.dart';
import '../../utils/http_method.dart';

@Route(path: '/v1/auth/reset-password', method: HttpMethod.post)
FutureOr<void> resetPassword(
  Request request,
  String token,
  String newPassword,
) {
  return request.auth.resetPassword(token: token, newPassword: newPassword);
}
