import 'package:jaspr/jaspr.dart';
import 'package:jaspr/dom.dart';

import '../reactive/form_field.dart';
import 'form_scope.dart';

/// A component that rebuilds when a specific form field changes.
///
/// Gets the form from [FormScope] and subscribes to the field at [path].
/// Only rebuilds when that specific field changes, making it efficient
/// for forms with many fields.
///
/// Usage:
/// ```dart
/// FormFieldBuilder<FormControl<String>>(
///   path: 'email',
///   builder: (context, field) => input(
///     value: field.value,
///     onInput: (v) => field.setValue(v),
///   ),
/// )
/// ```
class FormFieldBuilder<T extends FormField> extends StatefulComponent {
  final String path;
  final Component Function(BuildContext context, T field) builder;

  const FormFieldBuilder({
    required this.path,
    required this.builder,
    super.key,
  });

  @override
  State<FormFieldBuilder<T>> createState() => _FormFieldBuilderState<T>();
}

class _FormFieldBuilderState<T extends FormField>
    extends State<FormFieldBuilder<T>> {
  T? _field;

  void _onFieldChanged() {
    setState(() {});
  }

  void _subscribeToField() {
    final form = FormScope.of(context);
    final field = form.getField<T>(component.path);

    if (field != _field) {
      _field?.removeListener(_onFieldChanged);
      _field = field;
      _field?.addListener(_onFieldChanged);
    }
  }

  void _unsubscribeFromField() {
    _field?.removeListener(_onFieldChanged);
    _field = null;
  }

  @override
  void initState() {
    super.initState();
    _subscribeToField();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _subscribeToField();
  }

  @override
  void didUpdateComponent(covariant FormFieldBuilder<T> oldComponent) {
    super.didUpdateComponent(oldComponent);
    if (oldComponent.path != component.path) {
      _unsubscribeFromField();
      _subscribeToField();
    }
  }

  @override
  void dispose() {
    _unsubscribeFromField();
    super.dispose();
  }

  @override
  Component build(BuildContext context) {
    if (_field == null) {
      return div([
        Component.text('Field not found: ${component.path}'),
      ]);
    }
    return component.builder(context, _field as T);
  }
}
