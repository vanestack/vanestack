import 'package:vanestack/src/database/database.dart';
import 'package:vanestack/src/server.dart';
import 'package:vanestack/src/utils/env.dart';
import 'package:vanestack_common/vanestack_common.dart';

class MockServer extends VaneStackServer {
  final AppDatabase _db;

  MockServer({required AppDatabase db, required Environment env})
      : _db = db,
        super(
          env: Environment(
            port: env.port,
            jwtSecret: env.jwtSecret,
            logLevel: LogLevel.none,
            localStorageEnabled: env.localStorageEnabled,
            localStoragePath: env.localStoragePath,
            maxFileSize: env.maxFileSize,
            databasePath: env.databasePath,
            rateLimitMax: env.rateLimitMax,
            rateLimitWindowSeconds: env.rateLimitWindowSeconds,
            logRetentionDays: env.logRetentionDays,
          ),
        );

  @override
  AppDatabase get database => _db;
}
