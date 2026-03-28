import 'package:vanestack_common/vanestack_common.dart';
import 'package:vanestack_dashboard/utils/extensions.dart';
import 'package:intl/intl.dart';
import 'package:jaspr/jaspr.dart';
import 'package:jaspr/dom.dart';
import 'package:jaspr_riverpod/jaspr_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../forms/components/form_builder.dart';
import '../forms/components/form_field_builder.dart';
import '../forms/reactive/reactive_forms.dart';
import '../forms/validators.dart';
import '../providers/users.dart';
import '../utils/toast.dart';
import 'progress_indicator.dart';
import 'sheet.dart';

class UserForm extends StatefulComponent {
  final User? user;
  const UserForm({this.user, super.key});

  @override
  State<UserForm> createState() => _UserFormState();
}

class _UserFormState extends State<UserForm> {
  bool _saving = false;
  bool _deleting = false;

  final _date = DateFormat.yMd().add_Hms();

  final _form = Form({
    'id': FormControl<String>(
      initialValue: '',
      validators: [uuid()],
    ),
    'email': FormControl<String>(
      initialValue: '',
      validators: [required(), email()],
    ),
    'name': FormControl<String>(initialValue: ''),
    'password': FormControl<String>(
      initialValue: '',
      validators: [passwordStrength()],
    ),
  });

  Future<void> _save() async {
    _form.markAllAsTouched();
    if (!_form.validate()) {
      showToast(
        category: ToastCategory.error,
        title: 'Invalid form data',
      );
      return;
    }

    setState(() => _saving = true);

    try {
      final emailValue = _form.getControl<String>('email')!.value;
      final nameValue = _form.getControl<String>('name')!.value;
      final passwordValue = _form.getControl<String>('password')!.value.nullIfEmpty;

      if (component.user == null) {
        final idValue = _form.getControl<String>('id')!.value.nullIfEmpty;

        await context.read(usersProvider.notifier).createUser(
              id: idValue,
              name: nameValue,
              email: emailValue,
              password: passwordValue,
            );
        showToast(category: ToastCategory.success, title: "User created");
      } else {
        await context.read(usersProvider.notifier).updateUser(
              id: component.user!.id,
              name: nameValue,
              email: emailValue,
              password: passwordValue,
            );

        showToast(category: ToastCategory.success, title: "User updated");
      }

      Sheet.of(context)?.close();
    } on VaneStackException catch (e) {
      showToast(
        category: ToastCategory.error,
        title: 'Failed to save user',
        description: e.message,
      );
    } finally {
      setState(() => _saving = false);
    }
  }

  Future<void> _delete() async {
    setState(() => _deleting = true);

    try {
      await context.read(usersProvider.notifier).deleteUser(id: component.user!.id);

      showToast(category: ToastCategory.success, title: "User deleted");
      Sheet.of(context)?.close();
    } on VaneStackException catch (e) {
      showToast(
        category: ToastCategory.error,
        title: 'Failed to delete user',
        description: e.message,
      );
    } finally {
      setState(() => _deleting = false);
    }
  }

  @override
  void didUpdateComponent(covariant UserForm oldComponent) {
    super.didUpdateComponent(oldComponent);
    _form.setValue({
      'id': component.user?.id ?? '',
      'email': component.user?.email ?? '',
      'name': component.user?.name ?? '',
      'password': '',
    });
  }

  @override
  void dispose() {
    _form.dispose();
    super.dispose();
  }

