import 'dart:async';

import 'package:vanestack_common/vanestack_common.dart';
import 'package:shelf/shelf.dart';

import 'package:vanestack_annotation/vanestack_annotation.dart';
import '../../utils/extensions.dart';

@Route(path: '/v1/auth/verify-otp', method: HttpMethod.post)
FutureOr<AuthResponse> verifyOtp(Request request, String email, String otp) {
  return request.auth.verifyOtp(email: email, otp: otp);
}
