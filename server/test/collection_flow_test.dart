import 'dart:convert';
import 'dart:io';

import 'package:vanestack/src/database/database.dart';

import 'package:vanestack/src/server.dart';
import 'package:vanestack/src/utils/auth.dart';
import 'package:vanestack/src/utils/env.dart';
import 'package:vanestack_common/vanestack_common.dart';
import 'package:drift/drift.dart' show Variable;
import 'package:drift/native.dart';

import 'package:test/test.dart';

import 'mock_server.dart';
import 'test_utils.dart';

void main() {
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

  group('Collections E2E - full CRUD flow', () {
    test('create → list → update → drop', () async {
      final tableName = 'books';

      final params = {
        'name': tableName,
        'attributes': [
          TextAttribute(name: 'title', nullable: false).toJson(),
        ],
        'indexes': [
          Index(
            name: 'idx_books_title',
            columns: ['title'],
            unique: true,
          ).toJson(),
        ],
      };

      // 1️⃣ Create table
      final createRes = await client.post(
        '/v1/collections',
        body: params,
      );

      expect(createRes.status, 200);

      // Verify table exists in the DB
      final tables = await database
          .customSelect(
            "SELECT name FROM sqlite_master WHERE type='table' AND name=?",
            variables: [Variable(tableName)],
          )
          .get();
      expect(tables.length, 1);

      // List collections
      final listRes = await client.get('/v1/collections');
      expect(listRes.status, 200);
      final listJson = jsonDecode(listRes.body);
      expect(listJson, isA<List>());

      final collections = (listJson as List)
          .map((e) => CollectionMapper.fromJson(e))
          .toList();

      expect(collections, hasLength(1));
      expect(collections.first.name, equals(tableName));

      final updateParams = {
        'attributes': [
          TextAttribute(name: 'title', nullable: false),
          TextAttribute(name: 'description'),
        ].map((a) => a.toJson()).toList(),
        'indexes': [
          Index(name: 'idx_books_title', columns: ['title'], unique: true),
          Index(name: 'idx_books_description', columns: ['description']),
        ].map((i) => i.toJson()).toList(),
      };

      // Update collection: add 'description' column and new index
      final updateRes = await client.patch(
        '/v1/collections/books',
        body: updateParams,
      );
      expect(updateRes.status, 200);

      final rows = await database
          .customSelect('PRAGMA table_info("$tableName")')
          .get();

      final colNames = rows.map((r) => r.data['name'] as String).toList();
      expect(colNames, contains('description'));

      // Delete collection
      final dropRes = await client.del('/v1/collections/$tableName');
      expect(dropRes.status, 200);

      final tablesAfterDrop = await database
          .customSelect(
            "SELECT name FROM sqlite_master WHERE type='table' AND name=?",
            variables: [Variable(tableName)],
          )
          .get();
      expect(tablesAfterDrop.length, 0);
    });
  });
}
