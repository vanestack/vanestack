import 'dart:core';

import 'package:args/command_runner.dart';
import 'package:mailer/smtp_server.dart';
import 'package:shelf/shelf.dart';
import 'package:vanestack_common/vanestack_common.dart' show LogLevel;

import 'src/commands/collections.dart';
import 'src/commands/deploy.dart';
import 'src/commands/documents.dart';
import 'src/commands/generate.dart';
import 'src/commands/login.dart';
import 'src/commands/logout.dart';
import 'src/commands/logs.dart';
import 'src/commands/settings.dart';
import 'src/commands/start.dart';
import 'src/commands/storage.dart';
import 'src/commands/users.dart';
import 'src/database/database.dart';
import 'src/realtime/realtime.dart';
import 'src/server.dart';
import 'src/services/auth_service.dart';
import 'src/services/collections_service.dart';
import 'src/services/context.dart';
import 'src/services/documents_service.dart';
import 'src/services/hook_runner.dart';
import 'src/services/hooks.dart';
import 'src/services/logs_service.dart';
import 'src/services/settings_service.dart';
import 'src/services/storage_service.dart';
import 'src/services/users_service.dart';
import 'src/utils/env.dart';
import 'src/utils/http_method.dart';

export 'package:vanestack_common/vanestack_common.dart' show LogLevel;

export 'src/realtime/realtime.dart' show Transport;
export 'src/services/hooks.dart';
export 'src/utils/env.dart' show Environment, DatabaseBackend;
export 'src/utils/http_method.dart';
export 'src/utils/logger.dart' show Logger;

/// Public API for VaneStack server.
///
/// Configuration can be set via constructor parameters or environment variables.
/// See [Environment] for available options.
///
/// Constructor parameters take precedence over environment variables.
class VaneStack {
  final Map<(HttpMethod, String), Handler> _customRoutes = {};
  final Set<(HttpMethod, String)> _ignoredForClient = {};
  final HookExecutor _hookExecutor = HookExecutor();
  late final HookRegistry _hooks = HookRegistry(_hookExecutor);

  /// The environment configuration for the server.
  late final Environment env;

  VaneStack({
    int port = 8080,
    String jwtSecret = 'super_secret_jwt_key',
    bool localStorageEnabled = true,
    String localStoragePath = './data/storage',
    LogLevel logLevel = LogLevel.info,
    int maxFileSize = Environment.defaultMaxFileSize,
    DatabaseBackend databaseBackend = DatabaseBackend.sqlite,
    String sqlitePath = './data/database.sqlite',
    String? postgresUrl,
  }) {
    env = Environment.fromEnv(
      defaultPort: port,
      defaultJwtSecret: jwtSecret,
      defaultLocalStorageEnabled: localStorageEnabled,
      defaultLocalStoragePath: localStoragePath,
      defaultLogLevel: logLevel,
      defaultMaxFileSize: maxFileSize,
      defaultDatabaseBackend: databaseBackend,
      defaultSqlitePath: sqlitePath,
      defaultPostgresUrl: postgresUrl,
    );
  }

  late final _internalServer = VaneStackServer(
    customRoutes: () => _customRoutes,
    env: env,
    hooks: _hookExecutor,
  );

  late final _runner =
      CommandRunner('VaneStack', 'Your superpowered dart backend server.')
        ..addCommand(StartCommand(_internalServer))
        ..addCommand(UsersCommand(env))
        ..addCommand(CollectionsCommand(env))
        ..addCommand(DocumentsCommand(env))
        ..addCommand(StorageCommand(env))
        ..addCommand(LogsCommand(env))
        ..addCommand(SettingsCommand(env))
        ..addCommand(GenerateClientCommand(_customRoutes, _ignoredForClient))
        ..addCommand(LoginCommand())
        ..addCommand(LogoutCommand())
        ..addCommand(DeployCommand());

  /// Access to the database instance.
  /// This database is a drift sqlite database.
  ///
  /// https://pub.dev/packages/drift
  AppDatabase get database => _internalServer.database;

  /// Access to the realtime event bus.
  ///
  RealtimeEventBus get realtime => _internalServer.realtime;

