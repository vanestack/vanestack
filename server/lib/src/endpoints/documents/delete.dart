import 'dart:async';
import 'dart:io';

import 'package:shelf/shelf.dart';
import 'package:vanestack_annotation/vanestack_annotation.dart';
import 'package:vanestack_common/vanestack_common.dart';

import '../../permissions/rules_engine.dart';
import '../../utils/extensions.dart';
import '../../utils/logger.dart';

@Route(
  path: '/v1/documents/<collectionName>/<documentId>',
  method: HttpMethod.delete,
)
FutureOr<void> delete(
  Request request,
  String collectionName,
  String documentId,
) async {
  final db = request.database;
  final userId = request.userId;

  // Check for internal collections
  final adminCollections = db.allTables.map((e) => e.actualTableName).toSet();
  if (adminCollections.contains(collectionName)) {
    collectionsLogger.warn(
      'Document deletion denied: internal collection',
      context: 'collection=$collectionName',
      userId: userId,
    );
    throw VaneStackException(
      'Access to internal collections is denied.',
      status: HttpStatus.forbidden,
      code: AuthErrorCode.permissionDenied,
    );
  }

  // Get collection for permission check
  final collection = await request.collectionsCache.resolve(collectionName, db);

  if (collection == null) {
    throw VaneStackException(
      'Collection not found.',
      status: HttpStatus.notFound,
      code: CollectionsErrorCode.collectionNotFound,
    );
  }

  if (collection is ViewCollection) {
    collectionsLogger.warn(
      'Document deletion denied: view collection',
      context: 'collection=$collectionName',
      userId: userId,
    );
    throw VaneStackException(
      'Cannot delete documents from view collections. Views are read-only.',
      status: HttpStatus.forbidden,
      code: DocumentsErrorCode.viewIsReadOnly,
    );
  }

  final baseCollection = collection as BaseCollection;

  // Get document for permission check
  final document = await request.documents.get(
    collectionName: collectionName,
    documentId: documentId,
  );

  if (document == null) {
    throw VaneStackException(
      'Document not found.',
      status: HttpStatus.notFound,
      code: DocumentsErrorCode.documentNotFound,
    );
  }

  // Permission check
  final deleteRule = baseCollection.deleteRule;
  if (deleteRule == null) {
    if (!request.isSuperUser) {
      throw VaneStackException(
        'Permission denied.',
        status: HttpStatus.forbidden,
        code: AuthErrorCode.permissionDenied,
      );
    }
  } else if (deleteRule.trim().isNotEmpty && !request.isSuperUser) {
    final engine = RulesEngine(request: request, oldResource: document);

    final approved = await engine.evaluate(deleteRule);
    if (!approved) {
      throw VaneStackException(
        'Permission denied.',
        status: HttpStatus.forbidden,
        code: AuthErrorCode.permissionDenied,
      );
    }
  }

  // Delete document using service
  await request.documents.delete(
    collectionName: collectionName,
    documentId: documentId,
  );
}
