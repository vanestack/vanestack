import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:args/command_runner.dart';

import 'stdout.dart';

class LoginCommand extends Command {
  @override
  String get name => 'login';

  @override
  String get description => 'Authenticate with VaneStack cloud via GitHub.';

  LoginCommand() {
    argParser.addOption(
      'host',
      help: 'Cloud API URL.',
      defaultsTo: 'https://vanestack.dev',
    );
  }

  @override
  Future<void> run() async {
    final host = argResults!['host'] as String;

    // Start temporary local server to capture the callback
    final server = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
    final port = server.port;
    final callbackUrl = 'http://localhost:$port/callback';

    print(yellow('Waiting for GitHub authentication...'));

    // Build OAuth URL with CLI source info in state param
    final state = 'source:cli,redirect_uri:$callbackUrl';

    // Open browser — try platform-specific commands
    final oauthUrl = '$host/v1/auth/github?state=${Uri.encodeComponent(state)}';

    print('Opening browser to authenticate...');
    print('If the browser does not open, visit:\n  $oauthUrl');

    try {
      if (Platform.isMacOS) {
        await Process.run('open', [oauthUrl]);
      } else if (Platform.isLinux) {
        await Process.run('xdg-open', [oauthUrl]);
      } else if (Platform.isWindows) {
        await Process.run('start', [oauthUrl], runInShell: true);
      }
    } catch (_) {
      // Browser open failed — user can copy the URL
    }

    // Wait for the callback with the session token
    final completer = Completer<String?>();

    server.listen((request) async {
      if (request.uri.path == '/callback') {
        final token = request.uri.queryParameters['token'];

        if (token != null && token.isNotEmpty) {
          request.response
            ..statusCode = 200
            ..headers.contentType = ContentType.html
            ..write(_successPage);
          await request.response.close();
          completer.complete(token);
        } else {
          final error =
              request.uri.queryParameters['error'] ?? 'Unknown error';
          request.response
            ..statusCode = 400
            ..headers.contentType = ContentType.html
            ..write(_errorPage(error));
          await request.response.close();
          completer.complete(null);
        }
      } else {
        request.response
          ..statusCode = 404
          ..write('Not found');
        await request.response.close();
      }
    });

    // Wait up to 2 minutes for the callback
    final token = await completer.future.timeout(
      const Duration(minutes: 2),
      onTimeout: () {
        print(red('Authentication timed out.'));
        return null;
      },
    );

    await server.close();

    if (token == null) {
      print(red('Login failed.'));
      return;
    }

    // Save credentials
    final credDir = Directory('${Platform.environment['HOME']}/.vanestack');
    await credDir.create(recursive: true);

    final credFile = File('${credDir.path}/credentials.json');
    await credFile.writeAsString(
      const JsonEncoder.withIndent(
        '  ',
      ).convert({'host': host, 'token': token}),
    );

    print(green('Logged in successfully!'));
    print('Credentials saved to ${credFile.path}');
  }

  static const _successPage = '''
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>VaneStack — Authenticated</title>
  <link rel="preconnect" href="https://fonts.googleapis.com">
  <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
  <link href="https://fonts.googleapis.com/css2?family=Plus+Jakarta+Sans:wght@500;600;700;800&family=DM+Sans:wght@400;500&display=swap" rel="stylesheet">
  <style>
    *, *::before, *::after { box-sizing: border-box; margin: 0; padding: 0; }
    body {
      min-height: 100vh;
      display: flex;
      align-items: center;
      justify-content: center;
      background: linear-gradient(135deg, #1e3a5f 0%, #1e1b4b 40%, #2d1b4e 70%, #4a1942 100%);
      font-family: 'DM Sans', system-ui, sans-serif;
      color: #e2e8f0;
    }
    body::before {
      content: '';
      position: fixed;
      inset: 0;
      background-image:
        linear-gradient(rgba(255,255,255,0.4) 1px, transparent 1px),
        linear-gradient(90deg, rgba(255,255,255,0.4) 1px, transparent 1px);
      background-size: 48px 48px;
      opacity: 0.07;
      pointer-events: none;
    }
    .card {
      position: relative;
      max-width: 400px;
      width: 90%;
      padding: 2.5rem 2rem;
      background: rgba(15, 15, 25, 0.65);
      border: 1px solid rgba(255,255,255,0.08);
      border-radius: 1rem;
      backdrop-filter: blur(20px);
      text-align: center;
    }
    .icon {
      width: 56px;
      height: 56px;
      margin: 0 auto 1.25rem;
      border-radius: 50%;
      background: rgba(74, 222, 128, 0.12);
      display: flex;
      align-items: center;
      justify-content: center;
    }
    .icon svg { width: 28px; height: 28px; color: #4ade80; }
    h1 {
      font-family: 'Plus Jakarta Sans', system-ui, sans-serif;
      font-size: 1.5rem;
      font-weight: 700;
      margin-bottom: 0.5rem;
      color: #fff;
    }
    p { font-size: 0.9rem; color: rgba(226,232,240,0.55); line-height: 1.5; }
    .hint {
      margin-top: 1.5rem;
      padding-top: 1.25rem;
      border-top: 1px solid rgba(255,255,255,0.06);
      font-size: 0.8rem;
      color: rgba(226,232,240,0.35);
    }
    code {
      display: inline-block;
      margin-top: 0.25rem;
      padding: 0.15rem 0.5rem;
      background: rgba(255,255,255,0.06);
      border-radius: 0.35rem;
      font-family: 'Fira Code', monospace;
      font-size: 0.8rem;
      color: rgba(226,232,240,0.6);
    }
  </style>
</head>
<body>
  <div class="card">
    <div class="icon">
      <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke-width="2" stroke="currentColor">
        <path stroke-linecap="round" stroke-linejoin="round" d="M4.5 12.75l6 6 9-13.5"/>
      </svg>
    </div>
    <h1>You're in!</h1>
    <p>Authentication successful. You can close this tab and return to your terminal.</p>
    <div class="hint">
      Deploy your project with
      <br><code>vanestack deploy</code>
    </div>
  </div>
</body>
</html>
''';

