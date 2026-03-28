import 'dart:io';

import 'package:vanestack/src/database/database.dart';
import 'package:vanestack/src/server.dart';
import 'package:vanestack/src/utils/auth.dart';
import 'package:vanestack/src/utils/env.dart';
import 'package:vanestack_common/vanestack_common.dart';
import 'package:drift/drift.dart' show TableStatements, Value;

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

    // Create a test collection

    await database.customStatement('''
      CREATE TABLE notes (
        id TEXT PRIMARY KEY default (random_uuid_v7()),
        created_at INTEGER NOT NULL default (unixepoch()),
        updated_at INTEGER NOT NULL default (unixepoch()),
        content TEXT,
        email TEXT
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
        ]),
      ),
    );

    // Insert some sample documents
    await database.customStatement('''
      INSERT INTO notes (content, email)
      VALUES
      ('First note', 'a@example.com'),
      ('Second note', 'b@example.com'),
      ('Third note', 'c@example.com')
    ''');

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

  group('getAll documents', () {
    test('retrieves all documents without filters', () async {
      final res = await client.get('/v1/documents/notes');

      expect(res.status, 200);
      final result = ListDocumentsResultMapper.fromJson(res.json!);
      expect(result.count, equals(3));
      expect(result.documents.length, equals(3));
    });

    test('applies filter correctly', () async {
      final res = await client.get(
        '/v1/documents/notes',
        query: {'filter': "email='a@example.com'"},
      );

      expect(res.status, 200);
      final result = ListDocumentsResultMapper.fromJson(res.json!);
      expect(result.count, equals(1)); // count is total, not filtered
      expect(result.documents.length, equals(1));
      expect(result.documents.first.data['email'], equals('a@example.com'));
    });

    test('applies orderBy correctly', () async {
      final res = await client.get(
        '/v1/documents/notes',
        query: {'orderBy': '-email'},
      );

      expect(res.status, 200);
      final result = ListDocumentsResultMapper.fromJson(res.json!);
      expect(result.documents.first.data['email'], equals('c@example.com'));
      expect(result.documents.last.data['email'], equals('a@example.com'));
    });

    test('applies limit and offset', () async {
      final res = await client.get(
        '/v1/documents/notes',
        query: {'limit': '2', 'offset': '1'},
      );

      expect(res.status, 200);
      final result = ListDocumentsResultMapper.fromJson(res.json!);
      expect(result.documents.length, equals(2));
    });

    test('returns empty list for non-existing filter', () async {
      final res = await client.get(
        '/v1/documents/notes',
        query: {'filter': "email='nonexistent@example.com'"},
      );

      expect(res.status, 200);
      final result = ListDocumentsResultMapper.fromJson(res.json!);
      expect(result.documents, isEmpty);
      expect(result.count, equals(0));
    });

    test('returns 500 for invalid collection', () async {
      final res = await client.get('/v1/documents/nonexistent_table');

      expect(res.status, 404);

      expect(res.json!['error']['message'], contains('not found'));
    });
  });
}
