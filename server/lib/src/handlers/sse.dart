import 'dart:async';
import 'dart:convert';

import 'package:shelf/shelf.dart';

import '../utils/logger.dart';

Response sseHandler(Request request, String sessionId, Stream<Object> stream) {
  if (request.headers['accept']?.contains('text/event-stream') != true) {
    return Response.notFound(null);
  }

  late final StreamController<List<int>> controller;
  late final Timer keepalive;
  late final StreamSubscription subscription;

  void cleanup() {
    keepalive.cancel();
    subscription.cancel();
    controller.close();
  }

  controller = StreamController<List<int>>(
    onListen: () {
      // Send an initial SSE comment to flush through Cloudflare's
      // response buffer so the connection opens immediately.
      controller.add(utf8.encode(': ok\n\n'));

      // Send keepalive comments every 15s to stay well within
      // Cloudflare's 100-second idle timeout (Error 524).
      keepalive = Timer.periodic(const Duration(seconds: 15), (_) {
        try {
          controller.add(utf8.encode(':\n\n'));
        } catch (_) {
          cleanup();
        }
      });

      subscription = stream.listen(
        (data) {
          final encoded = switch (data) {
            String s => s,
            num n => n,
            _ => jsonEncode(data),
          };

          controller.add(utf8.encode('data: $encoded\n\n'));
        },
        onError: (Object e, StackTrace st) {
          realtimeLogger.error('SSE stream error', error: e, stackTrace: st);
        },
        onDone: cleanup,
      );
    },
    onCancel: cleanup,
  );

  return Response.ok(
    controller.stream,
    headers: {
      'Content-Type': 'text/event-stream',
      'Cache-Control': 'no-cache',
      'Connection': 'keep-alive',
      'X-Accel-Buffering': 'no',
    },
    context: {'shelf.io.buffer_output': false},
  );
}
