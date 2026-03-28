import 'dart:async';

import 'package:vanestack_common/vanestack_common.dart';

import '../database/database.dart';
import 'hook_runner.dart';

/// Thrown when a before-hook returns `false` to cancel the operation.
class HookCancelledException extends VaneStackException {
  final String hookId;

  HookCancelledException(this.hookId)
      : super('Operation cancelled by hook "$hookId"');
}

// ==================== Document Events ====================

class BeforeDocumentCreateEvent {
  String collectionName;
  Map<String, Object?> data;

  BeforeDocumentCreateEvent({required this.collectionName, required this.data});
}

class AfterDocumentCreateEvent {
  final String collectionName;
  final Document result;

  AfterDocumentCreateEvent({required this.collectionName, required this.result});
}

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

class AfterDocumentUpdateEvent {
  final String collectionName;
  final Document result;

  AfterDocumentUpdateEvent({required this.collectionName, required this.result});
}

class BeforeDocumentDeleteEvent {
  String collectionName;
  String documentId;

  BeforeDocumentDeleteEvent({
    required this.collectionName,
    required this.documentId,
  });
}

class AfterDocumentDeleteEvent {
  final String collectionName;
  final String documentId;

  AfterDocumentDeleteEvent({
    required this.collectionName,
    required this.documentId,
  });
}

// ==================== Collection Events ====================

class BeforeCollectionCreateEvent {
  String name;
  List<Attribute> attributes;

  BeforeCollectionCreateEvent({required this.name, required this.attributes});
}

class AfterCollectionCreateEvent {
  final Collection result;

  AfterCollectionCreateEvent({required this.result});
}

class BeforeCollectionUpdateEvent {
  String name;

  BeforeCollectionUpdateEvent({required this.name});
}

class AfterCollectionUpdateEvent {
  final Collection result;

  AfterCollectionUpdateEvent({required this.result});
}

class BeforeCollectionDeleteEvent {
  String name;

  BeforeCollectionDeleteEvent({required this.name});
}

class AfterCollectionDeleteEvent {
  final String name;

  AfterCollectionDeleteEvent({required this.name});
}

// ==================== User Events ====================

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

class AfterUserCreateEvent {
  final User result;

  AfterUserCreateEvent({required this.result});
}

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

class AfterUserUpdateEvent {
  final User result;

  AfterUserUpdateEvent({required this.result});
}

class BeforeUserDeleteEvent {
  String id;

  BeforeUserDeleteEvent({required this.id});
}

class AfterUserDeleteEvent {
  final String id;

  AfterUserDeleteEvent({required this.id});
}

// ==================== Auth Events ====================

class BeforeAuthSignInEvent {
  String email;

  BeforeAuthSignInEvent({required this.email});
}

class AfterAuthSignInEvent {
  final AuthResponse result;

  AfterAuthSignInEvent({required this.result});
}

// ==================== File Events ====================

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

class AfterFileUploadEvent {
  final DbFile result;

  AfterFileUploadEvent({required this.result});
}

class BeforeFileDeleteEvent {
  String fileId;

  BeforeFileDeleteEvent({required this.fileId});
}

class AfterFileDeleteEvent {
  final String fileId;

  AfterFileDeleteEvent({required this.fileId});
}

// ==================== Server Lifecycle Events ====================

class ServerStartedEvent {
  final String address;
  final int port;

