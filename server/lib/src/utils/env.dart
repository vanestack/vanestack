import 'dart:io' show Platform;

import 'package:vanestack_common/vanestack_common.dart' show LogLevel;

/// Which database backend the server talks to.
enum DatabaseBackend { sqlite, postgres }

/// Environment configuration for the VaneStack server.
///
/// Configuration can be set via environment variables:
/// - `VANESTACK_PORT`: Server port (default: 8080)
/// - `VANESTACK_JWT_SECRET_KEY`: JWT secret key (default: 'super_secret_jwt_key')
/// - `VANESTACK_LOCAL_STORAGE_ENABLED`: Enable local file storage (default: true)
/// - `VANESTACK_LOCAL_STORAGE_PATH`: Local file storage folder path (default: 'storage')
/// - `VANESTACK_LOG_LEVEL`: Log level (default: info)
/// - `VANESTACK_MAX_FILE_SIZE`: Maximum file upload size in bytes (default: 50MB)
/// - `VANESTACK_DATABASE`: Database backend — `sqlite` (default) or `postgres`
/// - `VANESTACK_SQLITE_PATH`: SQLite database file path (default: './data/database.sqlite')
/// - `VANESTACK_POSTGRES_URL`: Postgres connection URL (e.g. `postgres://user:pass@host:5432/db`).
///   Required when `VANESTACK_DATABASE=postgres`.
/// - `VANESTACK_RATE_LIMIT_MAX`: Max requests per window for rate limiting (default: 10)
/// - `VANESTACK_RATE_LIMIT_WINDOW_SECONDS`: Rate limit window in seconds (default: 60)
/// - `VANESTACK_LOG_RETENTION_DAYS`: Days to retain logs, 0 = no cleanup (default: 30)
class Environment {
  /// The secret key used for JWT authentication.
  /// Can be set via `VANESTACK_JWT_SECRET_KEY` environment variable.
  /// Defaults to 'super_secret_jwt_key'.
  /// Change this to a secure value in production.
  final String jwtSecret;

  /// The port the server will run on.
  /// Can be set via `VANESTACK_PORT` environment variable.
  /// Defaults to 8080.
  final int port;

  /// Whether local file storage is enabled.
  /// Can be set via `VANESTACK_LOCAL_STORAGE_ENABLED` environment variable.
  /// Defaults to true.
  final bool localStorageEnabled;

  /// The local file storage folder path.
  /// Can be set via `VANESTACK_LOCAL_STORAGE_PATH` environment variable.
  /// Defaults to './data/storage'.
  final String localStoragePath;

  /// The log level for the server.
  /// Can be set via `VANESTACK_LOG_LEVEL` environment variable.
  /// Defaults to LogLevel.info.
  final LogLevel logLevel;

  /// The maximum file upload size in bytes.
  /// Can be set via `VANESTACK_MAX_FILE_SIZE` environment variable.
  /// Defaults to 50MB (50 * 1024 * 1024 bytes).
  final int maxFileSize;

  /// Which database backend to use.
  /// Can be set via `VANESTACK_DATABASE` environment variable.
  /// Defaults to [DatabaseBackend.sqlite].
  final DatabaseBackend databaseBackend;

  /// The path to the SQLite database file.
  /// Can be set via `VANESTACK_SQLITE_PATH` environment variable.
  /// Defaults to './data/database.sqlite'.
  ///
  /// Only used when [databaseBackend] is [DatabaseBackend.sqlite].
  final String sqlitePath;

  /// Postgres connection URL (e.g. `postgres://user:pass@host:5432/db`).
  ///
  /// Can be set via `VANESTACK_POSTGRES_URL` environment variable.
  /// Required when [databaseBackend] is [DatabaseBackend.postgres].
  ///
  /// Supports schemes `postgres://` and `postgresql://`. An optional
  /// `sslmode=` query parameter controls TLS:
  /// `disable`, `require` (default), or `verify-full`.
  final String? postgresUrl;

  /// Maximum requests per rate limit window.
  /// Can be set via `VANESTACK_RATE_LIMIT_MAX` environment variable.
  /// Defaults to 10.
  final int rateLimitMax;

  /// Rate limit window duration in seconds.
  /// Can be set via `VANESTACK_RATE_LIMIT_WINDOW_SECONDS` environment variable.
  /// Defaults to 60.
  final int rateLimitWindowSeconds;

  /// Number of days to retain logs. 0 = no cleanup.
  /// Can be set via `VANESTACK_LOG_RETENTION_DAYS` environment variable.
  /// Defaults to 30.
  final int logRetentionDays;

