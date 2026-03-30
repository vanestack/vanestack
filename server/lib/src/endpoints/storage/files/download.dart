import 'dart:async';
import 'dart:io';

import 'package:path/path.dart';
import 'package:shelf/shelf.dart';
import 'package:vanestack_annotation/vanestack_annotation.dart';
import 'package:vanestack_common/vanestack_common.dart';

import '../../../permissions/rules_engine.dart';
import '../../../utils/extensions.dart';

class FileResponse {
  final Stream<List<int>> stream;
  final int size;
  final String mimeType;
  final String fileName;

  FileResponse({
    required this.stream,
    required this.size,
    required this.mimeType,
    required this.fileName,
  });
}

@Route(path: '/v1/files/<bucket>/<fileId>', method: HttpMethod.get)
FutureOr<FileResponse> download(
  Request request,
  String bucket,
  String fileId,
  String? token,
) async {
  final bucketEntity = await request.storageService.getBucket(bucket);
  if (bucketEntity == null) {
    throw VaneStackException('Bucket not found.', status: HttpStatus.notFound);
  }

  final file = await request.storageService.getFileById(fileId);
  if (file == null || file.bucket != bucket) {
    throw VaneStackException('File not found.', status: HttpStatus.notFound);
  }

  // Permission check - either via token or viewRule
  if (token != null) {
    if (token != file.downloadToken) {
      throw VaneStackException(
        'Invalid download token.',
        status: HttpStatus.forbidden,
      );
    }
  } else {
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
  }

  final fileName = basename(file.path);

  final fileBytes = await request.storageService.getFileContents(fileId);

  if (fileBytes == null) {
    throw VaneStackException(
      'File data not found.',
      status: HttpStatus.notFound,
    );
  }

  return FileResponse(
    stream: Stream.value(fileBytes),
    size: file.size,
    mimeType: file.mimeType,
    fileName: fileName,
  );
}
