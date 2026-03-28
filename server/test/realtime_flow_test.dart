import 'dart:async';
import 'dart:io';
import 'package:vanestack_client/vanestack_client.dart';
import 'package:drift/drift.dart';
import 'package:test/test.dart';
import 'package:vanestack/src/database/database.dart';
import 'package:vanestack/src/realtime/realtime.dart';
import 'package:vanestack/src/server.dart';
import 'package:vanestack/src/utils/extensions.dart';
import 'package:vanestack/src/utils/auth.dart';
import 'package:vanestack/src/utils/env.dart';
import 'package:drift/native.dart';

import 'mock_server.dart';
import 'test_utils.dart';

void main() {
  driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;

  late Environment env;
  late AppDatabase database;
  late JsonHttpClient client;
  late VaneStackServer server;
  late VaneStackClient vaneStackClient;

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

    final user = User(
      id: 'test_user',
      email: 'test@test.com',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    client = JsonHttpClient(
      '127.0.0.1',
      port,
      defaultHeaders: {HttpHeaders.authorizationHeader: 'Bearer $jwt'},
    );

    vaneStackClient = VaneStackClient(
      baseUrl: 'http://127.0.0.1:$port',
      authStorage: MemoryAuthStorage()
        ..save('vanestack_access_token', jwt)
        ..save('vanestack_user', user.toJsonString()),
    );

    await vaneStackClient.initialize();
  });

  tearDown(() async {
    client.close();
    database.close();
    await server.stop();
  });

  /// Helper to create the books table and collection with given rules.
  Future<void> createBooksCollection({
    Value<String?> listRule = const Value.absent(),
    Value<String?> viewRule = const Value.absent(),
    Value<String?> createRule = const Value.absent(),
  }) async {
    await database.customStatement('''
      CREATE TABLE IF NOT EXISTS books (
        id TEXT PRIMARY KEY default (random_uuid_v7()),
        title TEXT,
        author TEXT,
        created_at INTEGER DEFAULT (unixepoch()),
        updated_at INTEGER DEFAULT (unixepoch())
      )
    ''');

    await database.collections.insertOne(
      CollectionsCompanion.insert(
        name: 'books',
        attributes: Value([
          TextAttribute(name: 'id', primaryKey: true, nullable: false),
          TextAttribute(name: 'title'),
          TextAttribute(name: 'author'),
          DateAttribute(name: 'created_at', nullable: false),
          DateAttribute(name: 'updated_at', nullable: false),
        ]),
        listRule: listRule,
        viewRule: viewRule,
        createRule: createRule,
      ),
    );
  }

  /// Creates a VaneStackClient authenticated as a regular (non-superuser) user.
  VaneStackClient createRegularUserClient(int port, String jwtSecret) {
    final jwt = AuthUtils.generateJwt(
      userId: 'regular_user',
      jwtSecret: jwtSecret,
      superuser: false,
    );

    final user = User(
      id: 'regular_user',
      email: 'regular@test.com',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    final regularClient = VaneStackClient(
      baseUrl: 'http://127.0.0.1:$port',
      authStorage: MemoryAuthStorage()
        ..save('vanestack_access_token', jwt)
        ..save('vanestack_user', user.toJsonString()),
    );

    return regularClient;
  }

  group('Realtime: superuser', () {
    test('receives event when a document is created', () async {
      await createBooksCollection();

      final channel = Channel.collection(
        'books',
        type: DocumentEventType.create,
      );

      final (stream, unsubscribe) = await vaneStackClient.realtime.subscribe(
        channel: channel,
      );

      final completer = Completer<RealtimeEvent>();
      final sub = stream.listen((event) {
        completer.complete(event);
      });

      final payload = {
        'data': {'title': '1984', 'author': 'George Orwell'},
      };
      final res = await client.post('/v1/documents/books', body: payload);
      expect(res.status, 200);

      final evt = await completer.future.timeout(
        const Duration(seconds: 3),
        onTimeout: () => throw Exception('No realtime event received'),
      );

      expect(evt.channels, contains('books.*.created'));
      expect(evt, isA<DocumentCreatedEvent>());
      final documentEvent = evt as DocumentCreatedEvent;
      expect(documentEvent.document.data['title'], equals('1984'));
      expect(documentEvent.document.data['author'], equals('George Orwell'));

      await sub.cancel();
      unsubscribe();
    });
  });

  group('Realtime: regular user', () {
    test('receives event on public collection (empty listRule)', () async {
      await createBooksCollection(listRule: const Value(''));

      final regularClient = createRegularUserClient(env.port, env.jwtSecret);
      await regularClient.initialize();

      final channel = Channel.collection(
        'books',
        type: DocumentEventType.create,
      );

      final (stream, unsubscribe) = await regularClient.realtime.subscribe(
        channel: channel,
      );

      final completer = Completer<RealtimeEvent>();
      final sub = stream.listen((event) {
        completer.complete(event);
      });

      final payload = {
        'data': {'title': 'Brave New World', 'author': 'Aldous Huxley'},
      };
      final res = await client.post('/v1/documents/books', body: payload);
      expect(res.status, 200);

      final evt = await completer.future.timeout(
        const Duration(seconds: 3),
        onTimeout: () => throw Exception('No realtime event received'),
      );

      expect(evt, isA<DocumentCreatedEvent>());
      final documentEvent = evt as DocumentCreatedEvent;
      expect(documentEvent.document.data['title'], equals('Brave New World'));

      await sub.cancel();
      unsubscribe();
    });

    test(
      'does NOT receive event on superuser-only collection (null listRule)',
      () async {
        // listRule defaults to null (superuser-only)
        await createBooksCollection();

        final regularClient = createRegularUserClient(env.port, env.jwtSecret);
        await regularClient.initialize();

        final channel = Channel.collection(
          'books',
          type: DocumentEventType.create,
        );

        final (stream, unsubscribe) = await regularClient.realtime.subscribe(
          channel: channel,
        );

        bool eventReceived = false;
        final sub = stream.listen((event) {
          eventReceived = true;
        });

        final payload = {
          'data': {'title': 'Forbidden Book', 'author': 'Secret Author'},
        };
        final res = await client.post('/v1/documents/books', body: payload);
        expect(res.status, 200);

        // Give enough time for the event to arrive (it shouldn't)
        await Future.delayed(const Duration(seconds: 1));
        expect(eventReceived, isFalse);

        await sub.cancel();
        unsubscribe();
      },
    );

    test('receives event when rule matches authenticated user', () async {
      await createBooksCollection(
        listRule: const Value('request.auth.uid != null'),
      );

      final regularClient = createRegularUserClient(env.port, env.jwtSecret);
      await regularClient.initialize();

      final channel = Channel.collection(
        'books',
        type: DocumentEventType.create,
      );

      final (stream, unsubscribe) = await regularClient.realtime.subscribe(
        channel: channel,
      );

      final completer = Completer<RealtimeEvent>();
      final sub = stream.listen((event) {
        completer.complete(event);
      });

      final payload = {
        'data': {'title': 'Allowed Book', 'author': 'Known Author'},
      };
      final res = await client.post('/v1/documents/books', body: payload);
      expect(res.status, 200);

      final evt = await completer.future.timeout(
        const Duration(seconds: 3),
        onTimeout: () => throw Exception('No realtime event received'),
      );

      expect(evt, isA<DocumentCreatedEvent>());

      await sub.cancel();
      unsubscribe();
    });
  });

  group('Realtime: update and delete events', () {
    test('receives update event with old and new document', () async {
      await createBooksCollection(listRule: const Value(''));

      // Create a document first
      final createRes = await client.post(
        '/v1/documents/books',
        body: {
          'data': {'title': 'Draft', 'author': 'Author'},
        },
      );
      expect(createRes.status, 200);
      final docId = createRes.json!['id'] as String;

      // Subscribe to update events
      final channel = Channel.collection(
        'books',
        type: DocumentEventType.update,
      );

      final (stream, unsubscribe) = await vaneStackClient.realtime.subscribe(
        channel: channel,
      );

      final completer = Completer<RealtimeEvent>();
      final sub = stream.listen((event) {
        completer.complete(event);
      });

      // Update the document
      final updateRes = await client.patch(
        '/v1/documents/books/$docId',
        body: {
          'data': {'title': 'Final'},
        },
      );
      expect(updateRes.status, 200);

      final evt = await completer.future.timeout(
        const Duration(seconds: 3),
        onTimeout: () => throw Exception('No realtime event received'),
      );

      expect(evt, isA<DocumentUpdatedEvent>());
      expect(evt.channels, contains('books.*.updated'));
      final updateEvent = evt as DocumentUpdatedEvent;
      expect(updateEvent.newDocument.data['title'], equals('Final'));
      expect(updateEvent.oldDocument?.data['title'], equals('Draft'));

      await sub.cancel();
      unsubscribe();
    });

    test('receives delete event', () async {
      await createBooksCollection(listRule: const Value(''));

      // Create a document first
      final createRes = await client.post(
        '/v1/documents/books',
        body: {
          'data': {'title': 'To Delete', 'author': 'Author'},
        },
      );
      expect(createRes.status, 200);
      final docId = createRes.json!['id'] as String;

      // Subscribe to delete events
      final channel = Channel.collection(
        'books',
        type: DocumentEventType.delete,
      );

      final (stream, unsubscribe) = await vaneStackClient.realtime.subscribe(
        channel: channel,
      );

      final completer = Completer<RealtimeEvent>();
      final sub = stream.listen((event) {
        completer.complete(event);
      });

      // Delete the document
      final deleteRes = await client.del('/v1/documents/books/$docId');
      expect(deleteRes.status, 200);

      final evt = await completer.future.timeout(
        const Duration(seconds: 3),
        onTimeout: () => throw Exception('No realtime event received'),
      );

      expect(evt, isA<DocumentDeletedEvent>());
      expect(evt.channels, contains('books.*.deleted'));
      final deleteEvent = evt as DocumentDeletedEvent;
      expect(deleteEvent.document.id, equals(docId));

      await sub.cancel();
      unsubscribe();
    });
  });

  group('Realtime: custom event rules', () {
    test('receives custom event when rule is null (no restriction)', () async {
      final regularClient = createRegularUserClient(env.port, env.jwtSecret);
      await regularClient.initialize();

      final channel = Channel.custom('notifications');

      final (stream, unsubscribe) = await regularClient.realtime.subscribe(
        channel: channel,
      );

      final completer = Completer<RealtimeEvent>();
      final sub = stream.listen((event) {
        completer.complete(event);
      });

      server.realtime.emit(
        Transport(
          event: CustomRealtimeEvent(
            channels: ['notifications'],
            data: {'message': 'hello'},
          ),
        ),
      );

      final evt = await completer.future.timeout(
        const Duration(seconds: 3),
        onTimeout: () => throw Exception('No realtime event received'),
      );

      expect(evt, isA<CustomRealtimeEvent>());
      expect((evt as CustomRealtimeEvent).data['message'], equals('hello'));

      await sub.cancel();
      unsubscribe();
    });

    test('receives custom event when rule is empty string (public)', () async {
      final regularClient = createRegularUserClient(env.port, env.jwtSecret);
      await regularClient.initialize();

      final channel = Channel.custom('announcements');

      final (stream, unsubscribe) = await regularClient.realtime.subscribe(
        channel: channel,
      );

      final completer = Completer<RealtimeEvent>();
      final sub = stream.listen((event) {
        completer.complete(event);
      });

      server.realtime.emit(
        Transport(
          event: CustomRealtimeEvent(
            channels: ['announcements'],
            data: {'info': 'public'},
            rule: '',
          ),
        ),
      );

      final evt = await completer.future.timeout(
        const Duration(seconds: 3),
        onTimeout: () => throw Exception('No realtime event received'),
      );

      expect(evt, isA<CustomRealtimeEvent>());

      await sub.cancel();
      unsubscribe();
    });

    test(
      'receives custom event when rule matches authenticated user',
      () async {
        final regularClient = createRegularUserClient(env.port, env.jwtSecret);
        await regularClient.initialize();

        final channel = Channel.custom('private');

        final (stream, unsubscribe) = await regularClient.realtime.subscribe(
          channel: channel,
        );

        final completer = Completer<RealtimeEvent>();
        final sub = stream.listen((event) {
          completer.complete(event);
        });

        server.realtime.emit(
          Transport(
            event: CustomRealtimeEvent(
              channels: ['private'],
              data: {'secret': 'data'},
              rule: 'request.auth.uid != null',
            ),
          ),
        );

        final evt = await completer.future.timeout(
          const Duration(seconds: 3),
          onTimeout: () => throw Exception('No realtime event received'),
        );

        expect(evt, isA<CustomRealtimeEvent>());
        expect((evt as CustomRealtimeEvent).data['secret'], equals('data'));

        await sub.cancel();
        unsubscribe();
      },
    );

    test('does NOT receive custom event when rule rejects user', () async {
      final regularClient = createRegularUserClient(env.port, env.jwtSecret);
      await regularClient.initialize();

      final channel = Channel.custom('restricted');

      final (stream, unsubscribe) = await regularClient.realtime.subscribe(
        channel: channel,
      );

      bool eventReceived = false;
      final sub = stream.listen((event) {
        eventReceived = true;
      });

      // Rule requires a specific user that doesn't match the regular user
      server.realtime.emit(
        Transport(
          event: CustomRealtimeEvent(
            channels: ['restricted'],
            data: {'secret': 'value'},
            rule: 'request.auth.uid == "someone_else"',
          ),
        ),
      );

      await Future.delayed(const Duration(seconds: 1));
      expect(eventReceived, isFalse);

      await sub.cancel();
      unsubscribe();
    });

    test('superuser always receives custom event regardless of rule', () async {
      final channel = Channel.custom('admin-only');

      final (stream, unsubscribe) = await vaneStackClient.realtime.subscribe(
        channel: channel,
      );

      final completer = Completer<RealtimeEvent>();
      final sub = stream.listen((event) {
        completer.complete(event);
      });

      server.realtime.emit(
        Transport(
          event: CustomRealtimeEvent(
            channels: ['admin-only'],
            data: {'admin': true},
            rule: 'request.auth.uid == "specific_user"',
          ),
        ),
      );

      final evt = await completer.future.timeout(
        const Duration(seconds: 3),
        onTimeout: () => throw Exception('No realtime event received'),
      );

      expect(evt, isA<CustomRealtimeEvent>());

      await sub.cancel();
      unsubscribe();
    });
  });

  group('Realtime: file events', () {
    final testBucket = Bucket(
      name: 'avatars',
      listRule: '',
      viewRule: '',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    final testDbFile = DbFile(
      id: 'file-123',
      path: 'photos/avatar.png',
      bucket: 'avatars',
      size: 1024,
      mimeType: 'image/png',
      downloadToken: 'token-abc',
      metadata: {},
      isLocal: true,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    test('receives file_uploaded event', () async {
      final channel = Channel.custom('avatars.*');

      final (stream, unsubscribe) = await vaneStackClient.realtime.subscribe(
        channel: channel,
      );

      final completer = Completer<RealtimeEvent>();
      final sub = stream.listen((event) {
        completer.complete(event);
      });

      server.realtime.emit(
        FileTransport(
          bucket: testBucket,
          file: testDbFile,
          event: FileUploadedEvent(
            channels: ['avatars.*', 'avatars.*.uploaded', 'avatars.file-123'],
            file: testDbFile.toPublic(),
          ),
        ),
      );

      final evt = await completer.future.timeout(
        const Duration(seconds: 3),
        onTimeout: () => throw Exception('No realtime event received'),
      );

      expect(evt, isA<FileUploadedEvent>());
      final uploadEvent = evt as FileUploadedEvent;
      expect(uploadEvent.file.id, equals('file-123'));
      expect(uploadEvent.file.path, equals('photos/avatar.png'));
      expect(uploadEvent.file.bucket, equals('avatars'));

      await sub.cancel();
      unsubscribe();
    });

    test('receives file_moved event with old path', () async {
      final channel = Channel.custom('avatars.*');

      final (stream, unsubscribe) = await vaneStackClient.realtime.subscribe(
        channel: channel,
      );

      final completer = Completer<RealtimeEvent>();
      final sub = stream.listen((event) {
        completer.complete(event);
      });

      final movedFile = testDbFile.copyWith(path: 'photos/new-avatar.png');

      server.realtime.emit(
        FileTransport(
          bucket: testBucket,
          file: movedFile,
          event: FileMovedEvent(
            channels: ['avatars.*', 'avatars.*.moved', 'avatars.file-123'],
            file: movedFile.toPublic(),
            oldPath: 'photos/avatar.png',
          ),
        ),
      );

      final evt = await completer.future.timeout(
        const Duration(seconds: 3),
        onTimeout: () => throw Exception('No realtime event received'),
      );

      expect(evt, isA<FileMovedEvent>());
      final moveEvent = evt as FileMovedEvent;
      expect(moveEvent.file.path, equals('photos/new-avatar.png'));
      expect(moveEvent.oldPath, equals('photos/avatar.png'));

      await sub.cancel();
      unsubscribe();
    });

    test('receives file_deleted event', () async {
      final channel = Channel.custom('avatars.*');

      final (stream, unsubscribe) = await vaneStackClient.realtime.subscribe(
        channel: channel,
      );

      final completer = Completer<RealtimeEvent>();
      final sub = stream.listen((event) {
        completer.complete(event);
      });

      server.realtime.emit(
        FileTransport(
          bucket: testBucket,
          file: testDbFile,
          event: FileDeletedEvent(
            channels: ['avatars.*', 'avatars.*.deleted', 'avatars.file-123'],
            file: testDbFile.toPublic(),
          ),
        ),
      );

      final evt = await completer.future.timeout(
        const Duration(seconds: 3),
        onTimeout: () => throw Exception('No realtime event received'),
      );

      expect(evt, isA<FileDeletedEvent>());
      final deleteEvent = evt as FileDeletedEvent;
      expect(deleteEvent.file.id, equals('file-123'));

      await sub.cancel();
      unsubscribe();
    });

    test(
      'does NOT receive file event on superuser-only bucket (null rule)',
      () async {
        final privateBucket = Bucket(
          name: 'private',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        final regularClient = createRegularUserClient(env.port, env.jwtSecret);
        await regularClient.initialize();

        final channel = Channel.custom('private.*');

        final (stream, unsubscribe) = await regularClient.realtime.subscribe(
          channel: channel,
        );

        bool eventReceived = false;
        final sub = stream.listen((event) {
          eventReceived = true;
        });

        server.realtime.emit(
          FileTransport(
            bucket: privateBucket,
            file: testDbFile,
            event: FileUploadedEvent(
              channels: ['private.*'],
              file: testDbFile.toPublic(),
            ),
          ),
        );

        await Future.delayed(const Duration(seconds: 1));
        expect(eventReceived, isFalse);

        await sub.cancel();
        unsubscribe();
      },
    );

    test('receives file event on public bucket (empty rule)', () async {
      final regularClient = createRegularUserClient(env.port, env.jwtSecret);
      await regularClient.initialize();

      final channel = Channel.custom('avatars.*');

      final (stream, unsubscribe) = await regularClient.realtime.subscribe(
        channel: channel,
      );

      final completer = Completer<RealtimeEvent>();
      final sub = stream.listen((event) {
        completer.complete(event);
      });

      server.realtime.emit(
        FileTransport(
          bucket: testBucket,
          file: testDbFile,
          event: FileUploadedEvent(
            channels: ['avatars.*'],
            file: testDbFile.toPublic(),
          ),
        ),
      );

      final evt = await completer.future.timeout(
        const Duration(seconds: 3),
        onTimeout: () => throw Exception('No realtime event received'),
      );

      expect(evt, isA<FileUploadedEvent>());

      await sub.cancel();
      unsubscribe();
    });

    test('does NOT receive file event when rule rejects user', () async {
      final restrictedBucket = Bucket(
        name: 'restricted',
        listRule: 'request.auth.uid == "someone_else"',
        viewRule: 'request.auth.uid == "someone_else"',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final regularClient = createRegularUserClient(env.port, env.jwtSecret);
      await regularClient.initialize();

      final channel = Channel.custom('restricted.*');

      final (stream, unsubscribe) = await regularClient.realtime.subscribe(
        channel: channel,
      );

      bool eventReceived = false;
      final sub = stream.listen((event) {
        eventReceived = true;
      });

      server.realtime.emit(
        FileTransport(
          bucket: restrictedBucket,
          file: testDbFile,
          event: FileUploadedEvent(
            channels: ['restricted.*'],
            file: testDbFile.toPublic(),
          ),
        ),
      );

      await Future.delayed(const Duration(seconds: 1));
      expect(eventReceived, isFalse);

      await sub.cancel();
      unsubscribe();
    });

    test('superuser receives file event regardless of rule', () async {
      final restrictedBucket = Bucket(
        name: 'restricted',
        listRule: 'request.auth.uid == "someone_else"',
        viewRule: 'request.auth.uid == "someone_else"',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final channel = Channel.custom('restricted.*');

      final (stream, unsubscribe) = await vaneStackClient.realtime.subscribe(
        channel: channel,
      );

      final completer = Completer<RealtimeEvent>();
      final sub = stream.listen((event) {
        completer.complete(event);
      });

      server.realtime.emit(
        FileTransport(
          bucket: restrictedBucket,
          file: testDbFile,
          event: FileUploadedEvent(
            channels: ['restricted.*'],
            file: testDbFile.toPublic(),
          ),
        ),
      );

      final evt = await completer.future.timeout(
        const Duration(seconds: 3),
        onTimeout: () => throw Exception('No realtime event received'),
      );

      expect(evt, isA<FileUploadedEvent>());

      await sub.cancel();
      unsubscribe();
    });
  });

  group('Realtime: SSE handler', () {
    test('returns 404 without Accept: text/event-stream header', () async {
      final res = await client.get(
        '/v1/realtime',
        query: {'channels': 'books.*'},
      );
      expect(res.status, 404);
    });

    test('cleans up listeners on client disconnect', () async {
      await createBooksCollection(listRule: const Value(''));

      final channel = Channel.collection('books');

      final (stream, unsubscribe) = await vaneStackClient.realtime.subscribe(
        channel: channel,
      );

      final sub = stream.listen((_) {});

      // Disconnect
      await sub.cancel();
      unsubscribe();

      // Give cleanup time to propagate
      await Future.delayed(const Duration(milliseconds: 200));

      // Create a document — no listeners should fire (no errors, no hanging)
      final res = await client.post(
        '/v1/documents/books',
        body: {
          'data': {'title': 'After Disconnect', 'author': 'Nobody'},
        },
      );
      expect(res.status, 200);
    });
  });

  group('Realtime: file events (end-to-end)', () {
    late Environment storageEnv;
    late AppDatabase storageDb;
    late JsonHttpClient storageClient;
    late VaneStackServer storageServer;
    late VaneStackClient storageVaneStackClient;
    late Directory tempStorageDir;

    setUp(() async {
      final port = await findFreePort();
      tempStorageDir = await Directory.systemTemp.createTemp('vanestack_rt_');

      storageEnv = Environment(
        port: port,
        localStorageEnabled: true,
        localStoragePath: tempStorageDir.path,
      );
      storageDb = AppDatabase(NativeDatabase.memory(setup: AppDatabase.setup));
      storageServer = MockServer(db: storageDb, env: storageEnv);
      await storageServer.start();

      final jwt = AuthUtils.generateJwt(
        userId: 'test_user',
        jwtSecret: storageEnv.jwtSecret,
        superuser: true,
      );

      final user = User(
        id: 'test_user',
        email: 'test@test.com',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      storageClient = JsonHttpClient(
        '127.0.0.1',
        port,
        defaultHeaders: {HttpHeaders.authorizationHeader: 'Bearer $jwt'},
      );

      storageVaneStackClient = VaneStackClient(
        baseUrl: 'http://127.0.0.1:$port',
        authStorage: MemoryAuthStorage()
          ..save('vanestack_access_token', jwt)
          ..save('vanestack_user', user.toJsonString()),
      );

      await storageVaneStackClient.initialize();

      // Create a test bucket with public rules
      await storageClient.post(
        '/v1/buckets/uploads',
        body: {
          'listRule': '',
          'viewRule': '',
          'createRule': '',
          'deleteRule': '',
          'updateRule': '',
        },
      );
    });

    tearDown(() async {
      storageClient.close();
      storageDb.close();
      await storageServer.stop();
      if (await tempStorageDir.exists()) {
        await tempStorageDir.delete(recursive: true);
      }
    });

    test('receives file_uploaded event when uploading via HTTP', () async {
      final channel = Channel.custom('uploads.*');

      final (stream, unsubscribe) = await storageVaneStackClient.realtime
          .subscribe(channel: channel);

      final completer = Completer<RealtimeEvent>();
      final sub = stream.listen((event) {
        completer.complete(event);
      });

      final res = await storageClient.uploadFile(
        '/v1/files/uploads/upload',
        filePath: 'docs',
        fileName: 'readme.txt',
        fileContent: [72, 101, 108, 108, 111], // "Hello"
        mimeType: 'text/plain',
      );
      expect(res.status, 200);

      final evt = await completer.future.timeout(
        const Duration(seconds: 3),
        onTimeout: () => throw Exception('No realtime event received'),
      );

      expect(evt, isA<FileUploadedEvent>());
      final uploadEvent = evt as FileUploadedEvent;
      expect(uploadEvent.file.bucket, equals('uploads'));
      expect(uploadEvent.file.path, equals('docs/readme.txt'));

      await sub.cancel();
      unsubscribe();
    });

    test('receives file_moved event when moving via HTTP', () async {
      // Upload a file first
      final uploadRes = await storageClient.uploadFile(
        '/v1/files/uploads/upload',
        filePath: 'original',
        fileName: 'file.txt',
        fileContent: [72, 101, 108, 108, 111],
        mimeType: 'text/plain',
      );
      expect(uploadRes.status, 200);
      final fileId = uploadRes.json!['id'] as String;

      // Subscribe to move events
      final channel = Channel.custom('uploads.*');

      final (stream, unsubscribe) = await storageVaneStackClient.realtime
          .subscribe(channel: channel);

      final completer = Completer<RealtimeEvent>();
      final sub = stream.listen((event) {
        if (event is FileMovedEvent) completer.complete(event);
      });

      // Move the file (keep in same directory to avoid mkdir issues)
      final moveRes = await storageClient.patch(
        '/v1/files/uploads/$fileId',
        body: {'destination': 'original/renamed.txt'},
      );
      expect(moveRes.status, 200);

      final evt = await completer.future.timeout(
        const Duration(seconds: 3),
        onTimeout: () => throw Exception('No realtime event received'),
      );

      expect(evt, isA<FileMovedEvent>());
      final moveEvent = evt as FileMovedEvent;
      expect(moveEvent.file.path, equals('original/renamed.txt'));
      expect(moveEvent.oldPath, equals('original/file.txt'));

      await sub.cancel();
      unsubscribe();
    });

    test('receives file_deleted event when deleting via HTTP', () async {
      // Upload a file first
      final uploadRes = await storageClient.uploadFile(
        '/v1/files/uploads/upload',
        filePath: 'temp',
        fileName: 'delete_me.txt',
        fileContent: [72, 101, 108, 108, 111],
        mimeType: 'text/plain',
      );
      expect(uploadRes.status, 200);

      // Subscribe to delete events
      final channel = Channel.custom('uploads.*');

      final (stream, unsubscribe) = await storageVaneStackClient.realtime
          .subscribe(channel: channel);

      final completer = Completer<RealtimeEvent>();
      final sub = stream.listen((event) {
        if (event is FileDeletedEvent) completer.complete(event);
      });

      // Delete the file
      final deleteRes = await storageClient.del(
        '/v1/files/uploads',
        query: {'path': 'temp/delete_me.txt'},
      );
      expect(deleteRes.status, 200);

      final evt = await completer.future.timeout(
        const Duration(seconds: 3),
        onTimeout: () => throw Exception('No realtime event received'),
      );

      expect(evt, isA<FileDeletedEvent>());
      final deleteEvent = evt as FileDeletedEvent;
      expect(deleteEvent.file.path, equals('temp/delete_me.txt'));
      expect(deleteEvent.file.bucket, equals('uploads'));

      await sub.cancel();
      unsubscribe();
    });
  });
}
