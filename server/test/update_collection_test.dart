import 'dart:io';

import 'package:vanestack/src/database/database.dart';
import 'package:vanestack/src/server.dart';
import 'package:vanestack/src/utils/auth.dart';
import 'package:vanestack/src/utils/env.dart';
import 'package:vanestack_common/vanestack_common.dart';
import 'package:drift/drift.dart' hide Index;
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

  group('updateCollection', () {
    test('adds a new column and index (preserves system columns)', () async {
      // Arrange
      await database.customStatement(
        'CREATE TABLE books (id TEXT PRIMARY KEY, title TEXT, created_at INTEGER DEFAULT CURRENT_TIMESTAMP, updated_at INTEGER DEFAULT CURRENT_TIMESTAMP)',
      );

      await database.collections.insertOne(
        CollectionsCompanion.insert(
          name: 'books',
          attributes: Value([
            TextAttribute(name: 'id', primaryKey: true),
            TextAttribute(name: 'title'),
            IntAttribute(name: 'created_at'),
            IntAttribute(name: 'updated_at'),
          ]),
        ),
      );

      final params = {
        'attributes': [
          TextAttribute(name: 'title'),
          TextAttribute(name: 'description', nullable: true),
        ].map((a) => a.toJson()).toList(),
        'indexes': [
          Index(name: 'idx_books_title', columns: ['title'], unique: true),
        ].map((i) => i.toJson()).toList(),
      };

      // Act
      final res = await client.patch('/v1/collections/books', body: params);

      // Assert
      expect(res.status, 200);

      final columns = await database
          .customSelect('PRAGMA table_info("books")')
          .get();
      final columnNames = columns.map((r) => r.read<String>('name')).toList();

      // Must contain both user and system columns
      expect(
        columnNames,
        containsAll(['id', 'title', 'description', 'created_at', 'updated_at']),
      );

      // Check that index exists (ignoring autoindexes)
      final indexes = await database.customSelect("""
        SELECT name FROM sqlite_master
        WHERE type='index' 
          AND tbl_name='books'
          AND name NOT LIKE 'sqlite_autoindex_%'
        """).get();

      final indexNames = indexes.map((r) => r.read<String>('name')).toList();
      expect(indexNames, contains('idx_books_title'));
    });

    test('removes a column but keeps system columns', () async {
      await database.customStatement('''
        CREATE TABLE products (
          id TEXT PRIMARY KEY,
          name TEXT,
          price REAL,
          created_at INTEGER DEFAULT CURRENT_TIMESTAMP,
          updated_at INTEGER DEFAULT CURRENT_TIMESTAMP
        )
      ''');

      await database.collections.insertOne(
        CollectionsCompanion.insert(
          name: 'products',
          attributes: Value([
            TextAttribute(name: 'id', primaryKey: true),
            TextAttribute(name: 'name'),
            DoubleAttribute(name: 'price'),
            IntAttribute(name: 'created_at'),
            IntAttribute(name: 'updated_at'),
          ]),
        ),
      );

      final params = {
        'attributes': [
          TextAttribute(name: 'name'),
        ].map((a) => a.toJson()).toList(),
      };

      final res = await client.patch('/v1/collections/products', body: params);

      expect(res.status, 200);

      final columns = await database
          .customSelect('PRAGMA table_info("products")')
          .get();
      final columnNames = columns.map((r) => r.read<String>('name')).toList();

      expect(
        columnNames,
        containsAll(['id', 'name', 'created_at', 'updated_at']),
      );
      expect(columnNames, isNot(contains('price')));
    });

    test('returns 400 for invalid collection name', () async {
      final params = {
        'attributes': [TextAttribute(name: 'title').toJson()],
      };

      final res = await client.patch(
        '/v1/collections/123_invalid!',
        body: params,
      );

      expect(res.status, 400);
      expect(
        res.json!['error']['message'],
        contains('Invalid collection name'),
      );
    });

    test('returns 404 if collection does not exist', () async {
      final params = {
        'attributes': [TextAttribute(name: 'title').toJson()],
      };

      final res = await client.patch(
        '/v1/collections/nonexistent',
        body: params,
      );

      expect(res.status, 404);
      expect(res.json!['error']['message'], contains('does not exist'));
    });

    test('renames collection successfully and recreates trigger', () async {
      const oldTableName = 'old_table';
      const newTableName = 'new_table';

      final createParams = {
        'name': oldTableName,
        'attributes': [
          TextAttribute(name: 'value'),
        ].map((a) => a.toJson()).toList(),
        'indexes': [],
      };

      // 1️⃣ Create table
      final createRes = await client.post(
        '/v1/collections',
        body: createParams,
      );

      expect(createRes.status, 200);

      // Ensure trigger exists
      final beforeTriggers = await database
          .customSelect(
            "SELECT name FROM sqlite_master WHERE type='trigger' AND tbl_name='$oldTableName'",
          )
          .get();
      expect(beforeTriggers, isNotEmpty);

      // 2️⃣ Rename
      final renameParams = {'newCollectionName': newTableName};
      final renameRes = await client.patch(
        '/v1/collections/$oldTableName',
        body: renameParams,
      );
      expect(renameRes.status, 200);

      // Ensure table renamed
      final tablesResult = await database
          .customSelect(
            "SELECT name FROM sqlite_master WHERE type='table' AND name NOT LIKE 'sqlite_%'",
          )
          .get();
      final tableNames = tablesResult
          .map((row) => row.read<String>('name'))
          .toList();
      expect(tableNames, contains(newTableName));
      expect(tableNames, isNot(contains(oldTableName)));

      // Ensure old trigger dropped and new trigger created
      final triggers = await database
          .customSelect(
            "SELECT name FROM sqlite_master WHERE type='trigger' AND tbl_name='$newTableName'",
          )
          .get();
      expect(triggers, isNotEmpty);
    });

    test('returns 200 with no changes detected', () async {
      await database.customStatement('''
        CREATE TABLE customers (
          id TEXT PRIMARY KEY,
          email TEXT,
          created_at INTEGER DEFAULT CURRENT_TIMESTAMP,
          updated_at INTEGER DEFAULT CURRENT_TIMESTAMP
        )
      ''');

      await database.customStatement(
        'CREATE INDEX idx_customers_email ON customers(email)',
      );

      await database.collections.insertOne(
        CollectionsCompanion.insert(
          name: 'customers',
          attributes: Value([
            TextAttribute(name: 'id', primaryKey: true),
            TextAttribute(name: 'email'),
            IntAttribute(name: 'created_at'),
            IntAttribute(name: 'updated_at'),
          ]),
          indexes: Value([
            Index(name: 'idx_customers_email', columns: ['email']),
          ]),
        ),
      );

      final params = {
        'attributes': [
          TextAttribute(name: 'email').toJson(),
        ],
        'indexes': [
          Index(name: 'idx_customers_email', columns: ['email']).toJson(),
        ],
      };

      final res = await client.patch('/v1/collections/customers', body: params);

      expect(res.status, 200);
    });
  });
}
