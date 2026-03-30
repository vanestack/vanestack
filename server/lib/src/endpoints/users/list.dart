import 'dart:async';

import 'package:vanestack_common/vanestack_common.dart';
import 'package:shelf/shelf.dart';

import 'package:vanestack_annotation/vanestack_annotation.dart';
import '../../utils/extensions.dart';

@Route(path: '/v1/users', method: HttpMethod.get, requireSuperUserAuth: true)
FutureOr<ListUsersResult> list(
  Request request,
  String? orderBy,
  String? filter, [
  int? limit = 10,
  int? offset = 0,
]) {
  return request.users.list(
    filter: filter,
    orderBy: orderBy,
    limit: limit ?? 10,
    offset: offset ?? 0,
  );
}
