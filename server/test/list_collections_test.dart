import 'dart:convert';
import 'dart:io';

import 'package:vanestack/src/database/database.dart';
import 'package:vanestack/src/server.dart';
import 'package:vanestack/src/utils/auth.dart';
import 'package:vanestack/src/utils/env.dart';

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
    client.close();
    database.close();
    await server.stop();
  });

  test('listTables - returns user-defined tables', () async {
    // Arrange: ensure some tables exist (drift final db = container.read(dbProvider);
    // Optionally create a dummy table
    await database.customStatement(
      'CREATE TABLE IF NOT EXISTS dummy_table (id INTEGER PRIMARY KEY, name TEXT)',
    );

    await database.collections.insertOne(
      CollectionsCompanion.insert(
        name: 'dummy_table',
        attributes: Value([
          IntAttribute(name: 'id', primaryKey: true),
          TextAttribute(name: 'name'),
        ]),
      ),
    );

    // Act: call the endpoint
    final res = await client.get('/v1/collections');

    // Assert
    expect(res.status, 200);

    final json = jsonDecode(res.body);

    expect(json, isA<List>());

    // Check that dummy_table or another drift table is listed
    final collections = (json as List)
        .map((e) => CollectionMapper.fromJson(e))
        .toList();

    expect(collections, hasLength(1));
    expect(collections.first.name, equals('dummy_table'));
  });
}
