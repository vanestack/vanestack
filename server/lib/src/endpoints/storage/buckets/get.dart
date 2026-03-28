import 'dart:async';
import 'dart:io';

import 'package:vanestack_common/vanestack_common.dart';
import 'package:shelf/shelf.dart';

import '../../../../tools/route.dart';
import '../../../utils/extensions.dart';
import '../../../utils/http_method.dart';

@Route(
  path: '/v1/buckets/<bucket>',
  method: HttpMethod.get,
  requireSuperUserAuth: true,
)
FutureOr<Bucket> get(Request request, String bucket) async {
  final result = await request.storageService.getBucket(bucket);

  if (result == null) {
    throw VaneStackException('Bucket not found.', status: HttpStatus.notFound);
  }

  return result;
}
