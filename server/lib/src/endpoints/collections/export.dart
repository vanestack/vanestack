import 'dart:async';

import 'package:vanestack_common/vanestack_common.dart';
import 'package:shelf/shelf.dart';

import '../../../tools/route.dart';
import '../../utils/extensions.dart';
import '../../utils/http_method.dart';

@Route(
  path: '/v1/collections/export',
  method: HttpMethod.get,
  requireSuperUserAuth: true,
)
FutureOr<ExportResponse> export(Request request) {
  return request.collections.export();
}
