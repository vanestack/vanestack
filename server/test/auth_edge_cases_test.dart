import 'package:vanestack/src/database/database.dart';
import 'package:vanestack/src/server.dart';
import 'package:vanestack/src/services/auth_service.dart';
import 'package:vanestack/src/services/context.dart';
import 'package:vanestack/src/utils/env.dart';
import 'package:vanestack_common/vanestack_common.dart';
import 'package:drift/drift.dart' show driftRuntimeOptions, Value, TableStatements;
import 'package:drift/native.dart';
import 'package:test/test.dart';

import 'mock_server.dart';
import 'test_utils.dart';

void main() {
  driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;
  silenceTestLogs();

  group('AuthService Edge Cases', () {
    late AppDatabase database;
    late Environment env;
    late ServiceContext context;
    late AuthService authService;

    setUp(() async {
      env = Environment(port: 0);
      database = AppDatabase(NativeDatabase.memory(setup: AppDatabase.setup));
      context = (database: database, env: env, realtime: null, hooks: null);
      authService = AuthService(context);
    });

    tearDown(() async {
      await database.close();
    });

    group('signInWithEmailAndPassword', () {
      test('creates new user if not exists', () async {
        final result = await authService.signInWithEmailAndPassword(
          email: 'newuser@example.com',
          password: 'Secur3T3st!ng',
        );

        expect(result.user.email, 'newuser@example.com');
        expect(result.accessToken, isNotEmpty);
        expect(result.refreshToken, isNotEmpty);
      });

      test('normalizes email to lowercase', () async {
        final result = await authService.signInWithEmailAndPassword(
          email: 'NewUser@EXAMPLE.COM',
          password: 'Secur3T3st!ng',
        );

        expect(result.user.email, 'newuser@example.com');
      });

      test('trims whitespace from email', () async {
        final result = await authService.signInWithEmailAndPassword(
          email: '  user@example.com  ',
          password: 'Secur3T3st!ng',
        );

        expect(result.user.email, 'user@example.com');
      });

      test('throws if user exists but has no password', () async {
        // Create user without password (e.g., OAuth user)
        await database.users.insertOne(
          UsersCompanion.insert(
            id: 'user-id',
            email: 'oauthuser@example.com',
            // No passwordHash
          ),
        );

        expect(
          () => authService.signInWithEmailAndPassword(
            email: 'oauthuser@example.com',
            password: 'Secur3T3st!ng',
          ),
          throwsA(
            isA<VaneStackException>().having(
              (e) => e.message,
              'message',
              contains('not registered with password'),
            ),
          ),
        );
      });

      test('throws if password is incorrect', () async {
        // Create user with password
        await authService.signInWithEmailAndPassword(
          email: 'existing@example.com',
          password: 'C0rrect_T3st!',
        );

        expect(
          () => authService.signInWithEmailAndPassword(
            email: 'existing@example.com',
            password: 'Wr0ng_T3st!ng',
          ),
          throwsA(
            isA<VaneStackException>().having(
              (e) => e.message,
              'message',
              contains('Invalid password'),
            ),
          ),
        );
      });
    });

    group('refreshToken', () {
      test('throws if refresh token is empty', () async {
        expect(
          () => authService.refreshToken(refreshToken: ''),
          throwsA(
            isA<VaneStackException>().having(
              (e) => e.message,
              'message',
              contains('Missing refresh token'),
            ),
          ),
        );
      });

      test('throws if refresh token is invalid', () async {
        expect(
          () => authService.refreshToken(refreshToken: 'invalid-token'),
          throwsA(
            isA<VaneStackException>().having(
              (e) => e.message,
              'message',
              contains('Invalid refresh token'),
            ),
          ),
        );
      });

      test('throws if refresh token is expired', () async {
        // Create user and get tokens
        final result = await authService.signInWithEmailAndPassword(
          email: 'expired@example.com',
          password: 'Secur3T3st!ng',
        );

        // Manually expire the token
        await (database.refreshTokens.update()
              ..where((t) => t.refreshToken.equals(result.refreshToken)))
            .write(
              RefreshTokensCompanion(
                expiresAt: Value(
                  DateTime.now().subtract(const Duration(days: 1)),
                ),
              ),
            );

        expect(
          () => authService.refreshToken(refreshToken: result.refreshToken),
          throwsA(
            isA<VaneStackException>().having(
              (e) => e.message,
              'message',
              contains('expired'),
            ),
          ),
        );
      });

      test('throws if user is deleted after token was issued', () async {
        // Create user and get tokens
        final result = await authService.signInWithEmailAndPassword(
          email: 'deleted@example.com',
          password: 'Secur3T3st!ng',
        );

        // Delete the user
        await database.users.deleteWhere(
          (t) => t.email.equals('deleted@example.com'),
        );

        expect(
          () => authService.refreshToken(refreshToken: result.refreshToken),
          throwsA(
            isA<VaneStackException>().having(
              (e) => e.message,
              'message',
              contains('User not found'),
            ),
          ),
        );
      });

      test('successfully refreshes valid token', () async {
        // Create user and get tokens
        final result = await authService.signInWithEmailAndPassword(
          email: 'refresh@example.com',
          password: 'Secur3T3st!ng',
        );

        // Wait a moment to ensure different timestamp in new token
        await Future.delayed(const Duration(seconds: 1));

        // Refresh token
        final newResult = await authService.refreshToken(
          refreshToken: result.refreshToken,
        );

        expect(newResult.accessToken, isNotEmpty);
        expect(newResult.refreshToken, isNotEmpty);
        // New refresh token should be different
        expect(newResult.refreshToken, isNot(result.refreshToken));
      });
    });

    group('logout', () {
      test('throws if access token is empty', () async {
        expect(
          () => authService.logout(accessToken: ''),
          throwsA(
            isA<VaneStackException>().having(
              (e) => e.message,
              'message',
              contains('Missing access token'),
            ),
          ),
        );
      });

      test('throws if access token is invalid', () async {
        expect(
          () => authService.logout(accessToken: 'invalid-token'),
          throwsA(
            isA<VaneStackException>().having(
              (e) => e.message,
              'message',
              contains('Invalid access token'),
            ),
          ),
        );
      });

      test('successfully logs out valid user', () async {
        // Create user and get tokens
        final result = await authService.signInWithEmailAndPassword(
          email: 'logout@example.com',
          password: 'Secur3T3st!ng',
        );

        // Logout should succeed
        await authService.logout(accessToken: result.accessToken);

        // Refresh with old token should fail
        expect(
          () => authService.refreshToken(refreshToken: result.refreshToken),
          throwsA(isA<VaneStackException>()),
        );
      });
    });

    group('createPasswordResetToken', () {
      test('throws if user does not exist', () async {
        expect(
          () => authService.createPasswordResetToken(
            email: 'nonexistent@example.com',
          ),
          throwsA(
            isA<VaneStackException>().having(
              (e) => e.message,
              'message',
              contains('does not exist'),
            ),
          ),
        );
      });

      test('creates token for existing user', () async {
        // Create user
        await authService.signInWithEmailAndPassword(
          email: 'reset@example.com',
          password: 'Secur3T3st!ng',
        );

        // Create reset token
        final token = await authService.createPasswordResetToken(
          email: 'reset@example.com',
        );

        expect(token, isNotEmpty);
      });

      test('normalizes email', () async {
        // Create user
        await authService.signInWithEmailAndPassword(
          email: 'reset@example.com',
          password: 'Secur3T3st!ng',
        );

        // Create reset token with different casing
        final token = await authService.createPasswordResetToken(
          email: '  RESET@EXAMPLE.COM  ',
        );

        expect(token, isNotEmpty);
      });
    });

    group('resetPassword', () {
      test('throws if token is invalid', () async {
        expect(
          () => authService.resetPassword(
            token: 'invalid-token',
            newPassword: 'N3wSecur3!ng',
          ),
          throwsA(
            isA<VaneStackException>().having(
              (e) => e.message,
              'message',
              contains('Invalid reset token'),
            ),
          ),
        );
      });

      test('throws if token is expired', () async {
        // Create user and reset token
        await authService.signInWithEmailAndPassword(
          email: 'expired-reset@example.com',
          password: 'Secur3T3st!ng',
        );
        final token = await authService.createPasswordResetToken(
          email: 'expired-reset@example.com',
        );

        // Expire the token
        await (database.resetPasswordTokens.update()
              ..where((t) => t.token.equals(token)))
            .write(
              ResetPasswordTokensCompanion(
                expiresAt: Value(
                  DateTime.now().subtract(const Duration(hours: 1)),
                ),
              ),
            );

        expect(
          () => authService.resetPassword(
            token: token,
            newPassword: 'N3wSecur3!ng',
          ),
          throwsA(
            isA<VaneStackException>().having(
              (e) => e.message,
              'message',
              contains('expired'),
            ),
          ),
        );
      });

      test('throws if password is too weak', () async {
        await authService.signInWithEmailAndPassword(
          email: 'weak-pass@example.com',
          password: 'Secur3T3st!ng',
        );
        final token = await authService.createPasswordResetToken(
          email: 'weak-pass@example.com',
        );

        expect(
          () => authService.resetPassword(
            token: token,
            newPassword: 'weak', // Too short
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

      test('successfully resets password', () async {
        await authService.signInWithEmailAndPassword(
          email: 'successful-reset@example.com',
          password: 'MyOldSecure9!x',
        );
        final token = await authService.createPasswordResetToken(
          email: 'successful-reset@example.com',
        );

        await authService.resetPassword(
          token: token,
          newPassword: 'MyNewSecure7!z',
        );

        // Old password should fail
        expect(
          () => authService.signInWithEmailAndPassword(
            email: 'successful-reset@example.com',
            password: 'MyOldSecure9!x',
          ),
          throwsA(isA<VaneStackException>()),
        );

        // New password should work
        final result = await authService.signInWithEmailAndPassword(
          email: 'successful-reset@example.com',
          password: 'MyNewSecure7!z',
        );

        expect(result.user.email, 'successful-reset@example.com');
      });
    });

    group('verifyOtp', () {
      test('throws if email is empty', () async {
        expect(
          () => authService.verifyOtp(email: '', otp: '123456'),
          throwsA(
            isA<VaneStackException>().having(
              (e) => e.message,
              'message',
              contains('Email is required'),
            ),
          ),
        );
      });

      test('throws if OTP is empty', () async {
        expect(
          () => authService.verifyOtp(email: 'user@example.com', otp: ''),
          throwsA(
            isA<VaneStackException>().having(
              (e) => e.message,
              'message',
              contains('OTP is required'),
            ),
          ),
        );
      });

      test('throws if OTP is invalid', () async {
        expect(
          () =>
              authService.verifyOtp(email: 'user@example.com', otp: 'invalid'),
          throwsA(
            isA<VaneStackException>().having(
              (e) => e.message,
              'message',
              contains('Invalid OTP'),
            ),
          ),
        );
      });

      test('throws if OTP is expired', () async {
        // Create an expired OTP
        await database.otps.insertOne(
          OtpsCompanion.insert(
            email: 'otp@example.com',
            otp: '123456',
            expiresAt: Value(DateTime.now().subtract(const Duration(hours: 1))),
          ),
        );

        // The service distinguishes expired from invalid so the client can
        // prompt the user to request a new code rather than re-check typing.
        expect(
          () => authService.verifyOtp(email: 'otp@example.com', otp: '123456'),
          throwsA(
            isA<VaneStackException>()
                .having((e) => e.message, 'message', contains('expired'))
                .having((e) => e.code, 'code', AuthErrorCode.expiredOtp),
          ),
        );
      });

      test('successfully verifies valid OTP', () async {
        // Create a valid OTP
        await database.otps.insertOne(
          OtpsCompanion.insert(email: 'valid-otp@example.com', otp: '654321'),
        );

        final result = await authService.verifyOtp(
          email: 'valid-otp@example.com',
          otp: '654321',
        );

        expect(result.user.email, 'valid-otp@example.com');
        expect(result.accessToken, isNotEmpty);
        expect(result.refreshToken, isNotEmpty);
      });
    });

    group('signInWithIdToken', () {
      test('throws if provider is not configured', () async {
        // Create settings without OAuth providers
        final settings = Settings(
          id: 1,
          appName: 'Test',
          siteUrl: 'https://test.com',
          oauthProviders: const OAuthProviderList(),
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        expect(
          () => authService.signInWithIdToken(
            provider: IdTokenAuthProvider.google,
            idToken: 'fake-token',
            settings: settings,
          ),
          throwsA(
            isA<VaneStackException>().having(
              (e) => e.message,
              'message',
              contains('not configured'),
            ),
          ),
        );
      });

      test('throws if token format is invalid', () async {
        final settings = Settings(
          id: 1,
          appName: 'Test',
          siteUrl: 'https://test.com',
          oauthProviders: OAuthProviderList(
            google: OAuthProvider(
              enabled: true,
              clientId: 'test-client-id',
              clientSecret: 'test-secret',
            ),
          ),
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        expect(
          () => authService.signInWithIdToken(
            provider: IdTokenAuthProvider.google,
            idToken: 'not-a-jwt',
            settings: settings,
          ),
          throwsA(
            isA<VaneStackException>().having(
              (e) => e.message,
              'message',
              contains('Invalid token format'),
            ),
          ),
        );
      });
    });
  });

  group('Auth HTTP Endpoints Edge Cases', () {
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

    test('refresh without token fails', () async {
      final res = await client.get('/v1/auth/refresh');

      expect(res.status, 400);
    });

    test('logout without authorization fails', () async {
      final res = await client.del('/v1/auth/logout');

      expect(res.status, isNot(200));
    });

    test('reset-password with invalid token returns error', () async {
      final res = await client.post(
        '/v1/auth/reset-password',
        body: {'token': 'invalid-token', 'newPassword': 'N3wSecur3!ng'},
      );

      // Invalid token should return an error status
      expect(res.status, isNot(200));
    });

    test('forgot-password with non-existent email returns error', () async {
      final res = await client.post(
        '/v1/auth/forgot-password',
        body: {'email': 'nonexistent@example.com'},
      );

      // Non-existent email should return an error status
      expect(res.status, isNot(200));
    });
  });
}
