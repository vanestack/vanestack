import 'package:vanestack_client/vanestack_client.dart';
import 'package:vanestack_common/vanestack_common.dart';
import 'package:jaspr/jaspr.dart';
import 'package:jaspr/dom.dart';
import 'package:jaspr_riverpod/jaspr_riverpod.dart';

import '../components/progress_indicator.dart';
import '../forms/components/form_builder.dart';
import '../forms/components/form_field_builder.dart';
import '../forms/reactive/reactive_forms.dart';
import '../forms/validators.dart';
import '../providers/client.dart';
import '../providers/settings.dart';
import '../utils/toast.dart';

class S3SettingsPage extends StatefulComponent {
  const S3SettingsPage({super.key});

  @override
  State<StatefulComponent> createState() => _S3SettingsPageState();
}

class _S3SettingsPageState extends State<S3SettingsPage> {
  bool _isTestingConnection = false;
  bool _saving = false;

  final _form = Form({
    'enabled': FormControl<bool>(initialValue: false),
    'endpoint': FormControl<String>(initialValue: '', validators: [required()]),
    'bucket': FormControl<String>(initialValue: '', validators: [required()]),
    'region': FormControl<String>(initialValue: '', validators: [required()]),
    'accessKey': FormControl<String>(initialValue: '', validators: [required()]),
    'secretKey': FormControl<String>(initialValue: '', validators: [required()]),
  });

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    context.listenManual(settingsProvider, (prev, next) {
      if (prev?.value == null && next.value != null) {
        final s3 = next.value!.s3;
        _form.setValue({
          'enabled': s3?.enabled,
          'endpoint': s3?.endpoint,
          'bucket': s3?.bucket,
          'region': s3?.region,
          'accessKey': s3?.accessKey,
          'secretKey': s3?.secretKey,
        });
      }
    }, fireImmediately: true);
  }

  @override
  void dispose() {
    _form.dispose();
    super.dispose();
  }

  S3Settings _toSettings() => S3Settings(
    enabled: _form.getControl<bool>('enabled')!.value,
    endpoint: _form.getControl<String>('endpoint')!.value,
    bucket: _form.getControl<String>('bucket')!.value,
    region: _form.getControl<String>('region')!.value,
    accessKey: _form.getControl<String>('accessKey')!.value,
    secretKey: _form.getControl<String>('secretKey')!.value,
  );

  Future<void> _testConnection() async {
    final client = context.read(clientProvider);
    setState(() => _isTestingConnection = true);
    try {
      await client.settings.testS3Connection();

      showToast(
        category: ToastCategory.success,
        title: 'S3 Connection Successful',
      );
    } on VaneStackException catch (e) {
      showToast(
        category: ToastCategory.error,
        title: 'S3 Connection Failed',
        description: e.message,
      );
    } finally {
      setState(() => _isTestingConnection = false);
    }
  }

  Future<void> _handleSubmit() async {
    _form.markAllAsTouched();
    if (!_form.validate()) {
      return;
    }

    setState(() => _saving = true);

    try {
      await context.read(settingsProvider.notifier).updateS3(_toSettings());

      showToast(
        category: ToastCategory.success,
        title: 'S3 settings saved successfully',
      );
    } on VaneStackException catch (e) {
      showToast(
        category: ToastCategory.error,
        title: 'Failed to save S3 settings',
        description: e.message,
      );
    } finally {
      setState(() => _saving = false);
    }
  }

  void _toggleEnabled() {
    final enabled = _form.getControl<bool>('enabled')!;
    enabled.setValue(!enabled.value);
  }

  @override
  Component build(BuildContext context) {
    return FormBuilder(
      form: _form,
      builder: (context, form) => div(
        classes: 'form grid gap-6',
        [
          // Enabled Toggle
          FormFieldBuilder<FormControl<bool>>(
            path: 'enabled',
            builder: (context, field) => div(
              events: events(onClick: _toggleEnabled),
              classes: 'gap-2 flex flex-row items-start justify-between rounded-lg border p-4 shadow-xs cursor-pointer',
              [
                div(classes: 'flex flex-col gap-0.5', [
                  label(classes: 'leading-normal', htmlFor: 'enabled', [
                    Component.text('S3 Storage Enabled'),
                  ]),
                  p(classes: 'text-muted-foreground text-sm', [
                    Component.text('Toggle to activate or deactivate the S3 connection.'),
                  ]),
                ]),
                input(
                  id: 'enabled',
                  name: 'enabled',
                  type: InputType.checkbox,
                  attributes: {'role': 'switch'},
                  checked: field.value,
                  onChange: (v) {
                    if (v is bool) field.setValue(v);
                  },
                ),
              ],
            ),
          ),

          // Endpoint URL
          FormFieldBuilder<FormControl<String>>(
            path: 'endpoint',
            builder: (context, field) => div(classes: 'grid gap-2', [
              label(classes: 'label', [Component.text('Endpoint URL')]),
              input(
                type: InputType.text,
                classes: 'input',
                value: field.value,
                onInput: (v) => field.setValue(v),
                attributes: {
                  'placeholder': 'https://s3.amazonaws.com',
                  'aria-invalid': field.isTouched && field.error != null ? 'true' : 'false',
                },
              ),
              if (field.isTouched && field.error != null)
                p(classes: 'text-destructive text-sm', [Component.text(field.error!)]),
            ]),
          ),

          // Bucket and Region
          div(classes: 'grid md:grid-cols-2 gap-4', [
            FormFieldBuilder<FormControl<String>>(
              path: 'bucket',
              builder: (context, field) => div(classes: 'grid gap-2', [
                label(classes: 'label', [Component.text('Bucket Name')]),
                input(
                  type: InputType.text,
                  classes: 'input',
                  value: field.value,
                  onInput: (v) => field.setValue(v),
                  attributes: {
                    'placeholder': 'my-bucket-name',
                    'aria-invalid': field.isTouched && field.error != null ? 'true' : 'false',
                  },
                ),
                if (field.isTouched && field.error != null)
                  p(classes: 'text-destructive text-sm', [Component.text(field.error!)]),
              ]),
            ),
            FormFieldBuilder<FormControl<String>>(
              path: 'region',
              builder: (context, field) => div(classes: 'grid gap-2', [
                label(classes: 'label', [Component.text('Region')]),
                input(
                  type: InputType.text,
                  classes: 'input',
                  value: field.value,
                  onInput: (v) => field.setValue(v),
                  attributes: {
                    'placeholder': 'us-west-2',
                    'aria-invalid': field.isTouched && field.error != null ? 'true' : 'false',
                  },
                ),
                if (field.isTouched && field.error != null)
                  p(classes: 'text-destructive text-sm', [Component.text(field.error!)]),
              ]),
            ),
          ]),

          // Access Key and Secret Key
          div(classes: 'grid md:grid-cols-2 gap-4', [
            FormFieldBuilder<FormControl<String>>(
              path: 'accessKey',
              builder: (context, field) => div(classes: 'grid gap-2', [
                label(classes: 'label', [Component.text('Access Key ID')]),
                input(
                  type: InputType.text,
                  classes: 'input',
                  value: field.value,
                  onInput: (v) => field.setValue(v),
                  attributes: {
                    'placeholder': 'my-access-key-id',
                    'aria-invalid': field.isTouched && field.error != null ? 'true' : 'false',
                  },
                ),
                if (field.isTouched && field.error != null)
                  p(classes: 'text-destructive text-sm', [Component.text(field.error!)]),
              ]),
            ),
            FormFieldBuilder<FormControl<String>>(
              path: 'secretKey',
              builder: (context, field) => div(classes: 'grid gap-2', [
                label(classes: 'label', [Component.text('Secret Access Key')]),
                input(
                  type: InputType.password,
                  classes: 'input',
                  value: field.value,
                  onInput: (v) => field.setValue(v),
                  attributes: {
                    'placeholder': 'my-secret-access-key',
                    'aria-invalid': field.isTouched && field.error != null ? 'true' : 'false',
                  },
                ),
                if (field.isTouched && field.error != null)
                  p(classes: 'text-destructive text-sm', [Component.text(field.error!)]),
              ]),
            ),
          ]),

          // Buttons
          div(classes: 'grid md:grid-cols-2 gap-4', [
            button(
              disabled: _isTestingConnection,
              classes: 'btn-lg-outline',
              type: ButtonType.button,
              events: events(onClick: _testConnection),
              [
                if (_isTestingConnection) const ProgressIndicator() else i([], classes: 'icon-link'),
                Component.text('Test S3 Connection'),
              ],
            ),
            button(
              disabled: _saving,
              classes: 'btn-lg',
              type: ButtonType.button,
              events: events(onClick: _handleSubmit),
              [
                if (_saving) const ProgressIndicator() else i([], classes: 'icon-check'),
                Component.text('Save'),
              ],
            ),
          ]),
        ],
      ),
    );
  }
}
