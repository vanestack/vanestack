import 'dart:async';
import 'dart:io';

import 'package:shelf/shelf.dart';
import 'package:vanestack_annotation/vanestack_annotation.dart';
import 'package:vanestack_common/vanestack_common.dart';

import '../../../permissions/rules_engine.dart';
import '../../../utils/extensions.dart';

@Route(path: '/v1/files/<bucket>', method: HttpMethod.get)
FutureOr<ListFilesResult> list(
  Request request,
  String bucket,
  String? path,
  String? orderBy,
  String? filter, [
  int? limit = 10,
  int? offset = 0,
]) async {
  final storageService = request.storageService;

  final bucketEntity = await storageService.getBucket(bucket);
  if (bucketEntity == null) {
    throw VaneStackException('Bucket not found.', status: HttpStatus.notFound);
  }

  final (files, folders) = await storageService.listFiles(
    bucket: bucket,
    path: path,
    filter: filter,
    orderBy: orderBy,
    limit: limit,
    offset: offset ?? 0,
  );

  final listRule = bucketEntity.listRule;
  if (listRule == null) {
    if (!request.isSuperUser) {
      throw VaneStackException(
        'Permission denied.',
        status: HttpStatus.forbidden,
      );
    }
  } else if (listRule.trim().isNotEmpty && !request.isSuperUser) {
    final engine = RulesEngine(request: request);

    final checks = await Future.wait([
      for (final file in files) engine.evaluate(listRule, oldResource: file),
    ]);

    if (checks.contains(false)) {
      throw VaneStackException(
        'Permission denied.',
        status: HttpStatus.forbidden,
      );
    }
  }

  return ListFilesResult(
    files: files.map((e) => e.toPublic()).toList(),
    folders: folders,
  );
}
