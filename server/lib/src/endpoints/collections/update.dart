import 'dart:async';
import 'dart:io';

import 'package:vanestack_common/vanestack_common.dart';
import 'package:shelf/shelf.dart';

import '../../../tools/route.dart';
import '../../utils/extensions.dart';
import '../../utils/http_method.dart';

@Route(
  path: '/v1/collections/<collectionName>',
  method: HttpMethod.patch,
  requireSuperUserAuth: true,
)
FutureOr<Collection> update(
  Request request,
  String collectionName,
  String? newCollectionName,
  List<Attribute>? attributes,
  List<Index>? indexes,
  String? listRule,
  String? viewRule,
  String? createRule,
  String? updateRule,
  String? deleteRule,
  String? viewQuery,
) async {
  // Get existing collection to determine type
  final existing = await request.collections.getByName(collectionName);

  if (existing == null) {
    throw VaneStackException(
      'Collection "$collectionName" does not exist.',
      status: HttpStatus.notFound,
    );
  }

  if (existing is ViewCollection) {
    // Block attribute modifications for views
    if (attributes != null) {
      throw VaneStackException(
        'Cannot modify attributes for view collections. Attributes are inferred from the view query.',
        status: HttpStatus.badRequest,
      );
    }

    // Block index modifications for views
    if (indexes != null) {
      throw VaneStackException(
        'Cannot set indexes for view collections. Views do not support indexes.',
        status: HttpStatus.badRequest,
      );
    }

    // Block write rules for views
    if (createRule != null && createRule.trim().isNotEmpty) {
      throw VaneStackException(
        'Cannot set createRule for view collections. Views are read-only.',
        status: HttpStatus.badRequest,
      );
    }
    if (updateRule != null && updateRule.trim().isNotEmpty) {
      throw VaneStackException(
        'Cannot set updateRule for view collections. Views are read-only.',
        status: HttpStatus.badRequest,
      );
    }
    if (deleteRule != null && deleteRule.trim().isNotEmpty) {
      throw VaneStackException(
        'Cannot set deleteRule for view collections. Views are read-only.',
        status: HttpStatus.badRequest,
      );
    }

    return request.collections.updateView(
      name: collectionName,
      newName: newCollectionName,
      viewQuery: viewQuery,
      listRule: listRule,
      viewRule: viewRule,
    );
  }

  return request.collections.updateBase(
    name: collectionName,
    newName: newCollectionName,
    attributes: attributes,
    indexes: indexes,
    listRule: listRule,
    viewRule: viewRule,
    createRule: createRule,
    updateRule: updateRule,
    deleteRule: deleteRule,
  );
}
