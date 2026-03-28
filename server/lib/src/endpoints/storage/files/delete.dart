import 'dart:async';
import 'dart:io';

import 'package:vanestack_common/vanestack_common.dart';
import 'package:drift/drift.dart';
import 'package:shelf/shelf.dart';

import '../../../database/database.dart';
import '../../../permissions/rules_engine.dart';
import '../../../../tools/route.dart';
import '../../../utils/extensions.dart';
import '../../../utils/http_method.dart';

@Route(path: '/v1/files/<bucket>', method: HttpMethod.delete)
FutureOr<void> delete(Request request, String bucket, String path) async {
  final db = request.database;
  final bucketEntity =
      await (db.buckets.select()..where((tbl) => tbl.name.equals(bucket)))
          .getSingleOrNull();

  if (bucketEntity == null) {
    throw VaneStackException('Bucket not found.', status: HttpStatus.notFound);
  }

  // Query all files matching the path (exact match or prefix for folder contents)
  final files =
      await (db.files.select()..where(
            (tbl) =>
                (tbl.path.equals(path) | tbl.path.like('$path/%')) &
                tbl.bucket.equals(bucket),
          ))
          .get();

  if (files.isEmpty) {
    throw VaneStackException('File not found.', status: HttpStatus.notFound);
  }

  // Filter files by permission (check each file individually)
  final deleteRule = bucketEntity.deleteRule;
  final filesToDelete = <DbFile>[];

  for (final file in files) {
    if (deleteRule == null) {
      if (request.isSuperUser) {
        filesToDelete.add(file);
      }
    } else if (deleteRule.trim().isEmpty || request.isSuperUser) {
      filesToDelete.add(file);
    } else {
      final engine = RulesEngine(request: request, oldResource: file);
      if (await engine.evaluate(deleteRule)) {
        filesToDelete.add(file);
      }
    }
  }

  if (filesToDelete.isEmpty) {
    throw VaneStackException('Permission denied.', status: HttpStatus.forbidden);
  }

  // Delete each permitted file via the storage service
  final storageService = request.storageService;
  for (final file in filesToDelete) {
    await storageService.deleteFile(file.id);
  }
}
