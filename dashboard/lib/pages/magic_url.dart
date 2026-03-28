import 'package:vanestack_client/vanestack_client.dart';
import 'package:jaspr/dom.dart';
import 'package:jaspr/jaspr.dart';
import 'package:jaspr_riverpod/jaspr_riverpod.dart';

import '../components/progress_indicator.dart';
import '../providers/client.dart';

class MagicUrlPage extends StatefulComponent {
  final String? email;
  final String? otp;
  const MagicUrlPage({super.key, this.email, this.otp});

  @override
  State<StatefulComponent> createState() => _MagicUrlPageState();
}

class _MagicUrlPageState extends State<MagicUrlPage> {
  bool loading = true;
  String? error;

  @override
  void initState() {
    super.initState();
    _verifyOtp();
  }

  Future<void> _verifyOtp() async {
    final email = component.email;
    final otp = component.otp;

    if (email == null || email.isEmpty || otp == null || otp.isEmpty) {
      setState(() {
        loading = false;
        error = 'Missing email or code in URL.';
      });
      return;
    }

    final client = context.read(clientProvider);

    try {
      await Future.delayed(const Duration(milliseconds: 1500));
      await client.auth.verifyOtp(email: email, otp: otp);
    } on VaneStackException catch (e) {
      setState(() {
        loading = false;
        error = e.message;
      });
    } catch (e) {
      setState(() {
        loading = false;
        error = 'An unexpected error occurred.';
      });
    }
  }

  @override
  Component build(BuildContext context) {
    return div(classes: 'min-h-screen bg-background flex flex-col', [
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
          div(classes: 'p-6 bg-card rounded-2xl border border-border shadow-lg text-center', [
            if (loading) ...[
              h2(classes: 'font-display text-xl font-bold mb-2', [Component.text('Signing you in...')]),
              p(classes: 'text-muted-foreground text-sm mb-6', [
                Component.text('Please wait while we verify your link.'),
              ]),
              div(classes: 'flex justify-center py-4', [
                const ProgressIndicator(),
              ]),
            ] else if (error != null) ...[
              // Error icon
              div(
                classes: 'w-12 h-12 mx-auto mb-4 rounded-full bg-red-500/10 flex items-center justify-center',
                [i(classes: 'icon-x text-red-500 text-lg', [])],
              ),
              h2(classes: 'font-display text-xl font-bold mb-2', [Component.text('Login Failed')]),
              p(classes: 'text-destructive text-sm mb-6', [Component.text(error!)]),
              a(
                classes:
                    'w-full flex items-center justify-center gap-2 px-6 py-3 bg-foreground text-background rounded-xl font-semibold hover:opacity-90 transition-opacity duration-200',
                href: '/_/',
                [Component.text('Back to Login')],
              ),
            ],
          ]),
        ]),
      ]),
    ]);
  }
}
