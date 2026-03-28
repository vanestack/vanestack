import 'dart:async';

import 'package:shelf/shelf.dart';

import '../../../tools/route.dart';
import '../../utils/extensions.dart';
import '../../utils/http_method.dart';

@Route(
  path: '/v1/collections/<collectionName>',
  method: HttpMethod.delete,
  requireSuperUserAuth: true,
)
FutureOr<void> delete(Request request, String collectionName) async {
  await request.collections.delete(collectionName);
}
