import 'dart:async';

import '../utils/logger.dart';
import 'hooks.dart';

/// Internal class that stores callbacks and executes hooks.
///
/// This file is NOT exported from the public API.
/// Services import it directly to call `run*` methods.
class HookExecutor {
  final Map<String, FutureOr<bool> Function(BeforeDocumentCreateEvent)>
      beforeDocumentCreate = {};
  final Map<String, FutureOr<void> Function(AfterDocumentCreateEvent)>
      afterDocumentCreate = {};
  final Map<String, FutureOr<bool> Function(BeforeDocumentUpdateEvent)>
      beforeDocumentUpdate = {};
  final Map<String, FutureOr<void> Function(AfterDocumentUpdateEvent)>
      afterDocumentUpdate = {};
  final Map<String, FutureOr<bool> Function(BeforeDocumentDeleteEvent)>
      beforeDocumentDelete = {};
  final Map<String, FutureOr<void> Function(AfterDocumentDeleteEvent)>
      afterDocumentDelete = {};
  final Map<String, FutureOr<bool> Function(BeforeCollectionCreateEvent)>
      beforeCollectionCreate = {};
  final Map<String, FutureOr<void> Function(AfterCollectionCreateEvent)>
      afterCollectionCreate = {};
  final Map<String, FutureOr<bool> Function(BeforeCollectionUpdateEvent)>
      beforeCollectionUpdate = {};
  final Map<String, FutureOr<void> Function(AfterCollectionUpdateEvent)>
      afterCollectionUpdate = {};
  final Map<String, FutureOr<bool> Function(BeforeCollectionDeleteEvent)>
      beforeCollectionDelete = {};
  final Map<String, FutureOr<void> Function(AfterCollectionDeleteEvent)>
      afterCollectionDelete = {};
  final Map<String, FutureOr<bool> Function(BeforeUserCreateEvent)>
      beforeUserCreate = {};
  final Map<String, FutureOr<void> Function(AfterUserCreateEvent)>
      afterUserCreate = {};
  final Map<String, FutureOr<bool> Function(BeforeUserUpdateEvent)>
      beforeUserUpdate = {};
  final Map<String, FutureOr<void> Function(AfterUserUpdateEvent)>
      afterUserUpdate = {};
  final Map<String, FutureOr<bool> Function(BeforeUserDeleteEvent)>
      beforeUserDelete = {};
  final Map<String, FutureOr<void> Function(AfterUserDeleteEvent)>
      afterUserDelete = {};
  final Map<String, FutureOr<bool> Function(BeforeAuthSignInEvent)>
      beforeAuthSignIn = {};
  final Map<String, FutureOr<void> Function(AfterAuthSignInEvent)>
      afterAuthSignIn = {};
  final Map<String, FutureOr<bool> Function(BeforeFileUploadEvent)>
      beforeFileUpload = {};
  final Map<String, FutureOr<void> Function(AfterFileUploadEvent)>
      afterFileUpload = {};
  final Map<String, FutureOr<bool> Function(BeforeFileDeleteEvent)>
      beforeFileDelete = {};
  final Map<String, FutureOr<void> Function(AfterFileDeleteEvent)>
      afterFileDelete = {};
  final Map<String, FutureOr<void> Function(ServerStartedEvent)>
      serverStarted = {};
  final Map<String, FutureOr<void> Function(ServerStoppedEvent)>
      serverStopped = {};

  /// Removes a hook by its identifier from all registries.
  /// Returns `true` if the hook was found and removed.
  bool unregister(String id) {
    final maps = [
      beforeDocumentCreate,
      afterDocumentCreate,
      beforeDocumentUpdate,
      afterDocumentUpdate,
      beforeDocumentDelete,
      afterDocumentDelete,
      beforeCollectionCreate,
      afterCollectionCreate,
      beforeCollectionUpdate,
      afterCollectionUpdate,
      beforeCollectionDelete,
      afterCollectionDelete,
      beforeUserCreate,
      afterUserCreate,
      beforeUserUpdate,
      afterUserUpdate,
      beforeUserDelete,
      afterUserDelete,
      beforeAuthSignIn,
      afterAuthSignIn,
      beforeFileUpload,
      afterFileUpload,
      beforeFileDelete,
      afterFileDelete,
      serverStarted,
      serverStopped,
    ];
    var removed = false;
    for (final map in maps) {
      if (map.remove(id) != null) removed = true;
    }
    return removed;
  }

