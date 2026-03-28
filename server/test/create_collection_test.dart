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

  group('createCollection', () {
    test(
      'successfully creates a collection with system columns and index',
      () async {
        final params = {
          'name': 'notes',
          'attributes': [
            TextAttribute(name: 'title', nullable: false),
            TextAttribute(name: 'email', nullable: false, unique: true),
          ].map((a) => a.toJson()).toList(),
          'indexes': [
            Index(
              name: 'idx_notes_email',
              columns: ['email'],
              unique: true,
            ).toJson(),
          ],
        };

        // Act
        final res = await client.post('/v1/collections', body: params);

        // Assert
        expect(res.status, 200);

        // Verify the table exists
        final tables = await database
            .customSelect(
              "SELECT name FROM sqlite_master WHERE type='table' AND name='notes'",
            )
            .get();
        expect(tables, isNotEmpty);

        // Verify system columns exist
        final pragma = await database
            .customSelect('PRAGMA table_info("notes")')
            .get();
        final columnNames = pragma
            .map((row) => row.read<String>('name'))
            .toSet();

        expect(columnNames.contains('id'), isTrue);
        expect(columnNames.contains('created_at'), isTrue);
        expect(columnNames.contains('updated_at'), isTrue);
        expect(columnNames.contains('title'), isTrue);
        expect(columnNames.contains('email'), isTrue);

        // Verify triggers exist
        final triggers = await database
            .customSelect(
              "SELECT name, sql FROM sqlite_master WHERE type='trigger' AND tbl_name='notes'",
            )
            .get();

        final triggerNames = triggers
            .map((row) => row.read<String>('name'))
            .toList();

        expect(triggerNames, contains('notes_update_timestamp'));
      },
    );

    test('returns 400 when collection name is missing', () async {
      final params = {
        'name': '',
        'attributes': [TextAttribute(name: 'title').toJson()],
        'indexes': [],
      };

      final res = await client.post('/v1/collections', body: params);
      expect(res.status, 400);
      expect(
        res.json!['error']['message'],
        contains('Collection name is required'),
      );
    });

    test('returns 400 when columns list is empty', () async {
      final params = {'name': 'empty_table', 'attributes': [], 'indexes': []};

      final res = await client.post('/v1/collections', body: params);
      expect(res.status, 400);
      expect(
        res.json!['error']['message'],
        contains('At least one attribute is required'),
      );
    });

    test('returns 400 for invalid collection name', () async {
      final params = {
        'name': '123_invalid!',
        'attributes': [TextAttribute(name: 'title').toJson()],
        'indexes': [],
      };

      final res = await client.post('/v1/collections', body: params);
      expect(res.status, 400);
      expect(
        res.json!['error']['message'],
        contains('Invalid collection name'),
      );
    });

    test('creates collection without indexes if none provided', () async {
      final params = {
        'name': 'simple_table',
        'attributes': [TextAttribute(name: 'content').toJson()],
        'indexes': [],
      };

      final res = await client.post('/v1/collections', body: params);
      expect(res.status, 200);

      final tables = await database
          .customSelect(
            "SELECT name FROM sqlite_master WHERE type='table' AND name='simple_table'",
          )
          .get();
      expect(tables, isNotEmpty);

      // Confirm indexes list empty
      final indexes = await database
          .customSelect(
            "SELECT name FROM sqlite_master WHERE type='index' AND tbl_name='simple_table' AND name NOT LIKE 'sqlite_autoindex_%'",
          )
          .get();

      expect(indexes, isEmpty);
    });

    test(
      'automatically sets created_at and updated_at values on insert and update',
      () async {
        // Create table first
        final params = {
          'name': 'events',
          'attributes': [TextAttribute(name: 'description').toJson()],
          'indexes': [],
        };
        final res = await client.post('/v1/collections', body: params);
        expect(res.status, 200);

        // Insert manually
        await database.customStatement(
          "INSERT INTO events (description) VALUES ('Test event')",
        );
        final row = await database
            .customSelect('SELECT * FROM events')
            .getSingle();

        expect(row.read<String>('id'), isNotEmpty);
        final createdAt = row.read<int>('created_at');
        final updatedAt = row.read<int>('updated_at');
        expect(createdAt, isA<int>());
        expect(updatedAt, isA<int>());
        expect((updatedAt - createdAt).abs() < 5 * 1000, isTrue); // within 5s

        // Update row
        await database.customStatement(
          "UPDATE events SET description='Updated' WHERE id='${row.read<String>('id')}'",
        );
        final updatedRow = await database
            .customSelect('SELECT * FROM events')
            .getSingle();

        expect(updatedRow.read<int>('updated_at') >= updatedAt, isTrue);
      },
    );
  });
}
