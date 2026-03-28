import 'dart:async';

import 'package:shelf/shelf.dart';

import '../../../tools/route.dart';
import '../../utils/extensions.dart';
import '../../utils/http_method.dart';

@Route(path: '/v1/auth/forgot-password', method: HttpMethod.post)
FutureOr<void> sendPasswordResetEmail(
  Request request,
  String email,
  String? redirectTo,
) async {
  final settings = await request.settings();
  final smtpServer = await request.smtpServer();

  return request.auth.sendPasswordResetEmail(
    email: email,
    settings: settings,
    smtpServer: smtpServer,
    redirectTo: redirectTo,
  );
}
