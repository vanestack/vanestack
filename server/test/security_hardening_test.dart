import 'dart:io';

import 'package:vanestack/src/database/database.dart';
import 'package:vanestack/src/server.dart';
import 'package:vanestack/src/services/auth_service.dart';
import 'package:vanestack/src/services/collections_service.dart';
import 'package:vanestack/src/services/context.dart';
import 'package:vanestack/src/services/logs_service.dart';
import 'package:vanestack/src/utils/auth.dart';
import 'package:vanestack/src/utils/env.dart';
import 'package:vanestack/src/utils/logger.dart';
import 'package:vanestack_common/vanestack_common.dart';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:test/test.dart';

import 'mock_server.dart';
import 'test_utils.dart';

void main() {
  driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;
  silenceTestLogs();

  group('Rate Limiting', () {
    late Environment env;
    late AppDatabase database;
    late JsonHttpClient client;
    late VaneStackServer server;

    setUp(() async {
      final port = await findFreePort();
      // Low limit for testing: 3 requests per 60s window
      env = Environment(
        port: port,
        rateLimitMax: 3,
        rateLimitWindowSeconds: 60,
      );
      database = AppDatabase(NativeDatabase.memory(setup: AppDatabase.setup));
      server = MockServer(db: database, env: env);
      await server.start();
      client = JsonHttpClient('127.0.0.1', port);
    });

    tearDown(() async {
      client.close();
      configureLogger(clearDatabase: true);
      database.close();
      await server.stop();
    });

    test('allows requests under the limit', () async {
      for (var i = 0; i < 3; i++) {
        final res = await client.post(
          '/v1/auth/sign-in-email-password',
          body: {'email': 'test@example.com', 'password': 'Secur3T3st!ng'},
        );
        // Should get a real response (not 429)
        expect(res.status, isNot(429));
      }
    });

    test('returns 429 when limit is exceeded on auth endpoints', () async {
      // Exhaust the limit
      for (var i = 0; i < 3; i++) {
        await client.post(
          '/v1/auth/sign-in-email-password',
          body: {'email': 'test$i@example.com', 'password': 'Secur3T3st!ng'},
        );
      }

      // Next request should be rate limited
      final res = await client.post(
        '/v1/auth/sign-in-email-password',
        body: {'email': 'extra@example.com', 'password': 'Secur3T3st!ng'},
      );

      expect(res.status, 429);
      expect(res.json?['error'], contains('Too many requests'));
    });

    test('resets rate limit after window expires', () async {
      // Use a very short window (1 second)
      final shortPort = await findFreePort();
      final shortEnv = Environment(
        port: shortPort,
        rateLimitMax: 2,
        rateLimitWindowSeconds: 1,
      );
      final shortDb =
          AppDatabase(NativeDatabase.memory(setup: AppDatabase.setup));
      final shortServer = MockServer(db: shortDb, env: shortEnv);
      await shortServer.start();
      final shortClient = JsonHttpClient('127.0.0.1', shortPort);

      try {
        // Exhaust the limit
        for (var i = 0; i < 2; i++) {
          await shortClient.post(
            '/v1/auth/sign-in-email-password',
            body: {'email': 'evict$i@example.com', 'password': 'Secur3T3st!ng'},
          );
        }

        // Should be rate limited
        var res = await shortClient.post(
          '/v1/auth/sign-in-email-password',
          body: {'email': 'evict@example.com', 'password': 'Secur3T3st!ng'},
        );
        expect(res.status, 429);

        // Wait for window to expire
        await Future.delayed(const Duration(seconds: 2));

        // Should be allowed again (stale entries evicted)
        res = await shortClient.post(
          '/v1/auth/sign-in-email-password',
          body: {'email': 'evict@example.com', 'password': 'Secur3T3st!ng'},
        );
        expect(res.status, isNot(429));
      } finally {
        shortClient.close();
        shortDb.close();
        await shortServer.stop();
      }
    });

    test('does not rate-limit non-auth endpoints', () async {
      final jwt = AuthUtils.generateJwt(
        userId: 'test_user',
        jwtSecret: env.jwtSecret,
        superuser: true,
      );

      final authedClient = JsonHttpClient(
        '127.0.0.1',
        env.port,
        defaultHeaders: {HttpHeaders.authorizationHeader: 'Bearer $jwt'},
      );

      try {
        // Make many requests to a non-auth endpoint
        for (var i = 0; i < 10; i++) {
          final res = await authedClient.get('/health');
          expect(res.status, 200);
        }
      } finally {
        authedClient.close();
      }
    });
  });

  group('Health Endpoint', () {
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
      configureLogger(clearDatabase: true);
      database.close();
      await server.stop();
    });

    test('returns 200 ok', () async {
      final res = await client.get('/health');
      expect(res.json?['status'], equals('ok'));
      expect(res.status, 200);
    });
  });

  group('Invalid JWT Rejection', () {
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
      configureLogger(clearDatabase: true);
      database.close();
      await server.stop();
    });

    test('rejects JWT signed with wrong secret', () async {
      final badJwt = AuthUtils.generateJwt(
        userId: 'hacker',
        jwtSecret: 'wrong_secret_key',
        superuser: true,
      );

      final res = await client.get('/v1/logs', bearer: badJwt);
      expect(res.status, 401);
    });

    test('allows requests without any token as guest', () async {
      // Guest requests should pass through (endpoints decide access)
      final res = await client.get('/health');
      expect(res.status, 200);
    });

    test('allows opaque tokens to pass through as guest', () async {
      // Opaque tokens (like refresh tokens) should not be rejected
      final res = await client.get(
        '/v1/auth/refresh',
        bearer: 'opaque-refresh-token',
      );
      // Should get a business logic error (400), not a JWT error (401)
      expect(res.status, 400);
    });
  });

  group('OTP Replay Prevention', () {
    late AppDatabase database;
    late Environment env;
    late ServiceContext context;
    late AuthService authService;

    setUp(() async {
      env = Environment(port: 0);
      database = AppDatabase(NativeDatabase.memory(setup: AppDatabase.setup));
      context = (database: database, env: env, realtime: null, hooks: null, collectionsCache: null);
      authService = AuthService(context);
    });

    tearDown(() async {
      configureLogger(clearDatabase: true);
      await database.close();
    });

    test('OTP cannot be used twice', () async {
      // Insert a valid OTP directly
      await database.otps.insertOne(
        OtpsCompanion.insert(email: 'otp-replay@example.com', otp: 'ABC123'),
      );

      // First use should succeed
      final result = await authService.verifyOtp(
        email: 'otp-replay@example.com',
        otp: 'ABC123',
      );
      expect(result.accessToken, isNotEmpty);

      // Second use should fail
      expect(
        () => authService.verifyOtp(
          email: 'otp-replay@example.com',
          otp: 'ABC123',
        ),
        throwsA(
          isA<VaneStackException>().having(
            (e) => e.message,
            'message',
            contains('Invalid OTP'),
          ),
        ),
      );
    });

    test(
      'OTP row is deleted from database after successful verification',
      () async {
        await database.otps.insertOne(
          OtpsCompanion.insert(email: 'otp-delete@example.com', otp: 'DEF456'),
        );

        await authService.verifyOtp(
          email: 'otp-delete@example.com',
          otp: 'DEF456',
        );

        // Verify OTP row was deleted
        final remaining = await database.otps.select().get();
        expect(remaining, isEmpty);
      },
    );
  });

  group('Refresh Token Invalidation', () {
    late AppDatabase database;
    late Environment env;
    late ServiceContext context;
    late AuthService authService;

    setUp(() async {
      env = Environment(port: 0);
      database = AppDatabase(NativeDatabase.memory(setup: AppDatabase.setup));
      context = (database: database, env: env, realtime: null, hooks: null, collectionsCache: null);
      authService = AuthService(context);
    });

    tearDown(() async {
      configureLogger(clearDatabase: true);
      await database.close();
    });

    test('old refresh token is invalidated after refresh', () async {
      // Create a user
      final signIn = await authService.signInWithEmailAndPassword(
        email: 'refresh-test@example.com',
        password: 'Secur3T3st!ng',
      );

      // Refresh with the original token
      final refreshed = await authService.refreshToken(
        refreshToken: signIn.refreshToken,
      );
      expect(refreshed.accessToken, isNotEmpty);

      // Old refresh token should no longer work
      expect(
        () => authService.refreshToken(refreshToken: signIn.refreshToken),
        throwsA(
          isA<VaneStackException>().having(
            (e) => e.message,
            'message',
            contains('Invalid refresh token'),
          ),
        ),
      );
    });

    test('new refresh token works after refresh', () async {
      final signIn = await authService.signInWithEmailAndPassword(
        email: 'refresh-chain@example.com',
        password: 'Secur3T3st!ng',
      );

      final refreshed = await authService.refreshToken(
        refreshToken: signIn.refreshToken,
      );

      // New token should work
      final refreshed2 = await authService.refreshToken(
        refreshToken: refreshed.refreshToken,
      );
      expect(refreshed2.accessToken, isNotEmpty);
    });
  });

  group('Log Cleanup', () {
    late AppDatabase database;
    late Environment env;
    late ServiceContext context;
    late LogsService logsService;

    setUp(() async {
      env = Environment(port: 0);
      database = AppDatabase(NativeDatabase.memory(setup: AppDatabase.setup));
      context = (database: database, env: env, realtime: null, hooks: null, collectionsCache: null);
      logsService = LogsService(context);
    });

    tearDown(() async {
      configureLogger(clearDatabase: true);
      await database.close();
    });

    test('deletes logs older than retention period', () async {
      final now = DateTime.now();

      await database.logs.insertAll([
        // Old log (45 days ago)
        LogsCompanion.insert(
          level: LogLevel.info,
          source: LogSource.server,
          message: 'Old log entry',
          createdAt: Value(now.subtract(const Duration(days: 45))),
        ),
        // Recent log (5 days ago)
        LogsCompanion.insert(
          level: LogLevel.info,
          source: LogSource.server,
          message: 'Recent log entry',
          createdAt: Value(now.subtract(const Duration(days: 5))),
        ),
      ]);

      final deleted = await logsService.cleanup(retentionDays: 30);
      expect(deleted, 1);

      final remaining = await database.logs.select().get();
      expect(remaining, hasLength(1));
      expect(remaining.first.message, 'Recent log entry');
    });

    test('returns 0 when no logs to clean', () async {
      final deleted = await logsService.cleanup(retentionDays: 30);
      expect(deleted, 0);
    });

    test('returns 0 when retentionDays is 0', () async {
      await database.logs.insertOne(
        LogsCompanion.insert(
          level: LogLevel.info,
          source: LogSource.server,
          message: 'Test log entry',
          createdAt: Value(DateTime.now().subtract(const Duration(days: 100))),
        ),
      );

      final deleted = await logsService.cleanup(retentionDays: 0);
      expect(deleted, 0);

      // Log should still exist
      final remaining = await database.logs.select().get();
      expect(remaining, hasLength(1));
    });
  });

  group('Password Validation on Auto-Registration', () {
    late AppDatabase database;
    late Environment env;
    late ServiceContext context;
    late AuthService authService;

    setUp(() async {
      env = Environment(port: 0);
      database = AppDatabase(NativeDatabase.memory(setup: AppDatabase.setup));
      context = (database: database, env: env, realtime: null, hooks: null, collectionsCache: null);
      authService = AuthService(context);
    });

    tearDown(() async {
      configureLogger(clearDatabase: true);
      await database.close();
    });

    test('rejects weak password on new user registration', () async {
      expect(
        () => authService.signInWithEmailAndPassword(
          email: 'new@example.com',
          password: 'weak',
        ),
        throwsA(
          isA<VaneStackException>().having(
            (e) => e.message,
            'message',
            contains('at least'),
          ),
        ),
      );
    });

    test('rejects password without special characters', () async {
      expect(
        () => authService.signInWithEmailAndPassword(
          email: 'new@example.com',
          password: 'NoSpecial1A',
        ),
        throwsA(isA<VaneStackException>()),
      );
    });

    test('does not validate password on existing user sign-in', () async {
      // Register with strong password
      await authService.signInWithEmailAndPassword(
        email: 'existing@example.com',
        password: 'Str0ng_T3st!',
      );

      // Sign in again — should not re-validate password strength
      final result = await authService.signInWithEmailAndPassword(
        email: 'existing@example.com',
        password: 'Str0ng_T3st!',
      );
      expect(result.accessToken, isNotEmpty);
    });
  });

  group('DDL Sanitization', () {
    late AppDatabase database;
    late Environment env;
    late ServiceContext context;
    late CollectionsService collectionsService;

    setUp(() async {
      env = Environment(port: 0);
      database = AppDatabase(NativeDatabase.memory(setup: AppDatabase.setup));
      context = (database: database, env: env, realtime: null, hooks: null, collectionsCache: null);
      collectionsService = CollectionsService(context);
    });

    tearDown(() async {
      configureLogger(clearDatabase: true);
      await database.close();
    });

    test('rejects invalid foreign key onDelete action', () async {
      expect(
        () => collectionsService.createBase(
          name: 'bad_fk',
          attributes: [
            TextAttribute(
              name: 'ref_id',
              foreignKey: ForeignKey(
                table: 'other',
                column: 'id',
                onDelete: 'DROP TABLE other; --',
              ),
            ),
          ],
        ),
        throwsA(
          isA<VaneStackException>().having(
            (e) => e.message,
            'message',
            contains('Invalid foreign key'),
          ),
        ),
      );
    });

    test('accepts valid foreign key actions', () async {
      // Create the referenced table first
      await collectionsService.createBase(
        name: 'parent_table',
        attributes: [TextAttribute(name: 'name')],
      );

      // This should succeed with a valid action
      final collection = await collectionsService.createBase(
        name: 'child_table',
        attributes: [
          TextAttribute(
            name: 'parent_id',
            foreignKey: ForeignKey(
              table: 'parent_table',
              column: 'id',
              onDelete: 'CASCADE',
              onUpdate: 'SET NULL',
            ),
          ),
        ],
      );
      expect(collection.name, 'child_table');
    });

    test('rejects check constraint with dangerous SQL', () async {
      expect(
        () => collectionsService.createBase(
          name: 'bad_check',
          attributes: [
            IntAttribute(
              name: 'val',
              checkConstraint: 'val > 0; DROP TABLE users',
            ),
          ],
        ),
        throwsA(
          isA<VaneStackException>().having(
            (e) => e.message,
            'message',
            contains('disallowed characters'),
          ),
        ),
      );
    });

    test('rejects check constraint with DROP keyword', () async {
      expect(
        () => collectionsService.createBase(
          name: 'bad_check2',
          attributes: [
            IntAttribute(name: 'val', checkConstraint: 'val > 0 AND DROP'),
          ],
        ),
        throwsA(
          isA<VaneStackException>().having(
            (e) => e.message,
            'message',
            contains('DROP'),
          ),
        ),
      );
    });

    test('accepts valid check constraints', () async {
      final collection = await collectionsService.createBase(
        name: 'valid_checks',
        attributes: [
          IntAttribute(name: 'quantity', checkConstraint: 'quantity >= 0'),
          TextAttribute(name: 'email', checkConstraint: "email LIKE '%@%'"),
        ],
      );
      expect(collection.name, 'valid_checks');
    });

    test('escapes single quotes in default values', () async {
      final collection = await collectionsService.createBase(
        name: 'quote_test',
        attributes: [
          TextAttribute(name: 'greeting', defaultValue: "it's a test"),
        ],
      );
      expect(collection.name, 'quote_test');

      // Verify the table was created and a row can be inserted
      await database.customInsert('INSERT INTO "quote_test" DEFAULT VALUES');
      final rows = await database
          .customSelect('SELECT greeting FROM "quote_test"')
          .get();
      expect(rows.first.read<String>('greeting'), "it's a test");
    });
  });

  group('viewQuery Hardening', () {
    late AppDatabase database;
    late Environment env;
    late ServiceContext context;
    late CollectionsService collectionsService;

    setUp(() async {
      env = Environment(port: 0);
      database = AppDatabase(NativeDatabase.memory(setup: AppDatabase.setup));
      context = (database: database, env: env, realtime: null, hooks: null, collectionsCache: null);
      collectionsService = CollectionsService(context);

      // Create a base table to reference in views
      await collectionsService.createBase(
        name: 'items',
        attributes: [TextAttribute(name: 'name')],
      );
    });

    tearDown(() async {
      configureLogger(clearDatabase: true);
      await database.close();
    });

    test('rejects ATTACH in view query', () async {
      expect(
        () => collectionsService.createView(
          name: 'bad_view',
          viewQuery: "SELECT id FROM items; ATTACH DATABASE 'x' AS y",
        ),
        throwsA(isA<VaneStackException>()),
      );
    });

    test('rejects PRAGMA in view query', () async {
      expect(
        () => collectionsService.createView(
          name: 'bad_view',
          viewQuery: 'PRAGMA table_info(items)',
        ),
        throwsA(isA<VaneStackException>()),
      );
    });

    test('rejects WITH in view query', () async {
      expect(
        () => collectionsService.createView(
          name: 'bad_view',
          viewQuery: 'WITH cte AS (SELECT 1) SELECT id FROM items',
        ),
        throwsA(isA<VaneStackException>()),
      );
    });
  });
}
