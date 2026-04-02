import 'dart:async';

import 'package:vanestack_common/vanestack_common.dart';

import '../database/database.dart';
import 'hook_runner.dart';

/// Thrown when a before-hook returns `false` to cancel the operation.
class HookCancelledException extends VaneStackException {
  final String hookId;

  HookCancelledException(this.hookId)
    : super(
        'Operation cancelled by hook "$hookId"',
        code: ServerErrorCode.hookCancelled,
      );
}

// ==================== Document Events ====================

/// Fired before a document is created.
///
/// Fields are mutable — modify [data] or [collectionName] to alter
/// what gets persisted.
/// Return `false` from the hook callback to cancel the creation.
class BeforeDocumentCreateEvent {
  String collectionName;
  Map<String, Object?> data;

  BeforeDocumentCreateEvent({required this.collectionName, required this.data});
}

/// Fired after a document has been successfully created.
///
/// All fields are final — the document is already persisted.
/// Use this for side-effects like sending notifications or logging.
class AfterDocumentCreateEvent {
  final String collectionName;
  final Document result;

  AfterDocumentCreateEvent({
    required this.collectionName,
    required this.result,
  });
}

/// Fired before a document is updated.
///
/// Fields are mutable — modify [data], [documentId], or [collectionName]
/// to alter what gets persisted.
/// Return `false` from the hook callback to cancel the update.
class BeforeDocumentUpdateEvent {
  String collectionName;
  String documentId;
  Map<String, Object?> data;

  BeforeDocumentUpdateEvent({
    required this.collectionName,
    required this.documentId,
    required this.data,
  });
}

/// Fired after a document has been successfully updated.
///
/// All fields are final — the document is already persisted.
/// Use this for side-effects like cache invalidation or audit logging.
class AfterDocumentUpdateEvent {
  final String collectionName;
  final Document result;

  AfterDocumentUpdateEvent({
    required this.collectionName,
    required this.result,
  });
}

/// Fired before a document is deleted.
///
/// Fields are mutable — modify [documentId] or [collectionName] if needed.
/// Return `false` from the hook callback to cancel the deletion.
class BeforeDocumentDeleteEvent {
  String collectionName;
  String documentId;

  BeforeDocumentDeleteEvent({
    required this.collectionName,
    required this.documentId,
  });
}

/// Fired after a document has been successfully deleted.
///
/// All fields are final — the document has already been removed.
/// Use this for cleanup tasks like deleting associated files.
class AfterDocumentDeleteEvent {
  final String collectionName;
  final String documentId;

  AfterDocumentDeleteEvent({
    required this.collectionName,
    required this.documentId,
  });
}

// ==================== Collection Events ====================

/// Fired before a collection is created.
///
/// Fields are mutable — modify [name] or [attributes] to alter
/// the collection definition before it is saved.
/// Return `false` from the hook callback to cancel the creation.
class BeforeCollectionCreateEvent {
  String name;
  List<Attribute> attributes;

  BeforeCollectionCreateEvent({required this.name, required this.attributes});
}

/// Fired after a collection has been successfully created.
///
/// Use this for side-effects like setting up default documents
/// or notifying external systems.
class AfterCollectionCreateEvent {
  final Collection result;

  AfterCollectionCreateEvent({required this.result});
}

/// Fired before a collection is updated.
///
/// Fields are mutable — modify [name] to alter the update.
/// Return `false` from the hook callback to cancel the update.
class BeforeCollectionUpdateEvent {
  String name;

  BeforeCollectionUpdateEvent({required this.name});
}

/// Fired after a collection has been successfully updated.
class AfterCollectionUpdateEvent {
  final Collection result;

  AfterCollectionUpdateEvent({required this.result});
}

/// Fired before a collection is deleted.
///
/// Fields are mutable — modify [name] if needed.
/// Return `false` from the hook callback to cancel the deletion.
class BeforeCollectionDeleteEvent {
  String name;

  BeforeCollectionDeleteEvent({required this.name});
}

/// Fired after a collection has been successfully deleted.
///
/// Use this for cleanup tasks like removing associated storage buckets.
class AfterCollectionDeleteEvent {
  final String name;

