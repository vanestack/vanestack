import 'dart:async';

import 'package:vanestack_common/vanestack_common.dart';
import 'package:shelf/shelf.dart';

import '../../../tools/route.dart';
import '../../utils/extensions.dart';
import '../../utils/http_method.dart';

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
