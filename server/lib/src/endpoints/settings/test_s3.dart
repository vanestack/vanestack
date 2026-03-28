import 'dart:async';

import 'package:shelf/shelf.dart';

import '../../../tools/route.dart';
import '../../utils/extensions.dart';
import '../../utils/http_method.dart';

@Route(
  path: '/v1/settings/s3',
  method: HttpMethod.get,
  requireSuperUserAuth: true,
)
FutureOr<void> testS3Connection(Request request) {
  return request.settingsService.testS3Connection();
}
