import 'dart:async';

import 'package:vanestack_common/vanestack_common.dart';
import 'package:shelf/shelf.dart';

import 'package:vanestack_annotation/vanestack_annotation.dart';
import '../../utils/extensions.dart';

@Route(path: '/v1/users', method: HttpMethod.post, requireSuperUserAuth: true)
FutureOr<User> create(
  Request request,
  String? id,
  String? password,
  String? name,
  String email, [
  bool superUser = false,
]) {
  return request.users.create(
    id: id,
    email: email,
    password: password,
    name: name,
    superUser: superUser,
  );
}