  @override
  Component build(BuildContext context) {
    return FormBuilder(
      form: _form,
      builder: (context, form) => div(classes: "flex flex-col h-full", [
        // HEADER
        div(classes: "px-6 py-4 border-b bg-muted flex justify-between", [
          h2(classes: "text-lg font-bold", [
            Component.text(component.user == null ? "Create User" : "Edit User"),
          ]),
          div(classes: 'flex gap-2', [
            button(
              id: 'deleteBtn',
              classes: 'btn-icon-ghost hover:text-destructive ${component.user == null ? 'hidden' : ''}',
              events: events(onClick: _delete),
              [
                if (_deleting) const ProgressIndicator() else i(classes: 'icon-trash', []),
              ],
            ),
            button(
              classes: "btn-icon-ghost",
              events: events(onClick: () => Sheet.of(context)?.close()),
              [i(classes: "icon-x", [])],
            ),
          ]),
        ]),

        // FORM CONTENT
        div(classes: "p-6 space-y-6 flex-1 overflow-y-auto", [
          // ID (Disabled on update)
          FormFieldBuilder<FormControl<String>>(
            path: 'id',
            builder: (context, field) => label(classes: "field label grid gap-2", [
              Component.text("ID"),
              div(
                classes: "flex items-center space-x-2",
                [
                  input<String>(
                    classes: "input",
                    type: InputType.text,
                    disabled: component.user != null,
                    value: field.value,
                    onInput: (v) => field.setValue(v),
                    attributes: {
                      "placeholder": "Leave empty to auto-generate",
                      "aria-invalid": field.isTouched && field.error != null ? "true" : "false",
                    },
                  ),
                  if (component.user == null)
                    button(
                      classes: 'btn-secondary',
                      [Component.text('Generate')],
                      onClick: () => field.setValue(const Uuid().v7()),
                    ),
                ],
              ),
              if (field.isTouched && field.error != null)
                p(
                  classes: 'text-destructive text-sm',
                  [Component.text(field.error!)],
                ),
            ]),
          ),

          // NAME
          FormFieldBuilder<FormControl<String>>(
            path: 'name',
            builder: (context, field) => label(classes: "field label grid gap-2", [
              Component.text("Name"),
              input<String>(
                classes: "input",
                type: InputType.text,
                value: field.value,
                onInput: (v) => field.setValue(v),
                attributes: {
                  "aria-invalid": field.isTouched && field.error != null ? "true" : "false",
                },
              ),
              if (field.isTouched && field.error != null)
                p(
                  classes: 'text-destructive text-sm',
                  [Component.text(field.error!)],
                ),
            ]),
          ),

          // EMAIL
          FormFieldBuilder<FormControl<String>>(
            path: 'email',
            builder: (context, field) => label(classes: "field label grid gap-2", [
              div([
                Component.text("Email"),
                span(classes: "text-destructive", [Component.text('*')]),
              ]),
              input<String>(
                classes: "input",
                type: InputType.email,
                value: field.value,
                onInput: (v) => field.setValue(v),
                attributes: {
                  "aria-invalid": field.isTouched && field.error != null ? "true" : "false",
                },
              ),
              if (field.isTouched && field.error != null)
                p(
                  classes: 'text-destructive text-sm',
                  [Component.text(field.error!)],
                ),
            ]),
          ),

          // PASSWORD
          FormFieldBuilder<FormControl<String>>(
            path: 'password',
            builder: (context, field) => label(classes: "field label grid gap-2", [
              Component.text("Password"),
              input<String>(
                classes: "input",
                type: InputType.password,
                value: field.value,
                onInput: (v) => field.setValue(v),
                attributes: {
                  "placeholder":
                      component.user == null ? "Enter a password" : "Leave blank to keep current password",
                  "aria-invalid": field.isTouched && field.error != null ? "true" : "false",
                },
              ),
              if (field.isTouched && field.error != null)
                p(
                  classes: 'text-destructive text-sm',
                  [Component.text(field.error!)],
                ),
              p(classes: 'text-muted-foreground text-sm', [
                Component.text(
                    'Minimum 8 characters, including uppercase, lowercase, number, and special character.'),
              ]),
            ]),
          ),

          if (component.user != null)
            div(classes: "text-xs text-muted-foreground space-y-1", [
              div([
                Component.text("Created: ${_date.format(component.user!.createdAt)}"),
              ]),
              div([
                Component.text("Updated: ${_date.format(component.user!.updatedAt)}"),
              ]),
            ]),
        ]),

        // FOOTER BUTTONS
        div(classes: "px-6 py-4 border-t bg-muted flex justify-end gap-3", [
          button(
            classes: "btn-outline",
            events: events(onClick: () => Sheet.of(context)?.close()),
            [Component.text("Cancel")],
          ),
          button(
            classes: "btn",
            disabled: _saving,
            events: events(onClick: _save),
            [
              if (_saving) const ProgressIndicator(),
              if (!_saving) i(classes: "icon-check", []),
              Component.text("Save"),
            ],
          ),
        ]),
      ]),
    );
  }
}
