import 'dart:async';

import 'package:vanestack_common/vanestack_common.dart';
import 'package:shelf/shelf.dart';

import 'package:vanestack_annotation/vanestack_annotation.dart';
import '../../utils/extensions.dart';

@Route(
  path: '/v1/collections',
  method: HttpMethod.get,
  requireSuperUserAuth: true,
)
FutureOr<List<Collection>> list(
  Request request, [
  int? limit = 10,
  int? offset = 0,
]) {
  return request.collections.list(limit: limit, offset: offset);
}
