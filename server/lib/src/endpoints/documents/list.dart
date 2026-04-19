import 'dart:async';
import 'dart:io';

import 'package:shelf/shelf.dart';
import 'package:vanestack_annotation/vanestack_annotation.dart';
import 'package:vanestack_common/vanestack_common.dart';

import '../../permissions/rules_engine.dart';
import '../../utils/extensions.dart';

@Route(path: '/v1/documents/<collectionName>', method: HttpMethod.get)
FutureOr<ListDocumentsResult> list(
  Request request,
  String collectionName,
  String? orderBy,
  String? filter, [
  int? limit = 10,
  int? offset = 0,
]) async {
  try {
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
    final collection = await request.collectionsCache.resolve(
      collectionName,
      db,
    );

    if (collection == null) {
      throw VaneStackException(
        'Collection not found.',
        status: HttpStatus.notFound,
        code: CollectionsErrorCode.collectionNotFound,
      );
    }

    // List documents using service
    final result = await request.documents.list(
      collectionName: collectionName,
      filter: filter,
      orderBy: orderBy,
      limit: limit ?? 10,
      offset: offset ?? 0,
    );

    // Permission check
    final listRule = collection.listRule;
    if (listRule == null) {
      if (!request.isSuperUser) {
        throw VaneStackException(
          'Permission denied.',
          status: HttpStatus.forbidden,
          code: AuthErrorCode.permissionDenied,
        );
      }
    } else if (listRule.trim().isNotEmpty && !request.isSuperUser) {
      final engine = RulesEngine(request: request);

      bool failed = false;
      for (final doc in result.documents) {
        final approved = await engine.evaluate(listRule, oldResource: doc);
        if (!approved) {
          failed = true;
          break;
        }
      }

      if (failed) {
        throw VaneStackException(
          'Permission denied.',
          status: HttpStatus.forbidden,
          code: AuthErrorCode.permissionDenied,
        );
      }
    }

    return result;
  } catch (_) {
    rethrow;
  }
}
