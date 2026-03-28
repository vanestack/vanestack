import 'dart:async';

import 'package:vanestack_common/vanestack_common.dart';
import 'package:shelf/shelf.dart';

import '../../tools/route.dart';
import '../../src/utils/extensions.dart';
import '../../src/utils/http_method.dart';
import '../permissions/rules_engine.dart';
import '../realtime/realtime.dart';

@Route(path: '/v1/realtime', method: HttpMethod.get)
Stream<RealtimeEvent> subscribe(
  Request request,
  String sessionId,
  String channels,
) {
  late final StreamController<RealtimeEvent> controller;
  bool paused = false;

  controller = StreamController<RealtimeEvent>(
    onPause: () => paused = true,
    onResume: () => paused = false,
    onListen: () {
      //sse_channel package hardcodes ?sessionId param, so we need to clean it up
      final channelIter = channels
          .split('?')
          .first
          .split(',')
          .map((e) => e.trim());
      for (final channel in channelIter) {
        request.realtime.on(channel, (payload) async {
          if (payload is DocumentTransport) {
            final event = payload.event;
            final collection = payload.collection;

            final rule = channel.contains('*')
                ? collection.listRule
                : collection.viewRule;

            if (request.isSuperUser) {
              if (!paused) {
                controller.add(event);
              }
              return;
            }

            // null rule = superuser-only, already handled above
            if (rule == null) return;

            // empty rule = public, allow everyone
            if (rule.trim().isEmpty) {
              if (!paused) controller.add(event);
              return;
            }

            // non-empty rule = evaluate
            final engine = RulesEngine(
              context: 'realtime',
              request: request,
              newResource: switch (event) {
                DocumentCreatedEvent() => event.document,
                DocumentUpdatedEvent() => event.newDocument,
                _ => null,
              },
              oldResource: switch (event) {
                DocumentUpdatedEvent() => event.oldDocument,
                DocumentDeletedEvent() => event.document,
                _ => null,
              },
            );

            final approved = await engine.evaluate(rule);
            if (approved && !paused) {
              controller.add(event);
            }

            return;
          }

          if (payload is FileTransport) {
            final event = payload.event;
            final bucket = payload.bucket;

            final rule = channel.contains('*')
                ? bucket.listRule
                : bucket.viewRule;

            if (request.isSuperUser) {
              if (!paused) controller.add(event);
              return;
            }

            // null rule = superuser-only
            if (rule == null) return;

            // empty rule = public
            if (rule.trim().isEmpty) {
              if (!paused) controller.add(event);
              return;
            }

            // non-empty rule = evaluate
            final engine = RulesEngine(
              context: 'realtime',
              request: request,
              newResource: switch (event) {
                FileUploadedEvent() => payload.file,
                FileMovedEvent() => payload.file,
                _ => null,
              },
              oldResource: switch (event) {
                FileDeletedEvent() => payload.file,
                _ => null,
              },
            );

            final approved = await engine.evaluate(rule);
            if (approved && !paused) {
              controller.add(event);
            }

            return;
          }

          if (payload.event case CustomRealtimeEvent(:final rule)) {
            if (request.isSuperUser) {
              if (!paused) controller.add(payload.event);
              return;
            }

            // null rule = no restriction, allow everyone
            if (rule == null) {
              if (!paused) controller.add(payload.event);
              return;
            }

            // empty rule = public, allow everyone
            if (rule.trim().isEmpty) {
              if (!paused) controller.add(payload.event);
              return;
            }

            // non-empty rule = evaluate
            final engine = RulesEngine(
              context: 'realtime',
              request: request,
            );

            final approved = await engine.evaluate(rule);
            if (approved && !paused) {
              controller.add(payload.event);
            }
            return;
          }

          if (!paused) {
            controller.add(payload.event);
          }
        }, sessionId: sessionId);
      }
    },
    onCancel: () => request.realtime.removeBySession(sessionId),
  );

  return controller.stream;
}
