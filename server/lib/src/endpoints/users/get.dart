import 'dart:async';
import 'dart:io';

import 'package:vanestack_common/vanestack_common.dart';
import 'package:shelf/shelf.dart';

import '../../../tools/route.dart';
import '../../utils/extensions.dart';
import '../../utils/http_method.dart';

@Route(path: '/v1/users/<userId>', method: HttpMethod.get)
FutureOr<User> get(Request request, String userId) async {
  final user = await request.users.getById(userId);

  if (user == null) {
    throw VaneStackException('User not found.', status: HttpStatus.notFound);
  }

  return user;
}
