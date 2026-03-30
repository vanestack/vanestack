import 'dart:async';

import 'package:vanestack_common/vanestack_common.dart';
import 'package:shelf/shelf.dart';

import 'package:vanestack_annotation/vanestack_annotation.dart';
import '../../utils/extensions.dart';

@Route(
  path: '/v1/collections/<collectionName>/generate',
  method: HttpMethod.post,
  requireSuperUserAuth: true,
)
FutureOr<GenerateResponse> generate(
  Request request,
  String collectionName,
  int count,
) async {
  return request.collections.generate(
    collectionName: collectionName,
    count: count,
  );
}
