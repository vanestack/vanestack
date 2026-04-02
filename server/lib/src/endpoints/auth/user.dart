import 'dart:async';
import 'dart:io';

import 'package:shelf/shelf.dart';
import 'package:vanestack_annotation/vanestack_annotation.dart';
import 'package:vanestack_common/vanestack_common.dart';

import '../../utils/extensions.dart';

@Route(path: '/v1/auth/user', method: HttpMethod.get, requireAuth: true)
FutureOr<User> user(Request request) async {
  final userId = request.userId;

  if (userId == null || userId.isEmpty) {
    throw VaneStackException(
      'Missing user ID.',
      status: HttpStatus.badRequest,
      code: AuthErrorCode.missingAccessToken,
    );
  }

  final user = await request.auth.getUserById(userId);

  if (user == null) {
    // Return 401 instead of 404 to prevent info disclosure about deleted users
    throw VaneStackException(
      'Unauthorized.',
      status: HttpStatus.unauthorized,
      code: AuthErrorCode.permissionDenied,
    );
  }

  return user;
}
