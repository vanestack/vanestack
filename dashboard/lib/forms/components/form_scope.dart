import 'package:jaspr/jaspr.dart';

import '../reactive/form.dart';

/// An inherited component that provides a [Form] to its descendants.
///
/// Wrap your form UI with [FormBuilder] which provides this scope automatically,
/// then access the form from any descendant using [FormScope.of(context)].
class FormScope extends InheritedComponent {
  final Form form;

  const FormScope({
    required this.form,
    required super.child,
  });

  /// Gets the [Form] from the nearest [FormScope] ancestor.
  ///
  /// Throws if no [FormScope] is found in the widget tree.
  static Form of(BuildContext context) {
    final scope =
        context.dependOnInheritedComponentOfExactType<FormScope>();
    assert(scope != null, 'No FormScope found in context');
    return scope!.form;
  }

  /// Gets the [Form] from the nearest [FormScope] ancestor, or null if not found.
  static Form? maybeOf(BuildContext context) {
    final scope =
        context.dependOnInheritedComponentOfExactType<FormScope>();
    return scope?.form;
  }

  @override
  bool updateShouldNotify(covariant FormScope oldComponent) {
    return form != oldComponent.form;
  }
}
