import 'package:vanestack_common/vanestack_common.dart';

import '../database/database.dart';
import '../utils/logger.dart';

typedef EventListener = void Function(Transport event);

class RealtimeEventBus {
  final Map<String, List<_ListenerEntry>> _listeners = {};

  /// Register a listener for a given [channel], optionally tied to a [sessionId].
  Future<void> on(
    String channel,
    EventListener listener, {
    String? sessionId,
  }) async {
    final entry = _ListenerEntry(listener, sessionId);
    _listeners.putIfAbsent(channel, () => []).add(entry);
    realtimeLogger.debug(
      'Listener registered',
      context: 'channel=$channel, sessionId=$sessionId',
    );
  }

  /// Emit an event to all listeners registered for its channels.
  Future<void> emit(Transport wrapper) async {
    final channels = wrapper.event.channels;
    var listenerCount = 0;

    for (final channel in channels) {
      final listeners = _listeners[channel];

      if (listeners == null) continue;

      listenerCount += listeners.length;

      // Copy to prevent modification during iteration
      for (final entry in List<_ListenerEntry>.from(listeners)) {
        try {
          entry.listener(wrapper);
        } catch (e, st) {
          realtimeLogger.error(
            'Listener threw on channel $channel',
            error: e,
            stackTrace: st,
          );
        }
      }
    }

    realtimeLogger.debug(
      'Event emitted',
      context: 'channels=${channels.join(",")}, listeners=$listenerCount',
    );
  }

  /// Remove all listeners associated with a specific [sessionId].
  Future<void> removeBySession(String sessionId) async {
    _listeners.forEach((_, entries) {
      entries.removeWhere((entry) => entry.sessionId == sessionId);
    });
    realtimeLogger.debug(
      'Session listeners removed',
      context: 'sessionId=$sessionId',
    );
  }

  /// Remove all listeners for a specific [channel].
  Future<void> removeChannel(String channel) async {
    _listeners.remove(channel);
    realtimeLogger.debug('Channel removed', context: 'channel=$channel');
  }

  /// Remove everything.
  Future<void> clear() async {
    _listeners.clear();
    realtimeLogger.debug('All listeners cleared');
  }
}

class _ListenerEntry {
  final EventListener listener;
  final String? sessionId;
  _ListenerEntry(this.listener, this.sessionId);
}

/// A wrapper class to transport realtime events.
class Transport {
  final RealtimeEvent event;

  Transport({required this.event});
}

/// An extension of [Transport] for document-related events, providing direct access to the affected collection.
class DocumentTransport extends Transport {
  final Collection collection;

  DocumentTransport({required super.event, required this.collection});
}

/// An extension of [Transport] for file-related events, providing direct access to the affected bucket and file.
class FileTransport extends Transport {
  final Bucket bucket;
  final DbFile file;

  FileTransport({
    required super.event,
    required this.bucket,
    required this.file,
  });
}