  // Documents
  Future<void> runBeforeDocumentCreate(BeforeDocumentCreateEvent e) =>
      _runBefore(beforeDocumentCreate, e);
  Future<void> runAfterDocumentCreate(AfterDocumentCreateEvent e) =>
      _runAfter(afterDocumentCreate, e);
  Future<void> runBeforeDocumentUpdate(BeforeDocumentUpdateEvent e) =>
      _runBefore(beforeDocumentUpdate, e);
  Future<void> runAfterDocumentUpdate(AfterDocumentUpdateEvent e) =>
      _runAfter(afterDocumentUpdate, e);
  Future<void> runBeforeDocumentDelete(BeforeDocumentDeleteEvent e) =>
      _runBefore(beforeDocumentDelete, e);
  Future<void> runAfterDocumentDelete(AfterDocumentDeleteEvent e) =>
      _runAfter(afterDocumentDelete, e);

  // Collections
  Future<void> runBeforeCollectionCreate(BeforeCollectionCreateEvent e) =>
      _runBefore(beforeCollectionCreate, e);
  Future<void> runAfterCollectionCreate(AfterCollectionCreateEvent e) =>
      _runAfter(afterCollectionCreate, e);
  Future<void> runBeforeCollectionUpdate(BeforeCollectionUpdateEvent e) =>
      _runBefore(beforeCollectionUpdate, e);
  Future<void> runAfterCollectionUpdate(AfterCollectionUpdateEvent e) =>
      _runAfter(afterCollectionUpdate, e);
  Future<void> runBeforeCollectionDelete(BeforeCollectionDeleteEvent e) =>
      _runBefore(beforeCollectionDelete, e);
  Future<void> runAfterCollectionDelete(AfterCollectionDeleteEvent e) =>
      _runAfter(afterCollectionDelete, e);

  // Users
  Future<void> runBeforeUserCreate(BeforeUserCreateEvent e) =>
      _runBefore(beforeUserCreate, e);
  Future<void> runAfterUserCreate(AfterUserCreateEvent e) =>
      _runAfter(afterUserCreate, e);
  Future<void> runBeforeUserUpdate(BeforeUserUpdateEvent e) =>
      _runBefore(beforeUserUpdate, e);
  Future<void> runAfterUserUpdate(AfterUserUpdateEvent e) =>
      _runAfter(afterUserUpdate, e);
  Future<void> runBeforeUserDelete(BeforeUserDeleteEvent e) =>
      _runBefore(beforeUserDelete, e);
  Future<void> runAfterUserDelete(AfterUserDeleteEvent e) =>
      _runAfter(afterUserDelete, e);

  // Auth
  Future<void> runBeforeAuthSignIn(BeforeAuthSignInEvent e) =>
      _runBefore(beforeAuthSignIn, e);
  Future<void> runAfterAuthSignIn(AfterAuthSignInEvent e) =>
      _runAfter(afterAuthSignIn, e);

  // Files
  Future<void> runBeforeFileUpload(BeforeFileUploadEvent e) =>
      _runBefore(beforeFileUpload, e);
  Future<void> runAfterFileUpload(AfterFileUploadEvent e) =>
      _runAfter(afterFileUpload, e);
  Future<void> runBeforeFileDelete(BeforeFileDeleteEvent e) =>
      _runBefore(beforeFileDelete, e);
  Future<void> runAfterFileDelete(AfterFileDeleteEvent e) =>
      _runAfter(afterFileDelete, e);

  // Server lifecycle
  Future<void> runServerStarted(ServerStartedEvent e) =>
      _runAfter(serverStarted, e);
  Future<void> runServerStopped(ServerStoppedEvent e) =>
      _runAfter(serverStopped, e);

  /// Runs "before" hooks — returns `false` to cancel, exceptions are logged
  /// and rethrown.
  static Future<void> _runBefore<T>(
    Map<String, FutureOr<bool> Function(T)> callbacks,
    T event,
  ) async {
    for (final entry in callbacks.entries) {
      try {
        final result = await entry.value(event);
        if (!result) {
          throw HookCancelledException(entry.key);
        }
      } on HookCancelledException {
        rethrow;
      } catch (e, st) {
        serverLogger.error(
          'Hook "${entry.key}" failed for ${T.toString()}',
          error: e,
          stackTrace: st,
        );
        rethrow;
      }
    }
  }

  /// Runs "after" hooks — catches and logs exceptions without rethrowing.
  static Future<void> _runAfter<T>(
    Map<String, FutureOr<void> Function(T)> callbacks,
    T event,
  ) async {
    for (final entry in callbacks.entries) {
      try {
        await entry.value(event);
      } catch (e, st) {
        serverLogger.error(
          'Hook "${entry.key}" failed for ${T.toString()}',
          error: e,
          stackTrace: st,
        );
      }
    }
  }
}
