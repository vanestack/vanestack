import 'package:vanestack/src/database/database.dart';
import 'package:vanestack/src/server.dart';
import 'package:vanestack/src/utils/env.dart';
import 'package:vanestack_common/vanestack_common.dart';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:test/test.dart';

import 'mock_server.dart';
import 'test_utils.dart';

void main() {
  late Environment env;
  late AppDatabase database;
  late JsonHttpClient client;
  late VaneStackServer server;
  late int port;

  setUp(() async {
    port = await findFreePort();
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

  group('OAuth2 Endpoint', () {
    test('returns error when provider is not configured', () async {
      final res = await client.post('/v1/auth/oauth2/google');

      expect(res.status, 500);
      expect(res.json?['error']['message'], contains('not configured'));
    });

    test('returns error when provider is disabled', () async {
      // Configure Google provider but disable it
      await database.appSettings.update().write(
        AppSettingsCompanion(
          siteUrl: Value('http://localhost:$port'),
          oauthProviders: Value(
            OAuthProviderList(
              google: OAuthProvider(
                clientId: 'test-client-id',
                clientSecret: 'test-secret',
                enabled: false,
              ),
            ),
          ),
        ),
      );

      final res = await client.post('/v1/auth/oauth2/google');

      expect(res.status, 500);
      expect(res.json?['error']['message'], contains('disabled'));
    });

    test('returns authorization URL and stores state in database', () async {
      // Configure Google provider
      await database.appSettings.update().write(
        AppSettingsCompanion(
          siteUrl: Value('http://localhost:$port'),
          oauthProviders: Value(
            OAuthProviderList(
              google: OAuthProvider(
                clientId: 'test-client-id',
                clientSecret: 'test-secret',
                enabled: true,
              ),
            ),
          ),
        ),
      );

      final res = await client.post('/v1/auth/oauth2/google');

      expect(res.status, 200);

      // Parse the returned URL
      final authUrl = Uri.parse(res.body.replaceAll('"', ''));
      expect(authUrl.host, 'accounts.google.com');
      expect(authUrl.queryParameters['client_id'], 'test-client-id');
      expect(
        authUrl.queryParameters['redirect_uri'],
        'http://localhost:$port/v1/auth/oauth2/google/callback',
      );
      expect(authUrl.queryParameters['state'], isNotEmpty);

      // Verify state was stored in database
      final states = await database.oauthStates.select().get();
      expect(states.length, 1);
      expect(states.first.provider, 'google');
      expect(states.first.state, authUrl.queryParameters['state']);
    });

    test('works with multiple providers', () async {
      await database.appSettings.update().write(
        AppSettingsCompanion(
          siteUrl: Value('http://localhost:$port'),
          oauthProviders: Value(
            OAuthProviderList(
              google: OAuthProvider(
                clientId: 'google-client-id',
                clientSecret: 'google-secret',
              ),
              github: OAuthProvider(
                clientId: 'github-client-id',
                clientSecret: 'github-secret',
              ),
            ),
          ),
        ),
      );

      final googleRes = await client.post('/v1/auth/oauth2/google');
      final githubRes = await client.post('/v1/auth/oauth2/github');

      expect(googleRes.status, 200);
      expect(githubRes.status, 200);

      final googleUrl = Uri.parse(googleRes.body.replaceAll('"', ''));
      final githubUrl = Uri.parse(githubRes.body.replaceAll('"', ''));

      expect(googleUrl.host, 'accounts.google.com');
      expect(githubUrl.host, 'github.com');

      // Verify both states were stored
      final states = await database.oauthStates.select().get();
      expect(states.length, 2);
    });
  });

  group('OAuth2 Callback', () {
    test('returns error when code is missing', () async {
      final res = await client.get(
        '/v1/auth/oauth2/google/callback',
        query: {'state': 'some-state'},
      );

      expect(res.status, 400);
      expect(res.json?['error']['message'], contains('Missing code'));
    });

    test('returns error when state is missing', () async {
      final res = await client.get(
        '/v1/auth/oauth2/google/callback',
        query: {'code': 'some-code'},
      );

      expect(res.status, 400);
      expect(res.json?['error']['message'], contains('Missing state'));
    });

    test('returns error for invalid state', () async {
      await database.appSettings.update().write(
        AppSettingsCompanion(
          siteUrl: Value('http://localhost:$port'),
          oauthProviders: Value(
            OAuthProviderList(
              google: OAuthProvider(
                clientId: 'test-client-id',
                clientSecret: 'test-secret',
              ),
            ),
          ),
        ),
      );

      final res = await client.get(
        '/v1/auth/oauth2/google/callback',
        query: {'code': 'some-code', 'state': 'invalid-state'},
      );

      expect(res.status, 400);
      expect(
        res.json?['error']['message'],
        contains('Invalid or expired state'),
      );
    });

    test('returns error for expired state', () async {
      await database.appSettings.update().write(
        AppSettingsCompanion(
          siteUrl: Value('http://localhost:$port'),
          oauthProviders: Value(
            OAuthProviderList(
              google: OAuthProvider(
                clientId: 'test-client-id',
                clientSecret: 'test-secret',
              ),
            ),
          ),
        ),
      );

      // Insert an expired state
      await database.oauthStates.insertOne(
        OauthStatesCompanion.insert(
          state: 'expired-state',
          provider: 'google',
          expiresAt: Value(DateTime.now().subtract(Duration(minutes: 1))),
          redirectUrl: 'http://localhost:$port/welcome',
        ),
      );

      final res = await client.get(
        '/v1/auth/oauth2/google/callback',
        query: {'code': 'some-code', 'state': 'expired-state'},
      );

      expect(res.status, 400);
      expect(
        res.json?['error']['message'],
        contains('Invalid or expired state'),
      );
    });

    test('state can only be used once', () async {
      await database.appSettings.update().write(
        AppSettingsCompanion(
          siteUrl: Value('http://localhost:$port'),
          oauthProviders: Value(
            OAuthProviderList(
              google: OAuthProvider(
                clientId: 'test-client-id',
                clientSecret: 'test-secret',
              ),
            ),
          ),
        ),
      );

      // Insert a valid state
      await database.oauthStates.insertOne(
        OauthStatesCompanion.insert(
          state: 'valid-state',
          provider: 'google',
          redirectUrl: 'http://localhost:$port/welcome',
        ),
      );

      // First attempt - will fail at token exchange (external provider),
      // but state should be consumed
      await client.get(
        '/v1/auth/oauth2/google/callback',
        query: {'code': 'some-code', 'state': 'valid-state'},
      );

      // Second attempt should fail with invalid state
      final res2 = await client.get(
        '/v1/auth/oauth2/google/callback',
        query: {'code': 'some-code', 'state': 'valid-state'},
      );

      expect(res2.status, 400);
      expect(
        res2.json?['error']['message'],
        contains('Invalid or expired state'),
      );
    });
  });
}
