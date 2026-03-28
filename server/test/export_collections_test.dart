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

  group('exportCollections', () {
    test('successfully exports all collections', () async {
      // Arrange - create multiple collections
      final params1 = {
        'name': 'books',
        'attributes': [
          TextAttribute(name: 'title', nullable: false),
          TextAttribute(name: 'author'),
        ].map((a) => a.toJson()).toList(),
        'indexes': [
          Index(name: 'idx_books_title', columns: ['title'], unique: true),
        ].map((i) => i.toJson()).toList(),
        'listRule': 'user.id != null',
      };

      final params2 = {
        'name': 'users',
        'attributes': [
          TextAttribute(name: 'email', unique: true),
        ].map((a) => a.toJson()).toList(),
        'indexes': [],
        'createRule': 'user.role == "admin"',
      };

      await client.post('/v1/collections', body: params1);
      await client.post('/v1/collections', body: params2);

      // Act
      final res = await client.get('/v1/collections/export');

      // Assert
      expect(res.status, 200);

      final exportResponse = ExportResponseMapper.fromJson(res.json!);
      expect(exportResponse.collections.length, equals(2));
      expect(exportResponse.version, equals('1.0'));
      expect(exportResponse.exportedAt, isA<DateTime>());

      // Verify collections content
      final collectionNames = exportResponse.collections
          .map((c) => c.name)
          .toList();
      expect(collectionNames, containsAll(['books', 'users']));

      final booksCollection = exportResponse.collections.firstWhere(
        (c) => c.name == 'books',
      ) as BaseCollection;
      expect(booksCollection.attributes.length, greaterThan(0));
      expect(booksCollection.indexes.length, equals(1));
      expect(booksCollection.listRule, equals('user.id != null'));

      final usersCollection = exportResponse.collections.firstWhere(
        (c) => c.name == 'users',
      ) as BaseCollection;
      expect(usersCollection.createRule, equals('user.role == "admin"'));
    });

    test('returns empty collections list when no collections exist', () async {
      final res = await client.get('/v1/collections/export');

      expect(res.status, 200);

      final exportResponse = ExportResponseMapper.fromJson(res.json!);
      expect(exportResponse.collections, isEmpty);
      expect(exportResponse.version, equals('1.0'));
    });

    test('exports collections with all metadata fields', () async {
      final params = {
        'name': 'products',
        'attributes': [
          TextAttribute(name: 'name'),
          DoubleAttribute(name: 'price'),
        ].map((a) => a.toJson()).toList(),
        'indexes': [],
        'listRule': 'true',
        'viewRule': 'true',
        'createRule': 'user.role == "seller"',
        'updateRule': 'user.id == record.owner',
        'deleteRule': 'user.role == "admin"',
      };

      await client.post('/v1/collections', body: params);

      final res = await client.get('/v1/collections/export');
      expect(res.status, 200);

      final exportResponse = ExportResponseMapper.fromJson(res.json!);
      final product = exportResponse.collections.first as BaseCollection;

      expect(product.listRule, equals('true'));
      expect(product.viewRule, equals('true'));
      expect(product.createRule, equals('user.role == "seller"'));
      expect(product.updateRule, equals('user.id == record.owner'));
      expect(product.deleteRule, equals('user.role == "admin"'));
    });
  });
}
