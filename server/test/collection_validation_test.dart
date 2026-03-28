import 'dart:io';

import 'package:vanestack/src/database/database.dart';
import 'package:vanestack/src/server.dart';
import 'package:vanestack/src/utils/auth.dart';
import 'package:vanestack/src/utils/env.dart';
import 'package:vanestack_common/vanestack_common.dart';
import 'package:drift/drift.dart' hide Index;
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

  group('SQL Keyword Validation', () {
    test('rejects collection name that is SQL keyword "select"', () async {
      final params = {
        'name': 'select',
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

    test('rejects collection name that is SQL keyword "table"', () async {
      final params = {
        'name': 'table',
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

    test('rejects collection name that is SQL keyword "index"', () async {
      final params = {
        'name': 'index',
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

    test('rejects attribute name that is SQL keyword "where"', () async {
      final params = {
        'name': 'items',
        'attributes': [TextAttribute(name: 'where').toJson()],
        'indexes': [],
      };

      final res = await client.post('/v1/collections', body: params);
      expect(res.status, 500); // Exception thrown for invalid attribute
    });

    test('allows collection name similar to but not SQL keyword', () async {
      final params = {
        'name': 'selections',
        'attributes': [TextAttribute(name: 'title').toJson()],
        'indexes': [],
      };

      final res = await client.post('/v1/collections', body: params);
      expect(res.status, 200);
    });
  });

  group('Index Column Validation', () {
    test('rejects index referencing non-existent column', () async {
      final params = {
        'name': 'products',
        'attributes': [
          TextAttribute(name: 'name').toJson(),
          DoubleAttribute(name: 'price').toJson(),
        ],
        'indexes': [
          Index(
            name: 'idx_products_category',
            columns: ['category'], // category doesn't exist
          ).toJson(),
        ],
      };

      final res = await client.post('/v1/collections', body: params);
      expect(res.status, 400);
      expect(
        res.json!['error']['message'],
        contains('non-existent column'),
      );
      expect(
        res.json!['error']['message'],
        contains('category'),
      );
    });

    test('rejects index with multiple columns where one is non-existent',
        () async {
      final params = {
        'name': 'orders',
        'attributes': [
          TextAttribute(name: 'customer_id').toJson(),
          DateAttribute(name: 'order_date').toJson(),
        ],
        'indexes': [
          Index(
            name: 'idx_orders_composite',
            columns: ['customer_id', 'status'], // status doesn't exist
          ).toJson(),
        ],
      };

      final res = await client.post('/v1/collections', body: params);
      expect(res.status, 400);
      expect(
        res.json!['error']['message'],
        contains('non-existent column'),
      );
      expect(
        res.json!['error']['message'],
        contains('status'),
      );
    });

    test('allows index referencing system columns', () async {
      final params = {
        'name': 'logs',
        'attributes': [
          TextAttribute(name: 'message').toJson(),
        ],
        'indexes': [
          Index(
            name: 'idx_logs_created',
            columns: ['created_at'], // system column
          ).toJson(),
        ],
      };

      final res = await client.post('/v1/collections', body: params);
      expect(res.status, 200);

      // Verify index was created
      final indexes = await database
          .customSelect(
            "SELECT name FROM sqlite_master WHERE type='index' AND tbl_name='logs' AND name NOT LIKE 'sqlite_autoindex_%'",
          )
          .get();

      final indexNames = indexes.map((r) => r.read<String>('name')).toList();
      expect(indexNames, contains('idx_logs_created'));
    });

    test('rejects update with index referencing non-existent column', () async {
      // Create collection first
      await client.post(
        '/v1/collections',
        body: {
          'name': 'articles',
          'attributes': [TextAttribute(name: 'title').toJson()],
          'indexes': [],
        },
      );

      // Try to update with invalid index
      final res = await client.patch(
        '/v1/collections/articles',
        body: {
          'indexes': [
            Index(
              name: 'idx_articles_author',
              columns: ['author'], // author doesn't exist
            ).toJson(),
          ],
        },
      );

      expect(res.status, 400);
      expect(
        res.json!['error']['message'],
        contains('non-existent column'),
      );
    });

    test('import rejects index with non-existent column', () async {
      final collections = [
        {
          'name': 'books',
          'type': 'base',
          'attributes': [TextAttribute(name: 'title').toJson()],
          'indexes': [
            Index(
              name: 'idx_books_author',
              columns: ['author'], // author doesn't exist
            ).toJson(),
          ],
          'created_at': DateTime.now().millisecondsSinceEpoch ~/ 1000,
          'updated_at': DateTime.now().millisecondsSinceEpoch ~/ 1000,
        },
      ];

      final res = await client.post(
        '/v1/collections/import',
        body: {'collections': collections, 'overwrite': false},
      );

      expect(res.status, 200);

      final importResponse = ImportResponseMapper.fromJson(res.json!);
      expect(importResponse.created, isEmpty);
      expect(importResponse.errors, isNotEmpty);
      expect(importResponse.errors.first.error, contains('non-existent column'));
    });
  });

  group('Unique Constraint Change Detection', () {
    test('detects unique constraint added to column', () async {
      // Create collection without unique
      await client.post(
        '/v1/collections',
        body: {
          'name': 'users',
          'attributes': [TextAttribute(name: 'email').toJson()],
          'indexes': [],
        },
      );

      // Update to add unique constraint
      final res = await client.patch(
        '/v1/collections/users',
        body: {
          'attributes': [TextAttribute(name: 'email', unique: true).toJson()],
        },
      );

      expect(res.status, 200);

      // Verify UNIQUE constraint in schema
      final tableInfo = await database
          .customSelect(
            'SELECT sql FROM sqlite_master WHERE type="table" AND name="users"',
          )
          .getSingle();
      final schema = tableInfo.read<String>('sql');
      expect(schema, contains('UNIQUE'));
    });

    test('detects unique constraint removed from column', () async {
      // Create collection with unique
      await client.post(
        '/v1/collections',
        body: {
          'name': 'accounts',
          'attributes': [TextAttribute(name: 'username', unique: true).toJson()],
          'indexes': [],
        },
      );

      // Verify unique exists
      var tableInfo = await database
          .customSelect(
            'SELECT sql FROM sqlite_master WHERE type="table" AND name="accounts"',
          )
          .getSingle();
      expect(tableInfo.read<String>('sql'), contains('UNIQUE'));

      // Update to remove unique constraint
      final res = await client.patch(
        '/v1/collections/accounts',
        body: {
          'attributes': [
            TextAttribute(name: 'username', unique: false).toJson(),
          ],
        },
      );

      expect(res.status, 200);

      // Verify UNIQUE constraint removed
      tableInfo = await database
          .customSelect(
            'SELECT sql FROM sqlite_master WHERE type="table" AND name="accounts"',
          )
          .getSingle();
      final schema = tableInfo.read<String>('sql');
      // Username should not have UNIQUE (only id has it implicitly via PRIMARY KEY)
      expect(schema.contains('"username" TEXT NOT NULL UNIQUE'), isFalse);
    });
  });

  group('Foreign Key Change Detection', () {
    test('detects foreign key table change', () async {
      // Create referenced tables
      await client.post(
        '/v1/collections',
        body: {
          'name': 'categories_v1',
          'attributes': [TextAttribute(name: 'name').toJson()],
          'indexes': [],
        },
      );

      await client.post(
        '/v1/collections',
        body: {
          'name': 'categories_v2',
          'attributes': [TextAttribute(name: 'name').toJson()],
          'indexes': [],
        },
      );

      // Create collection with FK to v1
      await client.post(
        '/v1/collections',
        body: {
          'name': 'products',
          'attributes': [
            TextAttribute(name: 'name').toJson(),
            TextAttribute(
              name: 'category_id',
              foreignKey: ForeignKey(table: 'categories_v1', column: 'id'),
            ).toJson(),
          ],
          'indexes': [],
        },
      );

      // Verify FK to v1
      var tableInfo = await database
          .customSelect(
            'SELECT sql FROM sqlite_master WHERE type="table" AND name="products"',
          )
          .getSingle();
      expect(tableInfo.read<String>('sql'), contains('categories_v1'));

      // Update FK to point to v2
      final res = await client.patch(
        '/v1/collections/products',
        body: {
          'attributes': [
            TextAttribute(name: 'name').toJson(),
            TextAttribute(
              name: 'category_id',
              foreignKey: ForeignKey(table: 'categories_v2', column: 'id'),
            ).toJson(),
          ],
        },
      );

      expect(res.status, 200);

      // Verify FK now points to v2
      tableInfo = await database
          .customSelect(
            'SELECT sql FROM sqlite_master WHERE type="table" AND name="products"',
          )
          .getSingle();
      final schema = tableInfo.read<String>('sql');
      expect(schema, contains('categories_v2'));
      expect(schema, isNot(contains('categories_v1')));
    });

    test('detects foreign key onDelete change', () async {
      await client.post(
        '/v1/collections',
        body: {
          'name': 'authors',
          'attributes': [TextAttribute(name: 'name').toJson()],
          'indexes': [],
        },
      );

      // Create with no onDelete action
      await client.post(
        '/v1/collections',
        body: {
          'name': 'books',
          'attributes': [
            TextAttribute(name: 'title').toJson(),
            TextAttribute(
              name: 'author_id',
              foreignKey: ForeignKey(table: 'authors', column: 'id'),
            ).toJson(),
          ],
          'indexes': [],
        },
      );

      // Update to add CASCADE
      final res = await client.patch(
        '/v1/collections/books',
        body: {
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
        },
      );

      expect(res.status, 200);

      // Verify ON DELETE CASCADE
      final tableInfo = await database
          .customSelect(
            'SELECT sql FROM sqlite_master WHERE type="table" AND name="books"',
          )
          .getSingle();
      expect(tableInfo.read<String>('sql'), contains('ON DELETE CASCADE'));
    });

    test('detects foreign key removed from column', () async {
      await client.post(
        '/v1/collections',
        body: {
          'name': 'departments',
          'attributes': [TextAttribute(name: 'name').toJson()],
          'indexes': [],
        },
      );

      // Create with FK
      await client.post(
        '/v1/collections',
        body: {
          'name': 'employees',
          'attributes': [
            TextAttribute(name: 'name').toJson(),
            TextAttribute(
              name: 'dept_id',
              foreignKey: ForeignKey(table: 'departments', column: 'id'),
            ).toJson(),
          ],
          'indexes': [],
        },
      );

      // Verify FK exists
      var tableInfo = await database
          .customSelect(
            'SELECT sql FROM sqlite_master WHERE type="table" AND name="employees"',
          )
          .getSingle();
      expect(tableInfo.read<String>('sql'), contains('REFERENCES'));

      // Update to remove FK
      final res = await client.patch(
        '/v1/collections/employees',
        body: {
          'attributes': [
            TextAttribute(name: 'name').toJson(),
            TextAttribute(name: 'dept_id').toJson(), // No FK
          ],
        },
      );

      expect(res.status, 200);

      // Verify FK removed
      tableInfo = await database
          .customSelect(
            'SELECT sql FROM sqlite_master WHERE type="table" AND name="employees"',
          )
          .getSingle();
      expect(tableInfo.read<String>('sql'), isNot(contains('REFERENCES')));
    });
  });

  group('Check Constraint Change Detection', () {
    test('detects check constraint modification', () async {
      // Create with initial check constraint
      await client.post(
        '/v1/collections',
        body: {
          'name': 'products',
          'attributes': [
            TextAttribute(name: 'name').toJson(),
            IntAttribute(
              name: 'quantity',
              checkConstraint: 'quantity >= 0',
            ).toJson(),
          ],
          'indexes': [],
        },
      );

      // Verify initial constraint
      var tableInfo = await database
          .customSelect(
            'SELECT sql FROM sqlite_master WHERE type="table" AND name="products"',
          )
          .getSingle();
      expect(tableInfo.read<String>('sql'), contains('quantity >= 0'));

      // Update to change constraint
      final res = await client.patch(
        '/v1/collections/products',
        body: {
          'attributes': [
            TextAttribute(name: 'name').toJson(),
            IntAttribute(
              name: 'quantity',
              checkConstraint: 'quantity >= 0 AND quantity <= 1000',
            ).toJson(),
          ],
        },
      );

      expect(res.status, 200);

      // Verify new constraint
      tableInfo = await database
          .customSelect(
            'SELECT sql FROM sqlite_master WHERE type="table" AND name="products"',
          )
          .getSingle();
      final schema = tableInfo.read<String>('sql');
      expect(schema, contains('quantity >= 0 AND quantity <= 1000'));
    });

    test('detects check constraint removed', () async {
      // Create with check constraint
      await client.post(
        '/v1/collections',
        body: {
          'name': 'ratings',
          'attributes': [
            IntAttribute(
              name: 'score',
              checkConstraint: 'score >= 1 AND score <= 5',
            ).toJson(),
          ],
          'indexes': [],
        },
      );

      // Update to remove constraint
      final res = await client.patch(
        '/v1/collections/ratings',
        body: {
          'attributes': [
            IntAttribute(name: 'score').toJson(), // No check constraint
          ],
        },
      );

      expect(res.status, 200);

      // Verify constraint removed
      final tableInfo = await database
          .customSelect(
            'SELECT sql FROM sqlite_master WHERE type="table" AND name="ratings"',
          )
          .getSingle();
      expect(tableInfo.read<String>('sql'), isNot(contains('CHECK')));
    });
  });

  group('Default Value Change Detection', () {
    test('detects default value added to column', () async {
      // Create without default
      await client.post(
        '/v1/collections',
        body: {
          'name': 'settings',
          'attributes': [
            TextAttribute(name: 'setting_key').toJson(), // "key" is reserved
            TextAttribute(name: 'setting_value').toJson(),
          ],
          'indexes': [],
        },
      );

      // Update to add default
      final res = await client.patch(
        '/v1/collections/settings',
        body: {
          'attributes': [
            TextAttribute(name: 'setting_key').toJson(),
            TextAttribute(name: 'setting_value', defaultValue: 'default_value')
                .toJson(),
          ],
        },
      );

      expect(res.status, 200);

      // Verify default value in schema
      final tableInfo = await database
          .customSelect(
            'SELECT sql FROM sqlite_master WHERE type="table" AND name="settings"',
          )
          .getSingle();
      expect(tableInfo.read<String>('sql'), contains('DEFAULT'));
      expect(tableInfo.read<String>('sql'), contains('default_value'));
    });

    test('detects default value changed', () async {
      // Create with initial default
      await client.post(
        '/v1/collections',
        body: {
          'name': 'counters',
          'attributes': [
            TextAttribute(name: 'name').toJson(),
            IntAttribute(name: 'count', defaultValue: 0).toJson(),
          ],
          'indexes': [],
        },
      );

      // Verify initial default
      var tableInfo = await database
          .customSelect(
            'SELECT sql FROM sqlite_master WHERE type="table" AND name="counters"',
          )
          .getSingle();
      expect(tableInfo.read<String>('sql'), contains('DEFAULT 0'));

      // Update to change default
      final res = await client.patch(
        '/v1/collections/counters',
        body: {
          'attributes': [
            TextAttribute(name: 'name').toJson(),
            IntAttribute(name: 'count', defaultValue: 100).toJson(),
          ],
        },
      );

      expect(res.status, 200);

      // Verify new default
      tableInfo = await database
          .customSelect(
            'SELECT sql FROM sqlite_master WHERE type="table" AND name="counters"',
          )
          .getSingle();
      expect(tableInfo.read<String>('sql'), contains('DEFAULT 100'));
    });

    test('detects default value removed', () async {
      // Create with default
      await client.post(
        '/v1/collections',
        body: {
          'name': 'flags',
          'attributes': [
            TextAttribute(name: 'name').toJson(),
            BoolAttribute(name: 'enabled', defaultValue: true).toJson(),
          ],
          'indexes': [],
        },
      );

      // Update to remove default
      final res = await client.patch(
        '/v1/collections/flags',
        body: {
          'attributes': [
            TextAttribute(name: 'name').toJson(),
            BoolAttribute(name: 'enabled').toJson(), // No default
          ],
        },
      );

      expect(res.status, 200);

      // Verify default removed (enabled column should not have DEFAULT)
      final tableInfo = await database
          .customSelect(
            'SELECT sql FROM sqlite_master WHERE type="table" AND name="flags"',
          )
          .getSingle();
      final schema = tableInfo.read<String>('sql');
      // The schema should have enabled without a DEFAULT clause
      // But system columns will have defaults, so we check specifically for enabled
      final enabledMatch =
          RegExp(r'"enabled"[^,]+').firstMatch(schema)?.group(0) ?? '';
      expect(enabledMatch, isNot(contains('DEFAULT')));
    });
  });
}
