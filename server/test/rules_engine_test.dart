import 'dart:io';

import 'package:vanestack/src/database/database.dart';
import 'package:vanestack/src/permissions/rules_engine.dart';
import 'package:vanestack/src/server.dart';
import 'package:vanestack/src/utils/auth.dart';
import 'package:vanestack/src/utils/env.dart';
import 'package:vanestack_common/vanestack_common.dart';
import 'package:drift/drift.dart' show TableStatements, Value, Variable;
import 'package:drift/native.dart';
import 'package:shelf/shelf.dart';
import 'package:test/test.dart';

import 'mock_server.dart';
import 'test_utils.dart';

void main() {
  late Environment env;
  late AppDatabase database;
  late VaneStackServer server;
  late String documentId;
  late Request request;
  late RulesEngine engine;

  setUp(() async {
    final port = await findFreePort();
    env = Environment(port: port);
    database = AppDatabase(NativeDatabase.memory(setup: AppDatabase.setup));
    server = MockServer(db: database, env: env);
    await server.start();

    // Create test collection schema
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
          TextAttribute(name: 'id', nullable: false, primaryKey: true),
          DateAttribute(name: 'created_at', nullable: false),
          DateAttribute(name: 'updated_at', nullable: false),
          TextAttribute(name: 'content'),
          TextAttribute(name: 'email'),
          BoolAttribute(name: 'is_important'),
        ]),
      ),
    );

    // Insert test row
    final rowId = await database.customInsert('''
      INSERT INTO notes (content, email, is_important)
      VALUES ('My note', 'user@example.com', true);
    ''');

    documentId = await database
        .customSelect(
          'SELECT id FROM notes WHERE rowid = ?',
          variables: [Variable<int>(rowId)],
        )
        .getSingle()
        .then((row) => row.data['id'] as String);

    final jwt = AuthUtils.generateJwt(
      userId: 'test_user',
      jwtSecret: env.jwtSecret,
      superuser: true,
    );

    request = Request(
      'GET',
      Uri.parse('http://127.0.0.1:$port/v1/documents/notes/$documentId'),
      headers: {HttpHeaders.authorizationHeader: 'Bearer $jwt'},
      context: {
        'userId': 'test_user',
        'isSuperUser': true,
        'bearerToken': jwt,
        'database': database,
      },
    );

    engine = RulesEngine(
      request: request,
      newResource: Document(
        id: documentId,
        collection: 'notes',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        data: {
          'iter': [1, 2, 3],
          'number': 3.7,
          'text': 'Hello World',
          'map': {'a': 1, 'b': 2},
        },
      ),
    );
  });

  tearDown(() async {
    await server.stop();
    database.close();
  });

  group('RulesEngine integration', () {
    test('simple arithmetic rule works', () async {
      final result = await engine.evaluate('1 + 1 == 2');
      expect(result, isTrue);
    });

    test('can evaluate request context', () async {
      final result = await engine.evaluate('request.auth.uid == "test_user"');
      expect(result, isTrue);
    });

    test('can fetch and evaluate document existence', () async {
      final rule = 'exists("notes", "$documentId")';
      final result = await engine.evaluate(rule);
      expect(result, isTrue);
    });

    test('nonexistent document returns false for exists()', () async {
      final result = await engine.evaluate('exists("notes", "fake_id")');
      expect(result, isFalse);
    });

    test('can get document and evaluate field', () async {
      final rule = 'get("notes", "$documentId")["email"] == "user@example.com"';
      final result = await engine.evaluate(rule);
      expect(result, isTrue);
    });

    test('resource.data is visible when provided', () async {
      final newData = {'email': 'changed@example.com'};
      final result = await engine.evaluate(
        'resource.data["email"] == "changed@example.com"',
        oldResource: Document(
          id: documentId,
          collection: 'notes',
          data: newData,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
      );
      expect(result, isTrue);
    });

    test('caching: repeated document lookups hit cache', () async {
      // first call loads from DB
      final first = await engine.evaluate(
        'get("notes", "$documentId") != null',
      );
      // second call should use cache
      final second = await engine.evaluate(
        'get("notes", "$documentId") != null',
      );

      expect(first, isTrue);
      expect(second, isTrue);
    });

    test('DateTime member functions work', () async {
      final now = DateTime.now();

      final result2 = await engine.evaluate(
        'request.timestamp.year == ${now.year}',
      );

      expect(result2, isTrue);

      final result3 = await engine.evaluate(
        'request.timestamp.month == ${now.month}',
      );

      expect(result3, isTrue);
      final result4 = await engine.evaluate(
        'request.timestamp.day == ${now.day}',
      );
      expect(result4, isTrue);

      final result5 = await engine.evaluate(
        'request.timestamp.hour == ${now.hour}',
      );

      expect(result5, isTrue);

      final result6 = await engine.evaluate(
        'request.timestamp.minute == ${now.minute}',
      );

      expect(result6, isTrue);

      final result7 = await engine.evaluate(
        'request.timestamp.second == ${now.second}',
      );

      expect(result7, isTrue);
    });

    test('String member functions work', () async {
      final result1 = await engine.evaluate(
        'request.resource.data["text"].toLowerCase() == "hello world"',
      );
      expect(result1, isTrue);

      final result2 = await engine.evaluate(
        'request.resource.data["text"].startsWith("Hello")',
      );
      expect(result2, isTrue);

      final result3 = await engine.evaluate(
        'request.resource.data["text"].contains("World")',
      );
      expect(result3, isTrue);

      final result4 = await engine.evaluate(
        'request.resource.data["text"].length == 11',
      );
      expect(result4, isTrue);
    });

    test('num member functions work', () async {
      final result1 = await engine.evaluate('(3.7).floor() == 3');
      expect(result1, isTrue);

      final result2 = await engine.evaluate('(5.1).ceil() == 6');
      expect(result2, isTrue);

      final result3 = await engine.evaluate('(-10).abs() == 10');
      expect(result3, isTrue);

      final result4 = await engine.evaluate('(4).toStringAsFixed(2) == "4.00"');
      expect(result4, isTrue);
    });

    test('Iterable member functions work', () async {
      final result1 = await engine.evaluate(
        'request.resource.data["iter"].length == 3',
      );
      expect(result1, isTrue);

      final result2 = await engine.evaluate(
        'request.resource.data["iter"].contains(2)',
      );
      expect(result2, isTrue);

      final result3 = await engine.evaluate(
        'request.resource.data["iter"].isNotEmpty',
      );
      expect(result3, isTrue);

      final result4 = await engine.evaluate(
        'request.resource.data["iter"].join(",") == "1,2,3"',
      );
      expect(result4, isTrue);

      final result5 = await engine.evaluate(
        'request.resource.data["iter"].elementAt(1) == 2',
      );
      expect(result5, isTrue);
    });

    test('Map member accessors work', () async {
      final result1 = await engine.evaluate(
        'request.resource.data["map"].containsKey("a")',
      );
      expect(result1, isTrue);

      final result2 = await engine.evaluate(
        'request.resource.data["map"].keys.contains("b")',
      );

      expect(result2, isTrue);

      final result3 = await engine.evaluate(
        'request.resource.data["map"].values.first == 1',
      );
      expect(result3, isTrue);
    });
  });
}
