import 'dart:async';
import 'dart:io';

import 'package:vanestack_common/vanestack_common.dart';
import 'package:shelf/shelf.dart';

import 'package:vanestack_annotation/vanestack_annotation.dart';
import '../../../utils/extensions.dart';

@Route(
  path: '/v1/buckets/<bucket>',
  method: HttpMethod.get,
  requireSuperUserAuth: true,
)
FutureOr<Bucket> get(Request request, String bucket) async {
  final result = await request.storageService.getBucket(bucket);

  if (result == null) {
    throw VaneStackException('Bucket not found.', status: HttpStatus.notFound, code: StorageErrorCode.bucketNotFound);
  }

  return result;
}
