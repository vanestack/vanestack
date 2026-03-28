import 'dart:async';
import 'dart:io';

import 'package:vanestack_common/vanestack_common.dart';
import 'package:shelf/shelf.dart';

import '../../../tools/route.dart';
import '../../utils/extensions.dart';
import '../../utils/http_method.dart';

@Route(
  path: '/v1/collections/<collectionName>',
  method: HttpMethod.get,
  requireSuperUserAuth: true,
)
FutureOr<Collection> get(Request request, String collectionName) async {
  final collection = await request.collections.getByName(collectionName);

  if (collection == null) {
    throw VaneStackException(
      'Collection "$collectionName" not found.',
      status: HttpStatus.notFound,
    );
  }

  return collection;
}
