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
      VALUES ('Test content', 'test@example.com', 1)
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

  group('deleteDocument', () {
    test('successfully deletes document', () async {
      // Delete the document
      final deleteRes = await client.del('/v1/documents/notes/$documentId');
      expect(deleteRes.status, 200);

      // Verify document no longer exists
      final getRes = await client.get('/v1/documents/notes/$documentId');
      expect(getRes.status, 404);
    });

    test('returns 404 for non-existent document', () async {
      final res = await client.del('/v1/documents/notes/non-existent-id');

      expect(res.status, 404);
      expect(res.json!['error']['message'], contains('Document not found'));
    });

    test('returns 404 for non-existent collection', () async {
      final res = await client.del('/v1/documents/fake_collection/$documentId');

      expect(res.status, 404);
      expect(res.json!['error']['message'], contains('Collection not found'));
    });

    test('returns 403 for non-superuser without deleteRule', () async {
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
        final res = await nonSuperuserClient.del(
          '/v1/documents/notes/$documentId',
        );

        expect(res.status, 403);
      } finally {
        nonSuperuserClient.close();
      }
    });

    test('deleting already-deleted document returns 404', () async {
      // First delete
      final firstDelete = await client.del('/v1/documents/notes/$documentId');
      expect(firstDelete.status, 200);

      // Second delete should return 404
      final secondDelete = await client.del('/v1/documents/notes/$documentId');
      expect(secondDelete.status, 404);
    });

    test('returns 403 when accessing internal collections', () async {
      final res = await client.del('/v1/documents/_users/some-id');

      expect(res.status, 403);
      expect(
        res.json!['error']['message'],
        contains('Access to internal collections is denied'),
      );
    });
  });
}
