import 'dart:convert';
import 'dart:io';

import 'package:drift/drift.dart';
import 'package:mailer/smtp_server.dart';
import 'package:shelf/shelf.dart';
import 'package:vanestack_common/vanestack_common.dart';

import '../database/database.dart';
import '../realtime/realtime.dart';
import '../services/auth_service.dart';
import '../services/collections_service.dart';
import '../services/context.dart';
import '../services/documents_service.dart';
import '../services/hook_runner.dart';
import '../services/logs_service.dart';
import '../services/settings_service.dart';
import '../services/storage_service.dart';
import '../services/users_service.dart';
import '../storage/local_storage.dart';
import '../storage/s3_storage.dart';
import '../storage/storage.dart';
import '../utils/s3.dart';
import 'env.dart';

extension RequestUtils on Request {
  String? get bearerToken {
    final authHeader = headers[HttpHeaders.authorizationHeader];
    if (authHeader != null && authHeader.startsWith('Bearer ')) {
      return authHeader.replaceFirst('Bearer ', '');
    }

    if (url.queryParameters.containsKey('token')) {
      return url.queryParameters['token'];
    }

    return null;
  }

  bool get isSuperUser {
    final userType = context['userType'];
    return userType != null && userType == UserType.admin;
  }

  String? get userId {
    final uid = context['userId'];
    if (uid != null && uid is String) {
      return uid;
    }
    return null;
  }
}

Response response(
  int statusCode, {
  Map<String, Object?>? result,
  String? error,
}) {
  return Response(
    statusCode,
    encoding: Encoding.getByName('utf-8'),
    headers: {HttpHeaders.contentTypeHeader: 'application/json'},
    body: jsonEncode(result ?? {'error': error}),
  );
}

extension PublicUser on DbUser {
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

extension PublicFile on DbFile {
  File toPublic() {
    return File(
      id: id,
      path: path,
      bucket: bucket,
      size: size,
      mimeType: mimeType,
      metadata: metadata,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }
}

extension ServicesX on Request {
  AppDatabase get database {
    final database = context['database'];

    if (database == null || database is! AppDatabase) {
      throw Exception('Database not found in request context');
    }

    return database;
  }

  Environment get env {
    final env = context['env'];

    if (env == null || env is! Environment) {
      throw Exception('Environment not found in request context');
    }

    return env;
  }

  RealtimeEventBus get realtime {
    final realtime = context['realtime'];

    if (realtime == null || realtime is! RealtimeEventBus) {
      throw Exception('RealtimeEventBus not found in request context');
    }

    return realtime;
  }

  /// Retrieves the application settings from the database.
  Future<Settings> settings() async {
    final settings = await (database.appSettings.select()..limit(1))
        .getSingleOrNull();

    if (settings == null) {
      throw VaneStackException(
        'Application settings not found.',
        status: HttpStatus.internalServerError,
        code: StorageErrorCode.settingsNotFound,
      );
    }

    return settings;
  }

  /// Retrieves the SMTP server configuration.
  /// Use with the mailer package to send emails.
  ///
  /// ```dart
  /// final smtpServer = await request.smtpServer();
  /// final message = Message(...);
  /// final sendReport = await send(message, smtpServer);
  /// ```
  Future<SmtpServer> smtpServer() async {
    final appSettings = await settings();

    if (appSettings.mail == null) {
      throw VaneStackException(
        'Mailer is not configured.',
        status: HttpStatus.internalServerError,
        code: SettingsErrorCode.mailerNotConfigured,
      );
    }

    final opts = appSettings.mail!;

    return SmtpServer(
      opts.smtpServer,
      port: opts.smtpPort,
      username: opts.username,
      password: opts.password,
      ssl: opts.useSsl,
      allowInsecure: !opts.useSsl,
    );
  }

  /// Retrieves the storage backend based on application settings.
  ///
  /// If S3 is configured and enabled, returns S3 storage.
  /// Otherwise returns local storage (if enabled via environment).
  ///
  /// Use [forceLocal] to always use local storage regardless of settings.
  ///
  /// Throws [VaneStackException] if local storage is disabled and S3 is not configured.
  Future<Storage> storage({bool forceLocal = false}) async {
    final appSettings = await settings();

    // Check if we should use S3
    if (!forceLocal && appSettings.s3 != null && appSettings.s3!.enabled) {
      return S3Storage(client: S3Client(appSettings.s3!));
    }

    // Check if local storage is enabled
    if (!env.localStorageEnabled) {
      throw VaneStackException(
        'Local storage is disabled and S3 is not configured.',
        status: HttpStatus.serviceUnavailable,
        code: StorageErrorCode.storageNotConfigured,
      );
    }

    return LocalStorage(folder: env.localStoragePath);
  }

  HookExecutor? get hooks => context['hooks'] as HookExecutor?;

  /// Creates a ServiceContext from the request context.
  ServiceContext get serviceContext =>
      (database: database, env: env, realtime: realtime, hooks: hooks);

  /// Access the UsersService.
  UsersService get users => UsersService(serviceContext);

  /// Access the AuthService.
  AuthService get auth => AuthService(serviceContext);

  /// Access the CollectionsService.
  CollectionsService get collections => CollectionsService(serviceContext);

  /// Access the DocumentsService.
  DocumentsService get documents => DocumentsService(serviceContext);

  /// Access the StorageService.
  StorageService get storageService => StorageService(serviceContext);

  /// Access the SettingsService.
  SettingsService get settingsService => SettingsService(serviceContext);

  /// Access the LogsService.
  LogsService get logs => LogsService(serviceContext);
}