  ServerStartedEvent({required this.address, required this.port});
}

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

  // Documents
  String onBeforeDocumentCreate(
    FutureOr<bool> Function(BeforeDocumentCreateEvent) callback, {
    String? id,
  }) {
    final resolved = _resolveId(id);
    _executor.beforeDocumentCreate[resolved] = callback;
    return resolved;
  }

  String onAfterDocumentCreate(
    FutureOr<void> Function(AfterDocumentCreateEvent) callback, {
    String? id,
  }) {
    final resolved = _resolveId(id);
    _executor.afterDocumentCreate[resolved] = callback;
    return resolved;
  }

  String onBeforeDocumentUpdate(
    FutureOr<bool> Function(BeforeDocumentUpdateEvent) callback, {
    String? id,
  }) {
    final resolved = _resolveId(id);
    _executor.beforeDocumentUpdate[resolved] = callback;
    return resolved;
  }

  String onAfterDocumentUpdate(
    FutureOr<void> Function(AfterDocumentUpdateEvent) callback, {
    String? id,
  }) {
    final resolved = _resolveId(id);
    _executor.afterDocumentUpdate[resolved] = callback;
    return resolved;
  }

  String onBeforeDocumentDelete(
    FutureOr<bool> Function(BeforeDocumentDeleteEvent) callback, {
    String? id,
  }) {
    final resolved = _resolveId(id);
    _executor.beforeDocumentDelete[resolved] = callback;
    return resolved;
  }

  String onAfterDocumentDelete(
    FutureOr<void> Function(AfterDocumentDeleteEvent) callback, {
    String? id,
  }) {
    final resolved = _resolveId(id);
    _executor.afterDocumentDelete[resolved] = callback;
    return resolved;
  }

  // Collections
  String onBeforeCollectionCreate(
    FutureOr<bool> Function(BeforeCollectionCreateEvent) callback, {
    String? id,
  }) {
    final resolved = _resolveId(id);
    _executor.beforeCollectionCreate[resolved] = callback;
    return resolved;
  }

  String onAfterCollectionCreate(
    FutureOr<void> Function(AfterCollectionCreateEvent) callback, {
    String? id,
  }) {
    final resolved = _resolveId(id);
    _executor.afterCollectionCreate[resolved] = callback;
    return resolved;
  }

  String onBeforeCollectionUpdate(
    FutureOr<bool> Function(BeforeCollectionUpdateEvent) callback, {
    String? id,
  }) {
    final resolved = _resolveId(id);
    _executor.beforeCollectionUpdate[resolved] = callback;
    return resolved;
  }

  String onAfterCollectionUpdate(
    FutureOr<void> Function(AfterCollectionUpdateEvent) callback, {
    String? id,
  }) {
    final resolved = _resolveId(id);
    _executor.afterCollectionUpdate[resolved] = callback;
    return resolved;
  }

  String onBeforeCollectionDelete(
    FutureOr<bool> Function(BeforeCollectionDeleteEvent) callback, {
    String? id,
  }) {
    final resolved = _resolveId(id);
    _executor.beforeCollectionDelete[resolved] = callback;
    return resolved;
  }

  String onAfterCollectionDelete(
    FutureOr<void> Function(AfterCollectionDeleteEvent) callback, {
    String? id,
  }) {
    final resolved = _resolveId(id);
    _executor.afterCollectionDelete[resolved] = callback;
    return resolved;
  }

  // Users
  String onBeforeUserCreate(
    FutureOr<bool> Function(BeforeUserCreateEvent) callback, {
    String? id,
  }) {
    final resolved = _resolveId(id);
    _executor.beforeUserCreate[resolved] = callback;
    return resolved;
  }

  String onAfterUserCreate(
    FutureOr<void> Function(AfterUserCreateEvent) callback, {
    String? id,
  }) {
    final resolved = _resolveId(id);
    _executor.afterUserCreate[resolved] = callback;
    return resolved;
  }

  String onBeforeUserUpdate(
    FutureOr<bool> Function(BeforeUserUpdateEvent) callback, {
    String? id,
  }) {
    final resolved = _resolveId(id);
    _executor.beforeUserUpdate[resolved] = callback;
    return resolved;
  }

  String onAfterUserUpdate(
    FutureOr<void> Function(AfterUserUpdateEvent) callback, {
    String? id,
  }) {
    final resolved = _resolveId(id);
    _executor.afterUserUpdate[resolved] = callback;
    return resolved;
  }

  String onBeforeUserDelete(
    FutureOr<bool> Function(BeforeUserDeleteEvent) callback, {
    String? id,
  }) {
    final resolved = _resolveId(id);
    _executor.beforeUserDelete[resolved] = callback;
    return resolved;
  }

  String onAfterUserDelete(
    FutureOr<void> Function(AfterUserDeleteEvent) callback, {
    String? id,
  }) {
    final resolved = _resolveId(id);
    _executor.afterUserDelete[resolved] = callback;
    return resolved;
  }

  // Auth
  String onBeforeAuthSignIn(
    FutureOr<bool> Function(BeforeAuthSignInEvent) callback, {
    String? id,
  }) {
    final resolved = _resolveId(id);
    _executor.beforeAuthSignIn[resolved] = callback;
    return resolved;
  }

  String onAfterAuthSignIn(
    FutureOr<void> Function(AfterAuthSignInEvent) callback, {
    String? id,
  }) {
    final resolved = _resolveId(id);
    _executor.afterAuthSignIn[resolved] = callback;
    return resolved;
  }

  // Server lifecycle
  String onServerStarted(
    FutureOr<void> Function(ServerStartedEvent) callback, {
    String? id,
  }) {
    final resolved = _resolveId(id);
    _executor.serverStarted[resolved] = callback;
    return resolved;
  }

  String onServerStopped(
    FutureOr<void> Function(ServerStoppedEvent) callback, {
    String? id,
  }) {
    final resolved = _resolveId(id);
    _executor.serverStopped[resolved] = callback;
    return resolved;
  }

  // Files
  String onBeforeFileUpload(
    FutureOr<bool> Function(BeforeFileUploadEvent) callback, {
    String? id,
  }) {
    final resolved = _resolveId(id);
    _executor.beforeFileUpload[resolved] = callback;
    return resolved;
  }

  String onAfterFileUpload(
    FutureOr<void> Function(AfterFileUploadEvent) callback, {
    String? id,
  }) {
    final resolved = _resolveId(id);
    _executor.afterFileUpload[resolved] = callback;
    return resolved;
  }

  String onBeforeFileDelete(
    FutureOr<bool> Function(BeforeFileDeleteEvent) callback, {
    String? id,
  }) {
    final resolved = _resolveId(id);
    _executor.beforeFileDelete[resolved] = callback;
    return resolved;
  }

  String onAfterFileDelete(
    FutureOr<void> Function(AfterFileDeleteEvent) callback, {
    String? id,
  }) {
    final resolved = _resolveId(id);
    _executor.afterFileDelete[resolved] = callback;
    return resolved;
  }
}
