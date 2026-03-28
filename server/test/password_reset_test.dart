import 'package:vanestack/src/database/database.dart';
import 'package:vanestack/src/server.dart';
import 'package:vanestack/src/services/auth_service.dart';
import 'package:vanestack/src/services/context.dart';
import 'package:vanestack/src/utils/env.dart';

import 'package:drift/native.dart';

import 'package:test/test.dart';

import 'mock_server.dart';
import 'test_utils.dart';

void main() {
  late Environment env;
  late AppDatabase database;
  late JsonHttpClient client;
  late VaneStackServer server;

  setUp(() async {
    final port = await findFreePort();
    env = Environment(port: port);
    database = AppDatabase(NativeDatabase.memory(setup: AppDatabase.setup));
    server = MockServer(db: database, env: env);
    await server.start();
    client = JsonHttpClient('127.0.0.1', port);
  });

  tearDown(() async {
    client.close();
    database.close();
    await server.stop();
  });

  test('forgot-password -> reset-password -> login new password', () async {
    final email = 'bob@example.com';
    const oldPassword = 'OldP@ssw0rd123!';
    const newPassword = 'NewP@ssw0rd123!';

    // Create account via signup
    final signupRes = await client.post(
      '/v1/auth/sign-in-email-password',
      body: {'email': email, 'password': oldPassword},
    );

    expect(signupRes.status, anyOf(200, 201));

    // Create password reset token (bypasses email sending)
    final context = (database: database, env: env, realtime: null, hooks: null) as ServiceContext;
    final authService = AuthService(context);
    final token = await authService.createPasswordResetToken(email: email);
    expect(token, isNotEmpty);

    // Perform reset
    final resetRes = await client.post(
      '/v1/auth/reset-password',
      body: {'token': token, 'newPassword': newPassword},
    );
    expect(resetRes.status, 200);

    // Login with new password
    final loginRes = await client.post(
      '/v1/auth/sign-in-email-password',
      body: {'email': email, 'password': newPassword},
    );
    expect(loginRes.status, 200);
    expect(loginRes.json!['access_token'], isA<String>());
    expect(loginRes.json!['refresh_token'], isA<String>());
  });
}
