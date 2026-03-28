import 'package:vanestack_client/vanestack_client.dart';
import 'package:jaspr/dom.dart';
import 'package:jaspr/jaspr.dart';
import 'package:jaspr_riverpod/jaspr_riverpod.dart';

import '../components/progress_indicator.dart';
import '../forms/components/form_builder.dart';
import '../forms/components/form_field_builder.dart';
import '../forms/reactive/reactive_forms.dart';
import '../forms/validators.dart';
import '../providers/client.dart';
import '../utils/toast.dart';

class ForgotPasswordPage extends StatefulComponent {
  const ForgotPasswordPage({super.key});

  @override
  State<StatefulComponent> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  bool loading = false;
  bool sent = false;

  final _form = Form({
    'email': FormControl<String>(
      initialValue: '',
      validators: [required(), email()],
    ),
  });

  Future<void> handleSubmit() async {
    _form.markAllAsTouched();
    if (!_form.validate()) return;

    setState(() => loading = true);

    final client = context.read(clientProvider);
    try {
      await client.auth.sendPasswordResetEmail(
        email: _form.getControl<String>('email')!.value,
      );
      setState(() => sent = true);
    } on VaneStackException catch (e) {
      if (mounted) {
        showToast(
          title: 'Error',
          description: e.message,
        );
      }
    } finally {
      if (mounted) {
        setState(() => loading = false);
      }
    }
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
      builder: (context, formGroup) => div(classes: 'min-h-screen bg-background flex flex-col', [
        // Gradient header
        div(
          classes: 'relative overflow-hidden px-6 pt-12 pb-16 text-center',
          [
            div(classes: 'absolute inset-0 login-gradient', []),
            div(classes: 'absolute inset-0 opacity-[0.07] login-grid-overlay', []),
            div(classes: 'relative z-10', [
              div(classes: 'inline-flex items-center gap-2.5 mb-3', [
                img(src: '/_/images/logo.png', alt: 'VaneStack Logo', classes: 'h-10'),
                span(classes: 'text-2xl font-display font-bold tracking-tight text-white', [
                  Component.text('VaneStack'),
                ]),
              ]),
              p(classes: 'text-white/60 text-sm', [
                Component.text('Admin Dashboard'),
              ]),
            ]),
          ],
        ),

        // Card area
        div(classes: 'flex-1 flex items-start justify-center px-6 pt-8', [
          div(classes: 'w-full max-w-sm', [
            div(classes: 'p-6 bg-card rounded-2xl border border-border shadow-lg', [
              if (sent) ...[
                // Success state
                div(classes: 'text-center', [
                  div(
                    classes: 'w-12 h-12 mx-auto mb-4 rounded-full bg-emerald-500/10 flex items-center justify-center',
                    [i(classes: 'icon-mail-check text-emerald-500 text-lg', [])],
                  ),
                  h2(classes: 'font-display text-xl font-bold mb-2', [Component.text('Check your email')]),
                  p(classes: 'text-muted-foreground text-sm mb-6', [
                    Component.text('If an account exists with that email, we\'ve sent a password reset link.'),
                  ]),
                  a(
                    classes:
                        'w-full flex items-center justify-center gap-2 px-6 py-3 bg-foreground text-background rounded-xl font-semibold hover:opacity-90 transition-opacity duration-200',
                    href: '/_/login',
                    [Component.text('Back to Sign in')],
                  ),
                ]),
              ] else ...[
                // Form state
                div(classes: 'mb-8 text-center', [
                  h2(classes: 'font-display text-2xl font-bold mb-2', [
                    Component.text('Forgot password?'),
                  ]),
                  p(classes: 'text-muted-foreground text-sm', [
                    Component.text('Enter your email and we\'ll send a reset link'),
                  ]),
                ]),

                div(classes: 'form grid gap-5', [
                  FormFieldBuilder<FormControl<String>>(
                    path: 'email',
                    builder: (context, field) => div(classes: 'grid gap-2', [
                      label(
                        htmlFor: 'email',
                        classes: 'text-sm font-medium',
                        [Component.text('Email')],
                      ),
                      input(
                        id: 'email',
                        type: InputType.email,
                        name: 'email',
                        value: field.value,
                        onInput: (v) => field.setValue(v),
                        attributes: {
                          'aria-invalid': field.isTouched && field.error != null ? 'true' : 'false',
                          'placeholder': 'admin@example.com',
                        },
                      ),
                      if (field.isTouched && field.error != null)
                        p(
                          classes: 'text-sm text-destructive',
                          [Component.text(field.error!)],
                        ),
                    ]),
                  ),
                ]),

                div(classes: 'mt-6 space-y-3', [
                  button(
                    classes:
                        'w-full flex items-center justify-center gap-2 px-6 py-3 bg-foreground text-background rounded-xl font-semibold hover:opacity-90 transition-opacity duration-200',
                    type: ButtonType.button,
                    disabled: loading,
                    onClick: handleSubmit,
                    [
                      if (loading) const ProgressIndicator(),
                      Component.text('Send reset link'),
                    ],
                  ),
                  div(classes: 'text-center', [
                    a(
                      href: '/_/login',
                      classes: 'text-sm text-muted-foreground hover:text-foreground transition-colors duration-200',
                      [Component.text('\u2190 Back to Sign in')],
                    ),
                  ]),
                ]),
              ],
            ]),
          ]),
        ]),
      ]),
    );
  }
}
