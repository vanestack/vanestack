import 'dart:async';
import 'dart:io';

import 'package:vanestack_common/vanestack_common.dart';
import 'package:shelf/shelf.dart';

import 'package:vanestack_annotation/vanestack_annotation.dart';
import '../../utils/extensions.dart';

@Route(path: '/v1/users/<userId>', method: HttpMethod.get)
FutureOr<User> get(Request request, String userId) async {
  final user = await request.users.getById(userId);

  if (user == null) {
    throw VaneStackException(
      'User not found.',
      status: HttpStatus.notFound,
      code: ErrorCode.userNotFound,
    );
  }

  return user;
}
