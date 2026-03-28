import 'dart:async';
import 'dart:io';

import 'package:vanestack_common/vanestack_common.dart';
import 'package:shelf/shelf.dart';

import '../../../../tools/route.dart';
import '../../../utils/extensions.dart';
import '../../../utils/http_method.dart';

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
