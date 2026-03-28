import 'dart:io';

import 'package:vanestack/src/database/database.dart';
import 'package:vanestack/src/server.dart';
import 'package:vanestack/src/utils/auth.dart';
import 'package:vanestack/src/utils/env.dart';
import 'package:vanestack_common/vanestack_common.dart';

import 'package:drift/drift.dart' hide isNull;
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

  group('deleteCollection', () {
    test('successfully deletes an existing collections', () async {
      // Arrange

      await database.customStatement(
        'CREATE TABLE IF NOT EXISTS books (id INTEGER PRIMARY KEY, title TEXT)',
      );

      await database.collections.insertOne(
        CollectionsCompanion.insert(
          name: 'books',
          type: const Value('base'),
          attributes: Value([TextAttribute(name: 'title')]),
          indexes: const Value([]),
        ),
      );

      // Act
      final res = await client.del('/v1/collections/books');

      // Assert
      expect(res.status, 200);

      // Verify table is actually gone
      final tables = await database
          .customSelect(
            "SELECT name FROM sqlite_master WHERE type='table' AND name='books'",
          )
          .get();
      expect(tables, isEmpty);

      final collection =
          await (database.collections.select()
                ..where((tbl) => tbl.name.equals('books')))
              .getSingleOrNull();

      expect(collection, isNull);
    });

    test('returns 404 when collection name is missing', () async {
      final res = await client.del('/v1/collections/');

      expect(res.status, 404);
    });

    test('returns 400 for invalid collection name', () async {
      final res = await client.del('/v1/collections/123_invalid!');

      expect(res.status, 400);
      expect(
        res.json!['error']['message'],
        contains('Invalid collection name'),
      );
    });

    test('returns 404 if collection does not exist', () async {
      final res = await client.del('/v1/collections/nonexistent');

      expect(res.status, 404);
      expect(
        res.json!['error']['message'],
        contains('not found'),
      );
    });
  });
}
