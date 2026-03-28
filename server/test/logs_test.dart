import 'dart:io';

import 'package:vanestack/src/database/database.dart';
import 'package:vanestack/src/server.dart';
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

    // Clear any logs generated during server startup and disable DB logging for tests
    await database.logs.deleteAll();
    configureLogger(clearDatabase: true);

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
    configureLogger(clearDatabase: true);
    client.close();
    await server.stop();
  });

  group('list logs -', () {
    test('retrieves logs for superuser', () async {
      // Insert test logs
      await database.logs.insertAll([
        LogsCompanion.insert(
          level: LogLevel.info,
          source: LogSource.server,
          message: 'Server started',
        ),
        LogsCompanion.insert(
          level: LogLevel.warn,
          source: LogSource.auth,
          message: 'Invalid login attempt',
        ),
        LogsCompanion.insert(
          level: LogLevel.error,
          source: LogSource.database,
          message: 'Query failed',
        ),
      ]);

      final res = await client.get('/v1/logs');

      expect(res.status, 200);
      final result = ListAppLogsResultMapper.fromJson(res.json!);
      expect(result.count, equals(3));
      expect(result.logs.length, equals(3));
    });

    test('applies orderBy ascending', () async {
      await database.logs.insertAll([
        LogsCompanion.insert(
          level: LogLevel.info,
          source: LogSource.server,
          message: 'C message',
        ),
        LogsCompanion.insert(
          level: LogLevel.info,
          source: LogSource.server,
          message: 'A message',
        ),
        LogsCompanion.insert(
          level: LogLevel.info,
          source: LogSource.server,
          message: 'B message',
        ),
      ]);

      final res = await client.get('/v1/logs', query: {'orderBy': 'message'});

      expect(res.status, 200);
      final result = ListAppLogsResultMapper.fromJson(res.json!);
      expect(result.logs[0].message, equals('A message'));
      expect(result.logs[1].message, equals('B message'));
      expect(result.logs[2].message, equals('C message'));
    });

    test('applies limit parameter', () async {
      await database.logs.insertAll(
        List.generate(
          10,
          (i) => LogsCompanion.insert(
            level: LogLevel.info,
            source: LogSource.server,
            message: 'Log entry $i',
          ),
        ),
      );

      final res = await client.get('/v1/logs', query: {'limit': '3'});

      expect(res.status, 200);
      final result = ListAppLogsResultMapper.fromJson(res.json!);
      expect(result.logs.length, equals(3));
      expect(result.count, equals(10));
    });

    test('applies filter by level', () async {
      await database.logs.insertAll([
        LogsCompanion.insert(
          level: LogLevel.info,
          source: LogSource.server,
          message: 'Info log',
        ),
        LogsCompanion.insert(
          level: LogLevel.error,
          source: LogSource.auth,
          message: 'Error log',
        ),
        LogsCompanion.insert(
          level: LogLevel.info,
          source: LogSource.database,
          message: 'Another info',
        ),
      ]);

      final res = await client.get(
        '/v1/logs',
        query: {'filter': "level='info'"},
      );

      expect(res.status, 200);
      final result = ListAppLogsResultMapper.fromJson(res.json!);
      expect(result.count, equals(2));
      expect(result.logs.every((log) => log.level == LogLevel.info), isTrue);
    });

    test('applies filter by source', () async {
      await database.logs.insertAll([
        LogsCompanion.insert(
          level: LogLevel.info,
          source: LogSource.server,
          message: 'Server log',
        ),
        LogsCompanion.insert(
          level: LogLevel.info,
          source: LogSource.auth,
          message: 'Auth log',
        ),
        LogsCompanion.insert(
          level: LogLevel.info,
          source: LogSource.server,
          message: 'Another server log',
        ),
      ]);

      final res = await client.get(
        '/v1/logs',
        query: {'filter': "source='server'"},
      );

      expect(res.status, 200);
      final result = ListAppLogsResultMapper.fromJson(res.json!);
      expect(result.count, equals(2));
      expect(result.logs.every((log) => log.source == LogSource.server), isTrue);
    });

    test('returns 403 for non-superuser', () async {
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

      try {
        final res = await nonSuperuserClient.get('/v1/logs');
        expect(res.status, 403);
      } finally {
        nonSuperuserClient.close();
      }
    });

    test('returns empty result when no logs exist', () async {
      final res = await client.get('/v1/logs');

      expect(res.status, 200);
      final result = ListAppLogsResultMapper.fromJson(res.json!);
      expect(result.count, equals(0));
      expect(result.logs, isEmpty);
    });
  });
}
