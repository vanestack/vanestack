import 'dart:convert';

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

  group('Sign-In with ID Token', () {
    test('returns error when provider is not configured', () async {
      final res = await client.post(
        '/v1/auth/sign-in-with-id-token',
        body: {'provider': 'google', 'idToken': 'fake.jwt.token'},
      );

      expect(res.status, 400);
      expect(res.json?['error']['message'], contains('not configured'));
    });

    test('returns error when provider is disabled', () async {
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

      final res = await client.post(
        '/v1/auth/sign-in-with-id-token',
        body: {'provider': 'google', 'idToken': 'fake.jwt.token'},
      );

      expect(res.status, 400);
      expect(res.json?['error']['message'], contains('disabled'));
      expect(
        res.json?['error']['code'],
        AuthErrorCode.providerDisabled.value,
      );
    });

    test('returns error for invalid token format (not 3 parts)', () async {
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

      final res = await client.post(
        '/v1/auth/sign-in-with-id-token',
        body: {'provider': 'google', 'idToken': 'not-a-valid-jwt'},
      );

      expect(res.status, 400);
      expect(res.json?['error']['message'], contains('Invalid token format'));
    });

    test('returns error when kid is missing from token header', () async {
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

      // Create a JWT with no kid in header
      final header = base64Url.encode(
        utf8.encode(jsonEncode({'alg': 'RS256'})),
      );
      final payload = base64Url.encode(
        utf8.encode(jsonEncode({'sub': '123', 'email': 'test@example.com'})),
      );
      final signature = base64Url.encode(utf8.encode('fake-signature'));
      final fakeToken = '$header.$payload.$signature';

      final res = await client.post(
        '/v1/auth/sign-in-with-id-token',
        body: {'provider': 'google', 'idToken': fakeToken},
      );

      expect(res.status, 400);
      expect(res.json?['error']['message'], contains('Missing key ID'));
    });

    test('returns error when public key not found for kid', () async {
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

      // Create a JWT with a non-existent kid
      final header = base64Url.encode(
        utf8.encode(jsonEncode({'alg': 'RS256', 'kid': 'non-existent-key-id'})),
      );
      final payload = base64Url.encode(
        utf8.encode(jsonEncode({'sub': '123', 'email': 'test@example.com'})),
      );
      final signature = base64Url.encode(utf8.encode('fake-signature'));
      final fakeToken = '$header.$payload.$signature';

      final res = await client.post(
        '/v1/auth/sign-in-with-id-token',
        body: {'provider': 'google', 'idToken': fakeToken},
      );

      expect(res.status, 401);
      expect(res.json?['error']['message'], contains('Public key not found'));
    });

    test('supports all three ID token providers', () async {
      await database.appSettings.update().write(
        AppSettingsCompanion(
          siteUrl: Value('http://localhost:$port'),
          oauthProviders: Value(
            OAuthProviderList(
              google: OAuthProvider(
                clientId: 'google-client-id',
                clientSecret: 'google-secret',
              ),
              apple: OAuthProvider(
                clientId: 'apple-client-id',
                clientSecret: 'apple-secret',
              ),
              facebook: OAuthProvider(
                clientId: 'facebook-client-id',
                clientSecret: 'facebook-secret',
              ),
            ),
          ),
        ),
      );

      // All providers should be reachable (will fail at JWKS fetch or signature
      // verification, but we're testing that the endpoint routes correctly)
      final header = base64Url.encode(
        utf8.encode(jsonEncode({'alg': 'RS256', 'kid': 'test-kid'})),
      );
      final payload = base64Url.encode(
        utf8.encode(jsonEncode({'sub': '123', 'email': 'test@example.com'})),
      );
      final signature = base64Url.encode(utf8.encode('fake'));
      final fakeToken = '$header.$payload.$signature';

      for (final provider in ['google', 'apple', 'facebook']) {
        final res = await client.post(
          '/v1/auth/sign-in-with-id-token',
          body: {'provider': provider, 'idToken': fakeToken},
        );

        // Should get past config validation and fail at key lookup
        expect(res.status, 401);
        expect(res.json?['error']['message'], contains('Public key not found'));
      }
    });
  });
}
