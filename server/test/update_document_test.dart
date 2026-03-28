import 'dart:io';

import 'package:vanestack/src/database/database.dart';
import 'package:vanestack/src/server.dart';
import 'package:vanestack/src/utils/auth.dart';
import 'package:vanestack/src/utils/env.dart';
import 'package:vanestack_common/vanestack_common.dart';
import 'package:drift/drift.dart'
    show TableStatements, Value, Variable, driftRuntimeOptions;

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
  late String documentId;

  setUp(() async {
    final port = await findFreePort();
    env = Environment(port: port);
    database = AppDatabase(NativeDatabase.memory(setup: AppDatabase.setup));
    server = MockServer(db: database, env: env);
    await server.start();

    // Create a test collection
    await database.customStatement('''
      CREATE TABLE notes (
        id TEXT PRIMARY KEY default (random_uuid_v7()),
        created_at INTEGER NOT NULL default (unixepoch()),
        updated_at INTEGER NOT NULL default (unixepoch()),
        content TEXT,
        email TEXT,
        is_important INTEGER
      )
    ''');

    await database.collections.insertOne(
      CollectionsCompanion.insert(
        name: 'notes',
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
          TextAttribute(name: 'content'),
          TextAttribute(name: 'email'),
          BoolAttribute(name: 'is_important'),
        ]),
      ),
    );

    // Insert a sample document
    final rowId = await database.customInsert('''
      INSERT INTO notes (content, email, is_important)
      VALUES ('Original content', 'original@example.com', 0)
    ''');

    documentId = await database
        .customSelect(
          'SELECT id FROM notes WHERE rowid = ?',
          variables: [Variable<int>(rowId)],
        )
        .getSingle()
        .then((v) => v.data['id'] as String);

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

  group('updateDocument', () {
    test('successfully updates document fields', () async {
      final res = await client.patch(
        '/v1/documents/notes/$documentId',
        body: {
          'data': {
            'content': 'Updated content',
            'email': 'updated@example.com',
          },
        },
      );

      expect(res.status, 200);
      expect(res.json, isNotNull);
      expect(res.json!['data']['content'], equals('Updated content'));
      expect(res.json!['data']['email'], equals('updated@example.com'));
    });

    test('partial update preserves other fields', () async {
      // Update only content
      final res = await client.patch(
        '/v1/documents/notes/$documentId',
        body: {
          'data': {'content': 'New content only'},
        },
      );

      expect(res.status, 200);
      expect(res.json!['data']['content'], equals('New content only'));
      // Email should remain unchanged
      expect(res.json!['data']['email'], equals('original@example.com'));
    });

    test('returns 400 when updating system attribute id', () async {
      final res = await client.patch(
        '/v1/documents/notes/$documentId',
        body: {
          'data': {'id': 'new-id'},
        },
      );

      expect(res.status, 400);
      expect(
        res.json!['error']['message'],
        contains('cannot be set during update'),
      );
    });

    test('returns 400 when updating system attribute created_at', () async {
      final res = await client.patch(
        '/v1/documents/notes/$documentId',
        body: {
          'data': {'created_at': 1234567890},
        },
      );

      expect(res.status, 400);
      expect(
        res.json!['error']['message'],
        contains('cannot be set during update'),
      );
    });

    test('returns 400 for unknown attributes', () async {
      final res = await client.patch(
        '/v1/documents/notes/$documentId',
        body: {
          'data': {'unknown_field': 'value'},
        },
      );

      expect(res.status, 400);
      expect(res.json!['error']['message'], contains('Unknown attribute'));
    });

    test('returns 404 for non-existent document', () async {
      final res = await client.patch(
        '/v1/documents/notes/non-existent-id',
        body: {
          'data': {'content': 'Updated'},
        },
      );

      expect(res.status, 404);
      expect(res.json!['error']['message'], contains('Document not found'));
    });

    test('returns 404 for non-existent collection', () async {
      final res = await client.patch(
        '/v1/documents/fake_collection/$documentId',
        body: {
          'data': {'content': 'Updated'},
        },
      );

      expect(res.status, 404);
      expect(res.json!['error']['message'], contains('Collection not found'));
    });

    test('returns 403 for non-superuser without updateRule', () async {
      // Create a non-superuser JWT
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
        final res = await nonSuperuserClient.patch(
          '/v1/documents/notes/$documentId',
          body: {
            'data': {'content': 'Unauthorized update'},
          },
        );

        expect(res.status, 403);
      } finally {
        nonSuperuserClient.close();
      }
    });

    test('returns 403 when accessing internal collections', () async {
      final res = await client.patch(
        '/v1/documents/_users/some-id',
        body: {
          'data': {'foo': 'bar'},
        },
      );

      expect(res.status, 403);
      expect(
        res.json!['error']['message'],
        contains('Access to internal collections is denied'),
      );
    });
  });
}
