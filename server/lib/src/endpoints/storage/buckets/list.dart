import 'dart:async';

import 'package:vanestack_common/vanestack_common.dart';
import 'package:shelf/shelf.dart';

import 'package:vanestack_annotation/vanestack_annotation.dart';
import '../../../utils/extensions.dart';

@Route(path: '/v1/buckets', method: HttpMethod.get, requireSuperUserAuth: true)
FutureOr<List<Bucket>> list(Request request) {
  return request.storageService.listBuckets();
}