  AfterCollectionDeleteEvent({required this.name});
}

// ==================== User Events ====================

/// Fired before a user is created.
///
/// Fields are mutable — modify [email], [name], [password], or [superUser]
/// to alter the user before creation.
/// Return `false` from the hook callback to cancel the creation.
class BeforeUserCreateEvent {
  String email;
  String? name;
  String? password;
  bool superUser;

  BeforeUserCreateEvent({
    required this.email,
    this.name,
    this.password,
    this.superUser = false,
  });
}

/// Fired after a user has been successfully created.
///
/// Use this for side-effects like sending a welcome email.
class AfterUserCreateEvent {
  final User result;

  AfterUserCreateEvent({required this.result});
}

/// Fired before a user is updated.
///
/// Fields are mutable — modify any field to alter the update.
/// Return `false` from the hook callback to cancel the update.
class BeforeUserUpdateEvent {
  String id;
  String? email;
  String? name;
  String? password;
  bool? superUser;

  BeforeUserUpdateEvent({
    required this.id,
    this.email,
    this.name,
    this.password,
    this.superUser,
  });
}

/// Fired after a user has been successfully updated.
class AfterUserUpdateEvent {
  final User result;

  AfterUserUpdateEvent({required this.result});
}

/// Fired before a user is deleted.
///
/// Fields are mutable — modify [id] if needed.
/// Return `false` from the hook callback to cancel the deletion.
class BeforeUserDeleteEvent {
  String id;

  BeforeUserDeleteEvent({required this.id});
}

/// Fired after a user has been successfully deleted.
///
/// Use this for cleanup tasks like revoking sessions or deleting user data.
class AfterUserDeleteEvent {
  final String id;

  AfterUserDeleteEvent({required this.id});
}

// ==================== Auth Events ====================

/// Fired before a user signs in.
///
/// Fields are mutable — modify [email] to alter the sign-in lookup.
/// Return `false` from the hook callback to block the sign-in attempt.
class BeforeAuthSignInEvent {
  String email;

  BeforeAuthSignInEvent({required this.email});
}

/// Fired after a user has successfully signed in.
///
/// Use this for side-effects like audit logging or analytics.
class AfterAuthSignInEvent {
  final AuthResponse result;

  AfterAuthSignInEvent({required this.result});
}

// ==================== File Events ====================

/// Fired before a file is uploaded.
///
/// Fields are mutable — modify [bucket], [path], or [mimeType]
/// to alter where or how the file is stored.
/// Return `false` from the hook callback to cancel the upload.
class BeforeFileUploadEvent {
  String bucket;
  String path;
  String mimeType;

  BeforeFileUploadEvent({
    required this.bucket,
    required this.path,
    required this.mimeType,
  });
}

/// Fired after a file has been successfully uploaded.
///
/// Use this for side-effects like generating thumbnails or indexing metadata.
class AfterFileUploadEvent {
  final DbFile result;

  AfterFileUploadEvent({required this.result});
}

/// Fired before a file is deleted.
///
/// Fields are mutable — modify [fileId] if needed.
/// Return `false` from the hook callback to cancel the deletion.
class BeforeFileDeleteEvent {
  String fileId;

  BeforeFileDeleteEvent({required this.fileId});
}

/// Fired after a file has been successfully deleted.
class AfterFileDeleteEvent {
  final String fileId;

  AfterFileDeleteEvent({required this.fileId});
}

// ==================== Server Lifecycle Events ====================

/// Fired after the server has started and is accepting connections.
class ServerStartedEvent {
  final String address;
  final int port;

  ServerStartedEvent({required this.address, required this.port});
}

/// Fired when the server is shutting down.
class ServerStoppedEvent {
  ServerStoppedEvent();
}

// ==================== HookRegistry ====================

/// Public API for registering server-side hooks.
///
/// Only `on*` registration methods are exposed. Hook execution is handled
/// internally by services via [HookExecutor].
///
/// Each `on*` method accepts an optional [id] to identify the hook.
/// If omitted, an auto-generated identifier is assigned.
/// The identifier is always returned and can be passed to [unregister]
/// to remove the hook later.
class HookRegistry {
  HookRegistry(this._executor);

