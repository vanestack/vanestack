import 'dart:io';

import 'package:vanestack/src/database/database.dart';
import 'package:vanestack/src/server.dart';
import 'package:vanestack/src/utils/auth.dart';
import 'package:vanestack/src/utils/env.dart';

import 'package:vanestack_common/vanestack_common.dart';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';

import 'package:test/test.dart';
import 'package:uuid/uuid.dart';

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

    await database.users.insertAll(
      List.generate(
        10,
        (index) => UsersCompanion.insert(
          id: const Uuid().v7(),
          email: 'user_$index@test.com',
          superUser: Value(index % 2 == 0),
        ),
      ),
    );
  });

  tearDown(() async {
    client.close();
    database.close();
    await server.stop();
  });
  group('listUsers -', () {
    test('retrieves all users without filter', () async {
      // Act: call the endpoint
      final res = await client.get('/v1/users');

      expect(res.status, 200);
      final result = ListUsersResultMapper.fromJson(res.json!);
      expect(result.count, equals(10)); // count is total, not filtered
      expect(result.users.length, equals(10));
    });

    test('applies orderBy correctly', () async {
      final res = await client.get('/v1/users', query: {'orderBy': '-email'});

      expect(res.status, 200);
      final result = ListUsersResultMapper.fromJson(res.json!);
      expect(result.users.first.email, equals('user_9@test.com'));
      expect(result.users.last.email, equals('user_0@test.com'));
    });

    test('applies limit and offset', () async {
      final res = await client.get(
        '/v1/users',
        query: {'limit': '2', 'offset': '1'},
      );

      expect(res.status, 200);
      final result = ListUsersResultMapper.fromJson(res.json!);
      expect(result.users.length, equals(2));
    });

    test('applies filter correctly', () async {
      final res = await client.get(
        '/v1/users',
        query: {'filter': "email='user_1@test.com'"},
      );

      expect(res.status, 200);
      final result = ListUsersResultMapper.fromJson(res.json!);
      expect(result.count, equals(1)); // count is total, not filtered
      expect(result.users.length, equals(1));
      expect(result.users.first.email, equals('user_1@test.com'));
    });
  });
}
