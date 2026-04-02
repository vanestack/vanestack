import 'dart:async';
import 'dart:io';

import 'package:shelf/shelf.dart';
import 'package:vanestack_annotation/vanestack_annotation.dart';
import 'package:vanestack_common/vanestack_common.dart';

import '../../../utils/extensions.dart';

@Route(
  path: '/v1/buckets/<bucket>',
  method: HttpMethod.delete,
  requireSuperUserAuth: true,
)
FutureOr<void> delete(Request request, String bucket) async {
  if (bucket.isEmpty) {
    throw VaneStackException(
      'Bucket name is required.',
      status: HttpStatus.badRequest,
      code: StorageErrorCode.bucketNameRequired,
    );
  }

  // Get files to delete from storage backend
  final files = await request.storageService.getFilesInBucket(bucket);

  final storage = await request.storage();

  for (final file in files) {
    await storage.delete(bucket, file.path);
  }

  // Delete bucket and file records from database
  await request.storageService.deleteBucket(bucket);
}
