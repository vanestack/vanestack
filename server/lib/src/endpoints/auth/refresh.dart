import 'dart:async';
import 'dart:io';

import 'package:vanestack_common/vanestack_common.dart';
import 'package:shelf/shelf.dart';

import 'package:vanestack_annotation/vanestack_annotation.dart';
import '../../utils/extensions.dart';

@Route(path: '/v1/auth/refresh', method: HttpMethod.get)
FutureOr<AuthResponse> refresh(Request request) async {
  final refreshToken = request.bearerToken;

  if (refreshToken == null || refreshToken.isEmpty) {
    throw VaneStackException(
      'Missing refresh token.',
      status: HttpStatus.badRequest,
    );
  }

  return request.auth.refreshToken(refreshToken: refreshToken);
}