  final HookExecutor _executor;
  var _nextId = 0;

  String _resolveId(String? id) => id ?? 'hook_${_nextId++}';

  /// Removes a previously registered hook by its identifier.
  /// Returns `true` if the hook was found and removed.
  bool unregister(String id) => _executor.unregister(id);

  // ---- Documents ----

  /// Registers a hook that runs before a document is created.
  ///
  /// The [callback] receives a [BeforeDocumentCreateEvent] with mutable
  /// fields. Return `false` to cancel the creation and throw a
  /// [HookCancelledException].
  ///
  /// ```dart
  /// vanestack.hooks.onBeforeDocumentCreate((e) {
  ///   e.data['slug'] = slugify(e.data['title']);
  ///   return true;
  /// });
  /// ```
  String onBeforeDocumentCreate(
    FutureOr<bool> Function(BeforeDocumentCreateEvent) callback, {
    String? id,
  }) {
    final resolved = _resolveId(id);
    _executor.beforeDocumentCreate[resolved] = callback;
    return resolved;
  }

  /// Registers a hook that runs after a document is created.
  ///
  /// The [callback] receives an [AfterDocumentCreateEvent] with the
  /// persisted [Document]. Use for side-effects like notifications.
  String onAfterDocumentCreate(
    FutureOr<void> Function(AfterDocumentCreateEvent) callback, {
    String? id,
  }) {
    final resolved = _resolveId(id);
    _executor.afterDocumentCreate[resolved] = callback;
    return resolved;
  }

  /// Registers a hook that runs before a document is updated.
  ///
  /// The [callback] receives a [BeforeDocumentUpdateEvent] with mutable
  /// fields. Return `false` to cancel the update.
  String onBeforeDocumentUpdate(
    FutureOr<bool> Function(BeforeDocumentUpdateEvent) callback, {
    String? id,
  }) {
    final resolved = _resolveId(id);
    _executor.beforeDocumentUpdate[resolved] = callback;
    return resolved;
  }

  /// Registers a hook that runs after a document is updated.
  ///
  /// The [callback] receives an [AfterDocumentUpdateEvent] with the
  /// updated [Document]. Use for side-effects like cache invalidation.
  String onAfterDocumentUpdate(
    FutureOr<void> Function(AfterDocumentUpdateEvent) callback, {
    String? id,
  }) {
    final resolved = _resolveId(id);
    _executor.afterDocumentUpdate[resolved] = callback;
    return resolved;
  }

  /// Registers a hook that runs before a document is deleted.
  ///
  /// The [callback] receives a [BeforeDocumentDeleteEvent]. Return `false`
  /// to cancel the deletion.
  String onBeforeDocumentDelete(
    FutureOr<bool> Function(BeforeDocumentDeleteEvent) callback, {
    String? id,
  }) {
    final resolved = _resolveId(id);
    _executor.beforeDocumentDelete[resolved] = callback;
    return resolved;
  }

  /// Registers a hook that runs after a document is deleted.
  ///
  /// The [callback] receives an [AfterDocumentDeleteEvent]. Use for
  /// cleanup tasks like deleting associated files.
  String onAfterDocumentDelete(
    FutureOr<void> Function(AfterDocumentDeleteEvent) callback, {
    String? id,
  }) {
    final resolved = _resolveId(id);
    _executor.afterDocumentDelete[resolved] = callback;
    return resolved;
  }

  // ---- Collections ----

  /// Registers a hook that runs before a collection is created.
  ///
  /// The [callback] receives a [BeforeCollectionCreateEvent] with mutable
  /// fields. Return `false` to cancel the creation.
  String onBeforeCollectionCreate(
    FutureOr<bool> Function(BeforeCollectionCreateEvent) callback, {
    String? id,
  }) {
    final resolved = _resolveId(id);
    _executor.beforeCollectionCreate[resolved] = callback;
    return resolved;
  }

