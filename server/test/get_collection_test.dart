import 'dart:io';

import 'package:vanestack/src/database/database.dart';
import 'package:vanestack/src/server.dart';
import 'package:vanestack/src/utils/auth.dart';
import 'package:vanestack/src/utils/env.dart';
import 'package:vanestack_common/vanestack_common.dart';
import 'package:drift/drift.dart' show driftRuntimeOptions, Value, TableStatements;
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

  group('getCollection', () {
    test('successfully retrieves a collection by name', () async {
      // Arrange - create a collection
      await database.customStatement(
        'CREATE TABLE books (id TEXT PRIMARY KEY, title TEXT, created_at INTEGER, updated_at INTEGER)',
      );

      await database.collections.insertOne(
        CollectionsCompanion.insert(
          name: 'books',
          attributes: Value([
            TextAttribute(name: 'title'),
          ]),
          indexes: Value([
            Index(name: 'idx_books_title', columns: ['title']),
          ]),
          listRule: Value('user.id != null'),
        ),
      );

      // Act
      final res = await client.get('/v1/collections/books');

      // Assert
      expect(res.status, 200);
      expect(res.json!['name'], equals('books'));
      expect(res.json!['attributes'], isA<List>());
      expect(res.json!['indexes'], isA<List>());
      expect(res.json!['list_rule'], equals('user.id != null'));

      final collection = CollectionMapper.fromJson(res.json!) as BaseCollection;
      expect(collection.name, equals('books'));
      expect(collection.attributes.length, greaterThan(0));
      expect(collection.indexes.length, equals(1));
      expect(collection.indexes.first.name, equals('idx_books_title'));
    });

    test('returns 404 when collection does not exist', () async {
      final res = await client.get('/v1/collections/nonexistent');

      expect(res.status, 404);
      expect(
        res.json!['error']['message'],
        contains('not found'),
      );
    });

    test('returns 400 for invalid collection name', () async {
      final res = await client.get('/v1/collections/123_invalid!');

      expect(res.status, 400);
      expect(
        res.json!['error']['message'],
        contains('Invalid collection name'),
      );
    });

    test('returns collection with all rule fields', () async {
      await database.customStatement(
        'CREATE TABLE users (id TEXT PRIMARY KEY, email TEXT, created_at INTEGER, updated_at INTEGER)',
      );

      await database.collections.insertOne(
        CollectionsCompanion.insert(
          name: 'users',
          attributes: Value([
            TextAttribute(name: 'email'),
          ]),
          listRule: Value('user.id != null'),
          viewRule: Value('user.id == record.id'),
          createRule: Value('user.id != null'),
          updateRule: Value('user.id == record.id'),
          deleteRule: Value('user.role == "admin"'),
        ),
      );

      final res = await client.get('/v1/collections/users');

      expect(res.status, 200);
      final collection = CollectionMapper.fromJson(res.json!) as BaseCollection;
      expect(collection.listRule, equals('user.id != null'));
      expect(collection.viewRule, equals('user.id == record.id'));
      expect(collection.createRule, equals('user.id != null'));
      expect(collection.updateRule, equals('user.id == record.id'));
      expect(collection.deleteRule, equals('user.role == "admin"'));
    });

    test('returns 400 when collection name is empty', () async {
      final res = await client.get('/v1/collections/');

      expect(res.status, 404);
    });
  });
}
