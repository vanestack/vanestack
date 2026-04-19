import 'package:vanestack_common/vanestack_common.dart';
import 'package:drift/drift.dart' show Variable;
import 'package:expressions/expressions.dart' hide Variable;
import 'package:shelf/shelf.dart';

import '../database/database.dart';
import '../services/collections_cache.dart';
import '../utils/collection.dart';
import '../utils/extensions.dart';
import 'cache.dart';

class RulesEngine {
  static final Map<String, Expression> _expressionCache = {};

  final _docCache = SimpleCache<(String, String), Map<String, dynamic>>();
  final _existsCache = SimpleCache<(String, String), bool>();

  final _evaluator = ExpressionEvaluator.async(
    memberAccessors: [
      MemberAccessor<DateTime>({
        'year': (obj) => obj.year,
        'month': (obj) => obj.month,
        'day': (obj) => obj.day,
        'hour': (obj) => obj.hour,
        'minute': (obj) => obj.minute,
        'second': (obj) => obj.second,
        'millisecond': (obj) => obj.millisecond,
        'microsecond': (obj) => obj.microsecond,
        'secondsSinceEpoch': (obj) => obj.millisecondsSinceEpoch ~/ 1000,
        'millisecondsSinceEpoch': (obj) => obj.millisecondsSinceEpoch,
        'microsecondsSinceEpoch': (obj) => obj.microsecondsSinceEpoch,
        'weekday': (obj) => obj.weekday,
        'toIso8601String': (obj) => obj.toIso8601String,
        'toLocal': (obj) => obj.toLocal,
        'toUtc': (obj) => obj.toUtc,
        'toString': (obj) => obj.toString,
      }),
      MemberAccessor<String>({
        'contains': (obj) => obj.contains,
        'startsWith': (obj) => obj.startsWith,
        'endsWith': (obj) => obj.endsWith,
        'split': (obj) => obj.split,
        'toLowerCase': (obj) => obj.toLowerCase,
        'toUpperCase': (obj) => obj.toUpperCase,
        'trim': (obj) => obj.trim,
        'substring': (obj) => obj.substring,
        'replaceAll': (obj) => obj.replaceAll,
        'length': (obj) => obj.length,
        'isEmpty': (obj) => obj.isEmpty,
        'isNotEmpty': (obj) => obj.isNotEmpty,
      }),
      MemberAccessor<Iterable>({
        'length': (obj) => obj.length,
        'isEmpty': (obj) => obj.isEmpty,
        'isNotEmpty': (obj) => obj.isNotEmpty,
        'contains': (obj) => obj.contains,
        'join': (obj) => obj.join,
        'map': (obj) => obj.map,
        'elementAt': (obj) => obj.elementAt,
        'first': (obj) => obj.first,
        'last': (obj) => obj.last,
        'where': (obj) => obj.where,
        'toList': (obj) => obj.toList(),
        'toSet': (obj) => obj.toSet(),
      }),
      MemberAccessor<Map<dynamic, dynamic>>({
        'keys': (obj) => obj.keys,
        'values': (obj) => obj.values,
        'containsKey': (obj) => obj.containsKey,
        'containsValue': (obj) => obj.containsValue,
      }),
      MemberAccessor<num>({
        'abs': (obj) => obj.abs,
        'ceil': (obj) => obj.ceil,
        'floor': (obj) => obj.floor,
        'round': (obj) => obj.round,
        'toInt': (obj) => obj.toInt,
        'toDouble': (obj) => obj.toDouble,
        'clamp': (obj) => obj.clamp,
        'toStringAsFixed': (obj) => obj.toStringAsFixed,
        'toStringAsExponential': (obj) => obj.toStringAsExponential,
        'toStringAsPrecision': (obj) => obj.toStringAsPrecision,
        'toString': (obj) => obj.toString,
      }),
      MemberAccessor<RulesAuth>({
        'uid': (obj) => obj.uid,
        'isSuperUser': (obj) => obj.isSuperUser,
        'token': (obj) => obj.token,
      }),
      MemberAccessor<RulesRequest>({
        'path': (obj) => obj.path,
        'method': (obj) => obj.method,
        'headers': (obj) => obj.headers,
        'timestamp': (obj) => obj.timestamp,
        'auth': (obj) => obj.auth,
        'resource': (obj) => obj.resource,
      }),
      MemberAccessor<DocumentResource>({
        'data': (obj) => obj.data,
        'id': (obj) => obj.id,
        'collection': (obj) => obj.collection,
      }),
      MemberAccessor<FileResource>({
        'file': (obj) => obj.file,
        'id': (obj) => obj.id,
        'bucket': (obj) => obj.bucket,
      }),
      MemberAccessor<DbFile>({
        'id': (obj) => obj.id,
        'path': (obj) => obj.path,
        'bucket': (obj) => obj.bucket,
        'size': (obj) => obj.size,
        'mimeType': (obj) => obj.mimeType,
        'metadata': (obj) => obj.metadata,
        'createdAt': (obj) => obj.createdAt,
        'updatedAt': (obj) => obj.updatedAt,
      }),
    ],
  );

