import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:vanestack_common/vanestack_common.dart';
import 'package:crypto/crypto.dart';
import 'package:dart_jsonwebtoken/dart_jsonwebtoken.dart';
import 'package:drift/drift.dart';
import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server.dart';
import 'package:mustache_template/mustache_template.dart';
import 'package:uuid/uuid.dart';

import '../auth/oauth_providers.dart';
import '../database/database.dart';
import '../emails/otp_email.dart';
import '../emails/reset_password_email.dart';
import '../utils/auth.dart';
import '../utils/jwks.dart';
import '../utils/logger.dart';
import '../utils/validation.dart';
import 'context.dart';
import 'hooks.dart';

/// Service class for authentication operations.
///
/// This service handles all authentication-related business logic and can be used by:
/// - HTTP endpoints
/// - CLI commands
/// - Public API (`vanestack.auth.signIn()`, etc.)
class AuthService {
  final ServiceContext context;

  AuthService(this.context);

  AppDatabase get db => context.database;
  String get jwtSecret => context.env.jwtSecret;

  /// Signs in a user with email and password.
  /// Creates a new user if one doesn't exist.
  ///
  /// Throws [VaneStackException] if:
  /// - User exists but has no password set
  /// - Password is invalid
  Future<AuthResponse> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    var formattedEmail = email.trim().toLowerCase();

    if (context.hooks != null) {
      final e = BeforeAuthSignInEvent(email: formattedEmail);
      await context.hooks!.runBeforeAuthSignIn(e);
      formattedEmail = e.email;
    }

    authLogger.debug('Sign-in attempt', context: 'email=$formattedEmail');

    var user =
        await (db.users.select()..where((u) => u.email.equals(formattedEmail)))
            .getSingleOrNull();

    if (user == null) {
      final validationError = AuthUtils.validatePasswordStrength(password);
      if (validationError != null) {
        throw VaneStackException(
          validationError,
          status: HttpStatus.badRequest,
        );
      }

      final hash = await AuthUtils.hashPassword(password);

      user = await db.users.insertReturning(
        UsersCompanion.insert(
          id: const Uuid().v7(),
          email: formattedEmail,
          passwordHash: Value(hash),
        ),
      );
      await db.externalAuths.insertOne(
        ExternalAuthsCompanion.insert(
          userId: user.id,
          provider: 'email',
          providerId: formattedEmail,
        ),
      );
      authLogger.info(
        'New user registered',
        context: 'email=$formattedEmail',
        userId: user.id,
      );
    } else {
      if (user.passwordHash == null) {
        authLogger.warn(
          'Sign-in failed: user not registered with password',
          context: 'email=$formattedEmail',
          userId: user.id,
        );
        throw VaneStackException(
          'User not registered with password.',
          status: HttpStatus.badRequest,
        );
      }

      final valid = await AuthUtils.verifyPassword(password, user.passwordHash!);

      if (!valid) {
        authLogger.warn(
          'Sign-in failed: invalid password',
          context: 'email=$formattedEmail',
          userId: user.id,
        );
        throw VaneStackException(
          'Invalid password.',
          status: HttpStatus.badRequest,
        );
      }

      final hasEmailAuth =
          await (db.externalAuths.select()..where(
                (e) => e.userId.equals(user!.id) & e.provider.equals('email'),
              ))
              .getSingleOrNull();

      if (hasEmailAuth == null) {
        await db.externalAuths.insertOne(
          ExternalAuthsCompanion.insert(
            userId: user.id,
            provider: 'email',
            providerId: formattedEmail,
          ),
        );
      }
    }

    final accessToken = AuthUtils.generateJwt(
      userId: user.id,
      email: user.email,
      superuser: user.superUser,
      jwtSecret: jwtSecret,
    );
    final refreshToken = AuthUtils.generateRandomToken();

    await db.refreshTokens.insertOne(
      RefreshTokensCompanion.insert(
        userId: user.id,
        refreshToken: refreshToken,
        accessToken: accessToken,
      ),
    );

    authLogger.info(
      'User signed in successfully',
      context: 'email=$formattedEmail',
      userId: user.id,
    );

    final authResponse = AuthResponse(
      accessToken: accessToken,
      refreshToken: refreshToken,
      user: user.toPublic(),
    );

