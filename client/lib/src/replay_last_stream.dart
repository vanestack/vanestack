import 'dart:async';

class ReplayLastStream<T> {
  final _controller = StreamController<T>.broadcast();
  Value<T?>? _lastValue;

  void add(T value) {
    _lastValue = Value(value);

    _controller.add(value);
  }

  Stream<T?> get stream async* {
    if (_lastValue != null) yield _lastValue!.value;
    yield* _controller.stream;
  }

  Future<void> close() => _controller.close();
}

class Value<T> {
  T? value;
  Value(this.value);
}