  /// Default max file size: 50MB
  static const int defaultMaxFileSize = 50 * 1024 * 1024;
  const Environment({
    this.jwtSecret = 'super_secret_jwt_key',
    this.port = 8080,
    this.localStorageEnabled = true,
    this.localStoragePath = './data/storage',
    this.logLevel = LogLevel.info,
    this.maxFileSize = defaultMaxFileSize,
    this.databaseBackend = DatabaseBackend.sqlite,
    this.sqlitePath = './data/database.sqlite',
    this.postgresUrl,
    this.rateLimitMax = 10,
    this.rateLimitWindowSeconds = 60,
    this.logRetentionDays = 30,
  });

  /// Creates an Environment from system environment variables.
  ///
  /// Falls back to provided defaults or built-in defaults if env vars are not set.
  factory Environment.fromEnv({
    int? defaultPort,
    String? defaultJwtSecret,
    bool? defaultLocalStorageEnabled,
    String? defaultLocalStoragePath,
    LogLevel? defaultLogLevel,
    int? defaultMaxFileSize,
    DatabaseBackend? defaultDatabaseBackend,
    String? defaultSqlitePath,
    String? defaultPostgresUrl,
    int? defaultRateLimitMax,
    int? defaultRateLimitWindowSeconds,
    int? defaultLogRetentionDays,
  }) {
    final envPort = Platform.environment['VANESTACK_PORT'];
    final envSecret = Platform.environment['VANESTACK_JWT_SECRET_KEY'];
    final envLocalStorage =
        Platform.environment['VANESTACK_LOCAL_STORAGE_ENABLED'];
    final envLocalStoragePath =
        Platform.environment['VANESTACK_LOCAL_STORAGE_PATH'];
    final envLogLevel = Platform.environment['VANESTACK_LOG_LEVEL'];
    final envMaxFileSize = Platform.environment['VANESTACK_MAX_FILE_SIZE'];
    final envDatabase = Platform.environment['VANESTACK_DATABASE'];
    final envSqlitePath = Platform.environment['VANESTACK_SQLITE_PATH'];
    final envPostgresUrl = Platform.environment['VANESTACK_POSTGRES_URL'];
    final envRateLimitMax = Platform.environment['VANESTACK_RATE_LIMIT_MAX'];
    final envRateLimitWindow =
        Platform.environment['VANESTACK_RATE_LIMIT_WINDOW_SECONDS'];
    final envLogRetention =
        Platform.environment['VANESTACK_LOG_RETENTION_DAYS'];

    final backend = switch (envDatabase?.toLowerCase()) {
      'postgres' || 'postgresql' => DatabaseBackend.postgres,
      'sqlite' => DatabaseBackend.sqlite,
      null => defaultDatabaseBackend ?? DatabaseBackend.sqlite,
      final other => throw ArgumentError.value(
          other,
          'VANESTACK_DATABASE',
          'Expected "sqlite" or "postgres".',
        ),
    };

    return Environment(
      port: envPort != null
          ? int.tryParse(envPort) ?? defaultPort ?? 8080
          : defaultPort ?? 8080,
      jwtSecret: envSecret ?? defaultJwtSecret ?? 'super_secret_jwt_key',
      localStorageEnabled: envLocalStorage != null
          ? envLocalStorage.toLowerCase() == 'true'
          : defaultLocalStorageEnabled ?? true,
      localStoragePath:
          envLocalStoragePath ?? defaultLocalStoragePath ?? './data/storage',
      logLevel: switch (envLogLevel?.toLowerCase()) {
        'debug' => LogLevel.debug,
        'info' => LogLevel.info,
        'warn' => LogLevel.warn,
        'error' => LogLevel.error,
        'none' => LogLevel.none,
        _ => defaultLogLevel ?? LogLevel.info,
      },
      maxFileSize: envMaxFileSize != null
          ? int.tryParse(envMaxFileSize) ??
                defaultMaxFileSize ??
                Environment.defaultMaxFileSize
          : defaultMaxFileSize ?? Environment.defaultMaxFileSize,
      databaseBackend: backend,
      sqlitePath:
          envSqlitePath ?? defaultSqlitePath ?? './data/database.sqlite',
      postgresUrl: envPostgresUrl ?? defaultPostgresUrl,
      rateLimitMax: envRateLimitMax != null
          ? int.tryParse(envRateLimitMax) ?? defaultRateLimitMax ?? 10
          : defaultRateLimitMax ?? 10,
      rateLimitWindowSeconds: envRateLimitWindow != null
          ? int.tryParse(envRateLimitWindow) ??
                defaultRateLimitWindowSeconds ??
                60
          : defaultRateLimitWindowSeconds ?? 60,
      logRetentionDays: envLogRetention != null
          ? int.tryParse(envLogRetention) ?? defaultLogRetentionDays ?? 30
          : defaultLogRetentionDays ?? 30,
    );
  }
}
