import 'package:jaspr/jaspr.dart';

import '../reactive/form.dart';
import 'form_scope.dart';

/// A component that provides a [Form] to its descendants and rebuilds
/// when the form structure changes.
///
/// Wraps children in [FormScope] so descendants can access the form
/// via [FormScope.of(context)].
///
/// Usage:
/// ```dart
/// FormBuilder(
///   form: myForm,
///   builder: (context, form) => div([
///     FormFieldBuilder<FormControl<String>>(
///       path: 'email',
///       builder: (context, field) => input(value: field.value, ...),
///     ),
///     button(
///       onClick: () => form.validate(),
///       [text('Submit')],
///     ),
///   ]),
/// )
/// ```
class FormBuilder extends StatefulComponent {
  final Form form;
  final Component Function(BuildContext context, Form form) builder;

  const FormBuilder({
    required this.form,
    required this.builder,
    super.key,
  });

  @override
  State<FormBuilder> createState() => _FormBuilderState();
}

class _FormBuilderState extends State<FormBuilder> {
  void _onFormChanged() {
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    component.form.addListener(_onFormChanged);
  }

  @override
  void didUpdateComponent(covariant FormBuilder oldComponent) {
    super.didUpdateComponent(oldComponent);
    if (oldComponent.form != component.form) {
      oldComponent.form.removeListener(_onFormChanged);
      component.form.addListener(_onFormChanged);
    }
  }

  @override
  void dispose() {
    component.form.removeListener(_onFormChanged);
    super.dispose();
  }

  @override
  Component build(BuildContext context) {
    return FormScope(
      form: component.form,
      child: Builder(
        builder: (context) => component.builder(context, component.form),
      ),
    );
  }
}
