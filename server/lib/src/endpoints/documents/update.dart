import 'dart:async';
import 'dart:io';

import 'package:vanestack_common/vanestack_common.dart';
import 'package:shelf/shelf.dart';

import '../../permissions/rules_engine.dart';
import '../../../tools/route.dart';
import '../../utils/collection_data.dart';
import '../../utils/extensions.dart';
import '../../utils/http_method.dart';
import '../../utils/logger.dart';

@Route(
  path: '/v1/documents/<collectionName>/<documentId>',
  method: HttpMethod.patch,
)
FutureOr<Document> update(
  Request request,
  String collectionName,
  String documentId,
  Map<String, Object?> data,
) async {
  final db = request.database;
  final userId = request.userId;

  // Check for internal collections
  final adminCollections = db.allTables.map((e) => e.actualTableName).toSet();
  if (adminCollections.contains(collectionName)) {
    collectionsLogger.warn(
      'Document update denied: internal collection',
      context: 'collection=$collectionName',
      userId: userId,
    );
    throw VaneStackException(
      'Access to internal collections is denied.',
      status: HttpStatus.forbidden,
    );
  }

  // Get collection for permission check
  final collectionData = await db.managers.collections
      .filter((t) => t.name.equals(collectionName))
      .getSingleOrNull();

  if (collectionData == null) {
    throw VaneStackException('Collection not found.', status: HttpStatus.notFound);
  }

  final collection = collectionData.toModel();

  if (collection is ViewCollection) {
    collectionsLogger.warn(
      'Document update denied: view collection',
      context: 'collection=$collectionName',
      userId: userId,
    );
    throw VaneStackException(
      'Cannot update documents in view collections. Views are read-only.',
      status: HttpStatus.forbidden,
    );
  }

  final baseCollection = collection as BaseCollection;

  // Get existing document for permission check
  final oldDoc = await request.documents.get(
    collectionName: collectionName,
    documentId: documentId,
  );

  if (oldDoc == null) {
    throw VaneStackException('Document not found.', status: HttpStatus.notFound);
  }

  // Build new document for permission check
  final timestamp = DateTime.now();
  final newDoc = oldDoc.copyWith(
    updatedAt: timestamp,
    data: {...oldDoc.data, ...data}..remove('id'),
  );

  // Permission check
  final updateRule = baseCollection.updateRule;
  if (updateRule == null) {
    if (!request.isSuperUser) {
      throw VaneStackException('Permission denied.', status: HttpStatus.forbidden);
    }
  } else if (updateRule.trim().isNotEmpty && !request.isSuperUser) {
    final engine = RulesEngine(
      request: request,
      newResource: newDoc,
      oldResource: oldDoc,
    );

    final approved = await engine.evaluate(updateRule);
    if (!approved) {
      throw VaneStackException('Permission denied.', status: HttpStatus.forbidden);
    }
  }

  // Update document using service
  final result = await request.documents.update(
    collectionName: collectionName,
    documentId: documentId,
    data: data,
  );

  return result;
}
