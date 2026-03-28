import 'dart:io';

import 'package:vanestack/src/database/database.dart';
import 'package:vanestack/src/server.dart';
import 'package:vanestack/src/utils/auth.dart';
import 'package:vanestack/src/utils/env.dart';
import 'package:vanestack_common/vanestack_common.dart';
import 'package:drift/drift.dart' show TableStatements, Value, Variable;

import 'package:drift/native.dart';

import 'package:test/test.dart';

import 'mock_server.dart';
import 'test_utils.dart';

void main() {
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

    // Insert some sample documents
    final rowId = await database.customInsert('''
      INSERT INTO notes (content, email, is_important)
      VALUES
      ('First note', 'a@example.com', true);
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

  group('getOne document', () {
    test(
      'bool attributes are correctly parsed from int (database) to bool (user facing)',
      () async {
        final res = await client.get('/v1/documents/notes/$documentId');

        expect(res.status, 200);
        expect(res.json!['data']['is_important'], isTrue);
      },
    );
  });
}
