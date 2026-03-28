import 'package:vanestack_client/vanestack_client.dart';
import 'package:jaspr/dom.dart';
import 'package:jaspr/jaspr.dart';
import 'package:universal_web/web.dart';

import '../components/progress_indicator.dart';
import '../utils/auth_storage.dart';

@client
class ResetPasswordPage extends StatefulComponent {
  const ResetPasswordPage({super.key});

  @override
  State<StatefulComponent> createState() => _ResetPasswordPageState();
}

class _ResetPasswordPageState extends State<ResetPasswordPage> {
  final token = Uri.base.queryParameters['token'];

  final client = VaneStackClient(
    baseUrl: Uri(
      scheme: Uri.base.scheme,
      host: Uri.base.host,
      port: Uri.base.port,
    ).toString(),
    authStorage: NoopAuthStorage(),
  );

  bool loading = false;

  Future<void> handleSubmit(Event event) async {
    if (!kIsWeb) return;
    event.preventDefault();

    final form = event.target as HTMLFormElement;
    final valid = form.checkValidity();
    if (!valid) {
      return;
    }

    setState(() => loading = true);

    final password = form.elements.namedItem('password') as HTMLInputElement;
    final confirmPassword = form.elements.namedItem('confirm_password') as HTMLInputElement;

    if (password.value != confirmPassword.value) {
      window.alert('Passwords do not match');
      setState(() => loading = false);
      return;
    }

    if (token == null || token!.isEmpty) {
      window.alert('Invalid or missing token');
      setState(() => loading = false);
      return;
    }

    await client.auth.resetPassword(newPassword: password.value, token: token!);

    setState(() => loading = false);
  }

  @override
  Component build(BuildContext context) {
    return form(
      events: {'submit': handleSubmit},
      [
        div(classes: 'min-h-screen bg-background flex flex-col', [
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
                // Heading
                div(classes: 'mb-8 text-center', [
                  h2(classes: 'font-display text-2xl font-bold mb-2', [
                    Component.text('Reset your password'),
                  ]),
                  p(classes: 'text-muted-foreground text-sm', [
                    Component.text('Enter your new password below'),
                  ]),
                ]),

                // Form fields
                div(classes: 'form grid gap-5', [
                  div(classes: 'grid gap-2', [
                    label(
                      htmlFor: 'password',
                      classes: 'text-sm font-medium',
                      [Component.text('New Password')],
                    ),
                    input(
                      id: 'password',
                      name: 'password',
                      type: InputType.password,
                      attributes: {'placeholder': '\u2022\u2022\u2022\u2022\u2022\u2022\u2022\u2022'},
                    ),
                  ]),
                  div(classes: 'grid gap-2', [
                    label(
                      htmlFor: 'confirm_password',
                      classes: 'text-sm font-medium',
                      [Component.text('Confirm Password')],
                    ),
                    input(
                      id: 'confirm_password',
                      name: 'confirm_password',
                      type: InputType.password,
                      attributes: {'placeholder': '\u2022\u2022\u2022\u2022\u2022\u2022\u2022\u2022'},
                    ),
                  ]),
                ]),

                // Submit button
                div(classes: 'mt-6', [
                  button(
                    classes:
                        'w-full flex items-center justify-center gap-2 px-6 py-3 bg-foreground text-background rounded-xl font-semibold hover:opacity-90 transition-opacity duration-200',
                    type: ButtonType.submit,
                    disabled: loading,
                    [
                      if (loading) ProgressIndicator(),
                      Component.text('Reset Password'),
                    ],
                  ),
                ]),
              ]),
            ]),
          ]),
        ]),
      ],
    );
  }
}
