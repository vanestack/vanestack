import 'package:vanestack_common/vanestack_common.dart';
import 'package:jaspr/dom.dart';
import 'package:jaspr/jaspr.dart';
import 'package:jaspr_riverpod/jaspr_riverpod.dart';

import '../components/progress_indicator.dart';
import '../forms/components/form_builder.dart';
import '../forms/components/form_field_builder.dart';
import '../forms/reactive/reactive_forms.dart';
import '../forms/validators.dart';
import '../providers/settings.dart';
import '../utils/toast.dart';

class ApplicationSettingsPage extends StatefulComponent {
  const ApplicationSettingsPage({super.key});

  @override
  State<StatefulComponent> createState() => _ApplicationSettingsPageState();
}

class _ApplicationSettingsPageState extends State<ApplicationSettingsPage> {
  bool _saving = false;
  final _form = Form({
    'appName': FormControl<String>(
      initialValue: '',
      validators: [required()],
    ),
    'siteUrl': FormControl<String>(
      initialValue: '',
      validators: [required(), url()],
    ),
    'redirectUrls': FormArray<FormControl<String>>(),
  });

  void _addRedirectUrl([String initialValue = '']) {
    final array = _form.getArray<FormControl<String>>('redirectUrls')!;
    array.push(
      FormControl<String>(
        initialValue: initialValue,
        validators: [
          required(),
        ],
      ),
    );
  }

  void _removeRedirectUrl(int index) {
    final array = _form.getArray<FormControl<String>>('redirectUrls')!;
    array.removeAt(index);
  }

  String? get _effectiveAppName {
    final value = _form.getControl<String>('appName')!.value.trim();
    return value.isEmpty ? null : value;
  }

  String? get _effectiveSiteUrl {
    final value = _form.getControl<String>('siteUrl')!.value.trim();
    return value.isEmpty ? null : value;
  }

  List<String> get _effectiveRedirectUrls {
    final array = _form.getArray<FormControl<String>>('redirectUrls')!;
    return array.controls.map((c) => c.value).where((url) => url.isNotEmpty).toList();
  }

  Future<void> _handleSubmit() async {
    _form.markAllAsTouched();
    if (!_form.validate()) {
      return;
    }

    setState(() => _saving = true);

    try {
      await context
          .read(settingsProvider.notifier)
          .updateApp(
            appName: _effectiveAppName,
            siteUrl: _effectiveSiteUrl,
            redirectUrls: _effectiveRedirectUrls,
          );

      showToast(
        category: ToastCategory.success,
        title: 'Application settings saved successfully',
      );
    } on VaneStackException catch (e) {
      showToast(
        category: ToastCategory.error,
        title: 'Failed to save application settings',
        description: e.message,
      );
    } finally {
      setState(() => _saving = false);
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    context.listenManual(settingsProvider, (prev, next) {
      if (prev?.value == null && next.value != null) {
        final settings = next.value!;
        _form.setValue({'appName': settings.appName, 'siteUrl': settings.siteUrl});
        for (final url in settings.redirectUrls) {
          _addRedirectUrl(url);
        }
      }
    }, fireImmediately: true);
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
      builder: (context, form) => div(
        classes: 'form grid gap-6',
        [
          // App Name
          FormFieldBuilder<FormControl<String>>(
            path: 'appName',
            builder: (context, field) => div(classes: 'grid gap-2', [
              label(classes: 'label', [Component.text('Application Name')]),
              input(
                type: InputType.text,
                classes: 'input',
                value: field.value,
                onInput: (v) => field.setValue(v),
                attributes: {
                  'placeholder': 'My App Name',
                  'aria-invalid': field.isTouched && field.error != null ? 'true' : 'false',
                },
              ),
              if (field.isTouched && field.error != null)
                p(classes: 'text-destructive text-sm', [Component.text(field.error!)]),
            ]),
          ),

          // Site URL
          FormFieldBuilder<FormControl<String>>(
            path: 'siteUrl',
            builder: (context, field) => div(classes: 'grid gap-2', [
              label(classes: 'label', [Component.text('Site URL')]),
              input(
                classes: 'input',
                type: InputType.url,
                value: field.value,
                onInput: (v) => field.setValue(v),
                attributes: {
                  'placeholder': 'https://your-app-domain.com',
                  'aria-invalid': field.isTouched && field.error != null ? 'true' : 'false',
                },
              ),
              if (field.isTouched && field.error != null)
                p(classes: 'text-destructive text-sm', [Component.text(field.error!)]),
              p(classes: 'text-muted-foreground text-xs', [
                Component.text(
                  'Configure the default redirect URL used when a redirect URL is not specified or doesn\'t match one from the allow list.',
                ),
              ]),
            ]),
          ),

          // Redirect URLs Section (Dynamic List)
          Builder(
            builder: (context) {
              final redirectUrls = form.getArray<FormControl<String>>('redirectUrls')!;
              return div(classes: 'grid gap-4 p-4 border rounded-lg bg-muted', [
                label(classes: 'text-lg font-medium', [Component.text('Redirect URLs')]),
                p(classes: 'text-muted-foreground text-sm', [
                  Component.text(
                    'URLs that auth providers are permitted to redirect to post authentication. Wildcards are allowed, for example, https://*.domain.com',
                  ),
                ]),

                // List of Redirect Inputs
                if (redirectUrls.isEmpty)
                  p(classes: 'text-muted-foreground italic', [
                    Component.text('No redirect URLs defined.'),
                  ])
                else
                  for (var index = 0; index < redirectUrls.length; index++)
                    FormFieldBuilder<FormControl<String>>(
                      path: 'redirectUrls.[$index]',
                      builder: (context, field) => div(
                        classes: 'grid gap-2',
                        [
                          div(classes: 'flex gap-2 items-center', [
                            input<String>(
                              name: 'redirectUrl_$index',
                              classes: 'input flex-1',
                              type: InputType.url,
                              value: field.value,
                              attributes: {'placeholder': 'https://your-redirect-uri.com'},
                              onInput: (value) => field.setValue(value),
                            ),

                            button(
                              type: ButtonType.button,
                              classes: 'btn-icon-ghost text-destructive p-2',
                              events: events(onClick: () => _removeRedirectUrl(index)),
                              [i([], classes: 'icon-trash')],
                            ),
                          ]),
                          if (field.isTouched && field.error != null)
                            p(classes: 'text-destructive text-sm', [Component.text(field.error!)]),
                        ],
                      ),
                    ),

                // Add Button
                button(
                  type: ButtonType.button,
                  classes: 'btn-lg-outline mt-2 self-start border-dashed flex items-center justify-center gap-1',
                  events: events(onClick: _addRedirectUrl),
                  [i([], classes: 'icon-plus'), Component.text('Add Redirect URL')],
                ),
              ]);
            },
          ),

          // Save Button
          div(classes: 'flex justify-end', [
            button(
              disabled: _saving,
              classes: 'btn-lg',
              type: ButtonType.button,
              events: events(onClick: _handleSubmit),
              [
                if (_saving) const ProgressIndicator() else i([], classes: 'icon-check'),
                Component.text('Save Settings'),
              ],
            ),
          ]),
        ],
      ),
    );
  }
}
