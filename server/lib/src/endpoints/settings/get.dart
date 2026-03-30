import 'dart:async';

import 'package:vanestack_common/vanestack_common.dart';
import 'package:shelf/shelf.dart';

import 'package:vanestack_annotation/vanestack_annotation.dart';
import '../../utils/extensions.dart';

@Route(path: '/v1/settings', method: HttpMethod.get, requireSuperUserAuth: true)
FutureOr<Settings> get(Request request) {
  return request.settingsService.get();
}
