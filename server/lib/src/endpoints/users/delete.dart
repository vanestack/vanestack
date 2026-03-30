import 'dart:async';

import 'package:shelf/shelf.dart';

import 'package:vanestack_annotation/vanestack_annotation.dart';
import '../../utils/extensions.dart';

@Route(
  path: '/v1/users/<userId>',
  method: HttpMethod.delete,
  requireSuperUserAuth: true,
)
FutureOr<void> delete(Request request, String userId) {
  return request.users.delete(userId);
}
