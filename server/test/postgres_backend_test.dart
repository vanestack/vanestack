@Tags(['postgres'])
library;

import 'dart:io';

import 'package:drift/drift.dart' hide isNull, isNotNull, Index;
import 'package:postgres/postgres.dart' as pg;
import 'package:shelf/shelf.dart';
import 'package:test/test.dart';
import 'package:vanestack/src/database/database.dart';
import 'package:vanestack/src/permissions/rules_engine.dart';
import 'package:vanestack/src/services/auth_service.dart';
import 'package:vanestack/src/services/collections_service.dart';
import 'package:vanestack/src/services/context.dart';
import 'package:vanestack/src/services/documents_service.dart';
import 'package:vanestack/src/services/logs_service.dart';
import 'package:vanestack/src/services/storage_service.dart';
import 'package:vanestack/src/services/users_service.dart';
import 'package:vanestack/src/utils/env.dart';
import 'package:vanestack_common/vanestack_common.dart';

/// Postgres-backed integration tests.
///
/// These tests require a reachable postgres instance. Point them at it via:
///
///   VANESTACK_TEST_POSTGRES_URL=postgres://user:pass@host:5432/db dart test
///
/// Every test drops and recreates the public schema for isolation, so do
/// NOT point this at a database with real data.
void main() {
  final url = Platform.environment['VANESTACK_TEST_POSTGRES_URL'];
  if (url == null || url.isEmpty) {
    test(
      'postgres backend',
      () {},
      skip: 'Set VANESTACK_TEST_POSTGRES_URL to a disposable postgres URL.',
    );
    return;
  }

  /// Wipes the `public` schema so each test starts from a clean slate.
  Future<void> wipePublicSchema() async {
    final uri = Uri.parse(url);
    final userInfo = uri.userInfo.split(':');
    final endpoint = pg.Endpoint(
      host: uri.host,
      port: uri.hasPort ? uri.port : 5432,
      database: uri.pathSegments.first,
      username: userInfo.isNotEmpty ? Uri.decodeComponent(userInfo[0]) : null,
      password:
          userInfo.length > 1 ? Uri.decodeComponent(userInfo[1]) : null,
    );
    final sslMode = switch (uri.queryParameters['sslmode']) {
      'disable' => pg.SslMode.disable,
      'verify-full' => pg.SslMode.verifyFull,
      _ => pg.SslMode.require,
    };
    final conn = await pg.Connection.open(
      endpoint,
      settings: pg.ConnectionSettings(sslMode: sslMode),
    );
    try {
      await conn.execute('DROP SCHEMA IF EXISTS public CASCADE');
      await conn.execute('CREATE SCHEMA public');
    } finally {
      await conn.close();
    }
  }

  late AppDatabase db;
  late ServiceContext ctx;

  setUp(() async {
    await wipePublicSchema();
    db = AppDatabase(AppDatabase.postgresExecutor(url));
    // Force migration/onCreate by issuing a trivial drift query.
    await db.collections.select().get();
    ctx = (database: db, env: const Environment(), realtime: null, hooks: null, collectionsCache: null);
  });

  tearDown(() async {
    await db.close();
  });

  group('database bootstrap', () {
    test('migration creates drift schema tables', () async {
      final result = await db
          .customSelect(
            "SELECT table_name FROM information_schema.tables "
            "WHERE table_schema = current_schema()",
          )
          .get();
      final names = result.map((r) => r.read<String>('table_name')).toSet();
      expect(
        names,
        containsAll({'_users', '_files', '_collections', '_logs'}),
      );
    });

    test('random_uuid_v7() function is installed and returns a v7 uuid',
        () async {
      final row = await db
          .customSelect('SELECT random_uuid_v7() AS id')
          .getSingle();
      final id = row.read<String>('id');
      // RFC 9562 §5.7: version nibble is the 13th hex char; variant nibble
      // is at position 17 and must be 8, 9, a, or b.
      expect(id, matches(RegExp(r'^[0-9a-f]{8}-[0-9a-f]{4}-7[0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$')));
    });
  });

  group('users service (postgres)', () {
    test('create + getByEmail + list + filter', () async {
      final users = UsersService(ctx);

      await users.create(email: 'a@example.com', password: 'S3cur3P@ssPhrase!7Zx');
      await users.create(email: 'b@example.com', password: 'S3cur3P@ssPhrase!7Zx');
      await users.create(email: 'c@example.com', password: 'S3cur3P@ssPhrase!7Zx');

      final got = await users.getByEmail('b@example.com');
      expect(got, isNotNull);
      expect(got!.email, 'b@example.com');

      final all = await users.list();
      expect(all.count, 3);

      final filtered = await users.list(filter: "email = 'a@example.com'");
      expect(filtered.count, 1);
      expect(filtered.users.single.email, 'a@example.com');
    });
  });

  group('collections + documents service (postgres)', () {
    test('create collection, insert document, list, update, delete',
        () async {
      final collections = CollectionsService(ctx);
      final docs = DocumentsService(ctx);

      await collections.createBase(
        name: 'posts',
        attributes: [
          TextAttribute(name: 'title', nullable: false),
          IntAttribute(name: 'views', nullable: true),
          BoolAttribute(name: 'published', nullable: false),
        ],
      );

      final doc1 = await docs.create(
        collectionName: 'posts',
        data: {'title': 'hello', 'views': 1, 'published': true},
      );
      final doc2 = await docs.create(
        collectionName: 'posts',
        data: {'title': 'world', 'views': 5, 'published': false},
      );

      expect(doc1.id, matches(RegExp(r'^[0-9a-f-]{36}$')));
      expect(doc1.data['title'], 'hello');

      final got = await docs.get(
        collectionName: 'posts',
        documentId: doc1.id,
      );
      expect(got!.data['title'], 'hello');

      final listed = await docs.list(collectionName: 'posts');
      expect(listed.count, 2);

      final filtered = await docs.list(
        collectionName: 'posts',
        filter: "title = 'world'",
      );
      expect(filtered.count, 1);
      expect(filtered.documents.single.id, doc2.id);

      final updated = await docs.update(
        collectionName: 'posts',
        documentId: doc1.id,
        data: {'views': 42},
      );
      expect(updated.data['views'], 42);

      await docs.delete(collectionName: 'posts', documentId: doc2.id);
      final remaining = await docs.list(collectionName: 'posts');
      expect(remaining.count, 1);
    });

    test('raw INSERT without id auto-fills a v7 uuid via DB default',
        () async {
      final collections = CollectionsService(ctx);
      await collections.createBase(
        name: 'raw_items',
        attributes: [TextAttribute(name: 'label', nullable: false)],
      );

      await db.customStatement(
        'INSERT INTO "raw_items" ("label") VALUES (\'abc\')',
      );

      final row = await db
          .customSelect('SELECT "id" FROM "raw_items" LIMIT 1')
          .getSingle();
      final id = row.read<String>('id');
      expect(
        id,
        matches(RegExp(r'^[0-9a-f]{8}-[0-9a-f]{4}-7[0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$')),
      );
    });

    test('updated_at trigger advances on UPDATE', () async {
      final collections = CollectionsService(ctx);
      final docs = DocumentsService(ctx);
      await collections.createBase(
        name: 'trig',
        attributes: [TextAttribute(name: 'note', nullable: false)],
      );

      final doc = await docs.create(
        collectionName: 'trig',
        data: {'note': 'a'},
      );
      final originalUpdatedAt = doc.updatedAt!.millisecondsSinceEpoch;

      // Force a DB-side update so the trigger fires (bypassing the service,
      // which always sets updated_at explicitly).
      await Future<void>.delayed(const Duration(milliseconds: 1100));
      await db.customStatement(
        db.adaptPlaceholders(
          "UPDATE \"trig\" SET \"note\" = 'b' WHERE \"id\" = ?",
        ),
        [doc.id],
      );

      final row = await db
          .customSelect(
            db.adaptPlaceholders('SELECT updated_at FROM "trig" WHERE id = ?'),
            variables: [Variable<String>(doc.id)],
          )
          .getSingle();
      final newUpdatedAt = row.read<int>('updated_at');
      // epoch seconds; trigger should have bumped it at least 1 second ahead.
      expect(newUpdatedAt * 1000, greaterThan(originalUpdatedAt));
    });

    test('update collection renames table and keeps data', () async {
      final collections = CollectionsService(ctx);
      final docs = DocumentsService(ctx);
      await collections.createBase(
        name: 'old_name',
        attributes: [TextAttribute(name: 'val', nullable: false)],
      );
      final doc = await docs.create(
        collectionName: 'old_name',
        data: {'val': 'x'},
      );

      await collections.updateBase(name: 'old_name', newName: 'new_name');

      final listed = await docs.list(collectionName: 'new_name');
      expect(listed.count, 1);
      expect(listed.documents.single.id, doc.id);
    });

    test('delete collection drops table and metadata', () async {
      final collections = CollectionsService(ctx);
      await collections.createBase(
        name: 'doomed',
        attributes: [TextAttribute(name: 'v', nullable: false)],
      );
      await collections.delete('doomed');
      final exists = await collections.getByName('doomed');
      expect(exists, isNull);
    });
  });

  group('storage service (postgres)', () {
    test('bucket + file filter path works on postgres', () async {
      final storage = StorageService(ctx);
      await storage.createBucket(name: 'images');

      // Insert file records directly to avoid local FS dependency.
      final now = DateTime.now().millisecondsSinceEpoch ~/ 1000;
      for (final path in ['a/one.png', 'a/two.png', 'b/three.png']) {
        await db.customStatement(
          db.adaptPlaceholders(
            'INSERT INTO "_files" '
            '("id", "path", "bucket", "is_local", "size", '
            '"mime_type", "download_token", "created_at", "updated_at") '
            'VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)',
          ),
          [path, path, 'images', false, 100, 'image/png', 'tok_$path', now, now],
        );
      }

      final (files, topFolders) = await storage.listFiles(bucket: 'images');
      expect(files, isEmpty); // no top-level files; folders listed separately
      expect(topFolders.toSet(), {'a', 'b'});

      final (filesAt, folders) = await storage.listFiles(
        bucket: 'images',
        path: 'a/',
      );
      expect(filesAt.map((f) => f.path).toSet(), {'a/one.png', 'a/two.png'});
      expect(folders, isEmpty);

      final (filtered, _) = await storage.listFiles(
        bucket: 'images',
        path: 'a/',
        filter: "mime_type = 'image/png'",
      );
      expect(filtered.length, 2);
    });
  });

  group('stats endpoint date aggregation (postgres)', () {
    test('per-day YYYY-MM-DD grouping works on postgres', () async {
      // Use noon UTC anchors so timezone differences don't move the date.
      final nowUtc = DateTime.now().toUtc();
      final todayNoonUtc =
          DateTime.utc(nowUtc.year, nowUtc.month, nowUtc.day, 12);
      final yesterdayNoonUtc =
          todayNoonUtc.subtract(const Duration(days: 1));

      Future<void> insertLog(DateTime ts) async {
        await db.customStatement(
          db.adaptPlaceholders(
            'INSERT INTO "_logs" ("level", "source", "message", "created_at") '
            'VALUES (?, ?, ?, ?)',
          ),
          ['info', 'http', 'req', ts.millisecondsSinceEpoch ~/ 1000],
        );
      }

      await insertLog(todayNoonUtc);
      await insertLog(todayNoonUtc);
      await insertLog(yesterdayNoonUtc);

      // Mirrors the query shape in endpoints/stats/stats.dart: group by a
      // dialect-aware YYYY-MM-DD derived from the epoch-seconds column.
      final rows = await db
          .customSelect(
            db.adaptPlaceholders(
              "SELECT to_char(to_timestamp(\"created_at\"), 'YYYY-MM-DD') AS day, "
              'COUNT(*) AS c FROM "_logs" '
              'WHERE "source" = ? '
              'GROUP BY day ORDER BY day ASC',
            ),
            variables: [Variable<String>('http')],
          )
          .get();

      final perDay = {
        for (final r in rows) r.read<String>('day'): r.read<int>('c'),
      };

      String fmt(DateTime d) =>
          '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
      expect(perDay[fmt(todayNoonUtc)], 2);
      expect(perDay[fmt(yesterdayNoonUtc)], 1);
    });
  });

  group('logs service (postgres)', () {
    test('list with filter and paging', () async {
      final logs = LogsService(ctx);

      for (var i = 0; i < 5; i++) {
        await db.logs.insertOne(
          LogsCompanion.insert(
            level: LogLevel.info,
            source: LogSource.server,
            message: 'msg $i',
          ),
        );
      }

      final all = await logs.list(limit: 10);
      expect(all.count, 5);

      final filtered = await logs.list(filter: "message = 'msg 2'");
      expect(filtered.count, 1);
      expect(filtered.logs.single.message, 'msg 2');

      final paged = await logs.list(limit: 2, offset: 1);
      expect(paged.logs.length, 2);
      expect(paged.count, 5);
    });
  });

  // ------------------------- Auth flows (#1) -------------------------
  //
  // The 4 tables (_otps, _refresh_tokens, _reset_password_tokens,
  // _oauth_states) had their DB-side `expires_at` default removed in favor of
  // a Dart-side clientDefault. These tests assert the service path still
  // populates `expires_at` and the full flows complete end-to-end on postgres.
  group('auth flows (postgres)', () {
    test('sign-in with password issues tokens, refresh rotates them',
        () async {
      final auth = AuthService(ctx);
      const password = 'S3cur3P@ssPhrase!7Zx';

      final first = await auth.signInWithEmailAndPassword(
        email: 'auth@example.com',
        password: password,
      );
      expect(first.accessToken, isNotEmpty);
      expect(first.refreshToken, isNotEmpty);

      // refresh_tokens.expires_at must be populated (clientDefault) and
      // strictly in the future.
      final stored = await db.refreshTokens.select().getSingle();
      expect(
        stored.expiresAt.isAfter(DateTime.now()),
        isTrue,
        reason: 'refresh token expires_at not populated',
      );

      final rotated = await auth.refreshToken(
        refreshToken: first.refreshToken,
      );
      expect(rotated.accessToken, isNotEmpty);
      expect(rotated.refreshToken, isNot(first.refreshToken));
    });

    test('OTP create + verify consumes the row', () async {
      final users = UsersService(ctx);
      final auth = AuthService(ctx);

      await users.create(
        email: 'otp@example.com',
        password: 'S3cur3P@ssPhrase!7Zx',
      );

      final code = await auth.createOtp(email: 'otp@example.com');
      expect(code, hasLength(6));

      final otps = await db.otps.select().get();
      expect(otps, hasLength(1));
      expect(
        otps.single.expiresAt.isAfter(DateTime.now()),
        isTrue,
        reason: 'otp expires_at not populated',
      );

      final resp = await auth.verifyOtp(email: 'otp@example.com', otp: code);
      expect(resp.accessToken, isNotEmpty);

      // OTP is consumed after successful verification.
      final after = await db.otps.select().get();
      expect(after, isEmpty);
    });

    test('password reset: create token + reset succeeds', () async {
      final users = UsersService(ctx);
      final auth = AuthService(ctx);
      const original = 'S3cur3P@ssPhrase!7Zx';
      const replacement = 'N3wS3cur3P@ssPhrase!9Qv';

      await users.create(email: 'reset@example.com', password: original);

      final token = await auth.createPasswordResetToken(
        email: 'reset@example.com',
      );
      expect(token, isNotEmpty);

      final stored = await db.resetPasswordTokens.select().getSingle();
      expect(
        stored.expiresAt.isAfter(DateTime.now()),
        isTrue,
        reason: 'reset token expires_at not populated',
      );

      await auth.resetPassword(token: token, newPassword: replacement);

      // Can sign in with the new password.
      final signedIn = await auth.signInWithEmailAndPassword(
        email: 'reset@example.com',
        password: replacement,
      );
      expect(signedIn.accessToken, isNotEmpty);
    });
  });

  // ------------------- Collection update paths (#2) -------------------
  group('collection update with column changes (postgres)', () {
    test('add + remove + modify attributes preserves surviving data',
        () async {
      final collections = CollectionsService(ctx);
      final docs = DocumentsService(ctx);

      await collections.createBase(
        name: 'items',
        attributes: [
          TextAttribute(name: 'title', nullable: false),
          IntAttribute(name: 'qty', nullable: true),
        ],
      );

      final doc = await docs.create(
        collectionName: 'items',
        data: {'title': 'widget', 'qty': 3},
      );

      // Add 'price' (new), drop 'qty', keep 'title'.
      await collections.updateBase(
        name: 'items',
        attributes: [
          TextAttribute(name: 'title', nullable: false),
          DoubleAttribute(name: 'price', nullable: true),
        ],
      );

      final listed = await docs.list(collectionName: 'items');
      expect(listed.count, 1);
      expect(listed.documents.single.id, doc.id);
      expect(listed.documents.single.data['title'], 'widget');
      expect(listed.documents.single.data.containsKey('qty'), isFalse);

      // Insert another row using the new schema to prove it's usable.
      final priced = await docs.create(
        collectionName: 'items',
        data: {'title': 'gizmo', 'price': 9.99},
      );
      expect(priced.data['price'], 9.99);
    });
  });

  // ---------------------- View collections (#3) ----------------------
  group('view collections (postgres)', () {
    test('createView infers attributes and list returns rows', () async {
      final collections = CollectionsService(ctx);
      final docs = DocumentsService(ctx);

      await collections.createBase(
        name: 'articles',
        attributes: [
          TextAttribute(name: 'title', nullable: false),
          BoolAttribute(name: 'published', nullable: false),
        ],
      );
      await docs.create(
        collectionName: 'articles',
        data: {'title': 'a', 'published': true},
      );
      await docs.create(
        collectionName: 'articles',
        data: {'title': 'b', 'published': false},
      );

      final view = await collections.createView(
        name: 'published_articles',
        viewQuery: 'SELECT id, title FROM articles WHERE published = 1',
      );
      expect(view.attributes.map((a) => a.name), containsAll(['id', 'title']));

      final listed = await docs.list(collectionName: 'published_articles');
      expect(listed.count, 1);
      expect(listed.documents.single.data['title'], 'a');

      await collections.delete('published_articles');
      expect(await collections.getByName('published_articles'), null);
    });
  });

  // ------------------- Indexes: create + introspection (#4) -------------------
  group('indexes on postgres', () {
    test('unique + non-unique indexes round-trip via introspection',
        () async {
      final collections = CollectionsService(ctx);

      await collections.createBase(
        name: 'idx_test',
        attributes: [
          TextAttribute(name: 'email', nullable: false),
          TextAttribute(name: 'status', nullable: false),
        ],
        indexes: [
          Index(name: 'idx_email_unique', columns: ['email'], unique: true),
          Index(name: 'idx_status', columns: ['status']),
        ],
      );

      // Query pg_indexes directly to confirm both indexes exist with the
      // expected uniqueness flags.
      final rows = await db
          .customSelect(
            r'''
SELECT i.relname AS name, ix.indisunique AS is_unique
FROM pg_class t
JOIN pg_namespace n ON n.oid = t.relnamespace
JOIN pg_index ix ON t.oid = ix.indrelid
JOIN pg_class i ON i.oid = ix.indexrelid
WHERE n.nspname = current_schema()
  AND t.relname = $1
  AND NOT ix.indisprimary
''',
            variables: [Variable<String>('idx_test')],
          )
          .get();

      final byName = {
        for (final r in rows) r.read<String>('name'): r.read<bool>('is_unique'),
      };
      expect(byName['idx_email_unique'], isTrue);
      expect(byName['idx_status'], isFalse);
    });
  });

  // ----------- Check constraint + foreign key DDL (#5, #6) -----------
  group('check + foreign key (postgres)', () {
    test('CHECK constraint is enforced and FK references are respected',
        () async {
      final collections = CollectionsService(ctx);
      final docs = DocumentsService(ctx);

      await collections.createBase(
        name: 'authors',
        attributes: [TextAttribute(name: 'name', nullable: false)],
      );
      final author = await docs.create(
        collectionName: 'authors',
        data: {'name': 'Ada'},
      );

      await collections.createBase(
        name: 'books',
        attributes: [
          TextAttribute(name: 'title', nullable: false),
          IntAttribute(
            name: 'pages',
            nullable: false,
            checkConstraint: 'pages > 0',
          ),
          TextAttribute(
            name: 'author_id',
            nullable: false,
            foreignKey: ForeignKey(
              table: 'authors',
              column: 'id',
              onDelete: 'CASCADE',
            ),
          ),
        ],
      );

      // Happy path.
      final book = await docs.create(
        collectionName: 'books',
        data: {'title': 't', 'pages': 10, 'author_id': author.id},
      );
      expect(book.data['title'], 't');

      // Violates CHECK (pages > 0).
      await expectLater(
        () => docs.create(
          collectionName: 'books',
          data: {'title': 'bad', 'pages': 0, 'author_id': author.id},
        ),
        throwsA(anything),
      );

      // Violates FK (author doesn't exist).
      await expectLater(
        () => docs.create(
          collectionName: 'books',
          data: {
            'title': 'orphan',
            'pages': 1,
            'author_id': 'does-not-exist',
          },
        ),
        throwsA(anything),
      );
    });
  });

  // -------------- All 6 attribute types round-trip (#7) --------------
  group('attribute types (postgres)', () {
    test('Double, Date, Json round-trip through postgres', () async {
      final collections = CollectionsService(ctx);
      final docs = DocumentsService(ctx);

      await collections.createBase(
        name: 'all_types',
        attributes: [
          TextAttribute(name: 'name', nullable: false),
          IntAttribute(name: 'count', nullable: false),
          DoubleAttribute(name: 'ratio', nullable: false),
          BoolAttribute(name: 'active', nullable: false),
          DateAttribute(name: 'occurred', nullable: false),
          JsonAttribute(name: 'meta', nullable: true),
        ],
      );

      final occurred = DateTime.utc(2026, 4, 18, 12);
      final doc = await docs.create(
        collectionName: 'all_types',
        data: {
          'name': 'probe',
          'count': 42,
          'ratio': 3.14,
          'active': true,
          'occurred': occurred,
          'meta': {'tag': 'x', 'n': 2},
        },
      );

      final round = await docs.get(
        collectionName: 'all_types',
        documentId: doc.id,
      );
      expect(round, isNotNull);
      expect(round!.data['name'], 'probe');
      expect(round.data['count'], 42);
      expect(round.data['ratio'], 3.14);
      expect(round.data['active'], true);
      // DateAttribute is stored/returned as DateTime in epoch seconds.
      expect(
        (round.data['occurred'] as DateTime).millisecondsSinceEpoch ~/ 1000,
        occurred.millisecondsSinceEpoch ~/ 1000,
      );
      expect(round.data['meta'], {'tag': 'x', 'n': 2});
    });
  });

  // --------------------- ORDER BY on list (#8) ---------------------
  group('order by (postgres)', () {
    test('documents.list orders by column ascending and descending',
        () async {
      final collections = CollectionsService(ctx);
      final docs = DocumentsService(ctx);

      await collections.createBase(
        name: 'ranked',
        attributes: [
          TextAttribute(name: 'label', nullable: false),
          IntAttribute(name: 'score', nullable: false),
        ],
      );
      for (final (label, score) in [('b', 2), ('a', 1), ('c', 3)]) {
        await docs.create(
          collectionName: 'ranked',
          data: {'label': label, 'score': score},
        );
      }

      // OrderClauseParser uses `+field` / `-field` prefixes for direction.
      final asc = await docs.list(
        collectionName: 'ranked',
        orderBy: '+score',
      );
      expect(
        asc.documents.map((d) => d.data['label']).toList(),
        ['a', 'b', 'c'],
      );

      final desc = await docs.list(
        collectionName: 'ranked',
        orderBy: '-score',
      );
      expect(
        desc.documents.map((d) => d.data['label']).toList(),
        ['c', 'b', 'a'],
      );
    });
  });

  // -------------- Rules engine document lookup (#9) --------------
  group('rules engine (postgres)', () {
    test('existsDocument lookup goes through adaptPlaceholders', () async {
      final collections = CollectionsService(ctx);
      final docs = DocumentsService(ctx);

      await collections.createBase(
        name: 'posts_rules',
        attributes: [TextAttribute(name: 'title', nullable: false)],
      );
      final existing = await docs.create(
        collectionName: 'posts_rules',
        data: {'title': 'hello'},
      );

      final request = Request(
        'GET',
        Uri.parse('http://localhost/v1/test'),
        context: {'database': db, 'userId': 'u1', 'userType': 'admin'},
      );
      final engine = RulesEngine(request: request);

      // Rule references exists(collection, id) — drives the
      // `SELECT * from "posts_rules" WHERE id = ?` path that we adapted for
      // postgres.
      final existsTrue = await engine.evaluate(
        'exists("posts_rules", "${existing.id}")',
      );
      expect(existsTrue, isTrue);

      final existsFalse = await engine.evaluate(
        'exists("posts_rules", "nope-nope-nope")',
      );
      expect(existsFalse, isFalse);
    });
  });
}