  /// Access to the hook registry for registering before/after callbacks.
  ///
  /// Example:
  /// ```dart
  /// vanestack.hooks.onBeforeDocumentCreate((e) {
  ///   e.data['slug'] = slugify(e.data['title']);
  /// });
  ///
  /// vanestack.hooks.onAfterDocumentCreate((e) {
  ///   print('Created ${e.result.id} in ${e.collectionName}');
  /// });
  /// ```
  HookRegistry get hooks => _hooks;

  /// Single context instance shared by all services.
  late final ServiceContext _serviceContext = (
    database: _internalServer.database,
    env: env,
    realtime: _internalServer.realtime,
    hooks: _hookExecutor,
  );

  /// Access to the users service for programmatic user management.
  ///
  /// Example:
  /// ```dart
  /// final user = await vanestack.users.create(
  ///   email: 'test@example.com',
  ///   password: 'SecurePass123!',
  /// );
  /// ```
  late final UsersService users = UsersService(_serviceContext);

  /// Access to the auth service for programmatic authentication.
  ///
  /// Example:
  /// ```dart
  /// final response = await vanestack.auth.signInWithEmailAndPassword(
  ///   email: 'test@example.com',
  ///   password: 'SecurePass123!',
  /// );
  /// ```
  late final AuthService auth = AuthService(_serviceContext);

  /// Access to the collections service for programmatic collection management.
  ///
  /// Example:
  /// ```dart
  /// final collection = await vanestack.collections.getByName('posts');
  /// ```
  late final CollectionsService collections = CollectionsService(
    _serviceContext,
  );

  /// Access to the documents service for programmatic document management.
  ///
  /// Example:
  /// ```dart
  /// final doc = await vanestack.documents.create(
  ///   collectionName: 'posts',
  ///   data: {'title': 'Hello World'},
  /// );
  /// ```
  late final DocumentsService documents = DocumentsService(_serviceContext);

  /// Access to the storage service for programmatic storage management.
  ///
  /// Example:
  /// ```dart
  /// final bucket = await vanestack.storageService.createBucket(name: 'images');
  /// ```
  late final StorageService storage = StorageService(_serviceContext);

  /// Access to the settings service for programmatic settings management.
  ///
  /// Example:
  /// ```dart
  /// final settings = await vanestack.settingsService.get();
  /// ```
  late final SettingsService settings = SettingsService(_serviceContext);

  /// Access to the logs service for programmatic log access.
  ///
  /// Example:
  /// ```dart
  /// final result = await vanestack.logs.list(limit: 50);
  /// ```
  late final LogsService logs = LogsService(_serviceContext);

  Future<void> run(List<String> args) => _runner.run(args);

  /// Adds [Command] as a top-level command to this runner.
  ///
  /// Find out more at:
  ///
  /// https://pub.dev/packages/args#dispatching-commands
  void addCommand(Command command) => _runner.addCommand(command);

  /// Retrieves the SMTP server configuration.
  /// Uses the mailer package to send emails.
  ///
  /// https://pub.dev/packages/mailer
  ///
  /// ```dart
  /// final smtpServer = await vanestack.smtpServer();
  /// final message = Message(...);
  /// final sendReport = await send(message, smtpServer);
  /// ```
  Future<SmtpServer> smtpServer() async {
    final appSettings = await settings.get();

    if (appSettings.mail == null) {
      throw Exception('Mailer is not configured.');
    }

    final opts = appSettings.mail!;

    return SmtpServer(
      opts.smtpServer,
      port: opts.smtpPort,
      username: opts.username,
      password: opts.password,
      ssl: opts.useSsl,
    );
  }

  /// Adds a custom route to the server.
  ///
  /// [method] The HTTP method for the route.
  /// [path] The path of the route. Can have parameters like `/users/<userId>`.
  /// [handler] The handler function for the route.
  /// [ignoreForClient] If true, this route will not be included in the
  /// generated client SDK.
  ///
  /// Example:
  /// ```dart
  /// vanestack.addRoute(HttpMethod.get, '/hello', (request) => Response.ok('Hello!'));
  /// vanestack.addRoute(HttpMethod.get, '/internal', handler, ignoreForClient: true);
  /// ```
  void addRoute(
    HttpMethod method,
    String path,
    Handler handler, {
    bool ignoreForClient = false,
  }) {
    _customRoutes[(method, path)] = handler;
    if (ignoreForClient) {
      _ignoredForClient.add((method, path));
    }
  }
}
