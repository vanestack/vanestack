import 'dart:async';
import 'dart:io';

import 'package:vanestack_annotation/vanestack_annotation.dart';
import 'package:vanestack_common/vanestack_common.dart';
import 'package:shelf/shelf.dart';

import '../../utils/extensions.dart';

@Route(path: '/v1/auth/logout', method: HttpMethod.delete, requireAuth: true)
FutureOr<void> logout(Request request) async {
  final accessToken = request.bearerToken;

  if (accessToken == null || accessToken.isEmpty) {
    throw VaneStackException(
      'Missing access token.',
      status: HttpStatus.badRequest,
      code: AuthErrorCode.missingAccessToken,
    );
  }

  return request.auth.logout(accessToken: accessToken, userId: request.userId);
}
