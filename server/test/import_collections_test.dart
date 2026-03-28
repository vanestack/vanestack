import 'dart:io';

import 'package:vanestack/src/database/database.dart';
import 'package:vanestack/src/server.dart';
import 'package:vanestack/src/utils/auth.dart';
import 'package:vanestack/src/utils/env.dart';
import 'package:vanestack_common/vanestack_common.dart';
import 'package:drift/drift.dart' show driftRuntimeOptions;
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

  group('importCollections', () {
    test('successfully imports new collections', () async {
      final collections = [
        {
          'name': 'books',
          'type': 'base',
          'attributes': [
            TextAttribute(name: 'title', nullable: false).toJson(),
            TextAttribute(name: 'author').toJson(),
          ],
          'indexes': [
            Index(name: 'idx_books_title', columns: ['title']).toJson(),
          ],
          'list_rule': 'user.id != null',
          'created_at': DateTime.now().millisecondsSinceEpoch ~/ 1000,
          'updated_at': DateTime.now().millisecondsSinceEpoch ~/ 1000,
        },
        {
          'name': 'users',
          'type': 'base',
          'attributes': [TextAttribute(name: 'email', unique: true).toJson()],
          'indexes': [],
          'create_rule': 'user.role == "admin"',
          'created_at': DateTime.now().millisecondsSinceEpoch ~/ 1000,
          'updated_at': DateTime.now().millisecondsSinceEpoch ~/ 1000,
        },
      ];

      final res = await client.post(
        '/v1/collections/import',
        body: {'collections': collections, 'overwrite': false},
      );

      expect(res.status, 200);

      final importResponse = ImportResponseMapper.fromJson(res.json!);
      expect(importResponse.created, containsAll(['books', 'users']));
      expect(importResponse.updated, isEmpty);
      expect(importResponse.skipped, isEmpty);
      expect(importResponse.errors, isEmpty);

      // Verify collections were actually created
      final booksRes = await client.get('/v1/collections/books');
      expect(booksRes.status, 200);

      final usersRes = await client.get('/v1/collections/users');
      expect(usersRes.status, 200);
    });

    test('skips existing collections when overwrite=false', () async {
      // Create a collection first
      await client.post(
        '/v1/collections',
        body: {
          'name': 'books',
          'attributes': [TextAttribute(name: 'title').toJson()],
          'indexes': [],
        },
      );

      // Try to import the same collection
      final collections = [
        {
          'name': 'books',
          'type': 'base',
          'attributes': [
            TextAttribute(name: 'title').toJson(),
            TextAttribute(name: 'author').toJson(),
          ],
          'indexes': [],
          'created_at': DateTime.now().millisecondsSinceEpoch ~/ 1000,
          'updated_at': DateTime.now().millisecondsSinceEpoch ~/ 1000,
        },
      ];

      final res = await client.post(
        '/v1/collections/import',
        body: {'collections': collections, 'overwrite': false},
      );

      expect(res.status, 200);

      final importResponse = ImportResponseMapper.fromJson(res.json!);
      expect(importResponse.created, isEmpty);
      expect(importResponse.updated, isEmpty);
      expect(importResponse.skipped, contains('books'));
      expect(importResponse.errors, isEmpty);
    });

    test('overwrites existing collections when overwrite=true', () async {
      // Create a collection first
      await client.post(
        '/v1/collections',
        body: {
          'name': 'books',
          'attributes': [TextAttribute(name: 'title').toJson()],
          'indexes': [],
        },
      );

      // Import with overwrite=true
      final collections = [
        {
          'name': 'books',
          'type': 'base',
          'attributes': [
            TextAttribute(name: 'title').toJson(),
            TextAttribute(name: 'author').toJson(),
          ],
          'indexes': [],
          'created_at': DateTime.now().millisecondsSinceEpoch ~/ 1000,
          'updated_at': DateTime.now().millisecondsSinceEpoch ~/ 1000,
        },
      ];

      final res = await client.post(
        '/v1/collections/import',
        body: {'collections': collections, 'overwrite': true},
      );

      expect(res.status, 200);

      final importResponse = ImportResponseMapper.fromJson(res.json!);
      expect(importResponse.created, isEmpty);
      expect(importResponse.updated, contains('books'));
      expect(importResponse.skipped, isEmpty);
      expect(importResponse.errors, isEmpty);

      // Verify collection has new attribute
      final booksRes = await client.get('/v1/collections/books');
      expect(booksRes.status, 200);
      final collection = CollectionMapper.fromJson(booksRes.json!);
      final userAttrNames = collection.attributes
          .where((a) => !['id', 'created_at', 'updated_at'].contains(a.name))
          .map((a) => a.name)
          .toList();
      expect(userAttrNames, containsAll(['title', 'author']));
    });

    test('rejects collections with system column names', () async {
      final collections = [
        {
          'name': 'books',
          'type': 'base',
          'attributes': [
            TextAttribute(name: 'id', primaryKey: true).toJson(),
            TextAttribute(name: 'title').toJson(),
          ],
          'indexes': [],
          'created_at': DateTime.now().millisecondsSinceEpoch ~/ 1000,
          'updated_at': DateTime.now().millisecondsSinceEpoch ~/ 1000,
        },
      ];

      final res = await client.post(
        '/v1/collections/import',
        body: {'collections': collections, 'overwrite': false},
      );

      expect(res.status, 200);

      final importResponse = ImportResponseMapper.fromJson(res.json!);
      expect(importResponse.created, isEmpty);
      expect(importResponse.errors, isNotEmpty);
      expect(importResponse.errors.first.error, contains('system column'));
    });

    test('rejects collections with invalid names', () async {
      final collections = [
        {
          'name': '123_invalid!',
          'type': 'base',
          'attributes': [TextAttribute(name: 'title').toJson()],
          'indexes': [],
          'created_at': DateTime.now().millisecondsSinceEpoch ~/ 1000,
          'updated_at': DateTime.now().millisecondsSinceEpoch ~/ 1000,
        },
      ];

      final res = await client.post(
        '/v1/collections/import',
        body: {'collections': collections, 'overwrite': false},
      );

      expect(res.status, 200);

      final importResponse = ImportResponseMapper.fromJson(res.json!);
      expect(importResponse.created, isEmpty);
      expect(importResponse.errors, isNotEmpty);
      expect(
        importResponse.errors.first.error,
        contains('Invalid collection name'),
      );
    });

    test('imports multiple collections with mixed results', () async {
      // Create one collection beforehand
      await client.post(
        '/v1/collections',
        body: {
          'name': 'existing',
          'attributes': [TextAttribute(name: 'value').toJson()],
          'indexes': [],
        },
      );

      final collections = [
        {
          'name': 'new_collection',
          'type': 'base',
          'attributes': [TextAttribute(name: 'title').toJson()],
          'indexes': [],
          'created_at': DateTime.now().millisecondsSinceEpoch ~/ 1000,
          'updated_at': DateTime.now().millisecondsSinceEpoch ~/ 1000,
        },
        {
          'name': 'existing',
          'type': 'base',
          'attributes': [TextAttribute(name: 'value').toJson()],
          'indexes': [],
          'created_at': DateTime.now().millisecondsSinceEpoch ~/ 1000,
          'updated_at': DateTime.now().millisecondsSinceEpoch ~/ 1000,
        },
        {
          'name': '123_invalid',
          'type': 'base',
          'attributes': [TextAttribute(name: 'data').toJson()],
          'indexes': [],
          'created_at': DateTime.now().millisecondsSinceEpoch ~/ 1000,
          'updated_at': DateTime.now().millisecondsSinceEpoch ~/ 1000,
        },
      ];

      final res = await client.post(
        '/v1/collections/import',
        body: {'collections': collections, 'overwrite': false},
      );

      expect(res.status, 200);

      final importResponse = ImportResponseMapper.fromJson(res.json!);
      expect(importResponse.created, contains('new_collection'));
      expect(importResponse.skipped, contains('existing'));
      expect(importResponse.errors, isNotEmpty);
      expect(importResponse.errors.first.collection, equals('123_invalid'));
    });

    test('imports collections with indexes', () async {
      final collections = [
        {
          'name': 'products',
          'type': 'base',
          'attributes': [
            TextAttribute(name: 'name').toJson(),
            DoubleAttribute(name: 'price').toJson(),
          ],
          'indexes': [
            Index(
              name: 'idx_products_name',
              columns: ['name'],
              unique: true,
            ).toJson(),
            Index(name: 'idx_products_price', columns: ['price']).toJson(),
          ],
          'created_at': DateTime.now().millisecondsSinceEpoch ~/ 1000,
          'updated_at': DateTime.now().millisecondsSinceEpoch ~/ 1000,
        },
      ];

      final res = await client.post(
        '/v1/collections/import',
        body: {'collections': collections, 'overwrite': false},
      );

      expect(res.status, 200);

      final importResponse = ImportResponseMapper.fromJson(res.json!);
      expect(importResponse.created, contains('products'));
      expect(importResponse.errors, isEmpty);

      // Verify indexes were created
      final indexes = await database
          .customSelect(
            "SELECT name FROM sqlite_master WHERE type='index' AND tbl_name='products' AND name NOT LIKE 'sqlite_autoindex_%'",
          )
          .get();

      final indexNames = indexes.map((r) => r.read<String>('name')).toList();
      expect(
        indexNames,
        containsAll(['idx_products_name', 'idx_products_price']),
      );
    });
  });
}
