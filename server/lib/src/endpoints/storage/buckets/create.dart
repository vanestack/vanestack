import 'dart:async';

import 'package:vanestack_common/vanestack_common.dart';
import 'package:shelf/shelf.dart';

import '../../../../tools/route.dart';
import '../../../utils/extensions.dart';
import '../../../utils/http_method.dart';

@Route(
  path: '/v1/buckets/<bucket>',
  method: HttpMethod.post,
  requireSuperUserAuth: true,
)
FutureOr<Bucket> create(
  Request request,
  String bucket,
  String? listRule,
  String? viewRule,
  String? createRule,
  String? updateRule,
  String? deleteRule,
) {
  return request.storageService.createBucket(
    name: bucket,
    listRule: listRule,
    viewRule: viewRule,
    createRule: createRule,
    updateRule: updateRule,
    deleteRule: deleteRule,
  );
}
