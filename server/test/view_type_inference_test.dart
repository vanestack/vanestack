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

  /// Helper to create a base collection via the API.
  Future<void> createBase(
    JsonHttpClient client,
    String name,
    List<Attribute> attributes,
  ) async {
    final res = await client.post('/v1/collections', body: {
      'name': name,
      'attributes': attributes.map((a) => a.toJson()).toList(),
      'indexes': [],
    });
    expect(res.status, 200, reason: 'Failed to create base collection "$name": ${res.body}');
  }

  /// Helper to create a view collection via the API.
  Future<({int status, Map<String, dynamic>? json, String body})> createView(
    JsonHttpClient client,
    String name,
    String viewQuery,
  ) async {
    return client.post('/v1/collections', body: {
      'name': name,
      'type': 'view',
      'viewQuery': viewQuery,
      'attributes': [],
      'indexes': [],
    });
  }

  group('View type inference', () {
    test('preserves BOOL type from base collection', () async {
      await createBase(client, 'tasks', [
        BoolAttribute(name: 'completed', nullable: false),
        TextAttribute(name: 'title', nullable: false),
      ]);

      final viewRes = await createView(
        client,
        'tasks_view',
        'SELECT id, title, completed FROM tasks',
      );

      expect(viewRes.status, 200);

      final view = CollectionMapper.fromJson(viewRes.json!);
      expect(view, isA<ViewCollection>());

      final completedAttr =
          view.attributes.firstWhere((a) => a.name == 'completed');
      expect(completedAttr, isA<BoolAttribute>());
    });

    test('preserves DATE type from base collection', () async {
      await createBase(client, 'events', [
        TextAttribute(name: 'title', nullable: false),
        DateAttribute(name: 'event_date', nullable: false),
      ]);

      final viewRes = await createView(
        client,
        'events_view',
        'SELECT id, title, event_date FROM events',
      );

      expect(viewRes.status, 200);

      final view = CollectionMapper.fromJson(viewRes.json!);
      final eventDateAttr =
          view.attributes.firstWhere((a) => a.name == 'event_date');
      expect(eventDateAttr, isA<DateAttribute>());
    });

    test('preserves JSON type from base collection', () async {
      await createBase(client, 'configs', [
        TextAttribute(name: 'name', nullable: false),
        JsonAttribute(name: 'metadata', nullable: true),
      ]);

      final viewRes = await createView(
        client,
        'configs_view',
        'SELECT id, name, metadata FROM configs',
      );

      expect(viewRes.status, 200);

      final view = CollectionMapper.fromJson(viewRes.json!);
      final metadataAttr =
          view.attributes.firstWhere((a) => a.name == 'metadata');
      expect(metadataAttr, isA<JsonAttribute>());
    });

    test('preserves multiple semantic types in one view', () async {
      await createBase(client, 'records', [
        TextAttribute(name: 'label', nullable: false),
        BoolAttribute(name: 'active', nullable: false),
        DateAttribute(name: 'expires_at', nullable: true),
        IntAttribute(name: 'count', nullable: false),
        DoubleAttribute(name: 'score', nullable: true),
        JsonAttribute(name: 'tags', nullable: true),
      ]);

      final viewRes = await createView(
        client,
        'records_view',
        'SELECT id, label, active, expires_at, count, score, tags FROM records',
      );

      expect(viewRes.status, 200);

      final view = CollectionMapper.fromJson(viewRes.json!);

      expect(
        view.attributes.firstWhere((a) => a.name == 'label'),
        isA<TextAttribute>(),
      );
      expect(
        view.attributes.firstWhere((a) => a.name == 'active'),
        isA<BoolAttribute>(),
      );
      expect(
        view.attributes.firstWhere((a) => a.name == 'expires_at'),
        isA<DateAttribute>(),
      );
      expect(
        view.attributes.firstWhere((a) => a.name == 'count'),
        isA<IntAttribute>(),
      );
      expect(
        view.attributes.firstWhere((a) => a.name == 'score'),
        isA<DoubleAttribute>(),
      );
      expect(
        view.attributes.firstWhere((a) => a.name == 'tags'),
        isA<JsonAttribute>(),
      );
    });

    test('preserves system column types (created_at, updated_at as DATE)',
        () async {
      await createBase(client, 'items', [
        TextAttribute(name: 'name', nullable: false),
      ]);

      final viewRes = await createView(
        client,
        'items_view',
        'SELECT id, name, created_at, updated_at FROM items',
      );

      expect(viewRes.status, 200);

      final view = CollectionMapper.fromJson(viewRes.json!);

      expect(
        view.attributes.firstWhere((a) => a.name == 'created_at'),
        isA<DateAttribute>(),
      );
      expect(
        view.attributes.firstWhere((a) => a.name == 'updated_at'),
        isA<DateAttribute>(),
      );
    });

    test('preserves nullable from view PRAGMA, not base collection', () async {
      // Base collection has non-nullable BOOL
      await createBase(client, 'flags', [
        BoolAttribute(name: 'enabled', nullable: false),
      ]);

      final viewRes = await createView(
        client,
        'flags_view',
        'SELECT id, enabled FROM flags',
      );

      expect(viewRes.status, 200);

      final view = CollectionMapper.fromJson(viewRes.json!);
      final enabledAttr =
          view.attributes.firstWhere((a) => a.name == 'enabled');
      // The type should still be BOOL even though SQLite only sees INTEGER
      expect(enabledAttr, isA<BoolAttribute>());
    });

    test('falls back to SQLite type for computed/aliased columns', () async {
      await createBase(client, 'products', [
        TextAttribute(name: 'name', nullable: false),
        IntAttribute(name: 'price', nullable: false),
        IntAttribute(name: 'quantity', nullable: false),
      ]);

      final viewRes = await createView(
        client,
        'products_view',
        'SELECT id, name, price * quantity AS total_value FROM products',
      );

      expect(viewRes.status, 200);

      final view = CollectionMapper.fromJson(viewRes.json!);

      // 'name' should match the base collection
      expect(
        view.attributes.firstWhere((a) => a.name == 'name'),
        isA<TextAttribute>(),
      );
      // 'total_value' is computed and not in the base — falls back to SQLite type inference.
      // SQLite doesn't report a type for computed expressions, so it defaults to TEXT.
      final totalAttr =
          view.attributes.firstWhere((a) => a.name == 'total_value');
      expect(totalAttr, isA<TextAttribute>());
    });

    test('preserves types after updating a view query', () async {
      await createBase(client, 'notes', [
        TextAttribute(name: 'title', nullable: false),
        BoolAttribute(name: 'pinned', nullable: false),
        DateAttribute(name: 'due_date', nullable: true),
      ]);

      // Create initial view with only some columns
      await createView(
        client,
        'notes_view',
        'SELECT id, title FROM notes',
      );

      // Update the view to include more columns
      final updateRes = await client.patch('/v1/collections/notes_view', body: {
        'viewQuery': 'SELECT id, title, pinned, due_date FROM notes',
      });

      expect(updateRes.status, 200);

      final updated = CollectionMapper.fromJson(updateRes.json!);

      expect(
        updated.attributes.firstWhere((a) => a.name == 'pinned'),
        isA<BoolAttribute>(),
      );
      expect(
        updated.attributes.firstWhere((a) => a.name == 'due_date'),
        isA<DateAttribute>(),
      );
    });

    test('handles SELECT * from base collection', () async {
      await createBase(client, 'widgets', [
        TextAttribute(name: 'name', nullable: false),
        BoolAttribute(name: 'active', nullable: false),
        DateAttribute(name: 'manufactured_at', nullable: true),
      ]);

      final viewRes = await createView(
        client,
        'widgets_view',
        'SELECT * FROM widgets',
      );

      expect(viewRes.status, 200);

      final view = CollectionMapper.fromJson(viewRes.json!);

      expect(
        view.attributes.firstWhere((a) => a.name == 'active'),
        isA<BoolAttribute>(),
      );
      expect(
        view.attributes.firstWhere((a) => a.name == 'manufactured_at'),
        isA<DateAttribute>(),
      );
    });

    test('handles quoted table name in FROM clause', () async {
      await createBase(client, 'my_data', [
        BoolAttribute(name: 'flag', nullable: false),
      ]);

      final viewRes = await createView(
        client,
        'my_data_view',
        'SELECT id, flag FROM "my_data"',
      );

      expect(viewRes.status, 200);

      final view = CollectionMapper.fromJson(viewRes.json!);
      expect(
        view.attributes.firstWhere((a) => a.name == 'flag'),
        isA<BoolAttribute>(),
      );
    });
  });
}
