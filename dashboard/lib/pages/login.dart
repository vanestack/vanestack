import 'package:vanestack_client/vanestack_client.dart';
import 'package:vanestack_dashboard/utils/toast.dart';
import 'package:jaspr/dom.dart';
import 'package:jaspr/jaspr.dart';
import 'package:jaspr_riverpod/jaspr_riverpod.dart';

import '../components/progress_indicator.dart';
import '../forms/components/form_builder.dart';
import '../forms/components/form_field_builder.dart';
import '../forms/reactive/reactive_forms.dart';
import '../forms/validators.dart';
import '../providers/client.dart';

class LoginPage extends StatefulComponent {
  const LoginPage({super.key});

  @override
  State<StatefulComponent> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  bool loading = false;

  final _form = Form({
    'email': FormControl<String>(
      initialValue: '',
      validators: [required(), email()],
    ),
    'password': FormControl<String>(
      initialValue: '',
      validators: [required()],
    ),
  });

  Future<void> handleLogin() async {
    _form.markAllAsTouched();
    if (!_form.validate()) {
      return;
    }

    setState(() => loading = true);

    final client = context.read(clientProvider);
    try {
      await client.auth.signInWithEmailAndPassword(
        email: _form.getControl<String>('email')!.value,
        password: _form.getControl<String>('password')!.value,
      );
    } on VaneStackException catch (e) {
      if (mounted) {
        showToast(
          title: 'Login Failed',
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
      builder: (context, formGroup) => div(
        classes: 'min-h-screen bg-background flex',
        [
          // Left panel — branding (hidden on mobile)
          div(
            classes: 'hidden lg:flex lg:w-1/2 relative overflow-hidden items-end p-12',
            [
              // Background gradient
              div(classes: 'absolute inset-0 login-gradient', []),
              // Subtle grid overlay
              div(classes: 'absolute inset-0 opacity-[0.07] login-grid-overlay', []),
              // Content
              div(classes: 'relative z-10', [
                div(classes: 'flex items-center gap-3 mb-8', [
                  img(src: '/_/images/logo.png', alt: 'VaneStack Logo', classes: 'h-10'),
                  span(classes: 'text-2xl font-display font-bold tracking-tight text-white', [
                    Component.text('VaneStack'),
                  ]),
                ]),
                p(classes: 'text-3xl font-display font-bold text-white leading-snug mb-4 max-w-sm', [
                  Component.text('Your admin dashboard awaits.'),
                ]),
                p(classes: 'text-white/50 text-sm max-w-xs', [
                  Component.text('Manage collections, users, storage, and settings — all in one place.'),
                ]),
              ]),
            ],
          ),

          // Right panel — login form
          div(classes: 'flex-1 flex flex-col', [
            // Mobile header with gradient (hidden on lg)
            div(
              classes: 'lg:hidden relative overflow-hidden px-6 pt-12 pb-16 text-center',
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

            // Form area
            div(classes: 'flex-1 flex items-center justify-center px-6 py-10 lg:py-12', [
              div(classes: 'w-full max-w-sm lg:-mt-0 -mt-8', [
                div(
                  classes: 'p-6 bg-card rounded-2xl border border-border shadow-lg',
                  [
                    // Heading
                    div(classes: 'mb-8 text-center lg:text-left', [
                      h2(classes: 'font-display text-2xl font-bold mb-2', [
                        Component.text('Sign in'),
                      ]),
                      p(classes: 'text-muted-foreground text-sm', [
                        Component.text('Enter your credentials to continue'),
                      ]),
                    ]),

                    // Form fields
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
                      FormFieldBuilder<FormControl<String>>(
                        path: 'password',
                        builder: (context, field) => div(classes: 'grid gap-2', [
                          div(classes: 'flex items-center gap-2', [
                            label(
                              htmlFor: 'password',
                              classes: 'text-sm font-medium',
                              [Component.text('Password')],
                            ),
                            a(
                              classes:
                                  'ml-auto text-sm text-muted-foreground hover:text-foreground underline-offset-4 hover:underline transition-colors duration-200',
                              href: '/_/forgot-password',
                              [Component.text('Forgot password?')],
                            ),
                          ]),
                          input(
                            id: 'password',
                            name: 'password',
                            type: InputType.password,
                            value: field.value,
                            onInput: (v) => field.setValue(v),
                            attributes: {
                              'aria-invalid': field.isTouched && field.error != null ? 'true' : 'false',
                              'placeholder': '\u2022\u2022\u2022\u2022\u2022\u2022\u2022\u2022',
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

                    // Submit button
                    div(classes: 'mt-6', [
                      button(
                        classes:
                            'w-full flex items-center justify-center gap-2 px-6 py-3 bg-foreground text-background rounded-xl font-semibold hover:opacity-90 transition-opacity duration-200',
                        type: ButtonType.button,
                        disabled: loading,
                        onClick: handleLogin,
                        [
                          if (loading) const ProgressIndicator(),
                          Component.text('Sign in'),
                        ],
                      ),
                    ]),
                  ],
                ),
              ]),
            ]),
          ]),
        ],
      ),
    );
  }
}
