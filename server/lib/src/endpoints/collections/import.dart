import 'dart:async';

import 'package:vanestack_common/vanestack_common.dart';
import 'package:shelf/shelf.dart';

import 'package:vanestack_annotation/vanestack_annotation.dart';
import '../../utils/extensions.dart';

@Route(
  path: '/v1/collections/import',
  method: HttpMethod.post,
  requireSuperUserAuth: true,
)
FutureOr<ImportResponse> import(
  Request request,
  List<Map<String, dynamic>> collections, [
  bool overwrite = false,
]) async {
  return request.collections.import(
    collections: collections,
    overwrite: overwrite,
  );
}
