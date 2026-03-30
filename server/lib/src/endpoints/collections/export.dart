import 'dart:async';

import 'package:shelf/shelf.dart';
import 'package:vanestack_annotation/vanestack_annotation.dart';
import 'package:vanestack_common/vanestack_common.dart';

import '../../utils/extensions.dart';

@Route(
  path: '/v1/collections/export',
  method: HttpMethod.get,
  requireSuperUserAuth: true,
)
FutureOr<ExportResponse> export(Request request) {
  return request.collections.export();
}
