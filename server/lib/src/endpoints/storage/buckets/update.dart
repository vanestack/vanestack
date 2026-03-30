import 'dart:async';

import 'package:shelf/shelf.dart';
import 'package:vanestack_annotation/vanestack_annotation.dart';
import 'package:vanestack_common/vanestack_common.dart';

import '../../../utils/extensions.dart';

@Route(
  path: '/v1/buckets/<bucket>',
  method: HttpMethod.patch,
  requireSuperUserAuth: true,
)
FutureOr<Bucket> update(
  Request request,
  String bucket,
  String? newBucketName,
  String? listRule,
  String? viewRule,
  String? createRule,
  String? updateRule,
  String? deleteRule,
) {
  return request.storageService.updateBucket(
    name: bucket,
    newBucketName: newBucketName,
    listRule: listRule,
    viewRule: viewRule,
    createRule: createRule,
    updateRule: updateRule,
    deleteRule: deleteRule,
  );
}
