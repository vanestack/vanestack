import 'dart:convert';

import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/find_locale.dart';
import 'package:intl/intl.dart';
import 'package:jaspr/jaspr.dart';
import 'package:jaspr/dom.dart';
import 'package:jaspr_riverpod/jaspr_riverpod.dart';
import 'package:jaspr_router/jaspr_router.dart';

import 'components/layout.dart';
import 'pages/app_settings.dart';
import 'pages/auth_settings.dart';
import 'pages/collections.dart';
import 'pages/home.dart';
import 'pages/login.dart';
import 'pages/logs.dart';
import 'pages/storage.dart';
import 'pages/forgot_password.dart';
import 'pages/magic_url.dart';
import 'pages/reset_password.dart';
import 'pages/mail_settings.dart';
import 'pages/profile_settings.dart';
import 'pages/s3_settings.dart';
import 'pages/settings.dart';
import 'pages/superusers_settings.dart';
import 'pages/users.dart';
import 'providers/client.dart';
import 'providers/user.dart';

class App extends StatefulComponent {
  const App({super.key});

  @override
  State<StatefulComponent> createState() => _AppState();
}

class _AppState extends State<App> {
  @override
  void initState() {
    super.initState();
    findSystemLocale().then((locale) {
      return initializeDateFormatting().then(
        (_) => Intl.defaultLocale = locale,
      );
    });
  }

  @override
  Component build(BuildContext context) {
    return div([
      Builder(
        builder: (context) {
          final user = context.watch(userProvider);
          return user.maybeWhen(
            orElse: () => Component.empty(),
            data: (user) {
              if (user == null) {
                return Router(
                  redirect: (context, state) {
                    if (state.location.contains('magic-url')) {
                      final queryParams = state.queryParams;

                      var query = '';
                      if (queryParams.isEmpty) {
                        return '/_/login';
                      }

                      final email = queryParams['email'];
                      if (email?.trim().isNotEmpty ?? false) {
                        query += 'email=${Uri.encodeComponent(email!)}';
                      }

                      final code = queryParams['otp'];
                      if (code?.trim().isNotEmpty ?? false) {
                        if (query.isNotEmpty) {
                          query += '&';
                        }
                        query += 'otp=${Uri.encodeComponent(code!)}';
                      }

                      return '/_/magic-url?$query';
                    }

                    if (state.location.contains('forgot-password')) {
                      return '/_/forgot-password';
                    }

                    if (state.location.contains('reset-password')) {
                      final token = state.queryParams['token'];
                      if (token != null && token.isNotEmpty) {
                        return '/_/reset-password?token=${Uri.encodeComponent(token)}';
                      }
                      return '/_/login';
                    }

                    return '/_/login';
                  },
                  routes: [
                    Route(
                      path: '/_/magic-url',
                      builder: (context, state) => MagicUrlPage(
                        email: state.queryParams['email'],
                        otp: state.queryParams['otp'],
                      ),
                    ),
                    Route(
                      path: '/_/forgot-password',
                      builder: (context, state) => const ForgotPasswordPage(),
                    ),
                    Route(
                      path: '/_/reset-password',
                      builder: (context, state) => const ResetPasswordPage(),
                    ),
                    Route(
                      path: '/_/login',
                      builder: (context, state) => const LoginPage(),
                    ),
                  ],
                );
              }

              final client = context.watch(clientProvider);
              if (!_isSuperUser(client.accessToken)) {
                return _UnauthorizedPage();
              }

              return Router(
                redirect: (context, state) {
                  if (state.location == '/' || state.location == '/login' || state.location.contains('magic-url')) {
                    return '/_/home';
                  }

                  if (!state.location.startsWith('/_')) {
                    final newLocation = '/_${state.location.startsWith('/') ? '' : '/'}${state.location}';
                    return newLocation;
                  }

                  return null;
                },
                routes: [
                  Route(
                    path: '/_/home',
                    builder: (context, state) => Layout(child: HomePage(), path: state.location),
                  ),
                  ShellRoute(
                    builder: (context, state, component) => Layout(child: component, path: state.location),
                    routes: [
                      Route(
                        path: '/_/collections',
                        builder: (context, state) => const CollectionsPage(),
                      ),
                      Route(
                        path: '/_/collections/:collection',
                        builder: (context, state) => CollectionsPage(
                          selectedCollection: state.params['collection'],
                        ),
                      ),
                    ],
                  ),
                  Route(
                    path: '/_/users',
                    builder: (context, state) => Layout(
                      child: const UsersPage(),
                      path: state.location,
                    ),
                  ),
                  ShellRoute(
                    builder: (context, state, component) => Layout(child: component, path: state.location),
                    routes: [
                      Route(
                        path: '/_/storage',
                        builder: (context, state) => const StoragePage(),
                      ),
                      Route(
                        path: '/_/storage/:bucket',
                        builder: (context, state) => StoragePage(
                          selectedBucket: state.params['bucket'],
                        ),
                      ),
                    ],
                  ),
                  Route(
                    path: '/_/logs',
                    builder: (context, state) => Layout(child: LogsPage(), path: state.location),
                  ),
                  Route(
                    path: '/_/profile',
                    builder: (context, state) => Layout(child: ProfileSettingsPage(), path: state.location),
                  ),
                  ShellRoute(
                    builder: (context, state, component) => Layout(
                      child: SettingsPage(
                        child: component,
                        path: state.location,
                      ),
                      path: state.location,
                    ),
                    routes: [
                      Route(
                        path: '/_/settings',
                        redirect: (context, state) => '/_/settings/application',
                      ),

                      Route(
                        path: '/_/settings/application',
                        builder: (context, state) => const ApplicationSettingsPage(),
                      ),
                      Route(
                        path: '/_/settings/auth',
                        builder: (context, state) => const AuthSettingsPage(),
                      ),
                      Route(
                        path: '/_/settings/storage',
                        builder: (context, state) => const S3SettingsPage(),
                      ),
                      Route(
                        path: '/_/settings/email',
                        builder: (context, state) => const MailSettingsPage(),
                      ),
                      Route(
                        path: '/_/settings/superusers',
                        builder: (context, state) => const SuperusersSettingsPage(),
                      ),
                    ],
                  ),
                ],
              );
            },
          );
        },
      ),

      div(id: 'toaster', classes: 'toaster', []),
    ]);
  }
}

