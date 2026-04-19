import 'dart:io';

import 'package:vanestack/src/database/database.dart';
import 'package:vanestack/src/server.dart';
import 'package:vanestack/src/services/context.dart';
import 'package:vanestack/src/services/settings_service.dart';
import 'package:vanestack/src/utils/auth.dart';
import 'package:vanestack/src/utils/env.dart';
import 'package:vanestack_common/vanestack_common.dart';
import 'package:drift/drift.dart' show driftRuntimeOptions;
import 'package:drift/native.dart';
import 'package:test/test.dart';

import 'mock_server.dart';
import 'test_utils.dart';

void main() {
  driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;
  silenceTestLogs();

  group('SettingsService Unit Tests', () {
    late AppDatabase database;
    late Environment env;
    late ServiceContext context;
    late SettingsService settingsService;

    setUp(() async {
      env = Environment(port: 0);
      database = AppDatabase(NativeDatabase.memory(setup: AppDatabase.setup));
      context = (database: database, env: env, realtime: null, hooks: null, collectionsCache: null);
      settingsService = SettingsService(context);
    });

    tearDown(() async {
      await database.close();
    });

    group('get()', () {
      test('creates default settings if none exist', () async {
        final settings = await settingsService.get();

        expect(settings, isNotNull);
        expect(settings.appName, isNotEmpty);
      });

      test('returns existing settings if they exist', () async {
        // Create initial settings
        await settingsService.update(appName: 'Test App');

        // Get should return the same settings
        final settings = await settingsService.get();

        expect(settings.appName, 'Test App');
      });
    });

    group('update()', () {
      test('updates app name', () async {
        final settings = await settingsService.update(appName: 'My App');

        expect(settings.appName, 'My App');
      });

      test('updates site URL', () async {
        final settings = await settingsService.update(
          siteUrl: 'https://example.com',
        );

        expect(settings.siteUrl, 'https://example.com');
      });

      test('updates redirect URLs', () async {
        final settings = await settingsService.update(
          redirectUrls: ['https://app.example.com', 'https://dev.example.com'],
        );

        expect(settings.redirectUrls, contains('https://app.example.com'));
        expect(settings.redirectUrls, contains('https://dev.example.com'));
      });

      test('updates S3 settings', () async {
        final s3Settings = S3Settings(
          enabled: true,
          bucket: 'my-bucket',
          region: 'us-east-1',
          accessKey: 'AKIAIOSFODNN7EXAMPLE',
          secretKey: 'wJalrXUtnFEMI/K7MDENG/bPxRfiCYEXAMPLEKEY',
          endpoint: 'https://s3.amazonaws.com',
        );

        final settings = await settingsService.update(s3: s3Settings);

        expect(settings.s3, isNotNull);
        expect(settings.s3!.bucket, 'my-bucket');
        expect(settings.s3!.region, 'us-east-1');
        expect(settings.s3!.enabled, true);
      });

      test('updates mail settings', () async {
        final mailSettings = MailSettings(
          smtpServer: 'smtp.example.com',
          smtpPort: 587,
          username: 'user@example.com',
          password: 'password',
          fromAddress: 'noreply@example.com',
          fromName: 'My App',
        );

        final settings = await settingsService.update(mail: mailSettings);

        expect(settings.mail, isNotNull);
        expect(settings.mail!.smtpServer, 'smtp.example.com');
        expect(settings.mail!.smtpPort, 587);
      });

      test('updates OAuth providers', () async {
        final providers = OAuthProviderList(
          google: OAuthProvider(
            enabled: true,
            clientId: 'google-client-id',
            clientSecret: 'google-client-secret',
          ),
        );

        final settings = await settingsService.update(
          oauthProviders: providers,
        );

        expect(settings.oauthProviders.google, isNotNull);
        expect(settings.oauthProviders.google!.enabled, true);
        expect(settings.oauthProviders.google!.clientId, 'google-client-id');
      });

      test('creates settings if none exist when updating', () async {
        // Update without calling get() first
        final settings = await settingsService.update(
          appName: 'New App',
          siteUrl: 'https://newapp.com',
        );

        expect(settings.appName, 'New App');
        expect(settings.siteUrl, 'https://newapp.com');
      });
    });

    group('testS3Connection()', () {
      test('throws if S3 not configured', () async {
        // Create settings without S3
        await settingsService.update(appName: 'Test');

        expect(
          () => settingsService.testS3Connection(),
          throwsA(
            isA<VaneStackException>().having(
              (e) => e.message,
              'message',
              contains('S3 settings not configured'),
            ),
          ),
        );
      });
    });

    group('generateAppleClientSecret()', () {
      test('throws if clientId is empty', () {
        expect(
          () => settingsService.generateAppleClientSecret(
            clientId: '',
            teamId: 'team123',
            keyId: 'key123',
            privateKey: 'privatekey',
            duration: 3600,
          ),
          throwsA(
            isA<VaneStackException>().having(
              (e) => e.message,
              'message',
              contains('All fields are required'),
            ),
          ),
        );
      });

      test('throws if teamId is empty', () {
        expect(
          () => settingsService.generateAppleClientSecret(
            clientId: 'client123',
            teamId: '',
            keyId: 'key123',
            privateKey: 'privatekey',
            duration: 3600,
          ),
          throwsA(
            isA<VaneStackException>().having(
              (e) => e.message,
              'message',
              contains('All fields are required'),
            ),
          ),
        );
      });

      test('throws if keyId is empty', () {
        expect(
          () => settingsService.generateAppleClientSecret(
            clientId: 'client123',
            teamId: 'team123',
            keyId: '',
            privateKey: 'privatekey',
            duration: 3600,
          ),
          throwsA(
            isA<VaneStackException>().having(
              (e) => e.message,
              'message',
              contains('All fields are required'),
            ),
          ),
        );
      });

      test('throws if privateKey is empty', () {
        expect(
          () => settingsService.generateAppleClientSecret(
            clientId: 'client123',
            teamId: 'team123',
            keyId: 'key123',
            privateKey: '',
            duration: 3600,
          ),
          throwsA(
            isA<VaneStackException>().having(
              (e) => e.message,
              'message',
              contains('All fields are required'),
            ),
          ),
        );
      });

      test('throws if duration is zero', () {
        expect(
          () => settingsService.generateAppleClientSecret(
            clientId: 'client123',
            teamId: 'team123',
            keyId: 'key123',
            privateKey: 'privatekey',
            duration: 0,
          ),
          throwsA(
            isA<VaneStackException>().having(
              (e) => e.message,
              'message',
              contains('Duration must be a positive integer'),
            ),
          ),
        );
      });

      test('throws if duration is negative', () {
        expect(
          () => settingsService.generateAppleClientSecret(
            clientId: 'client123',
            teamId: 'team123',
            keyId: 'key123',
            privateKey: 'privatekey',
            duration: -100,
          ),
          throwsA(
            isA<VaneStackException>().having(
              (e) => e.message,
              'message',
              contains('Duration must be a positive integer'),
            ),
          ),
        );
      });

      test('throws with invalid private key format', () {
        expect(
          () => settingsService.generateAppleClientSecret(
            clientId: 'client123',
            teamId: 'team123',
            keyId: 'key123',
            privateKey: 'invalid-key-format',
            duration: 3600,
          ),
          throwsA(
            isA<VaneStackException>().having(
              (e) => e.message,
              'message',
              contains('Failed to generate client secret'),
            ),
          ),
        );
      });
    });
  });

  group('Settings HTTP Endpoints', () {
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

      final jwt = AuthUtils.generateJwt(
        userId: 'test_user',
        jwtSecret: env.jwtSecret,
        superuser: true,
      );

      client = JsonHttpClient(
        '127.0.0.1',
        port,
        defaultHeaders: {HttpHeaders.authorizationHeader: 'Bearer $jwt'},
      );
    });

    tearDown(() async {
      client.close();
      database.close();
      await server.stop();
    });

    test('GET /v1/settings returns settings', () async {
      final res = await client.get('/v1/settings');

      expect(res.status, 200);
      expect(res.json!['app_name'], isNotNull);
    });

    test('PATCH /v1/settings updates settings', () async {
      final res = await client.patch(
        '/v1/settings',
        body: {
          'appName': 'Updated App Name',
          'siteUrl': 'https://myapp.example.com',
        },
      );

      expect(res.status, 200);
      // Response contains the updated settings - check the JSON has keys
      expect(res.json, isNotNull);
    });

    test('PATCH /v1/settings accepts valid request', () async {
      final res = await client.patch(
        '/v1/settings',
        body: {
          'appName': 'Test App',
        },
      );

      expect(res.status, 200);
    });

    test('requires superuser for settings access', () async {
      // Create a non-superuser JWT
      final nonSuperuserJwt = AuthUtils.generateJwt(
        userId: 'regular_user',
        jwtSecret: env.jwtSecret,
        superuser: false,
      );

      final nonSuperuserClient = JsonHttpClient(
        '127.0.0.1',
        env.port,
        defaultHeaders: {
          HttpHeaders.authorizationHeader: 'Bearer $nonSuperuserJwt',
        },
      );

      final res = await nonSuperuserClient.get('/v1/settings');

      expect(res.status, 403);

      nonSuperuserClient.close();
    });
  });
}