    if (context.hooks != null) {
      await context.hooks!.runAfterAuthSignIn(
        AfterAuthSignInEvent(result: authResponse),
      );
    }

    return authResponse;
  }

  /// Generates an OTP code using alphanumeric characters.
  String _generateOtpCode() {
    final random = Random.secure();
    const chars =
        'ABCDEFGHJKLMNPQRSTUVWXYZ23456789'; // Excludes I, O, 0, 1 for clarity
    return List.generate(6, (_) => chars[random.nextInt(chars.length)]).join();
  }

  /// Creates an OTP for a user without sending an email.
  ///
  /// Useful for CLI or testing scenarios.
  /// Returns the generated OTP code.
  ///
  /// Throws [VaneStackException] if:
  /// - Email is empty or invalid
  /// - User with email doesn't exist
  Future<String> createOtp({required String email}) async {
    final formattedEmail = email.trim().toLowerCase();

    if (formattedEmail.isEmpty) {
      throw VaneStackException(
        'Email is required.',
        status: HttpStatus.badRequest,
      );
    }

    if (!validateEmail(formattedEmail)) {
      throw VaneStackException(
        'Invalid email format.',
        status: HttpStatus.badRequest,
      );
    }

    final user =
        await (db.users.select()..where((u) => u.email.equals(formattedEmail)))
            .getSingleOrNull();

    if (user == null) {
      throw VaneStackException(
        'User with that email does not exist.',
        status: HttpStatus.notFound,
      );
    }

    final otpCode = _generateOtpCode();

    await db.otps.insertOne(
      OtpsCompanion.insert(email: formattedEmail, otp: otpCode),
    );

    authLogger.info('OTP created for user', context: 'email=$formattedEmail');
    return otpCode;
  }

  /// Sends an OTP to the given email address.
  ///
  /// Throws [VaneStackException] if:
  /// - Email is empty or invalid
  /// - Mail settings are not configured
  Future<void> sendOtp({
    required String email,
    required Settings settings,
    required SmtpServer smtpServer,
  }) async {
    final formattedEmail = email.trim().toLowerCase();

    authLogger.debug('OTP sign-in requested', context: 'email=$formattedEmail');

    if (formattedEmail.isEmpty) {
      authLogger.warn('OTP sign-in failed: empty email');
      throw VaneStackException(
        'Email is required.',
        status: HttpStatus.badRequest,
      );
    }

    if (!validateEmail(formattedEmail)) {
      authLogger.warn(
        'OTP sign-in failed: invalid email format',
        context: 'email=$formattedEmail',
      );
      throw VaneStackException(
        'Invalid email format.',
        status: HttpStatus.badRequest,
      );
    }

    final otpCode = _generateOtpCode();

    await db.otps.insertOne(
      OtpsCompanion.insert(email: formattedEmail, otp: otpCode),
    );

    authLogger.debug('OTP generated', context: 'email=$formattedEmail');

    final opts = settings.mail!;

    final user =
        await (db.users.select()..where((u) => u.email.equals(formattedEmail)))
            .getSingleOrNull();

    final message = Message()
      ..from = Address(opts.fromAddress, opts.fromName)
      ..recipients.add(formattedEmail)
      ..subject = 'Your Sign-In OTP Code'
      ..html = Template(opts.otpTemplate ?? otpEmail).renderString({
        'otp_code': otpCode,
        'user': {
          'email': formattedEmail,
          if (user != null) 'id': user.id,
          if (user?.name != null) 'name': user!.name,
        },
      });

    await send(message, smtpServer);
    authLogger.info('OTP email sent', context: 'email=$formattedEmail');
  }

  /// Verifies an OTP and returns auth tokens.
  /// Creates a new user if one doesn't exist.
  ///
  /// Throws [VaneStackException] if:
  /// - Email or OTP is empty
  /// - OTP is invalid or expired
  Future<AuthResponse> verifyOtp({
    required String email,
    required String otp,
  }) async {
    final formattedEmail = email.trim().toLowerCase();

    if (formattedEmail.isEmpty) {
      throw VaneStackException(
        'Email is required.',
        status: HttpStatus.badRequest,
      );
    }

    if (otp.isEmpty) {
      throw VaneStackException(
        'OTP is required.',
        status: HttpStatus.badRequest,
      );
    }

    // Clean up expired OTPs for this email
    await db.otps.deleteWhere(
      (o) =>
          o.email.equals(formattedEmail) &
          o.expiresAt.isSmallerThanValue(DateTime.now()),
    );

    final row =
        await (db.otps.select()..where(
              (o) => o.email.equals(formattedEmail) & o.otp.equals(otp),
            ))
            .getSingleOrNull();

    if (row == null) {
      throw VaneStackException('Invalid OTP.', status: HttpStatus.badRequest);
    }

    if (row.expiresAt.isBefore(DateTime.now())) {
      throw VaneStackException(
        'OTP has expired.',
        status: HttpStatus.badRequest,
      );
    }

    // Delete the used OTP to prevent replay attacks
    await db.otps.deleteWhere((o) => o.id.equals(row.id));

    var user =
        await (db.users.select()..where((u) => u.email.equals(formattedEmail)))
            .getSingleOrNull();

    user ??= await db.users.insertReturning(
      UsersCompanion.insert(id: const Uuid().v7(), email: formattedEmail),
    );

    final accessToken = AuthUtils.generateJwt(
      userId: user.id,
      email: user.email,
      superuser: user.superUser,
      jwtSecret: jwtSecret,
    );
    final refreshToken = AuthUtils.generateRandomToken();

    await db.refreshTokens.insertOne(
      RefreshTokensCompanion.insert(
        userId: user.id,
        refreshToken: refreshToken,
        accessToken: accessToken,
      ),
    );

    final authResponse = AuthResponse(
      accessToken: accessToken,
      refreshToken: refreshToken,
      user: user.toPublic(),
    );

    if (context.hooks != null) {
      await context.hooks!.runAfterAuthSignIn(
        AfterAuthSignInEvent(result: authResponse),
      );
    }

    return authResponse;
  }

  /// Refreshes auth tokens using a refresh token.
  ///
  /// Throws [VaneStackException] if:
  /// - Refresh token is missing or invalid
  /// - Refresh token is expired
  /// - User not found
  Future<AuthResponse> refreshToken({required String refreshToken}) async {
    if (refreshToken.isEmpty) {
      authLogger.warn('Token refresh failed: missing refresh token');
      throw VaneStackException(
        'Missing refresh token.',
        status: HttpStatus.badRequest,
      );
    }

    final tokenRecord =
        await (db.refreshTokens.select()
              ..where((t) => t.refreshToken.equals(refreshToken)))
            .getSingleOrNull();

    if (tokenRecord == null) {
      authLogger.warn('Token refresh failed: invalid refresh token');
      throw VaneStackException(
        'Invalid refresh token.',
        status: HttpStatus.badRequest,
      );
    }

    if (tokenRecord.expiresAt.isBefore(DateTime.now())) {
      authLogger.warn(
        'Token refresh failed: token expired',
        userId: tokenRecord.userId,
      );
      throw VaneStackException(
        'Refresh token expired.',
        status: HttpStatus.badRequest,
      );
    }

    final user =
        await (db.users.select()..where((u) => u.id.equals(tokenRecord.userId)))
            .getSingleOrNull();

    if (user == null) {
      authLogger.warn(
        'Token refresh failed: user not found',
        userId: tokenRecord.userId,
      );
      throw VaneStackException('User not found.', status: HttpStatus.notFound);
    }

    final newAccessToken = AuthUtils.generateJwt(
      jwtSecret: jwtSecret,
      superuser: user.superUser,
      userId: user.id,
      email: user.email,
    );

    final newRefreshToken = AuthUtils.generateRandomToken();

    // Delete the old refresh token to prevent reuse
    await db.refreshTokens.deleteWhere(
      (t) => t.refreshToken.equals(refreshToken),
    );

    await db.refreshTokens.insertOne(
      RefreshTokensCompanion.insert(
        userId: user.id,
        refreshToken: newRefreshToken,
        accessToken: newAccessToken,
      ),
    );

    authLogger.debug('Token refreshed', userId: user.id);

    return AuthResponse(
      accessToken: newAccessToken,
      refreshToken: newRefreshToken,
      user: user.toPublic(),
    );
  }

  /// Logs out a user by invalidating their access token.
  ///
  /// Throws [VaneStackException] if:
  /// - Access token is missing or invalid
  Future<void> logout({required String accessToken, String? userId}) async {
    if (accessToken.isEmpty) {
      authLogger.warn('Logout failed: missing access token', userId: userId);
      throw VaneStackException(
        'Missing access token.',
        status: HttpStatus.badRequest,
      );
    }

    final deletedCount = await db.refreshTokens.deleteWhere(
      (t) => t.accessToken.equals(accessToken),
    );

    if (deletedCount == 0) {
      authLogger.warn('Logout failed: invalid access token', userId: userId);
      throw VaneStackException(
        'Invalid access token.',
        status: HttpStatus.badRequest,
      );
    }

    authLogger.info('User logged out', userId: userId);
  }

  /// Sends a password reset email.
  ///
  /// Creates a password reset token for a user without sending an email.
  ///
  /// Useful for testing or CLI scenarios where email is not needed.
  /// Returns the generated token.
  ///
  /// Throws [VaneStackException] if user with email doesn't exist.
  Future<String> createPasswordResetToken({required String email}) async {
    final formattedEmail = email.trim().toLowerCase();
    final user =
        await (db.users.select()..where((u) => u.email.equals(formattedEmail)))
            .getSingleOrNull();

    if (user == null) {
      throw VaneStackException(
        'User with that email does not exist.',
        status: HttpStatus.notFound,
      );
    }

    final resetToken = AuthUtils.generateRandomToken();

    await db.resetPasswordTokens.insertOne(
      ResetPasswordTokensCompanion.insert(userId: user.id, token: resetToken),
    );

    return resetToken;
  }

  /// Sends a password reset email to the user.
  ///
  /// For security, this method always returns successfully regardless of
  /// whether the email exists. This prevents user enumeration attacks.
  ///
  /// Throws [VaneStackException] if:
  /// - Invalid redirect URL
  Future<void> sendPasswordResetEmail({
    required String email,
    required Settings settings,
    required SmtpServer smtpServer,
    String? redirectTo,
  }) async {
    final formattedEmail = email.trim().toLowerCase();

    // Validate redirect URL first (before checking user existence)
    final redirect = Uri.parse(redirectTo ?? settings.siteUrl);
    if (redirectTo != null &&
        !(settings.redirectUrls.contains(redirect.origin) ||
            settings.siteUrl.contains(redirect.origin))) {
      throw VaneStackException(
        'Invalid redirect URL.',
        status: HttpStatus.badRequest,
      );
    }

    // Check if user exists - silently return if not (prevents user enumeration)
    final user =
        await (db.users.select()..where((u) => u.email.equals(formattedEmail)))
            .getSingleOrNull();

    if (user == null) {
      // Silently return without sending email to prevent user enumeration
      authLogger.debug('Password reset requested for non-existent email');
      return;
    }

    // Create reset token and send email
    final resetToken = await createPasswordResetToken(email: email);
    final opts = settings.mail!;

    final withTokenQuery = redirect.replace(
      queryParameters: {...redirect.queryParameters, 'token': resetToken},
    );

    final message = Message()
      ..from = Address(opts.fromAddress, opts.fromName)
      ..recipients.add(formattedEmail)
      ..subject = 'Password Reset Request'
      ..html = Template(opts.resetPasswordTemplate ?? resetPasswordEmail)
          .renderString({
            'reset_url': withTokenQuery.toString(),
            'user': {'email': formattedEmail, 'name': user.name, 'id': user.id},
          });

    await send(message, smtpServer);
  }

  /// Resets a user's password using a reset token.
  ///
  /// Throws [VaneStackException] if:
  /// - Token is invalid or expired
  /// - Password doesn't meet strength requirements
  /// - User not found
  /// - New password is same as old password
  Future<void> resetPassword({
    required String token,
    required String newPassword,
  }) async {
    authLogger.debug('Password reset attempt');

    final tokenRecord =
        await (db.resetPasswordTokens.select()
              ..where((t) => t.token.equals(token)))
            .getSingleOrNull();

    if (tokenRecord == null) {
      authLogger.warn('Password reset failed: invalid token');
      throw VaneStackException(
        'Invalid reset token.',
        status: HttpStatus.badRequest,
      );
    }

    if (tokenRecord.expiresAt.isBefore(DateTime.now())) {
      authLogger.warn(
        'Password reset failed: token expired',
        userId: tokenRecord.userId,
      );
      throw VaneStackException(
        'Reset token expired.',
        status: HttpStatus.badRequest,
      );
    }

    final validationError = AuthUtils.validatePasswordStrength(newPassword);

    if (validationError != null) {
      authLogger.warn(
        'Password reset failed: weak password',
        userId: tokenRecord.userId,
      );
      throw VaneStackException(validationError, status: HttpStatus.badRequest);
    }

    final user =
        await (db.users.select()..where((u) => u.id.equals(tokenRecord.userId)))
            .getSingleOrNull();

    if (user == null) {
      authLogger.warn(
        'Password reset failed: user not found',
        userId: tokenRecord.userId,
      );
      throw VaneStackException('User not found.', status: HttpStatus.notFound);
    }

    if (user.passwordHash != null &&
        await AuthUtils.verifyPassword(newPassword, user.passwordHash!)) {
      authLogger.warn('Password reset failed: same password', userId: user.id);
      throw VaneStackException(
        'New password must be different from the old.',
        status: HttpStatus.conflict,
      );
    }

    final newHash = await AuthUtils.hashPassword(newPassword);

    await db.transaction(() async {
      await db.managers.users
          .filter((u) => u.id.equals(user.id))
          .update(
            (u) => u(
              passwordHash: Value(newHash),
              updatedAt: Value(DateTime.now()),
            ),
          );

      await db.resetPasswordTokens.deleteWhere((t) => t.token.equals(token));
    });

    authLogger.info('Password reset successful', userId: user.id);
  }

  /// Gets an OAuth URL for the given provider.
  ///
  /// Throws [VaneStackException] if:
  /// - Provider is not configured or disabled
  /// - Invalid redirect URL
  Future<String> getOAuthUrl({
    required String provider,
    required Settings settings,
    String? redirectUrl,
  }) async {
    final config = OAuthProviderConfig.values.byName(provider);
    final state = _generateState();

    final redirect = Uri.parse(
      redirectUrl ?? '${settings.siteUrl}/v1/auth/oauth2/$provider/callback',
    );

    if (redirectUrl != null && !_isValidRedirectUrl(redirect, settings)) {
      throw VaneStackException(
        'Invalid redirect URL.',
        status: HttpStatus.badRequest,
      );
    }

    final providerSettings = _getOAuthSettings(provider, settings);

    if (providerSettings == null) {
      throw VaneStackException(
        'OAuth provider not configured',
        status: HttpStatus.internalServerError,
      );
    }

    if (providerSettings.enabled != true) {
      throw VaneStackException(
        'OAuth provider is disabled',
        status: HttpStatus.internalServerError,
      );
    }

    await db.oauthStates.insertOne(
      OauthStatesCompanion.insert(
        state: state,
        provider: provider,
        redirectUrl: redirect.toString(),
      ),
    );

    final authUrl = Uri.https(config.authHost, config.authPath, {
      'client_id': switch (config) {
        OAuthProviderConfig.google =>
          providerSettings.clientId.split(',').first,
        OAuthProviderConfig.apple => providerSettings.clientId.split(',').first,
        _ => providerSettings.clientId,
      },
      'redirect_uri':
          '${settings.siteUrl}/v1/auth/oauth2/${config.name}/callback',
      'response_type': 'code',
      'scope': config.scope,
      'state': state,
      // Apple requires form_post when requesting email/name scopes
      if (config == OAuthProviderConfig.apple) 'response_mode': 'form_post',
    });

    return authUrl.toString();
  }

  /// Handles OAuth callback and returns auth tokens.
  ///
  /// Throws [VaneStackException] if:
  /// - Code or state is missing
  /// - State is invalid or expired
  /// - Provider is not configured or disabled
  /// - Email not provided by OAuth provider
  Future<(AuthResponse, String)> handleOAuthCallback({
    required String provider,
    required String code,
    required String state,
    required Settings settings,
    String? userName,
  }) async {
    // Clean up expired states
    await db.oauthStates.deleteWhere(
      (s) => s.expiresAt.isSmallerThanValue(DateTime.now()),
    );

    // Validate and consume state (one-time use)
    final oauthState =
        await (db.oauthStates.select()..where((s) => s.state.equals(state)))
            .getSingleOrNull();

    if (oauthState == null) {
      throw VaneStackException(
        'Invalid or expired state',
        status: HttpStatus.badRequest,
      );
    }

    // Delete the used state
    await db.oauthStates.deleteWhere((s) => s.id.equals(oauthState.id));

    final providerSettings = _getOAuthSettings(provider, settings);

    if (providerSettings == null) {
      throw VaneStackException(
        'OAuth2 provider not configured.',
        status: HttpStatus.badRequest,
      );
    }

    if (providerSettings.enabled != true) {
      throw VaneStackException(
        'OAuth2 provider is disabled.',
        status: HttpStatus.badRequest,
      );
    }

    final config = OAuthProviderConfig.values.byName(provider);

    final tokenResponse = await exchangeCodeForToken(
      config,
      code,
      switch (config) {
        OAuthProviderConfig.google =>
          providerSettings.clientId.split(',').first,
        OAuthProviderConfig.apple => providerSettings.clientId.split(',').first,
        _ => providerSettings.clientId,
      },
      providerSettings.clientSecret,
      '${settings.siteUrl}/v1/auth/oauth2/${config.name}/callback',
    );

    final socialUser = await fetchSocialUser(config, tokenResponse);

    // Try to find existing user by provider ID (handles returning users
    // where the provider no longer sends email, e.g. Apple after first auth)
    DbUser? user;
    if (socialUser.providerId != null) {
      final externalAuth =
          await (db.externalAuths.select()..where(
                (e) =>
                    e.provider.equals(provider) &
                    e.providerId.equals(socialUser.providerId!),
              ))
              .getSingleOrNull();

      if (externalAuth != null) {
        user =
            await (db.users.select()
                  ..where((u) => u.id.equals(externalAuth.userId)))
                .getSingleOrNull();
      }
    }

    // No existing link — require email for first-time sign-up
    if (user == null) {
      final email = socialUser.email;
      if (email == null || email.isEmpty) {
        throw VaneStackException(
          'Email not provided by OAuth2 provider.',
          status: HttpStatus.badRequest,
        );
      }

      if (!socialUser.emailVerified) {
        throw VaneStackException(
          'Email not verified by OAuth2 provider.',
          status: HttpStatus.badRequest,
        );
      }

      user = await (db.users.select()..where((u) => u.email.equals(email)))
          .getSingleOrNull();

      // Use userName from Apple's form post if socialUser.name is not available
      final displayName = socialUser.name ?? userName;

      user ??= await db.users.insertReturning(
        UsersCompanion.insert(
          id: const Uuid().v7(),
          email: email,
          name: Value.absentIfNull(displayName),
        ),
      );

      // Store the provider link for future sign-ins
      if (socialUser.providerId != null) {
        await db.externalAuths.insertOne(
          ExternalAuthsCompanion.insert(
            userId: user.id,
            provider: provider,
            providerId: socialUser.providerId!,
          ),
        );
      }
    }

    final providerNames =
        await (db.externalAuths.select()
              ..where((e) => e.userId.equals(user!.id)))
            .get()
            .then((rows) => rows.map((r) => r.provider).toList());

    final accessToken = AuthUtils.generateJwt(
      userId: user.id,
      email: user.email,
      superuser: user.superUser,
      jwtSecret: jwtSecret,
    );

    final refreshToken = AuthUtils.generateRandomToken();

    await db.refreshTokens.insertOne(
      RefreshTokensCompanion.insert(
        userId: user.id,
        refreshToken: refreshToken,
        accessToken: accessToken,
      ),
    );

    return (
      AuthResponse(
        accessToken: accessToken,
        refreshToken: refreshToken,
        user: user.toPublic(providers: providerNames),
      ),
      oauthState.redirectUrl,
    );
  }

  /// Signs in with an ID token from Google, Apple, or Facebook.
  ///
  /// Throws [VaneStackException] if:
  /// - Provider is not configured or disabled
  /// - Token is invalid or expired
  /// - Email not provided in token
  Future<AuthResponse> signInWithIdToken({
    required IdTokenAuthProvider provider,
    required String idToken,
    required Settings settings,
    String? nonce,
  }) async {
    final oauthSettings = switch (provider) {
      IdTokenAuthProvider.google => settings.oauthProviders.google,
      IdTokenAuthProvider.apple => settings.oauthProviders.apple,
      IdTokenAuthProvider.facebook => settings.oauthProviders.facebook,
    };

    if (oauthSettings == null || !oauthSettings.enabled) {
      throw VaneStackException(
        'Provider not configured or disabled',
        status: HttpStatus.badRequest,
      );
    }

    String? email;
    String? name;
    String? providerId;

    final parts = idToken.split('.');
    final isJwt = parts.length == 3;

    if (isJwt) {
      // JWT token — validate signature via JWKS.
      final header = _decodeJwtPart(parts[0]);
      final payload = _decodeJwtPart(parts[1]);

      final kid = header['kid'] as String?;
      if (kid == null) {
        throw VaneStackException(
          'Missing key ID (kid) in token header',
          status: HttpStatus.badRequest,
        );
      }

      final jwks = await JwksCache.getJwks(provider.name);
      final jwk = JwksCache.findKey(jwks, kid);
      if (jwk == null) {
        throw VaneStackException(
          'Public key not found for kid: $kid',
          status: HttpStatus.unauthorized,
        );
      }

      try {
        final publicKey = JWTKey.fromJWK(jwk);
        JWT.verify(idToken, publicKey, checkHeaderType: false);
      } on JWTExpiredException {
        throw VaneStackException(
          'Token has expired',
          status: HttpStatus.badRequest,
        );
      } on JWTException catch (e) {
        throw VaneStackException(
          'Invalid token signature: ${e.message}',
          status: HttpStatus.badRequest,
        );
      }

      final issuer = payload['iss'] as String?;
      final audience = payload['aud'] as String?;

      final validIssuers = switch (provider) {
        IdTokenAuthProvider.google => [
          'https://accounts.google.com',
          'accounts.google.com',
        ],
        IdTokenAuthProvider.apple => ['https://appleid.apple.com'],
        IdTokenAuthProvider.facebook => ['https://www.facebook.com'],
      };

      if (issuer == null || !validIssuers.contains(issuer)) {
        throw VaneStackException(
          'Invalid issuer',
          status: HttpStatus.badRequest,
        );
      }

      if (audience == null ||
          !oauthSettings.clientId
              .split(',')
              .map((e) => e.trim())
              .contains(audience)) {
        throw VaneStackException(
          'Invalid audience',
          status: HttpStatus.badRequest,
        );
      }

      // Verify nonce if provided (required for Apple and Facebook).
      if (nonce != null) {
        final tokenNonce = payload['nonce'] as String?;
        final expectedHash = sha256.convert(utf8.encode(nonce)).toString();
        if (tokenNonce == null || tokenNonce != expectedHash) {
          throw VaneStackException(
            'Invalid nonce',
            status: HttpStatus.badRequest,
          );
        }
      }

      email = payload['email'] as String?;
      name = payload['name'] as String?;
      providerId = payload['sub'] as String?;
    } else {
      // Opaque access token (e.g. Facebook classic login on desktop).
      // Validate by calling the provider's user info API.
      if (provider != IdTokenAuthProvider.facebook) {
        throw VaneStackException(
          'Invalid token format',
          status: HttpStatus.badRequest,
        );
      }

      final config = OAuthProviderConfig.facebook;
      final socialUser = await fetchSocialUser(config, {
        'access_token': idToken,
      });

      email = socialUser.email;
      name = socialUser.name;
      providerId = socialUser.providerId;
    }

    // Try to find existing user by provider ID (handles returning users
    // where the provider no longer sends email, e.g. Apple after first auth)
    DbUser? user;
    final providerName = provider.name;
    final pid = providerId;
    if (pid != null) {
      final externalAuth =
          await (db.externalAuths.select()..where(
                (e) =>
                    e.provider.equals(providerName) & e.providerId.equals(pid),
              ))
              .getSingleOrNull();

      if (externalAuth != null) {
        user =
            await (db.users.select()
                  ..where((u) => u.id.equals(externalAuth.userId)))
                .getSingleOrNull();
      }
    }

    // No existing link — require email for first-time sign-up
    if (user == null) {
      if (email == null || email.isEmpty) {
        throw VaneStackException(
          'Email not provided in token',
          status: HttpStatus.badRequest,
        );
      }

      final verifiedEmail = email;

      user =
          await (db.users.select()..where((u) => u.email.equals(verifiedEmail)))
              .getSingleOrNull();

      user ??= await db.users.insertReturning(
        UsersCompanion.insert(
          id: const Uuid().v7(),
          email: verifiedEmail,
          name: Value.absentIfNull(name),
        ),
      );

      // Store the provider link for future sign-ins
      if (pid != null) {
        await db.externalAuths.insertOne(
          ExternalAuthsCompanion.insert(
            userId: user.id,
            provider: providerName,
            providerId: pid,
          ),
        );
      }
    }

    final providerNames =
        await (db.externalAuths.select()
              ..where((e) => e.userId.equals(user!.id)))
            .get()
            .then((rows) => rows.map((r) => r.provider).toList());

    final accessToken = AuthUtils.generateJwt(
      userId: user.id,
      email: user.email,
      superuser: user.superUser,
      jwtSecret: jwtSecret,
    );
    final refreshToken = AuthUtils.generateRandomToken();

    await db.refreshTokens.insertOne(
      RefreshTokensCompanion.insert(
        userId: user.id,
        refreshToken: refreshToken,
        accessToken: accessToken,
      ),
    );

    final authResponse = AuthResponse(
      accessToken: accessToken,
      refreshToken: refreshToken,
      user: user.toPublic(providers: providerNames),
    );

    if (context.hooks != null) {
      await context.hooks!.runAfterAuthSignIn(
        AfterAuthSignInEvent(result: authResponse),
      );
    }

    return authResponse;
  }

  /// Gets the current user by ID.
  Future<User?> getUserById(String userId) async {
    final user = await (db.users.select()..where((u) => u.id.equals(userId)))
        .getSingleOrNull();

    return user?.toPublic();
  }

  OAuthProvider? _getOAuthSettings(String provider, Settings settings) {
    return switch (provider) {
      'google' => settings.oauthProviders.google,
      'github' => settings.oauthProviders.github,
      'discord' => settings.oauthProviders.discord,
      'apple' => settings.oauthProviders.apple,
      'facebook' => settings.oauthProviders.facebook,
      'linkedin' => settings.oauthProviders.linkedin,
      'slack' => settings.oauthProviders.slack,
      'spotify' => settings.oauthProviders.spotify,
      'reddit' => settings.oauthProviders.reddit,
      'twitch' => settings.oauthProviders.twitch,
      _ => null,
    };
  }

  /// Validates if a redirect URL is allowed.
  /// Supports both HTTP origins (https://example.com) and custom URL schemes (myapp://).
  bool _isValidRedirectUrl(Uri redirect, Settings settings) {
    // For custom URL schemes, check if the scheme is in the allowed list
    if (redirect.scheme != 'http' && redirect.scheme != 'https') {
      final schemePrefix = '${redirect.scheme}://';
      return settings.redirectUrls.any(
        (url) => url.startsWith(schemePrefix) || url == redirect.toString(),
      );
    }

    // For HTTP/HTTPS, check origin
    return settings.redirectUrls.contains(redirect.origin) ||
        settings.siteUrl.contains(redirect.origin);
  }

  String _generateState([int length = 32]) {
    final random = Random.secure();
    final bytes = List<int>.generate(length, (_) => random.nextInt(256));
    return base64UrlEncode(bytes).replaceAll('=', '');
  }

  Map<String, dynamic> _decodeJwtPart(String part) {
    final normalized = base64Url.normalize(part);
    final decoded = utf8.decode(base64Url.decode(normalized));
    return jsonDecode(decoded) as Map<String, dynamic>;
  }
}

extension _PublicUser on DbUser {
  User toPublic({List<String> providers = const []}) {
    return User(
      id: id,
      email: email,
      name: name,
      providers: providers,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }
}
