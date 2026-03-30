import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:shelf/shelf.dart';

import 'package:vanestack_annotation/vanestack_annotation.dart';
import '../utils/extensions.dart';


@Route(path: '/health', method: HttpMethod.get, ignoreForClient: true)
FutureOr<Response> health(Request request) async {
  final db = request.database;

  bool dbHealthy;
  try {
    await db.customSelect('SELECT 1').get();
    dbHealthy = true;
  } catch (_) {
    dbHealthy = false;
  }

  final healthy = dbHealthy;
  final body = jsonEncode({
    'status': healthy ? 'ok' : 'degraded',
    'database': dbHealthy ? 'ok' : 'unreachable',
  });

  return Response(
    healthy ? HttpStatus.ok : HttpStatus.serviceUnavailable,
    body: body,
    headers: {HttpHeaders.contentTypeHeader: 'application/json'},
  );
}
