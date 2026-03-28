import 'dart:async';

import 'package:vanestack_common/vanestack_common.dart';
import 'package:shelf/shelf.dart';

import '../../../../tools/route.dart';
import '../../../utils/extensions.dart';
import '../../../utils/http_method.dart';

@Route(path: '/v1/buckets', method: HttpMethod.get, requireSuperUserAuth: true)
FutureOr<List<Bucket>> list(Request request) {
  return request.storageService.listBuckets();
}
