import 'dart:async';

import 'package:vanestack_common/vanestack_common.dart';
import 'package:shelf/shelf.dart';

import 'package:vanestack_annotation/vanestack_annotation.dart';
import '../../utils/extensions.dart';

@Route(
  path: '/v1/users/<userId>',
  method: HttpMethod.patch,
  requireSuperUserAuth: true,
)
FutureOr<User> update(
  Request request,
  String userId,
  String? email,
  String? password,
  String? name,
  bool? superUser,
) {
  return request.users.update(
    id: userId,
    email: email,
    password: password,
    name: name,
    superUser: superUser,
  );
}
