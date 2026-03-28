import 'dart:async';

import 'package:shelf/shelf.dart';

import '../../../tools/route.dart';
import '../../utils/extensions.dart';
import '../../utils/http_method.dart';

@Route(
  path: '/v1/users/<userId>',
  method: HttpMethod.delete,
  requireSuperUserAuth: true,
)
FutureOr<void> delete(Request request, String userId) {
  return request.users.delete(userId);
}
