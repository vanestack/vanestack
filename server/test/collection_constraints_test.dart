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

  group('CHECK Constraints', () {
    test('creates collection with CHECK constraint on integer field', () async {
      final params = {
        'name': 'products',
        'attributes': [
          TextAttribute(name: 'name').toJson(),
          IntAttribute(
            name: 'quantity',
            checkConstraint: 'quantity >= 0',
          ).toJson(),
        ],
        'indexes': [],
      };

      final res = await client.post('/v1/collections', body: params);
      expect(res.status, 200);

      // Verify CHECK constraint exists in schema
      final tableInfo = await database
          .customSelect(
            'SELECT sql FROM sqlite_master WHERE type="table" AND name="products"',
          )
          .getSingle();
      final schema = tableInfo.read<String>('sql');
      expect(schema, contains('CHECK'));
      expect(schema, contains('quantity >= 0'));

      // Test that CHECK constraint is enforced
      await database.customStatement(
        "INSERT INTO products (name, quantity) VALUES ('Widget', 10)",
      );

      // This should fail due to CHECK constraint
      try {
        await database.customStatement(
          "INSERT INTO products (name, quantity) VALUES ('BadWidget', -5)",
        );
        fail('Should have thrown constraint violation');
      } catch (e) {
        expect(e.toString(), contains('CHECK constraint failed'));
      }
    });

    test('creates collection with CHECK constraint on text field', () async {
      final params = {
        'name': 'users',
        'attributes': [
          TextAttribute(
            name: 'email',
            checkConstraint: "email LIKE '%@%'",
          ).toJson(),
        ],
        'indexes': [],
      };

      final res = await client.post('/v1/collections', body: params);
      expect(res.status, 200);

      final tableInfo = await database
          .customSelect(
            'SELECT sql FROM sqlite_master WHERE type="table" AND name="users"',
          )
          .getSingle();
      final schema = tableInfo.read<String>('sql');
      expect(schema, contains('CHECK'));
      expect(schema, contains("email LIKE '%@%'"));
    });

    test('creates collection with multiple CHECK constraints', () async {
      final params = {
        'name': 'employees',
        'attributes': [
          TextAttribute(name: 'name').toJson(),
          IntAttribute(
            name: 'age',
            checkConstraint: 'age >= 18 AND age <= 100',
          ).toJson(),
          DoubleAttribute(
            name: 'salary',
            checkConstraint: 'salary > 0',
          ).toJson(),
        ],
        'indexes': [],
      };

      final res = await client.post('/v1/collections', body: params);
      expect(res.status, 200);

      final tableInfo = await database
          .customSelect(
            'SELECT sql FROM sqlite_master WHERE type="table" AND name="employees"',
          )
          .getSingle();
      final schema = tableInfo.read<String>('sql');
      expect(schema, contains('age >= 18 AND age <= 100'));
      expect(schema, contains('salary > 0'));
    });

    test('updates collection to add CHECK constraint', () async {
      // Create without constraint
      await client.post(
        '/v1/collections',
        body: {
          'name': 'inventory',
          'attributes': [IntAttribute(name: 'stock').toJson()],
          'indexes': [],
        },
      );

      // Update to add constraint
      final res = await client.patch(
        '/v1/collections/inventory',
        body: {
          'attributes': [
            IntAttribute(name: 'stock', checkConstraint: 'stock >= 0').toJson(),
          ],
        },
      );

      expect(res.status, 200);

      final tableInfo = await database
          .customSelect(
            'SELECT sql FROM sqlite_master WHERE type="table" AND name="inventory"',
          )
          .getSingle();
      final schema = tableInfo.read<String>('sql');

      expect(schema, contains('CHECK'));
      expect(schema, contains('stock >= 0'));
    });
  });

  group('FOREIGN KEY Constraints', () {
    test('creates collection with FOREIGN KEY reference', () async {
      // First create the referenced table
      await client.post(
        '/v1/collections',
        body: {
          'name': 'categories',
          'attributes': [TextAttribute(name: 'name').toJson()],
          'indexes': [],
        },
      );

      // Create table with foreign key
      final params = {
        'name': 'products',
        'attributes': [
          TextAttribute(name: 'name').toJson(),
          TextAttribute(
            name: 'category_id',
            foreignKey: ForeignKey(table: 'categories', column: 'id'),
          ).toJson(),
        ],
        'indexes': [],
      };

      final res = await client.post('/v1/collections', body: params);
      expect(res.status, 200);

      final tableInfo = await database
          .customSelect(
            'SELECT sql FROM sqlite_master WHERE type="table" AND name="products"',
          )
          .getSingle();
      final schema = tableInfo.read<String>('sql');
      expect(schema, contains('REFERENCES'));
      expect(schema, contains('categories'));
    });

    test('creates FOREIGN KEY with ON DELETE CASCADE', () async {
      await client.post(
        '/v1/collections',
        body: {
          'name': 'authors',
          'attributes': [TextAttribute(name: 'name').toJson()],
          'indexes': [],
        },
      );

      final params = {
        'name': 'books',
        'attributes': [
          TextAttribute(name: 'title').toJson(),
          TextAttribute(
            name: 'author_id',
            foreignKey: ForeignKey(
              table: 'authors',
              column: 'id',
              onDelete: 'CASCADE',
            ),
          ).toJson(),
        ],
        'indexes': [],
      };

      final res = await client.post('/v1/collections', body: params);
      expect(res.status, 200);

      final tableInfo = await database
          .customSelect(
            'SELECT sql FROM sqlite_master WHERE type="table" AND name="books"',
          )
          .getSingle();
      final schema = tableInfo.read<String>('sql');
      expect(schema, contains('ON DELETE CASCADE'));
    });

    test('creates FOREIGN KEY with ON UPDATE SET NULL', () async {
      await client.post(
        '/v1/collections',
        body: {
          'name': 'departments',
          'attributes': [TextAttribute(name: 'name').toJson()],
          'indexes': [],
        },
      );

      final params = {
        'name': 'employees',
        'attributes': [
          TextAttribute(name: 'name').toJson(),
          TextAttribute(
            name: 'department_id',
            nullable: true,
            foreignKey: ForeignKey(
              table: 'departments',
              column: 'id',
              onUpdate: 'SET NULL',
            ),
          ).toJson(),
        ],
        'indexes': [],
      };

      final res = await client.post('/v1/collections', body: params);
      expect(res.status, 200);

      final tableInfo = await database
          .customSelect(
            'SELECT sql FROM sqlite_master WHERE type="table" AND name="employees"',
          )
          .getSingle();
      final schema = tableInfo.read<String>('sql');
      expect(schema, contains('ON UPDATE SET NULL'));
    });

    test('creates multiple FOREIGN KEYs in same table', () async {
      await client.post(
        '/v1/collections',
        body: {
          'name': 'users',
          'attributes': [TextAttribute(name: 'name').toJson()],
          'indexes': [],
        },
      );

      await client.post(
        '/v1/collections',
        body: {
          'name': 'projects',
          'attributes': [TextAttribute(name: 'title').toJson()],
          'indexes': [],
        },
      );

      final params = {
        'name': 'tasks',
        'attributes': [
          TextAttribute(name: 'title').toJson(),
          TextAttribute(
            name: 'assigned_to',
            foreignKey: ForeignKey(table: 'users', column: 'id'),
          ).toJson(),
          TextAttribute(
            name: 'project_id',
            foreignKey: ForeignKey(table: 'projects', column: 'id'),
          ).toJson(),
        ],
        'indexes': [],
      };

      final res = await client.post('/v1/collections', body: params);
      expect(res.status, 200);

      final tableInfo = await database
          .customSelect(
            'SELECT sql FROM sqlite_master WHERE type="table" AND name="tasks"',
          )
          .getSingle();
      final schema = tableInfo.read<String>('sql');

      // Check both foreign keys exist
      final foreignKeyCount = 'REFERENCES'.allMatches(schema).length;
      expect(foreignKeyCount, equals(2));
    });

    test('updates collection to add FOREIGN KEY', () async {
      await client.post(
        '/v1/collections',
        body: {
          'name': 'companies',
          'attributes': [TextAttribute(name: 'name').toJson()],
          'indexes': [],
        },
      );

      await client.post(
        '/v1/collections',
        body: {
          'name': 'employees',
          'attributes': [
            TextAttribute(name: 'name').toJson(),
            TextAttribute(name: 'company_id').toJson(),
          ],
          'indexes': [],
        },
      );

      // Update to add foreign key
      final res = await client.patch(
        '/v1/collections/employees',
        body: {
          'attributes': [
            TextAttribute(name: 'name').toJson(),
            TextAttribute(
              name: 'company_id',
              foreignKey: ForeignKey(table: 'companies', column: 'id'),
            ).toJson(),
          ],
        },
      );

      expect(res.status, 200);

      final tableInfo = await database
          .customSelect(
            'SELECT sql FROM sqlite_master WHERE type="table" AND name="employees"',
          )
          .getSingle();
      final schema = tableInfo.read<String>('sql');
      expect(schema, contains('REFERENCES "companies"'));
    });
  });

  group('Combined Constraints', () {
    test('creates column with both CHECK and FOREIGN KEY', () async {
      await client.post(
        '/v1/collections',
        body: {
          'name': 'categories',
          'attributes': [IntAttribute(name: 'priority').toJson()],
          'indexes': [],
        },
      );

      final params = {
        'name': 'items',
        'attributes': [
          TextAttribute(name: 'name').toJson(),
          TextAttribute(
            name: 'category_id',
            checkConstraint: "category_id != ''",
            foreignKey: ForeignKey(
              table: 'categories',
              column: 'id',
              onDelete: 'RESTRICT',
            ),
          ).toJson(),
        ],
        'indexes': [],
      };

      final res = await client.post('/v1/collections', body: params);
      expect(res.status, 200);

      final tableInfo = await database
          .customSelect(
            'SELECT sql FROM sqlite_master WHERE type="table" AND name="items"',
          )
          .getSingle();
      final schema = tableInfo.read<String>('sql');
      expect(schema, contains('CHECK'));
      expect(schema, contains('REFERENCES'));
      expect(schema, contains('ON DELETE RESTRICT'));
    });
  });
}
