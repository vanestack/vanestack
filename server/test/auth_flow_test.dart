import 'package:vanestack/src/database/database.dart';

import 'package:vanestack/src/server.dart';
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

  group('Auth E2E', () {
    test('signup -> refresh -> logout -> refresh fail', () async {
      // 1) Sign In
      final email = 'alice@example.com';
      final password = 'Str0ngP@ssw0rd!';
      final signInRes = await client.post(
        '/v1/auth/sign-in-email-password',
        body: {'email': email, 'password': password},
      );

      expect(signInRes.status, anyOf(200, 201));
      final signInJson = signInRes.json!;
      final accessToken = signInJson['access_token'] as String;
      final refreshToken = signInJson['refresh_token'] as String;
      expect(accessToken, isNotEmpty);
      expect(refreshToken, isNotEmpty);
      expect(signInJson['user'], isA<Map>());

      // 2) Refresh
      // refresh may be GET /v1/auth/refresh using bearer or query ?token=
      final refreshRes = await client.get(
        '/v1/auth/refresh',
        bearer: refreshToken,
      );
      expect(refreshRes.status, 200);
      final refreshJson = refreshRes.json!;
      final access2 = refreshJson['access_token'] as String;
      final refresh2 = refreshJson['refresh_token'] as String;
      expect(access2, isNotEmpty);
      expect(refresh2, isNotEmpty);

      // 4) Logout with the second refresh token
      final logoutRes = await client.del('/v1/auth/logout', bearer: access2);
      expect(logoutRes.status, anyOf(200, 204));

      // 5) Refresh should fail after logout
      final refreshFail = await client.get(
        '/v1/auth/refresh',
        bearer: refresh2,
      );
      expect(refreshFail.status, anyOf(400, 401, 403));
    });
  });
}
