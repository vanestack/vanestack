import 'dart:async';
import 'dart:io';

import 'package:shelf/shelf.dart';
import 'package:vanestack_annotation/vanestack_annotation.dart';
import 'package:vanestack_common/vanestack_common.dart';

import '../../utils/extensions.dart';

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
