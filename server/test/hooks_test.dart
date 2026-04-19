import 'package:vanestack/src/database/database.dart';
import 'package:vanestack/src/services/auth_service.dart';
import 'package:vanestack/src/services/collections_service.dart';
import 'package:vanestack/src/services/context.dart';
import 'package:vanestack/src/services/documents_service.dart';
import 'package:vanestack/src/services/hook_runner.dart';
import 'package:vanestack/src/services/hooks.dart';
import 'package:vanestack/src/services/users_service.dart';
import 'package:vanestack/src/utils/env.dart';
import 'package:vanestack_common/vanestack_common.dart';
import 'package:drift/drift.dart' show driftRuntimeOptions;
import 'package:drift/native.dart';
import 'package:test/test.dart';

import 'test_utils.dart';

void main() {
  driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;
  silenceTestLogs();

  late AppDatabase database;
  late Environment env;
  late HookExecutor executor;
  late HookRegistry registry;
  late ServiceContext context;

  setUp(() async {
    env = Environment(port: 0);
    database = AppDatabase(NativeDatabase.memory(setup: AppDatabase.setup));
    executor = HookExecutor();
    context = (database: database, env: env, realtime: null, hooks: executor, collectionsCache: null);
    registry = HookRegistry(executor);
  });

  tearDown(() async {
    await database.close();
  });

  // ==================== Document Hooks ====================

  group('Document Hooks', () {
    late CollectionsService collectionsService;
    late DocumentsService documentsService;

    setUp(() async {
      collectionsService = CollectionsService(context);
      documentsService = DocumentsService(context);

      // Create a test collection
      await collectionsService.createBase(
        name: 'posts',
        attributes: [
          TextAttribute(name: 'title', nullable: false),
          TextAttribute(name: 'body', nullable: true),
        ],
      );
    });

    test('before create fires and can modify data', () async {
      registry.onBeforeDocumentCreate((e) {
        e.data['title'] = 'Modified Title';
        return true;
      });

      final doc = await documentsService.create(
        collectionName: 'posts',
        data: {'title': 'Original Title'},
        emitEvent: false,
      );

      expect(doc.data['title'], 'Modified Title');
    });

    test('after create fires with result', () async {
      Document? captured;
      registry.onAfterDocumentCreate((e) {
        captured = e.result;
      });

      final doc = await documentsService.create(
        collectionName: 'posts',
        data: {'title': 'Test'},
        emitEvent: false,
      );

      expect(captured, isNotNull);
      expect(captured!.id, doc.id);
      expect(captured!.data['title'], 'Test');
    });

    test('before update fires and can modify data', () async {
      final doc = await documentsService.create(
        collectionName: 'posts',
        data: {'title': 'Original'},
        emitEvent: false,
      );

      registry.onBeforeDocumentUpdate((e) {
        e.data['title'] = 'Hook Modified';
        return true;
      });

      final updated = await documentsService.update(
        collectionName: 'posts',
        documentId: doc.id,
        data: {'title': 'User Update'},
        emitEvent: false,
      );

      expect(updated.data['title'], 'Hook Modified');
    });

    test('after update fires with result', () async {
      final doc = await documentsService.create(
        collectionName: 'posts',
        data: {'title': 'Original'},
        emitEvent: false,
      );

      Document? captured;
      registry.onAfterDocumentUpdate((e) {
        captured = e.result;
      });

      await documentsService.update(
        collectionName: 'posts',
        documentId: doc.id,
        data: {'title': 'Updated'},
        emitEvent: false,
      );

      expect(captured, isNotNull);
      expect(captured!.data['title'], 'Updated');
    });

    test('before delete fires with correct fields', () async {
      final doc = await documentsService.create(
        collectionName: 'posts',
        data: {'title': 'To Delete'},
        emitEvent: false,
      );

      String? capturedCollection;
      String? capturedId;
      registry.onBeforeDocumentDelete((e) {
        capturedCollection = e.collectionName;
        capturedId = e.documentId;
        return true;
      });

      await documentsService.delete(
        collectionName: 'posts',
        documentId: doc.id,
        emitEvent: false,
      );

      expect(capturedCollection, 'posts');
      expect(capturedId, doc.id);
    });

    test('after delete fires with correct id', () async {
      final doc = await documentsService.create(
        collectionName: 'posts',
        data: {'title': 'To Delete'},
        emitEvent: false,
      );

      String? capturedId;
      registry.onAfterDocumentDelete((e) {
        capturedId = e.documentId;
      });

      await documentsService.delete(
        collectionName: 'posts',
        documentId: doc.id,
        emitEvent: false,
      );

      expect(capturedId, doc.id);
    });

    test('before create can cancel by returning false', () async {
      registry.onBeforeDocumentCreate((e) {
        return false;
      });

      expect(
        () => documentsService.create(
          collectionName: 'posts',
          data: {'title': 'Should Not Exist'},
          emitEvent: false,
        ),
        throwsA(isA<HookCancelledException>()),
      );

      // Verify document was not created
      final result = await documentsService.list(collectionName: 'posts');
      expect(result.documents, isEmpty);
    });
  });

  // ==================== Collection Hooks ====================

  group('Collection Hooks', () {
    late CollectionsService collectionsService;

    setUp(() {
      collectionsService = CollectionsService(context);
    });

    test('before create fires', () async {
      String? capturedName;
      registry.onBeforeCollectionCreate((e) {
        capturedName = e.name;
        return true;
      });

      await collectionsService.createBase(
        name: 'items',
        attributes: [TextAttribute(name: 'label', nullable: false)],
      );

      expect(capturedName, 'items');
    });

    test('after create fires with result', () async {
      Collection? captured;
      registry.onAfterCollectionCreate((e) {
        captured = e.result;
      });

      await collectionsService.createBase(
        name: 'items',
        attributes: [TextAttribute(name: 'label', nullable: false)],
      );

      expect(captured, isNotNull);
      expect(captured!.name, 'items');
    });

    test('before delete can cancel by returning false', () async {
      await collectionsService.createBase(
        name: 'protected',
        attributes: [TextAttribute(name: 'val', nullable: false)],
      );

      registry.onBeforeCollectionDelete((e) {
        return false;
      });

      expect(
        () => collectionsService.delete('protected'),
        throwsA(isA<HookCancelledException>()),
      );

      // Verify collection still exists
      final exists = await collectionsService.exists('protected');
      expect(exists, isTrue);
    });
  });

  // ==================== User Hooks ====================

  group('User Hooks', () {
    late UsersService usersService;

    setUp(() {
      usersService = UsersService(context);
    });

    test('before create fires and can modify data', () async {
      registry.onBeforeUserCreate((e) {
        e.name = 'Hook Name';
        return true;
      });

      final user = await usersService.create(
        email: 'test@example.com',
        name: 'Original',
      );

      expect(user.name, 'Hook Name');
    });

    test('after create fires with result', () async {
      User? captured;
      registry.onAfterUserCreate((e) {
        captured = e.result;
      });

      final user = await usersService.create(email: 'test@example.com');

      expect(captured, isNotNull);
      expect(captured!.id, user.id);
      expect(captured!.email, 'test@example.com');
    });

    test('before delete can cancel by returning false', () async {
      final user = await usersService.create(email: 'nodelete@example.com');

      registry.onBeforeUserDelete((e) {
        return false;
      });

      expect(
        () => usersService.delete(user.id),
        throwsA(isA<HookCancelledException>()),
      );

      // Verify user still exists
      final found = await usersService.getById(user.id);
      expect(found, isNotNull);
    });
  });

  // ==================== Auth Hooks ====================

  group('Auth Hooks', () {
    late AuthService authService;

    setUp(() {
      authService = AuthService(context);
    });

    test('before sign-in fires with correct email', () async {
      String? capturedEmail;
      registry.onBeforeAuthSignIn((e) {
        capturedEmail = e.email;
        return true;
      });

      await authService.signInWithEmailAndPassword(
        email: 'auth@example.com',
        password: 'Str0ng_P4ss!',
      );

      expect(capturedEmail, 'auth@example.com');
    });

    test('after sign-in fires with AuthResponse result', () async {
      AuthResponse? captured;
      registry.onAfterAuthSignIn((e) {
        captured = e.result;
      });

      final result = await authService.signInWithEmailAndPassword(
        email: 'auth@example.com',
        password: 'Str0ng_P4ss!',
      );

      expect(captured, isNotNull);
      expect(captured!.user.email, 'auth@example.com');
      expect(captured!.accessToken, result.accessToken);
    });
  });

  // ==================== Execution Order ====================

  group('Execution Order', () {
    test('multiple callbacks fire in registration order', () async {
      final order = <int>[];

      registry.onBeforeDocumentCreate((e) {
        order.add(1);
        return true;
      });
      registry.onBeforeDocumentCreate((e) {
        order.add(2);
        return true;
      });
      registry.onBeforeDocumentCreate((e) {
        order.add(3);
        return true;
      });

      final collectionsService = CollectionsService(context);
      await collectionsService.createBase(
        name: 'ordered',
        attributes: [TextAttribute(name: 'val', nullable: false)],
      );

      final documentsService = DocumentsService(context);
      await documentsService.create(
        collectionName: 'ordered',
        data: {'val': 'test'},
        emitEvent: false,
      );

      expect(order, [1, 2, 3]);
    });
  });
}