  final Map<String, dynamic> _context;
  final AppDatabase _database;
  final CollectionsCache _collectionsCache;

  RulesEngine({
    required Request request,
    Resource? newResource,
    Resource? oldResource,

    /// default | realtime
    String? context = 'default',
  }) : _context = {
         'request': RulesRequest(
           context: context ?? 'default',
           path: request.requestedUri.path,
           resource: newResource == null
               ? null
               : switch (newResource) {
                   Document newDoc => DocumentResource(
                     data: newDoc.data,
                     id: newDoc.id,
                     collection: newDoc.collection,
                   ),
                   DbFile file => FileResource(
                     file: file,
                     bucket: file.bucket,
                     id: file.id,
                   ),
                   _ => throw VaneStackException(
                     'Invalid newResource provided for rules evaluation.',
                     code: ServerErrorCode.unknownError,
                   ),
                 },
           timestamp: DateTime.now(),
           auth: RulesAuth(
             uid: request.userId,
             isSuperUser: request.isSuperUser,
             token: request.bearerToken,
           ),
           headers: request.headers,
           method: request.method,
         ),
         'resource': oldResource == null
             ? null
             : switch (oldResource) {
                 Document doc => DocumentResource(
                   data: doc.data,
                   id: doc.id,
                   collection: doc.collection,
                 ),
                 DbFile file => FileResource(
                   file: file,
                   bucket: file.bucket,
                   id: file.id,
                 ),
                 _ => throw VaneStackException(
                   'Invalid oldResource provided for rules evaluation.',
                   code: ServerErrorCode.unknownError,
                 ),
               },
       },
       _database = request.database,
       _collectionsCache = request.collectionsCache;

  Future<Collection?> _getCollection(String collectionName) async {
    return _collectionsCache.resolve(collectionName, _database);
  }

  Future<Map<String, dynamic>?> _getDocument(
    String collection,
    String documentId,
  ) async {
    final cacheKey = (collection, documentId);
    final cachedValue = _docCache.get(cacheKey);
    if (cachedValue != null) {
      return cachedValue;
    }

    final collectionInfo = await _getCollection(collection);

    if (collectionInfo == null) {
      return null;
    }

    final result = await _database
        .customSelect(
          _database.adaptPlaceholders(
            'SELECT * from "$collection" WHERE id = ? LIMIT 1',
          ),
          variables: [Variable<String>(documentId)],
        )
        .getSingleOrNull();

    if (result == null) {
      return null;
    }

    final data = CollectionUtils.decodeFromDb(collectionInfo, result.data);

    _docCache.set(cacheKey, data);

    return data;
  }

  Future<bool> _existsDocument(String collection, String documentId) async {
    final cacheKey = (collection, documentId);

    final cachedValue = _existsCache.get(cacheKey);
    if (cachedValue != null) {
      return cachedValue;
    }

    final result = await _database
        .customSelect(
          _database.adaptPlaceholders(
            'SELECT * from "$collection" WHERE id = ? LIMIT 1',
          ),
          variables: [Variable<String>(documentId)],
        )
        .getSingleOrNull();

    _existsCache.set((collection, documentId), result != null);

    return result != null;
  }

  /// [oldResource] may be overriden here for list evaluations so we don't have to recreate the engine
  Future<bool> evaluate(String rule, {Resource? oldResource}) async {
    final expr = _expressionCache[rule] ??= Expression.parse(rule);

    Stream result = _evaluator.eval(expr, {
      ..._context,
      if (oldResource != null)
        'resource': switch (oldResource) {
          Document doc => DocumentResource(
            data: doc.data,
            id: doc.id,
            collection: doc.collection,
          ),
          DbFile file => FileResource(
            file: file,
            bucket: file.bucket,
            id: file.id,
          ),
          _ => throw VaneStackException(
            'Invalid oldResource provided for rules evaluation.',
            code: ServerErrorCode.unknownError,
          ),
        },
      'get': _getDocument,
      'exists': _existsDocument,
    });

    return result.first.then((v) => v == true);
  }
}

class RulesRequest {
  final RulesResource? resource;
  final DateTime timestamp;
  final RulesAuth auth;
  final Map<String, String> headers;
  final String method;
  final String path;
  final String context;

  RulesRequest({
    this.resource,
    required this.timestamp,
    required this.auth,
    required this.headers,
    required this.method,
    required this.path,
    required this.context,
  });
}

sealed class RulesResource {
  final String id;

  const RulesResource({required this.id});
}

class DocumentResource extends RulesResource {
  final String collection;
  final Map<String, dynamic> data;

  const DocumentResource({
    required this.data,
    required this.collection,
    required super.id,
  });
}

class FileResource extends RulesResource {
  final String bucket;
  final DbFile file;

  const FileResource({
    required this.file,
    required this.bucket,
    required super.id,
  });
}

class RulesAuth {
  final String? uid;
  final bool isSuperUser;
  final String? token;

  RulesAuth({this.uid, required this.isSuperUser, this.token});
}
