import 'dart:async';

import 'package:shelf/shelf.dart';

import 'package:vanestack_annotation/vanestack_annotation.dart';
import '../../utils/extensions.dart';

@Route(path: '/v1/auth/sign-in-with-otp', method: HttpMethod.post)
FutureOr<void> signInWithOtp(Request request, String email) async {
  final settings = await request.settings();
  final smtpServer = await request.smtpServer();

  return request.auth.sendOtp(
    email: email,
    settings: settings,
    smtpServer: smtpServer,
  );
}
