import 'dart:async';

Stream<R> combineLatest2<A, B, R>(
  Stream<A> streamA,
  Stream<B> streamB,
  R Function(A a, B b) combiner,
) async* {
  A? latestA;
  B? latestB;
  bool hasA = false;
  bool hasB = false;

  final controller = StreamController<R>();

  void emitIfReady() {
    if (hasA && hasB) {
      controller.add(combiner(latestA as A, latestB as B));
    }
  }

  final subA = streamA.listen((a) {
    latestA = a;
    hasA = true;
    emitIfReady();
  });

  final subB = streamB.listen((b) {
    latestB = b;
    hasB = true;
    emitIfReady();
  });

  controller.onCancel = () {
    subA.cancel();
    subB.cancel();
  };

  yield* controller.stream;
}
