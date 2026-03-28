import 'dart:async';
import 'dart:io';

import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart' as shelf_io;
import 'package:shelf_proxy/shelf_proxy.dart';
import 'package:shelf_router/shelf_router.dart';
import 'package:shelf_static/shelf_static.dart';

import 'database/database.dart';
import 'embedded_site.dart';
import 'middleware/cors.dart';
import 'middleware/decode_jwt.dart';
import 'middleware/inject.dart';
import 'middleware/pretty_logger.dart';
import 'middleware/rate_limit.dart';
import 'realtime/realtime.dart';
import 'routes.dart';
import 'services/context.dart';
import 'services/hook_runner.dart';
import 'services/hooks.dart';
import 'services/logs_service.dart';
import 'utils/env.dart';
import 'utils/http_method.dart';
import 'utils/logger.dart';

const bool kReleaseMode = bool.fromEnvironment('dart.vm.product');

class VaneStackServer {
  late HttpServer? _httpServer;
  Timer? _logCleanupTimer;

  late final AppDatabase database = AppDatabase(null, env.databasePath);

  final Environment env;

  final realtime = RealtimeEventBus();

  final Map<(HttpMethod, String), Handler>? Function()? customRoutes;

  final HookExecutor? hooks;

  VaneStackServer({this.customRoutes, required this.env, this.hooks});

  Future<void> start({bool devMode = false}) async {
    configureLogger(logLevel: env.logLevel, database: database);

    // Warn about insecure default JWT secret
    if (env.jwtSecret == 'super_secret_jwt_key') {
      serverLogger.warn(
        '⚠️  WARNING: Using default JWT secret key. '
        'Set VANESTACK_JWT_SECRET_KEY environment variable to a secure value in production.',
      );
    }

    serverLogger.info(
      'Starting VaneStack server...',
      context: 'port=${env.port}, mode=${kReleaseMode ? 'release' : 'debug'}',
    );

    var router = Router();

    registerRoutes(router);
    serverLogger.debug('Routes registered');

    router.mount('/_/', (Request req) {
      if (!devMode) {
        var path = req.url.path;
        if (path.isEmpty) {
          path += 'index.html';
        }

        final file = EmbeddedSite.files['build/jaspr/$path'];
        if (file == null) {
          return Response.ok(
            EmbeddedSite.files['build/jaspr/index.html']!,
            headers: {'content-type': 'text/html'},
          );
        }

        return Response.ok(file, headers: {'content-type': _guessMime(path)});
      } else {
        return proxyHandler("http://localhost:8079")(req);
      }
    });

    final routes = customRoutes?.call() ?? <(HttpMethod, String), Handler>{};
    for (final MapEntry(:key, :value) in routes.entries) {
      router.add(key.$1.name, key.$2, value);
    }

    final publicDir = Directory('public');
    if (publicDir.existsSync()) {
      router.mount('/', createStaticHandler('public'));
    }

    final handler = const Pipeline()
        .addMiddleware(
          inject({
            'database': database,
            'env': env,
            'realtime': realtime,
            'hooks': ?hooks,
          }),
        )
        .addMiddleware(cors())
        .addMiddleware(prettyLogger())
        .addMiddleware(rateLimit())
        .addMiddleware(decodeJwt())
        .addHandler(router.call);

    _httpServer = await shelf_io.serve(
      handler,
      InternetAddress.anyIPv4,
      env.port,
      shared: true,
    );

    _httpServer?.autoCompress = true;
    _httpServer?.serverHeader = 'VaneStack';

    // Set up periodic log cleanup
    if (env.logRetentionDays > 0) {
      final ServiceContext serviceContext = (
        database: database,
        env: env,
        realtime: null,
        hooks: null,
      );
      final logsService = LogsService(serviceContext);

      // Run cleanup immediately on startup
      final deleted = await logsService.cleanup(
        retentionDays: env.logRetentionDays,
      );
      if (deleted > 0) {
        serverLogger.info('Log cleanup: removed $deleted old log entries');
      }

      // Schedule daily cleanup
      _logCleanupTimer = Timer.periodic(const Duration(hours: 24), (_) async {
        try {
          final count = await logsService.cleanup(
            retentionDays: env.logRetentionDays,
          );
          if (count > 0) {
            serverLogger.info('Log cleanup: removed $count old log entries');
          }
        } catch (e, st) {
          serverLogger.error('Log cleanup failed', error: e, stackTrace: st);
        }
      });
    }

    serverLogger.info(
      'Server started successfully',
      context:
          'address=http://${_httpServer!.address.host}:${_httpServer!.port}',
    );

    try {
      await hooks?.runServerStarted(
        ServerStartedEvent(
          address: _httpServer!.address.host,
          port: _httpServer!.port,
        ),
      );
    } catch (e, st) {
      serverLogger.error('ServerStarted hook failed', error: e, stackTrace: st);
    }
  }

  Future<void> stop() async {
    serverLogger.info('Shutting down server...');
    try {
      await hooks?.runServerStopped(ServerStoppedEvent());
    } catch (e, st) {
      serverLogger.error('ServerStopped hook failed', error: e, stackTrace: st);
    }
    _logCleanupTimer?.cancel();
    await _httpServer?.close(force: true);
    await shutdownLogger();
    await database.close();
    serverLogger.info('Server stopped');
  }
}

String _guessMime(String path) {
  if (path.endsWith('.html')) return 'text/html';
  if (path.endsWith('.css')) return 'text/css';
  if (path.endsWith('.js')) return 'application/javascript';
  if (path.endsWith('.png')) return 'image/png';
  if (path.endsWith('.jpg')) return 'image/jpeg';
  if (path.endsWith('.jpeg')) return 'image/jpeg';
  if (path.endsWith('.svg')) return 'image/svg+xml';
  if (path.endsWith('.json')) return 'application/json';
  return 'application/octet-stream';
}