  static String _errorPage(String error) => '''
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>VaneStack — Authentication Failed</title>
  <link rel="preconnect" href="https://fonts.googleapis.com">
  <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
  <link href="https://fonts.googleapis.com/css2?family=Plus+Jakarta+Sans:wght@500;600;700;800&family=DM+Sans:wght@400;500&display=swap" rel="stylesheet">
  <style>
    *, *::before, *::after { box-sizing: border-box; margin: 0; padding: 0; }
    body {
      min-height: 100vh;
      display: flex;
      align-items: center;
      justify-content: center;
      background: linear-gradient(135deg, #1e3a5f 0%, #1e1b4b 40%, #2d1b4e 70%, #4a1942 100%);
      font-family: 'DM Sans', system-ui, sans-serif;
      color: #e2e8f0;
    }
    body::before {
      content: '';
      position: fixed;
      inset: 0;
      background-image:
        linear-gradient(rgba(255,255,255,0.4) 1px, transparent 1px),
        linear-gradient(90deg, rgba(255,255,255,0.4) 1px, transparent 1px);
      background-size: 48px 48px;
      opacity: 0.07;
      pointer-events: none;
    }
    .card {
      position: relative;
      max-width: 400px;
      width: 90%;
      padding: 2.5rem 2rem;
      background: rgba(15, 15, 25, 0.65);
      border: 1px solid rgba(255,255,255,0.08);
      border-radius: 1rem;
      backdrop-filter: blur(20px);
      text-align: center;
    }
    .icon {
      width: 56px;
      height: 56px;
      margin: 0 auto 1.25rem;
      border-radius: 50%;
      background: rgba(239, 68, 68, 0.12);
      display: flex;
      align-items: center;
      justify-content: center;
    }
    .icon svg { width: 28px; height: 28px; color: #ef4444; }
    h1 {
      font-family: 'Plus Jakarta Sans', system-ui, sans-serif;
      font-size: 1.5rem;
      font-weight: 700;
      margin-bottom: 0.5rem;
      color: #fff;
    }
    p { font-size: 0.9rem; color: rgba(226,232,240,0.55); line-height: 1.5; }
    .error-detail {
      margin-top: 1rem;
      padding: 0.6rem 1rem;
      background: rgba(239, 68, 68, 0.08);
      border: 1px solid rgba(239, 68, 68, 0.15);
      border-radius: 0.5rem;
      font-size: 0.8rem;
      color: rgba(239, 68, 68, 0.8);
      font-family: 'Fira Code', monospace;
    }
    .hint {
      margin-top: 1.5rem;
      padding-top: 1.25rem;
      border-top: 1px solid rgba(255,255,255,0.06);
      font-size: 0.8rem;
      color: rgba(226,232,240,0.35);
    }
    code {
      padding: 0.15rem 0.5rem;
      background: rgba(255,255,255,0.06);
      border-radius: 0.35rem;
      font-family: 'Fira Code', monospace;
      font-size: 0.8rem;
      color: rgba(226,232,240,0.6);
    }
  </style>
</head>
<body>
  <div class="card">
    <div class="icon">
      <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke-width="2" stroke="currentColor">
        <path stroke-linecap="round" stroke-linejoin="round" d="M6 18L18 6M6 6l12 12"/>
      </svg>
    </div>
    <h1>Authentication failed</h1>
    <p>Something went wrong during sign-in.</p>
    <div class="error-detail">$error</div>
    <div class="hint">
      Try again with <code>vanestack login</code>
    </div>
  </div>
</body>
</html>
''';
}
