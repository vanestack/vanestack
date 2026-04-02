import 'dart:async';
import 'dart:io';

import 'package:vanestack_common/vanestack_common.dart';
import 'package:drift/drift.dart';
import 'package:shelf/shelf.dart';

import '../../../permissions/rules_engine.dart';
import 'package:vanestack_annotation/vanestack_annotation.dart';
import '../../../utils/extensions.dart';

@Route(path: '/v1/files/<bucket>/<fileId>', method: HttpMethod.patch)
FutureOr<File> move(
  Request request,
  String bucket,
  String fileId,
  String destination,
) async {
  final db = request.database;
  final bucketEntity =
      await (db.buckets.select()..where((tbl) => tbl.name.equals(bucket)))
          .getSingleOrNull();

  if (bucketEntity == null) {
    throw VaneStackException('Bucket not found.', status: HttpStatus.notFound, code: StorageErrorCode.bucketNotFound);
  }

  final file =
      await (db.files.select()
            ..where((tbl) => tbl.id.equals(fileId) & tbl.bucket.equals(bucket)))
          .getSingleOrNull();

  if (file == null) {
    throw VaneStackException('File not found.', status: HttpStatus.notFound, code: StorageErrorCode.fileNotFound);
  }

  final updateRule = bucketEntity.updateRule;
  if (updateRule == null) {
    if (!request.isSuperUser) {
      throw VaneStackException(
        'Permission denied.',
        status: HttpStatus.forbidden,
        code: AuthErrorCode.permissionDenied,
      );
    }
  } else if (updateRule.trim().isNotEmpty && !request.isSuperUser) {
    final engine = RulesEngine(request: request, oldResource: file);

    final approved = await engine.evaluate(updateRule);
    if (!approved) {
      throw VaneStackException(
        'Permission denied.',
        status: HttpStatus.forbidden,
        code: AuthErrorCode.permissionDenied,
      );
    }
  }

  final result = await request.storageService.moveFile(
    fileId: fileId,
    destination: destination,
  );

  return result.toPublic();
}
