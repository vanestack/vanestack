import 'dart:async';
import 'dart:io';

import 'package:vanestack_common/vanestack_common.dart';
import 'package:drift/drift.dart';
import 'package:path/path.dart';
import 'package:shelf/shelf.dart';
import 'package:shelf_multipart/shelf_multipart.dart';
import 'package:uuid/uuid.dart';

import '../../../database/database.dart';
import '../../../permissions/rules_engine.dart';
import '../../../../tools/route.dart';
import '../../../utils/extensions.dart';
import '../../../utils/http_method.dart';

@Route(path: '/v1/files/<bucket>/upload', method: HttpMethod.post)
FutureOr<File> upload(Request request, String bucket) async {
  if (request.formData() case var multipart?) {
    String? uploadPath;
    FormData? file;
    Map<String, String> fields = {};

    await for (final data in multipart.formData) {
      if (data.name == 'path') {
        uploadPath = (await data.part.readString()).trim();
        continue;
      }

      if (data.filename != null) {
        file = data;
        continue;
      }

      fields[data.name] = await data.part.readString();
    }

    final db = request.database;

    final bucketEntity =
        await (db.buckets.select()..where((tbl) => tbl.name.equals(bucket)))
            .getSingleOrNull();

    if (bucketEntity == null) {
      throw VaneStackException('Bucket not found.', status: HttpStatus.notFound);
    }

    if (file == null) {
      throw VaneStackException('File is required.', status: HttpStatus.badRequest);
    }

    if (uploadPath == null) {
      throw VaneStackException('Path is required.', status: HttpStatus.badRequest);
    }

    final safePath = normalize(uploadPath);

    if (safePath.isEmpty) {
      throw VaneStackException('Path is required.', status: HttpStatus.badRequest);
    }

    if (isAbsolute(safePath) ||
        safePath.contains('..') ||
        safePath.startsWith('/') ||
        safePath.contains('../') ||
        safePath.contains('..\\')) {
      throw VaneStackException('Invalid path.', status: HttpStatus.badRequest);
    }

    final mimeType =
        file.part.headers['content-type'] ?? 'application/octet-stream';

    final filename = basename(file.filename!);
    if (filename.isEmpty || filename.contains('..')) {
      throw VaneStackException('Invalid filename.');
    }

    // If the path already includes a filename (has an extension), use it as-is.
    // Otherwise, treat it as a directory and append the uploaded filename.
    var pathWithName = extension(safePath).isNotEmpty
        ? safePath
        : join(safePath, filename);
    if (pathWithName.startsWith('./')) {
      pathWithName = pathWithName.substring(2);
    }

    final size = request.headers['content-length'] != null
        ? int.tryParse(request.headers['content-length']!)
        : null;

    // Build a temporary DbFile for permission checking
    final timestamp = DateTime.now();
    final tempFile = DbFile(
      isLocal: false,
      id: const Uuid().v7(),
      path: pathWithName,
      bucket: bucket,
      size: size ?? 0,
      mimeType: mimeType,
      downloadToken: '',
      metadata: fields,
      createdAt: timestamp,
      updatedAt: timestamp,
    );

    final createRule = bucketEntity.createRule;

    if (createRule == null) {
      if (!request.isSuperUser) {
        throw VaneStackException(
          'Permission denied.',
          status: HttpStatus.forbidden,
        );
      }
    } else if (createRule.trim().isNotEmpty && !request.isSuperUser) {
      final engine = RulesEngine(request: request, newResource: tempFile);

      final approved = await engine.evaluate(createRule);
      if (!approved) {
        throw VaneStackException(
          'Permission denied.',
          status: HttpStatus.forbidden,
        );
      }
    }

    final result = await request.storageService.uploadFile(
      bucket: bucket,
      path: pathWithName,
      filename: filename,
      data: file.part,
      mimeType: mimeType,
      metadata: fields,
    );

    return result.toPublic();
  } else {
    throw VaneStackException(
      'No multipart data found in request',
      status: HttpStatus.badRequest,
    );
  }
}
