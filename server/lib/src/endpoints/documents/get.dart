import 'dart:async';
import 'dart:io';

import 'package:vanestack_common/vanestack_common.dart';
import 'package:shelf/shelf.dart';

import '../../permissions/rules_engine.dart';
import 'package:vanestack_annotation/vanestack_annotation.dart';
import '../../utils/extensions.dart';

@Route(
  path: '/v1/documents/<collectionName>/<documentId>',
  method: HttpMethod.get,
)
FutureOr<Document> get(
  Request request,
  String collectionName,
  String documentId,
) async {
  final db = request.database;

  // Check for internal collections
  final adminCollections = db.allTables.map((e) => e.actualTableName).toSet();
  if (adminCollections.contains(collectionName)) {
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

  // Get document using service
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
  final viewRule = collection.viewRule;

  if (viewRule == null) {
    if (!request.isSuperUser) {
      throw VaneStackException(
        'Permission denied.',
        status: HttpStatus.forbidden,
        code: AuthErrorCode.permissionDenied,
      );
    }
  } else if (viewRule.trim().isNotEmpty && !request.isSuperUser) {
    final engine = RulesEngine(request: request, oldResource: document);

    final approved = await engine.evaluate(viewRule);
    if (!approved) {
      throw VaneStackException(
        'Permission denied.',
        status: HttpStatus.forbidden,
        code: AuthErrorCode.permissionDenied,
      );
    }
  }

  return document;
}
