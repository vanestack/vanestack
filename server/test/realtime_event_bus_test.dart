import 'package:vanestack/src/realtime/realtime.dart';
import 'package:test/test.dart';
import 'package:vanestack_common/vanestack_common.dart';

void main() {
  group('RealtimeEventBus', () {
    late RealtimeEventBus eventBus;

    setUp(() {
      eventBus = RealtimeEventBus();
    });

    test('registers and emits events to listeners', () {
      bool wasCalled = false;

      eventBus.on('channel1', (event) {
        wasCalled = true;
        expect(event, isA<Transport>());
      });

      final event = Transport(
        event: CustomRealtimeEvent(channels: ['channel1'], data: {}),
      );

      eventBus.emit(event);
      expect(wasCalled, isTrue);
    });

    test('does not call listener for unrelated channels', () {
      bool wasCalled = false;

      eventBus.on('channel1', (_) => wasCalled = true);

      final event = Transport(
        event: CustomRealtimeEvent(channels: ['other'], data: {}),
      );

      eventBus.emit(event);
      expect(wasCalled, isFalse);
    });

    test('multiple listeners on same event are all called', () {
      int callCount = 0;

      eventBus.on('channel1', (_) => callCount++);
      eventBus.on('channel1', (_) => callCount++);
      eventBus.on('channel1', (_) => callCount++);

      final event = Transport(
        event: CustomRealtimeEvent(channels: ['channel1'], data: {}),
      );

      eventBus.emit(event);
      expect(callCount, equals(3));
    });

    test('listeners are removed by session', () {
      int callCount = 0;

      eventBus.on('channel1', (_) => callCount++, sessionId: 'abc');
      eventBus.on('channel1', (_) => callCount++, sessionId: 'def');

      eventBus.removeBySession('abc');

      final event = Transport(
        event: CustomRealtimeEvent(channels: ['channel1'], data: {}),
      );

      eventBus.emit(event);
      expect(callCount, equals(1));
    });

    test('listeners are removed by event name', () {
      int callCount = 0;

      eventBus.on('channel1', (_) => callCount++);
      eventBus.on('channel2', (_) => callCount++);

      eventBus.removeChannel('channel1');

      final event = Transport(
        event: CustomRealtimeEvent(
          channels: ['channel1', 'channel2'],
          data: {},
        ),
      );

      eventBus.emit(event);
      expect(callCount, equals(1)); // only channel2 listener called
    });

    test('clear removes all listeners', () {
      int callCount = 0;

      eventBus.on('channel1', (_) => callCount++);
      eventBus.on('channel2', (_) => callCount++);

      eventBus.clear();

      final event = Transport(
        event: CustomRealtimeEvent(
          channels: ['channel1', 'channel2'],
          data: {},
        ),
      );

      eventBus.emit(event);
      expect(callCount, equals(0));
    });

    test('listeners are safe during modification while emitting', () {
      int callCount = 0;

      eventBus.on('channel1', (_) {
        callCount++;
        eventBus.on('channel1', (_) => callCount++);
      });

      final event = Transport(
        event: CustomRealtimeEvent(channels: ['channel1'], data: {}),
      );

      eventBus.emit(event);
      expect(callCount, equals(1)); // new listener should not fire immediately
    });
  });
}
