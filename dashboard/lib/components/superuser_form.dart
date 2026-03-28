import 'package:vanestack_common/vanestack_common.dart';
import 'package:vanestack_dashboard/providers/client.dart';
import 'package:intl/intl.dart';
import 'package:jaspr/jaspr.dart';
import 'package:jaspr/dom.dart';
import 'package:jaspr_riverpod/jaspr_riverpod.dart';

import '../forms/components/form_builder.dart';
import '../forms/components/form_field_builder.dart';
import '../forms/reactive/reactive_forms.dart';
import '../forms/validators.dart';
import '../providers/superusers.dart';
import '../providers/user.dart';
import '../utils/toast.dart';
import 'progress_indicator.dart';
import 'sheet.dart';

class SuperuserForm extends StatefulComponent {
  final User? user;
  const SuperuserForm({this.user, super.key});

  @override
  State<SuperuserForm> createState() => _SuperuserFormState();
}

class _SuperuserFormState extends State<SuperuserForm> {
  bool _saving = false;
  bool _deleting = false;

  final _date = DateFormat.yMd().add_Hms();

  final _form = Form({
    'email': FormControl<String>(
      initialValue: '',
      validators: [required(), email()],
    ),
    'name': FormControl<String>(initialValue: ''),
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

      if (component.user == null) {
        await context
            .read(superusersProvider.notifier)
            .createSuperuser(
              name: nameValue.isEmpty ? null : nameValue,
              email: emailValue,
            );
        showToast(category: ToastCategory.success, title: "Superuser created");
      } else {
        await context
            .read(superusersProvider.notifier)
            .updateSuperuser(
              id: component.user!.id,
              name: nameValue.isEmpty ? null : nameValue,
              email: emailValue,
            );

        if (context.read(userProvider).value?.id == component.user!.id) {
          // Update user info if the current user updated themselves
          await context.read(clientProvider).auth.refresh();
        }

        showToast(category: ToastCategory.success, title: "Superuser updated");
      }

      Sheet.of(context)?.close();
    } on VaneStackException catch (e) {
      showToast(
        category: ToastCategory.error,
        title: 'Failed to save superuser',
        description: e.message,
      );
    } finally {
      setState(() => _saving = false);
    }
  }

  Future<void> _delete() async {
    setState(() => _deleting = true);

    try {
      await context.read(superusersProvider.notifier).deleteSuperuser(id: component.user!.id);

      showToast(category: ToastCategory.success, title: "Superuser deleted");
      Sheet.of(context)?.close();
    } on VaneStackException catch (e) {
      showToast(
        category: ToastCategory.error,
        title: 'Failed to delete superuser',
        description: e.message,
      );
    } finally {
      setState(() => _deleting = false);
    }
  }

  @override
  void didUpdateComponent(covariant SuperuserForm oldComponent) {
    super.didUpdateComponent(oldComponent);
    _form.setValue({
      'email': component.user?.email ?? '',
      'name': component.user?.name ?? '',
    });
  }

  @override
  void dispose() {
    _form.dispose();
    super.dispose();
  }

  @override
  Component build(BuildContext context) {
    final currentUser = context.watch(userProvider).value;
    final isCurrentUser = component.user != null && currentUser?.id == component.user!.id;

    return FormBuilder(
      form: _form,
      builder: (context, form) => div(classes: "flex flex-col h-full", [
        // HEADER
        div(classes: "px-6 py-4 border-b bg-muted flex justify-between", [
          h2(classes: "text-lg font-bold", [
            Component.text(component.user == null ? "Add Superuser" : "Edit Superuser"),
          ]),
          div(classes: 'flex gap-2', [
            if (component.user != null && !isCurrentUser)
              button(
                key: ValueKey('delete_btn_${component.user!.id}'),
                id: 'deleteBtn',
                classes: 'btn-icon-ghost hover:text-destructive',
                type: ButtonType.button,
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
