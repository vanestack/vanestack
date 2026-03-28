import 'dart:io';

import 'package:vanestack/src/database/database.dart';
import 'package:vanestack/src/server.dart';
import 'package:vanestack/src/utils/auth.dart';
import 'package:vanestack/src/utils/env.dart';
import 'package:vanestack_common/vanestack_common.dart';

import 'package:drift/drift.dart' hide isNull, isNotNull;
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

  group('createDocument', () {
    test('successfully creates a new document in a collection', () async {
      // Arrange
      await database.customStatement(
        'CREATE TABLE IF NOT EXISTS books (id TEXT PRIMARY KEY default (random_uuid_v7()), title TEXT, author TEXT, created_at INTEGER DEFAULT (unixepoch()), updated_at INTEGER DEFAULT (unixepoch()))',
      );

      await database.collections.insertOne(
        CollectionsCompanion.insert(
          name: 'books',
          attributes: Value([
            TextAttribute(
              name: 'id',
              nullable: false,
              primaryKey: true,
              defaultValue: '(random_uuid_v7())',
            ),
            DateAttribute(
              name: 'created_at',
              nullable: false,
              defaultValue: '(unixepoch())',
            ),
            DateAttribute(
              name: 'updated_at',
              nullable: false,
              defaultValue: '(unixepoch())',
            ),
            TextAttribute(name: 'title'),
            TextAttribute(name: 'author'),
          ]),
        ),
      );

      final payload = {
        'data': {'title': 'The Hobbit', 'author': 'J.R.R. Tolkien'},
      };

      // Act
      final res = await client.post('/v1/documents/books', body: payload);

      // Assert
      expect(res.status, 200);
      expect(res.json, isNotNull);
      expect(res.json!['data']['title'], equals('The Hobbit'));
      expect(res.json!['data']['author'], equals('J.R.R. Tolkien'));
      expect(res.json!['id'], isNotEmpty);
    });

    test('returns 404 when collection does not exist', () async {
      final payload = {
        'data': {'title': 'Invisible Collection'},
      };
      final res = await client.post('/v1/documents/ghosts', body: payload);

      expect(res.status, 404);
      expect(res.json!['error']['message'], contains('Collection not found'));
    });

    test(
      'parse bool values as integers and inserts 0 or 1 in database',
      () async {
        await database.customStatement(
          'CREATE TABLE IF NOT EXISTS books (id TEXT PRIMARY KEY default (random_uuid_v7()), created_at INTEGER DEFAULT (unixepoch()), updated_at INTEGER DEFAULT (unixepoch()), published INTEGER NOT NULL)',
        );

        await database.collections.insertOne(
          CollectionsCompanion.insert(
            name: 'books',
            attributes: Value([
              TextAttribute(
                name: 'id',
                nullable: false,
                primaryKey: true,
                defaultValue: '(random_uuid_v7())',
              ),
              DateAttribute(
                name: 'created_at',
                nullable: false,
                defaultValue: '(unixepoch())',
              ),
              DateAttribute(
                name: 'updated_at',
                nullable: false,
                defaultValue: '(unixepoch())',
              ),
              BoolAttribute(name: 'published', nullable: false),
            ]),
          ),
        );

        // Act: send payload missing 'title'
        final res = await client.post(
          '/v1/documents/books',
          body: {
            'data': {'published': true},
          },
        );

        // Assert
        expect(res.status, 200);
        final id = res.json!['id'];

        final row = await database
            .customSelect(
              'SELECT * FROM books WHERE id = ?',
              variables: [Variable<String>(id)],
            )
            .getSingle();

        expect(row.data['published'], equals(1));
      },
    );

    test('returns 400 when validation fails', () async {
      // Arrange: define collection expecting 'title' field
      await database.customStatement(
        'CREATE TABLE IF NOT EXISTS books (id TEXT PRIMARY KEY default (random_uuid_v7()), title TEXT NOT NULL, created_at INTEGER DEFAULT (unixepoch()), updated_at INTEGER DEFAULT (unixepoch()))',
      );

      await database.collections.insertOne(
        CollectionsCompanion.insert(
          name: 'books',
          attributes: Value([
            TextAttribute(
              name: 'id',
              nullable: false,
              primaryKey: true,
              defaultValue: '(random_uuid_v7())',
            ),
            DateAttribute(
              name: 'created_at',
              nullable: false,
              defaultValue: '(unixepoch())',
            ),
            DateAttribute(
              name: 'updated_at',
              nullable: false,
              defaultValue: '(unixepoch())',
            ),
            TextAttribute(name: 'title', nullable: false),
          ]),
        ),
      );

      // Act: send payload missing 'title'
      final res = await client.post(
        '/v1/documents/books',
        body: {
          'data': {'foo': 'bar'},
        },
      );

      // Assert
      expect(res.status, 400);
      expect(res.json!['error']['message'], contains('Validation failed'));
    });

    test('returns 403 when accessing internal collections', () async {
      // "collections" is an internal table
      final payload = {
        'data': {'foo': 'bar'},
      };
      final res = await client.post('/v1/documents/_users', body: payload);

      expect(res.status, 403);
      expect(
        res.json!['error']['message'],
        contains('Access to internal collections is denied'),
      );
    });
  });
}
