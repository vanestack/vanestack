import 'dart:async';

import 'package:shelf/shelf.dart';

import 'package:vanestack_annotation/vanestack_annotation.dart';
import '../../utils/extensions.dart';

@Route(
  path: '/v1/collections/<collectionName>',
  method: HttpMethod.delete,
  requireSuperUserAuth: true,
)
FutureOr<void> delete(Request request, String collectionName) async {
  await request.collections.delete(collectionName);
}