  /// Registers a hook that runs after a collection is created.
  ///
  /// The [callback] receives an [AfterCollectionCreateEvent] with the
  /// persisted [Collection].
  String onAfterCollectionCreate(
    FutureOr<void> Function(AfterCollectionCreateEvent) callback, {
    String? id,
  }) {
    final resolved = _resolveId(id);
    _executor.afterCollectionCreate[resolved] = callback;
    return resolved;
  }

  /// Registers a hook that runs before a collection is updated.
  ///
  /// The [callback] receives a [BeforeCollectionUpdateEvent] with mutable
  /// fields. Return `false` to cancel the update.
  String onBeforeCollectionUpdate(
    FutureOr<bool> Function(BeforeCollectionUpdateEvent) callback, {
    String? id,
  }) {
    final resolved = _resolveId(id);
    _executor.beforeCollectionUpdate[resolved] = callback;
    return resolved;
  }

  /// Registers a hook that runs after a collection is updated.
  ///
  /// The [callback] receives an [AfterCollectionUpdateEvent] with the
  /// updated [Collection].
  String onAfterCollectionUpdate(
    FutureOr<void> Function(AfterCollectionUpdateEvent) callback, {
    String? id,
  }) {
    final resolved = _resolveId(id);
    _executor.afterCollectionUpdate[resolved] = callback;
    return resolved;
  }

  /// Registers a hook that runs before a collection is deleted.
  ///
  /// The [callback] receives a [BeforeCollectionDeleteEvent]. Return `false`
  /// to cancel the deletion.
  String onBeforeCollectionDelete(
    FutureOr<bool> Function(BeforeCollectionDeleteEvent) callback, {
    String? id,
  }) {
    final resolved = _resolveId(id);
    _executor.beforeCollectionDelete[resolved] = callback;
    return resolved;
  }

  /// Registers a hook that runs after a collection is deleted.
  ///
  /// The [callback] receives an [AfterCollectionDeleteEvent] with the
  /// deleted collection's name.
  String onAfterCollectionDelete(
    FutureOr<void> Function(AfterCollectionDeleteEvent) callback, {
    String? id,
  }) {
    final resolved = _resolveId(id);
    _executor.afterCollectionDelete[resolved] = callback;
    return resolved;
  }

  // ---- Users ----

  /// Registers a hook that runs before a user is created.
  ///
  /// The [callback] receives a [BeforeUserCreateEvent] with mutable
  /// fields. Return `false` to cancel the creation.
  String onBeforeUserCreate(
    FutureOr<bool> Function(BeforeUserCreateEvent) callback, {
    String? id,
  }) {
    final resolved = _resolveId(id);
    _executor.beforeUserCreate[resolved] = callback;
    return resolved;
  }

  /// Registers a hook that runs after a user is created.
  ///
  /// The [callback] receives an [AfterUserCreateEvent] with the
  /// persisted [User]. Use for side-effects like sending a welcome email.
  String onAfterUserCreate(
    FutureOr<void> Function(AfterUserCreateEvent) callback, {
    String? id,
  }) {
    final resolved = _resolveId(id);
    _executor.afterUserCreate[resolved] = callback;
    return resolved;
  }

  /// Registers a hook that runs before a user is updated.
  ///
  /// The [callback] receives a [BeforeUserUpdateEvent] with mutable
  /// fields. Return `false` to cancel the update.
  String onBeforeUserUpdate(
    FutureOr<bool> Function(BeforeUserUpdateEvent) callback, {
    String? id,
  }) {
    final resolved = _resolveId(id);
    _executor.beforeUserUpdate[resolved] = callback;
    return resolved;
  }

  /// Registers a hook that runs after a user is updated.
  ///
  /// The [callback] receives an [AfterUserUpdateEvent] with the
  /// updated [User].
  String onAfterUserUpdate(
    FutureOr<void> Function(AfterUserUpdateEvent) callback, {
    String? id,
  }) {
    final resolved = _resolveId(id);
    _executor.afterUserUpdate[resolved] = callback;
    return resolved;
  }

