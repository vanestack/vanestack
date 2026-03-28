import 'package:vanestack_common/vanestack_common.dart';
import 'package:intl/intl.dart';
import 'package:jaspr/dom.dart';
import 'package:jaspr/jaspr.dart';
import 'package:jaspr_riverpod/jaspr_riverpod.dart';

import '../components/menu_button.dart';
import '../components/progress_indicator.dart';
import '../forms/components/form_builder.dart';
import '../forms/components/form_field_builder.dart';
import '../forms/reactive/reactive_forms.dart';
import '../forms/validators.dart';
import '../providers/client.dart';
import '../providers/user.dart';
import '../utils/toast.dart';

class ProfileSettingsPage extends StatefulComponent {
  const ProfileSettingsPage({super.key});

  @override
  State<StatefulComponent> createState() => _ProfileSettingsPageState();
}

class _ProfileSettingsPageState extends State<ProfileSettingsPage> {
  final _date = DateFormat.yMd().add_Hms();
  bool _saving = false;
  bool _signingOut = false;

  final _form = Form({
    'name': FormControl<String>(
      initialValue: '',
      validators: [
        required(),
      ],
    ),
    'newPassword': FormControl<String>(
      initialValue: '',
      validators: [
        passwordStrength(),
      ],
    ),
    'confirmPassword': FormControl<String>(
      initialValue: '',
      validators: [
        matches('newPassword', 'Passwords do not match'),
      ],
    ),
  });

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    context.listenManual(userProvider, (prev, next) {
      if (prev?.value == null && next.value != null) {
        _form.patchValue({'name': next.value?.name ?? ''});
      }
    }, fireImmediately: true);
  }

  Future<void> _saveProfile() async {
    _form.markAllAsTouched();
    if (!_form.validate()) {
      showToast(category: ToastCategory.error, title: 'Please fix form errors');
      return;
    }

    setState(() => _saving = true);

    try {
      final client = context.read(clientProvider);
      final user = context.read(userProvider).value;

      if (user == null) return;

      final name = _form.getControl<String>('name')!.value.trim();
      final newPassword = _form.getControl<String>('newPassword')!.value;
      final password = newPassword.isNotEmpty ? newPassword : null;

      await client.users.update(
        userId: user.id,
        name: name.isEmpty ? null : name,
        password: password,
      );

      // Refresh auth to update user data
      await client.auth.refresh();

      // Reset password fields
      _form.getControl<String>('newPassword')!.reset('');
      _form.getControl<String>('confirmPassword')!.reset('');

      showToast(category: ToastCategory.success, title: 'Profile updated');
    } on VaneStackException catch (e) {
      showToast(
        category: ToastCategory.error,
        title: 'Failed to update profile',
        description: e.message,
      );
    } finally {
      setState(() => _saving = false);
    }
  }

  Future<void> _signOut() async {
    setState(() => _signingOut = true);

    try {
      final client = context.read(clientProvider);
      await client.auth.logout();
      // Router will redirect to login when userProvider becomes null
    } on VaneStackException catch (e) {
      showToast(
        category: ToastCategory.error,
        title: 'Failed to sign out',
        description: e.message,
      );
      setState(() => _signingOut = false);
    }
  }

  @override
  void dispose() {
    _form.dispose();
    super.dispose();
  }

  @override
  Component build(BuildContext context) {
    final userAsync = context.watch(userProvider);
    final user = userAsync.value;

    return FormBuilder(
      form: _form,
      builder: (context, form) => div(
        classes: 'flex flex-col flex-1 h-full overflow-hidden',
        [
          // Appbar
          div(
            classes: 'h-16 bg-card border-b border-border shrink-0 px-4 flex items-center',
            [
              MenuButton(classes: 'md:hidden mr-2'),
              h1(
                classes: 'text-2xl font-semibold',
                [Component.text('Profile')],
              ),
            ],
          ),
          // Body
          div(classes: 'flex-1 overflow-y-auto bg-card', [
            div(classes: 'max-w-4xl p-4 md:p-6', [
              div(classes: 'space-y-8', [
                div(classes: 'flex flex-col md:flex-row', [
                  // Profile Section
                  div(
                    classes:
                        'space-y-4 flex-1 md:border-r md:border-border md:mr-8 md:pr-8 md:border-b-0 border-b pb-6 mb-6',
                    [
                      div([
                        h2(classes: 'text-lg font-semibold', [Component.text('Account Information')]),
                        p(classes: 'text-sm text-muted-foreground', [
                          Component.text('Change your account information below.'),
                        ]),
                      ]),
                      // Email (read-only)
                      label(classes: 'label grid gap-2', [
                        Component.text('Email'),
                        input(
                          id: 'email',
                          type: InputType.email,
                          disabled: true,
                          value: user?.email ?? '',
                          classes: 'bg-muted p-2 rounded-md',
                        ),
                        p(classes: 'text-xs text-muted-foreground', [
                          Component.text('Email cannot be changed.'),
                        ]),
                      ]),

                      // Name
                      FormFieldBuilder<FormControl<String>>(
                        path: 'name',
                        builder: (context, field) => label(classes: 'label grid gap-2', [
                          Component.text('Name'),
                          input<String>(
                            id: 'name',
                            classes: 'input',
                            type: InputType.text,
                            value: field.value,
                            onInput: (v) => field.setValue(v),
                            attributes: {
                              'placeholder': 'Your display name',
                              'aria-invalid': field.isTouched && field.error != null ? 'true' : 'false',
                            },
                          ),
                          if (field.isTouched && field.error != null)
                            p(classes: 'text-sm text-destructive', [Component.text(field.error!)]),
                          if (user != null)
                            div(classes: 'text-xs text-muted-foreground space-y-1', [
                              div([Component.text('Member since ${_date.format(user.createdAt)}')]),
                            ]),
                        ]),
                      ),
                    ],
                  ),

                  // Password Section
                  div(
                    classes: 'space-y-4 flex-1',
                    [
                      div([
                        h2(classes: 'text-lg font-semibold', [Component.text('Change Password')]),
                        p(classes: 'text-sm text-muted-foreground', [
                          Component.text('Leave blank to keep your current password.'),
                        ]),
                      ]),

                      // New Password
                      FormFieldBuilder<FormControl<String>>(
                        path: 'newPassword',
                        builder: (context, field) => label(classes: 'grid gap-2 label', [
                          Component.text('New Password'),
                          input<String>(
                            id: 'newPassword',
                            classes: 'input',
                            type: InputType.password,
                            value: field.value,
                            onInput: (v) => field.setValue(v),
                            attributes: {
                              'placeholder': 'Enter new password',
                              'aria-invalid': field.isTouched && field.error != null ? 'true' : 'false',
                            },
                          ),
                          if (field.isTouched && field.error != null)
                            p(classes: 'text-sm text-destructive', [Component.text(field.error!)]),
                          p(classes: 'text-xs text-muted-foreground', [
                            Component.text(
                              'Minimum 8 characters with uppercase, lowercase, number, and special character.',
                            ),
                          ]),
                        ]),
                      ),

                      // Confirm Password
                      FormFieldBuilder<FormControl<String>>(
                        path: 'confirmPassword',
                        builder: (context, field) => label(classes: 'grid gap-2 label', [
                          Component.text('Confirm Password'),
                          input<String>(
                            id: 'confirmPassword',
                            classes: 'input',
                            type: InputType.password,
                            value: field.value,
                            onInput: (v) => field.setValue(v),
                            attributes: {
                              'placeholder': 'Confirm new password',
                              'aria-invalid': field.isTouched && field.error != null ? 'true' : 'false',
                            },
                          ),
                          if (field.isTouched && field.error != null)
                            p(classes: 'text-sm text-destructive', [Component.text(field.error!)]),
                        ]),
                      ),
                    ],
                  ),
                ]),

                // Save Button
                div(classes: 'flex justify-end', [
                  button(
                    disabled: _saving,
                    classes: 'btn-lg',
                    events: events(onClick: _saveProfile),
                    [
                      if (_saving) const ProgressIndicator() else i(classes: 'icon-check', []),
                      Component.text('Save Changes'),
                    ],
                  ),
                ]),

                hr(classes: 'border-border'),

                // Sign Out Section
                div(classes: 'space-y-4', [
                  div([
                    h2(classes: 'text-lg font-semibold', [Component.text('Sign Out')]),
                    p(classes: 'text-sm text-muted-foreground', [
                      Component.text('Sign out of your account on this device.'),
                    ]),
                  ]),
                  button(
                    disabled: _signingOut,
                    classes: 'btn-lg-secondary',
                    events: events(onClick: _signOut),
                    [
                      if (_signingOut) const ProgressIndicator() else i(classes: 'icon-log-out', []),
                      Component.text('Sign Out'),
                    ],
                  ),
                ]),
              ]),
            ]),
          ]),
        ],
      ),
    );
  }
}