/// Decodes the JWT access token and checks if superUser claim is true.
bool _isSuperUser(String? token) {
  if (token == null) return false;

  try {
    final parts = token.split('.');
    if (parts.length != 3) return false;

    final payload = parts[1];
    final normalized = base64Url.normalize(payload);
    final decoded = utf8.decode(base64Url.decode(normalized));
    final json = jsonDecode(decoded) as Map<String, dynamic>;

    return json['superUser'] == true;
  } catch (_) {
    return false;
  }
}

class _UnauthorizedPage extends StatelessComponent {
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
            // Shield icon
            div(
              classes: 'w-12 h-12 mx-auto mb-4 rounded-full bg-red-500/10 flex items-center justify-center',
              [i(classes: 'icon-shield-x text-red-500 text-lg', [])],
            ),
            h2(classes: 'font-display text-xl font-bold mb-2', [Component.text('Access Denied')]),
            p(classes: 'text-muted-foreground text-sm mb-6', [
              Component.text(
                'You do not have permission to access the admin dashboard. '
                'Please contact an administrator if you believe this is an error.',
              ),
            ]),
            button(
              classes:
                  'w-full flex items-center justify-center gap-2 px-6 py-3 bg-destructive text-destructive-foreground rounded-xl font-semibold hover:opacity-90 transition-opacity duration-200',
              type: ButtonType.button,
              onClick: () async {
                final client = context.read(clientProvider);
                await client.auth.logout();
              },
              [Component.text('Log Out')],
            ),
          ]),
        ]),
      ]),
    ]);
  }
}
