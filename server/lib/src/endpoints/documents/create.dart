import 'dart:async';
import 'dart:io';

import 'package:vanestack_common/vanestack_common.dart';
import 'package:shelf/shelf.dart';
import 'package:uuid/uuid.dart';

import '../../permissions/rules_engine.dart';
import '../../../tools/route.dart';
import '../../utils/collection_data.dart';
import '../../utils/extensions.dart';
import '../../utils/http_method.dart';
import '../../utils/logger.dart';

@Route(path: '/v1/documents/<collectionName>', method: HttpMethod.post)
FutureOr<Document> create(
  Request request,
  String collectionName,
  Map<String, Object?> data,
) async {
  final db = request.database;
  final userId = request.userId;

  // Check for internal collections
  final adminCollections = db.allTables.map((e) => e.actualTableName).toSet();
  if (adminCollections.contains(collectionName)) {
    collectionsLogger.warn(
      'Document creation denied: internal collection',
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
    throw VaneStackException(
      'Collection not found.',
      status: HttpStatus.notFound,
    );
  }

  final collection = collectionData.toModel();

  if (collection is ViewCollection) {
    collectionsLogger.warn(
      'Document creation denied: view collection',
      context: 'collection=$collectionName',
      userId: userId,
    );
    throw VaneStackException(
      'Cannot create documents in view collections. Views are read-only.',
      status: HttpStatus.forbidden,
    );
  }

  final baseCollection = collection as BaseCollection;

  // Build document for permission check
  final timestamp = DateTime.now();
  final newDoc = Document(
    id: data['id'] as String? ?? const Uuid().v7(),
    collection: baseCollection.name,
    createdAt: timestamp,
    updatedAt: timestamp,
    data: {...data}..remove('id'),
  );

  // Permission check
  final createRule = baseCollection.createRule;
  if (createRule == null) {
    if (!request.isSuperUser) {
      throw VaneStackException(
        'Permission denied.',
        status: HttpStatus.forbidden,
      );
    }
  } else if (createRule.trim().isNotEmpty && !request.isSuperUser) {
    final engine = RulesEngine(request: request, newResource: newDoc);

    final approved = await engine.evaluate(createRule);
    if (!approved) {
      throw VaneStackException(
        'Permission denied.',
        status: HttpStatus.forbidden,
      );
    }
  }

  // Create document using service
  final result = await request.documents.create(
    collectionName: collectionName,
    data: data,
  );

  return result;
}
