import 'dart:async';
import 'dart:io';

import 'package:shelf/shelf.dart';
import 'package:vanestack_annotation/vanestack_annotation.dart';
import 'package:vanestack_common/vanestack_common.dart';

import '../../utils/extensions.dart';

@Route(
  path: '/v1/collections',
  method: HttpMethod.post,
  requireSuperUserAuth: true,
)
FutureOr<Collection> create(
  Request request,
  String name,
  String? listRule,
  String? viewRule,
  String? createRule,
  String? updateRule,
  String? deleteRule,
  String? viewQuery,
  String? type,
  List<Attribute>? attributes,
  List<Index>? indexes,
) async {
  // Parse type with default to 'base'
  final collectionType = type == 'view'
      ? CollectionType.view
      : CollectionType.base;

  if (collectionType == CollectionType.view) {
    if (viewQuery == null || viewQuery.trim().isEmpty) {
      throw VaneStackException(
        'viewQuery is required for view collections.',
        status: HttpStatus.badRequest,
        code: CollectionsErrorCode.viewQueryRequired,
      );
    }

    // Validate that write rules are not provided for views
    if (createRule != null && createRule.trim().isNotEmpty) {
      throw VaneStackException(
        'createRule cannot be set for view collections. Views are read-only.',
        status: HttpStatus.badRequest,
        code: CollectionsErrorCode.viewIsReadOnly,
      );
    }
    if (updateRule != null && updateRule.trim().isNotEmpty) {
      throw VaneStackException(
        'updateRule cannot be set for view collections. Views are read-only.',
        status: HttpStatus.badRequest,
        code: CollectionsErrorCode.viewIsReadOnly,
      );
    }
    if (deleteRule != null && deleteRule.trim().isNotEmpty) {
      throw VaneStackException(
        'deleteRule cannot be set for view collections. Views are read-only.',
        status: HttpStatus.badRequest,
        code: CollectionsErrorCode.viewIsReadOnly,
      );
    }

    final result = await request.collections.createView(
      name: name,
      viewQuery: viewQuery,
      listRule: listRule,
      viewRule: viewRule,
    );

    return result;
  }

  final result = await request.collections.createBase(
    name: name,
    attributes: attributes ?? [],
    indexes: indexes ?? [],
    listRule: listRule,
    viewRule: viewRule,
    createRule: createRule,
    updateRule: updateRule,
    deleteRule: deleteRule,
  );

  return result;
}
