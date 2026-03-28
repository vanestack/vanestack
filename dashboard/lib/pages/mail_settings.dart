import 'package:vanestack_client/vanestack_client.dart';
import 'package:jaspr/jaspr.dart';
import 'package:jaspr/dom.dart';
import 'package:jaspr_riverpod/jaspr_riverpod.dart';

import '../components/progress_indicator.dart';
import '../forms/components/form_builder.dart';
import '../forms/components/form_field_builder.dart';
import '../forms/reactive/reactive_forms.dart';
import '../forms/validators.dart';
import '../providers/settings.dart';
import '../utils/toast.dart';

enum MailSettingsTab { smtp, templates }

class MailSettingsPage extends StatefulComponent {
  const MailSettingsPage({super.key});

  @override
  State<StatefulComponent> createState() => _MailSettingsPageState();
}

class _MailSettingsPageState extends State<MailSettingsPage> {
  bool _saving = false;
  MailSettingsTab _activeTab = MailSettingsTab.smtp;

  final _form = Form({
    'server': FormControl<String>(initialValue: '', validators: [required()]),
    'port': FormControl<int>(initialValue: 587),
    'username': FormControl<String>(initialValue: '', validators: [required()]),
    'password': FormControl<String>(initialValue: '', validators: [required()]),
    'fromAddress': FormControl<String>(initialValue: '', validators: [required()]),
    'fromName': FormControl<String>(initialValue: '', validators: [required()]),
    'useSsl': FormControl<bool>(initialValue: false),
    'otpTemplate': FormControl<String>(initialValue: ''),
    'resetPasswordTemplate': FormControl<String>(initialValue: ''),
  });

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    context.listenManual(settingsProvider, (prev, next) {
      if (prev?.value == null && next.value != null) {
        final mail = next.value!.mail;
        _form.setValue({
          'server': mail?.smtpServer ?? '',
          'port': mail?.smtpPort ?? 587,
          'username': mail?.username ?? '',
          'password': mail?.password ?? '',
          'fromAddress': mail?.fromAddress ?? '',
          'fromName': mail?.fromName ?? '',
          'useSsl': mail?.useSsl ?? false,
          'otpTemplate': mail?.otpTemplate ?? '',
          'resetPasswordTemplate': mail?.resetPasswordTemplate ?? '',
        });
      }
    }, fireImmediately: true);
  }

  @override
  void dispose() {
    _form.dispose();
    super.dispose();
  }

  MailSettings _toSettings() {
    final otpTemplate = _form.getControl<String>('otpTemplate')!.value;
    final resetPasswordTemplate = _form.getControl<String>('resetPasswordTemplate')!.value;

    return MailSettings(
      smtpServer: _form.getControl<String>('server')!.value,
      smtpPort: _form.getControl<int>('port')!.value,
      username: _form.getControl<String>('username')!.value,
      password: _form.getControl<String>('password')!.value,
      fromAddress: _form.getControl<String>('fromAddress')!.value,
      fromName: _form.getControl<String>('fromName')!.value,
      useSsl: _form.getControl<bool>('useSsl')!.value,
      otpTemplate: otpTemplate.isEmpty ? null : otpTemplate,
      resetPasswordTemplate: resetPasswordTemplate.isEmpty ? null : resetPasswordTemplate,
    );
  }

  void _setTab(MailSettingsTab tab) {
    setState(() => _activeTab = tab);
  }

  Future<void> _handleSubmit() async {
    _form.markAllAsTouched();
    if (!_form.validate()) {
      return;
    }

    setState(() => _saving = true);

    try {
      await context.read(settingsProvider.notifier).updateMail(_toSettings());

      showToast(
        category: ToastCategory.success,
        title: 'Email settings saved successfully',
      );
    } on VaneStackException catch (e) {
      showToast(
        category: ToastCategory.error,
        title: 'Failed to save email settings',
        description: e.message,
      );
    } finally {
      setState(() => _saving = false);
    }
  }

  @override
  Component build(BuildContext context) {
    return FormBuilder(
      form: _form,
      builder: (context, form) => div(classes: 'space-y-4', [
        // Tab navigation with save button
        div(classes: 'flex justify-between items-center border-b border-border', [
          div(classes: 'flex gap-1 overflow-x-auto', [
            _buildTab('SMTP Settings', MailSettingsTab.smtp, 'icon-server'),
            _buildTab('Email Templates', MailSettingsTab.templates, 'icon-mail'),
          ]),
          button(
            disabled: _saving,
            classes: 'btn',
            type: ButtonType.button,
            events: events(onClick: _handleSubmit),
            [
              if (_saving) const ProgressIndicator() else i([], classes: 'icon-check'),
              Component.text('Save'),
            ],
          ),
        ]),

        // Tab content
        if (_activeTab == MailSettingsTab.smtp) _buildSmtpTab(),
        if (_activeTab == MailSettingsTab.templates) _buildTemplatesTab(),
      ]),
    );
  }

  Component _buildTab(String tabLabel, MailSettingsTab tab, String icon) {
    final isActive = _activeTab == tab;
    return button(
      type: ButtonType.button,
      classes:
          'px-4 py-3 text-sm font-medium transition-colors flex items-center gap-2 border-b-2 ${isActive ? 'border-primary text-primary' : 'border-transparent text-muted-foreground hover:text-foreground'}',
      events: events(onClick: () => _setTab(tab)),
      [
        i(classes: '$icon text-sm', []),
        Component.text(tabLabel),
      ],
    );
  }

  Component _buildSmtpTab() {
    return div(classes: 'grid gap-6', [
      // Server and Port
      div(classes: 'grid md:grid-cols-2 gap-4', [
        FormFieldBuilder<FormControl<String>>(
          path: 'server',
          builder: (context, field) => div(classes: 'grid gap-2', [
            label(classes: 'label', [Component.text('Server')]),
            input(
              type: InputType.text,
              classes: 'input',
              value: field.value,
              onInput: (v) => field.setValue(v),
              attributes: {
                'placeholder': 'smtp.example.com',
                'aria-invalid': field.isTouched && field.error != null ? 'true' : 'false',
              },
            ),
            if (field.isTouched && field.error != null)
              p(classes: 'text-destructive text-sm', [Component.text(field.error!)]),
          ]),
        ),
        FormFieldBuilder<FormControl<int>>(
          path: 'port',
          builder: (context, field) => div(classes: 'grid gap-2', [
            label(classes: 'label', [Component.text('Port')]),
            input<num?>(
              type: InputType.number,
              classes: 'input',
              value: field.value.toString(),
              onInput: (v) => field.setValue(v?.toInt() ?? field.value),
              attributes: {
                'placeholder': '587',
                'aria-invalid': field.isTouched && field.error != null ? 'true' : 'false',
              },
            ),
            if (field.isTouched && field.error != null)
              p(classes: 'text-destructive text-sm', [Component.text(field.error!)]),
          ]),
        ),
      ]),

      // Username and Password
      div(classes: 'grid md:grid-cols-2 gap-4', [
        FormFieldBuilder<FormControl<String>>(
          path: 'username',
          builder: (context, field) => div(classes: 'grid gap-2', [
            label(classes: 'label', [Component.text('Username')]),
            input(
              type: InputType.text,
              classes: 'input',
              value: field.value,
              onInput: (v) => field.setValue(v),
              attributes: {
                'placeholder': '',
                'aria-invalid': field.isTouched && field.error != null ? 'true' : 'false',
              },
            ),
            if (field.isTouched && field.error != null)
              p(classes: 'text-destructive text-sm', [Component.text(field.error!)]),
          ]),
        ),
        FormFieldBuilder<FormControl<String>>(
          path: 'password',
          builder: (context, field) => div(classes: 'grid gap-2', [
            label(classes: 'label', [Component.text('Password')]),
            input(
              type: InputType.password,
              classes: 'input',
              value: field.value,
              onInput: (v) => field.setValue(v),
              attributes: {
                'placeholder': '',
                'aria-invalid': field.isTouched && field.error != null ? 'true' : 'false',
              },
            ),
            if (field.isTouched && field.error != null)
              p(classes: 'text-destructive text-sm', [Component.text(field.error!)]),
          ]),
        ),
      ]),

      // From Address and From Name
      div(classes: 'grid md:grid-cols-2 gap-4', [
        FormFieldBuilder<FormControl<String>>(
          path: 'fromAddress',
          builder: (context, field) => div(classes: 'grid gap-2', [
            label(classes: 'label', [Component.text('From Address')]),
            input(
              type: InputType.text,
              classes: 'input',
              value: field.value,
              onInput: (v) => field.setValue(v),
              attributes: {
                'placeholder': 'noreply@example.com',
                'aria-invalid': field.isTouched && field.error != null ? 'true' : 'false',
              },
            ),
            if (field.isTouched && field.error != null)
              p(classes: 'text-destructive text-sm', [Component.text(field.error!)]),
          ]),
        ),
        FormFieldBuilder<FormControl<String>>(
          path: 'fromName',
          builder: (context, field) => div(classes: 'grid gap-2', [
            label(classes: 'label', [Component.text('From Name')]),
            input(
              type: InputType.text,
              classes: 'input',
              value: field.value,
              onInput: (v) => field.setValue(v),
              attributes: {
                'placeholder': 'My App',
                'aria-invalid': field.isTouched && field.error != null ? 'true' : 'false',
              },
            ),
            if (field.isTouched && field.error != null)
              p(classes: 'text-destructive text-sm', [Component.text(field.error!)]),
          ]),
        ),
      ]),

      // Use SSL
      FormFieldBuilder<FormControl<bool>>(
        path: 'useSsl',
        builder: (context, field) => div(classes: 'grid gap-2', [
          label(classes: 'label', [Component.text('Use SSL')]),
          input(
            type: InputType.checkbox,
            classes: 'input',
            attributes: {'role': 'switch'},
            checked: field.value,
            onChange: (v) {
              if (v is bool) field.setValue(v);
            },
          ),
        ]),
      ),
    ]);
  }

  Component _buildTemplatesTab() {
    return div(classes: 'grid gap-6', [
      p(classes: 'text-muted-foreground text-sm', [
        Component.text(
          'You can use {{user.id}}, {{user.email}}, and {{user.name}} in your templates. Those values will be automatically replaced when sending emails if they are available.',
        ),
      ]),

      // OTP Template
      FormFieldBuilder<FormControl<String>>(
        path: 'otpTemplate',
        builder: (context, field) => div(classes: 'grid gap-3', [
          label(classes: 'label', [Component.text('OTP Sign In Template')]),
          textarea(
            classes: 'textarea w-full h-48',
            [Component.text(field.value)],
            onInput: (v) => field.setValue(v),
          ),
          p(classes: 'text-muted-foreground text-sm', [
            Component.text('Use {{otp_code}} to insert the OTP code.'),
          ]),
        ]),
      ),

      // Reset Password Template
      FormFieldBuilder<FormControl<String>>(
        path: 'resetPasswordTemplate',
        builder: (context, field) => div(classes: 'grid gap-3', [
          label(classes: 'label', [Component.text('Reset Password Template')]),
          textarea(
            classes: 'textarea w-full h-48',
            [Component.text(field.value)],
            onInput: (v) => field.setValue(v),
          ),
          p(classes: 'text-muted-foreground text-sm', [
            Component.text('Use {{reset_url}} to insert the reset link.'),
          ]),
        ]),
      ),
    ]);
  }
}