  /// Registers a hook that runs before a user is deleted.
  ///
  /// The [callback] receives a [BeforeUserDeleteEvent]. Return `false`
  /// to cancel the deletion.
  String onBeforeUserDelete(
    FutureOr<bool> Function(BeforeUserDeleteEvent) callback, {
    String? id,
  }) {
    final resolved = _resolveId(id);
    _executor.beforeUserDelete[resolved] = callback;
    return resolved;
  }

  /// Registers a hook that runs after a user is deleted.
  ///
  /// The [callback] receives an [AfterUserDeleteEvent]. Use for cleanup
  /// tasks like revoking sessions or deleting user data.
  String onAfterUserDelete(
    FutureOr<void> Function(AfterUserDeleteEvent) callback, {
    String? id,
  }) {
    final resolved = _resolveId(id);
    _executor.afterUserDelete[resolved] = callback;
    return resolved;
  }

  // ---- Auth ----

  /// Registers a hook that runs before a user signs in.
  ///
  /// The [callback] receives a [BeforeAuthSignInEvent] with mutable
  /// fields. Return `false` to block the sign-in attempt.
  String onBeforeAuthSignIn(
    FutureOr<bool> Function(BeforeAuthSignInEvent) callback, {
    String? id,
  }) {
    final resolved = _resolveId(id);
    _executor.beforeAuthSignIn[resolved] = callback;
    return resolved;
  }

  /// Registers a hook that runs after a user signs in.
  ///
  /// The [callback] receives an [AfterAuthSignInEvent] with the
  /// [AuthResponse]. Use for audit logging or analytics.
  String onAfterAuthSignIn(
    FutureOr<void> Function(AfterAuthSignInEvent) callback, {
    String? id,
  }) {
    final resolved = _resolveId(id);
    _executor.afterAuthSignIn[resolved] = callback;
    return resolved;
  }

  // ---- Server lifecycle ----

  /// Registers a hook that runs after the server starts.
  ///
  /// The [callback] receives a [ServerStartedEvent] with the server's
  /// address and port.
  String onServerStarted(
    FutureOr<void> Function(ServerStartedEvent) callback, {
    String? id,
  }) {
    final resolved = _resolveId(id);
    _executor.serverStarted[resolved] = callback;
    return resolved;
  }

  /// Registers a hook that runs when the server is shutting down.
  ///
  /// Use for cleanup tasks like closing external connections.
  String onServerStopped(
    FutureOr<void> Function(ServerStoppedEvent) callback, {
    String? id,
  }) {
    final resolved = _resolveId(id);
    _executor.serverStopped[resolved] = callback;
    return resolved;
  }

  // ---- Files ----

  /// Registers a hook that runs before a file is uploaded.
  ///
  /// The [callback] receives a [BeforeFileUploadEvent] with mutable
  /// fields. Return `false` to cancel the upload.
  String onBeforeFileUpload(
    FutureOr<bool> Function(BeforeFileUploadEvent) callback, {
    String? id,
  }) {
    final resolved = _resolveId(id);
    _executor.beforeFileUpload[resolved] = callback;
    return resolved;
  }

  /// Registers a hook that runs after a file is uploaded.
  ///
  /// The [callback] receives an [AfterFileUploadEvent] with the
  /// persisted [DbFile]. Use for side-effects like generating thumbnails.
  String onAfterFileUpload(
    FutureOr<void> Function(AfterFileUploadEvent) callback, {
    String? id,
  }) {
    final resolved = _resolveId(id);
    _executor.afterFileUpload[resolved] = callback;
    return resolved;
  }

  /// Registers a hook that runs before a file is deleted.
  ///
  /// The [callback] receives a [BeforeFileDeleteEvent]. Return `false`
  /// to cancel the deletion.
  String onBeforeFileDelete(
    FutureOr<bool> Function(BeforeFileDeleteEvent) callback, {
    String? id,
  }) {
    final resolved = _resolveId(id);
    _executor.beforeFileDelete[resolved] = callback;
    return resolved;
  }

  /// Registers a hook that runs after a file is deleted.
  String onAfterFileDelete(
    FutureOr<void> Function(AfterFileDeleteEvent) callback, {
    String? id,
  }) {
    final resolved = _resolveId(id);
    _executor.afterFileDelete[resolved] = callback;
    return resolved;
  }
}
