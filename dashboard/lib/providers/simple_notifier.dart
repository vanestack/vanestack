import 'package:jaspr_riverpod/jaspr_riverpod.dart';

class SimpleNotifier<T> extends Notifier<T> {
  final T initialValue;
  SimpleNotifier(this.initialValue);
  @override
  T build() => initialValue;

  void set(T newState) {
    state = newState;
  }
}
