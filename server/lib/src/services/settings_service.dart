import 'dart:io';

import 'package:vanestack_common/vanestack_common.dart';
import 'package:dart_jsonwebtoken/dart_jsonwebtoken.dart';
import 'package:drift/drift.dart';

import '../database/database.dart';
import '../utils/logger.dart';
import '../utils/random_name.dart';
import '../utils/s3.dart';
import 'context.dart';

/// Service class for application settings operations.
///
/// Can be used by:
/// - HTTP endpoints
/// - CLI commands
/// - Public API (`vanestack.settingsService.get()`, etc.)
class SettingsService {
  final ServiceContext context;

  SettingsService(this.context);

  AppDatabase get db => context.database;

  // Settings rarely change but are read on most requests (storage backend
  // resolution, SMTP config, OAuth redirects). A short process-wide TTL
  // turns the steady-state cost from one round-trip per request into
  // one per [_cacheTtl] window across the whole server.
  static const _cacheTtl = Duration(seconds: 10);
  static ({Settings settings, DateTime expiresAt})? _cache;

  static void invalidateCache() => _cache = null;

  /// Gets the application settings.
  /// Creates default settings if none exist.
  Future<Settings> get() async {
    final cached = _cache;
    if (cached != null && DateTime.now().isBefore(cached.expiresAt)) {
      return cached.settings;
    }
    final settings = await _fetch();
    _cache = (
      settings: settings,
      expiresAt: DateTime.now().add(_cacheTtl),
    );
    return settings;
  }

  Future<Settings> _fetch() async {
    final settings = await (db.appSettings.select()..limit(1))
        .getSingleOrNull();

    if (settings == null) {
      return db.appSettings.insertReturning(
        AppSettingsCompanion.insert(
          appName: generateRandomName(),
          oauthProviders: const OAuthProviderList(),
        ),
      );
    }

    return settings;
  }

  /// Updates application settings.
  ///
  /// Creates settings if they don't exist.
  ///
  /// Throws [VaneStackException] if update fails.
  Future<Settings> update({
    String? appName,
    String? siteUrl,
    List<String>? redirectUrls,
    S3Settings? s3,
    MailSettings? mail,
    OAuthProviderList? oauthProviders,
  }) async {
    final existingSettings = await (db.appSettings.select()..limit(1))
        .getSingleOrNull();

    Settings? data;

    if (existingSettings == null) {
      final insert = AppSettingsCompanion.insert(
        id: const Value(1),
        oauthProviders: oauthProviders ?? const OAuthProviderList(),
        appName: appName ?? generateRandomName(),
        redirectUrls: Value.absentIfNull(redirectUrls),
        siteUrl: Value.absentIfNull(siteUrl),
        s3: Value.absentIfNull(s3),
        mail: Value.absentIfNull(mail),
        createdAt: Value(DateTime.now()),
        updatedAt: Value(DateTime.now()),
      );

      data = await db.appSettings.insertReturningOrNull(insert);
    } else {
      final updateCompanion = AppSettingsCompanion(
        id: Value(existingSettings.id),
        oauthProviders: Value.absentIfNull(oauthProviders),
        appName: Value(appName ?? existingSettings.appName),
        siteUrl: Value.absentIfNull(siteUrl),
        redirectUrls: Value.absentIfNull(redirectUrls),
        s3: Value.absentIfNull(s3),
        mail: Value.absentIfNull(mail),
        createdAt: Value.absentIfNull(existingSettings.createdAt),
        updatedAt: Value(DateTime.now()),
      );

      final result =
          await (db.appSettings.update()
                ..where((t) => t.id.equals(existingSettings.id)))
              .writeReturning(updateCompanion);

      data = result.firstOrNull;
    }

    if (data == null) {
      throw VaneStackException(
        'Failed to update settings.',
        status: HttpStatus.internalServerError,
        code: SettingsErrorCode.updateFailed,
      );
    }

    serverLogger.info('Settings updated');

    _cache = (
      settings: data,
      expiresAt: DateTime.now().add(_cacheTtl),
    );

    return data;
  }

  /// Tests the S3 connection using the current settings.
  ///
  /// Throws [VaneStackException] if:
  /// - Settings not found
  /// - S3 settings not configured
  /// - Connection test fails
  Future<void> testS3Connection() async {
    final settings = await get();

    if (settings.s3 == null) {
      throw VaneStackException(
        'S3 settings not configured.',
        status: HttpStatus.badRequest,
        code: SettingsErrorCode.s3NotConfigured,
      );
    }

    final client = S3Client(settings.s3!);

    final result = await client.testConnection();

    if (!result) {
      serverLogger.warn('S3 connection test failed');
      throw VaneStackException(
        'Failed to connect to S3.',
        status: HttpStatus.internalServerError,
        code: SettingsErrorCode.s3ConnectionFailed,
      );
    }

    serverLogger.info('S3 connection test successful');
  }

  /// Generates an Apple client secret JWT.
  ///
  /// Throws [VaneStackException] if:
  /// - Required fields are missing
  /// - Duration is invalid
  /// - JWT generation fails
  String generateAppleClientSecret({
    required String clientId,
    required String teamId,
    required String keyId,
    required String privateKey,
    required int duration,
  }) {
    if (clientId.isEmpty ||
        teamId.isEmpty ||
        keyId.isEmpty ||
        privateKey.isEmpty) {
      throw VaneStackException(
        'All fields are required.',
        status: HttpStatus.badRequest,
        code: SettingsErrorCode.appleSecretGenerationFailed,
      );
    }

    if (duration <= 0) {
      throw VaneStackException(
        'Duration must be a positive integer.',
        status: HttpStatus.badRequest,
        code: SettingsErrorCode.appleSecretGenerationFailed,
      );
    }

    try {
      final now = DateTime.now();
      final expiry = now.add(Duration(seconds: duration));

      final jwt = JWT(
        {
          'iss': teamId,
          'iat': now.millisecondsSinceEpoch ~/ 1000,
          'exp': expiry.millisecondsSinceEpoch ~/ 1000,
          'aud': 'https://appleid.apple.com',
          'sub': clientId,
        },
        header: {'kid': keyId},
      );

      final token = jwt.sign(
        ECPrivateKey(privateKey),
        algorithm: JWTAlgorithm.ES256,
      );

      return token;
    } catch (e) {
      throw VaneStackException(
        'Failed to generate client secret: ${e.toString()}',
        status: HttpStatus.badRequest,
        code: SettingsErrorCode.appleSecretGenerationFailed,
      );
    }
  }
}
