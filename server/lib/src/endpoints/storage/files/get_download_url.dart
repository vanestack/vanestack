import 'dart:async';
import 'dart:io';

import 'package:shelf/shelf.dart';
import 'package:vanestack_annotation/vanestack_annotation.dart';
import 'package:vanestack_common/vanestack_common.dart';

import '../../../permissions/rules_engine.dart';
import '../../../utils/extensions.dart';

@Route(path: '/v1/files/<bucket>/<fileId>/url', method: HttpMethod.get)
FutureOr<GetDownloadUrlResult> getDownloadUrl(
  Request request,
  String bucket,
  String fileId,
) async {
  // Get file and bucket for permission check

  final bucketEntity = await request.storageService.getBucket(bucket);

  if (bucketEntity == null) {
    throw VaneStackException('Bucket not found.', status: HttpStatus.notFound);
  }

  final file = await request.storageService.getFileById(fileId);

  if (file == null || file.bucket != bucket) {
    throw VaneStackException('File not found.', status: HttpStatus.notFound);
  }

  // Permission check
  final viewRule = bucketEntity.viewRule;

  if (viewRule == null) {
    if (!request.isSuperUser) {
      throw VaneStackException(
        'Permission denied.',
        status: HttpStatus.forbidden,
      );
    }
  } else if (viewRule.trim().isNotEmpty && !request.isSuperUser) {
    final engine = RulesEngine(request: request, oldResource: file);

    final approved = await engine.evaluate(viewRule);
    if (!approved) {
      throw VaneStackException(
        'Permission denied.',
        status: HttpStatus.forbidden,
      );
    }
  }

  // Get download URL using service
  final url = await request.storageService.getDownloadUrl(
    bucketName: bucket,
    fileId: fileId,
  );

  return GetDownloadUrlResult(url: url);
}
