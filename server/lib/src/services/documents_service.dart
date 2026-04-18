import 'dart:io';

import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';
import 'package:vanestack_common/vanestack_common.dart';

import '../database/database.dart';
import '../realtime/realtime.dart';
import '../utils/collection.dart';
import '../utils/collection_data.dart';
import '../utils/filter_parser.dart';
import '../utils/logger.dart';
import '../utils/order_clause_parser.dart';
import 'context.dart';
import 'hooks.dart';

/// Service class for document CRUD operations.
///
/// This service handles raw document operations without permission checks.
/// Permission checks should be handled by the calling code (endpoints).
///
/// Can be used by:
/// - HTTP endpoints (with permission checks)
/// - CLI commands
/// - Public API (`vanestack.documents.create()`, etc.)
class DocumentsService {
  final ServiceContext context;

  DocumentsService(this.context);

  AppDatabase get db => context.database;
  RealtimeEventBus? get realtime => context.realtime;

  /// Creates a document in a collection.
  ///
  /// Throws [VaneStackException] if:
  /// - Collection not found
  /// - Collection is a view (read-only)
  /// - Validation fails
  Future<Document> create({
    required String collectionName,
    required Map<String, Object?> data,
    bool emitEvent = true,
  }) async {
    final collectionData =
        await (db.collections.select()
              ..where((tbl) => tbl.name.equals(collectionName)))
            .getSingleOrNull();

    if (collectionData == null) {
      throw VaneStackException(
        'Collection not found.',
        status: HttpStatus.notFound,
        code: DocumentsErrorCode.collectionNotFound,
      );
    }

    final collection = collectionData.toModel();

    if (collection is ViewCollection) {
      throw VaneStackException(
        'Cannot create documents in view collections. Views are read-only.',
        status: HttpStatus.forbidden,
        code: DocumentsErrorCode.viewIsReadOnly,
      );
    }

    final baseCollection = collection as BaseCollection;

    try {
      CollectionUtils.validateCreate(baseCollection, data);
    } on FormatException catch (e) {
      throw VaneStackException(
        'Validation failed: ${e.message}',
        status: HttpStatus.badRequest,
        code: DocumentsErrorCode.validationFailed,
      );
    }

    if (context.hooks != null) {
      final e = BeforeDocumentCreateEvent(
        collectionName: collectionName,
        data: data,
      );
      await context.hooks!.runBeforeDocumentCreate(e);
      collectionName = e.collectionName;
      data = e.data;
    }

    collectionsLogger.debug(
      'Creating document',
      context: 'collection=$collectionName',
    );

    final timestamp = DateTime.now();
    final newDoc = Document(
      id: data['id'] as String? ?? const Uuid().v7(),
      collection: baseCollection.name,
      createdAt: timestamp,
      updatedAt: timestamp,
      data: {...data}..remove('id'),
    );

    final encodedData = CollectionUtils.documentToRow(baseCollection, newDoc);

    await db.customStatement(
      db.adaptPlaceholders(
        'INSERT INTO "$collectionName" (${encodedData.keys.map((k) => '"$k"').join(', ')}) VALUES (${List.filled(encodedData.length, '?').join(', ')})',
      ),
      [...encodedData.values],
    );

    if (emitEvent && realtime != null) {
      realtime!.emit(
        DocumentTransport(
          collection: baseCollection,
          event: DocumentCreatedEvent(
            channels: [
              '${baseCollection.name}.*',
              '${baseCollection.name}.*.created',
              '${baseCollection.name}.${newDoc.id}',
              '${baseCollection.name}.${newDoc.id}.created',
            ],
            document: newDoc,
          ),
        ),
      );
    }

    collectionsLogger.info(
      'Document created',
      context: 'collection=$collectionName, id=${newDoc.id}',
    );

    if (context.hooks != null) {
      await context.hooks!.runAfterDocumentCreate(
        AfterDocumentCreateEvent(
          collectionName: collectionName,
          result: newDoc,
        ),
      );
    }

    return newDoc;
  }

  /// Gets a document by ID.
  ///
  /// Returns `null` if document not found.
  ///
  /// Throws [VaneStackException] if:
  /// - Collection not found
  Future<Document?> get({
    required String collectionName,
    required String documentId,
  }) async {
    final collectionData =
        await (db.collections.select()
              ..where((tbl) => tbl.name.equals(collectionName)))
            .getSingleOrNull();

    if (collectionData == null) {
      throw VaneStackException(
        'Collection not found.',
        status: HttpStatus.notFound,
        code: DocumentsErrorCode.collectionNotFound,
      );
    }

    final collection = collectionData.toModel();

    final row = await db
        .customSelect(
          db.adaptPlaceholders(
            'SELECT * from "$collectionName" WHERE id = ? LIMIT 1',
          ),
          variables: [Variable<String>(documentId)],
        )
        .getSingleOrNull();

    if (row == null) {
      return null;
    }

    return CollectionUtils.toDocument(collection, row.data);
  }

  /// Lists documents in a collection.
  Future<ListDocumentsResult> list({
    required String collectionName,
    String? filter,
    String? orderBy,
    int limit = 10,
    int offset = 0,
  }) async {
    final collectionData =
        await (db.collections.select()
              ..where((tbl) => tbl.name.equals(collectionName)))
            .getSingleOrNull();

    if (collectionData == null) {
      throw VaneStackException(
        'Collection not found.',
        status: HttpStatus.notFound,
        code: DocumentsErrorCode.collectionNotFound,
      );
    }

    final collection = collectionData.toModel();

    // Build allowed fields from collection attributes + built-in fields
    final allowedFields = <String>{
      'id',
      'created_at',
      'updated_at',
      ...collection.attributes.map((a) => a.name),
    };

    String? whereClause;
    List<Object?>? paramValues;
    if (filter != null) {
      (whereClause, paramValues) = FilterParser(
        filter,
        allowedFields: allowedFields,
      ).parse();
      if (whereClause.isNotEmpty) {
        whereClause = ' WHERE $whereClause';
      } else {
        whereClause = null;
      }
    }

    String? orderClause;
    if (orderBy != null) {
      final (sql, _) = OrderClauseParser(
        orderBy,
        allowedFields: allowedFields,
      ).parse();
      orderClause = sql.isNotEmpty ? ' $sql' : null;
    }

    final result = await db
        .customSelect(
          db.adaptPlaceholders(
            'SELECT * from "$collectionName"${whereClause ?? ''}${orderClause ?? ''} LIMIT ? OFFSET ?',
          ),
          variables: [
            ...?paramValues?.map((value) => Variable(value)),
            Variable<int>(limit),
            Variable<int>(offset),
          ],
        )
        .get();

    final count = await db
        .customSelect(
          db.adaptPlaceholders(
            'SELECT COUNT(*) as count from "$collectionName"${whereClause ?? ''}',
          ),
          variables: [...?paramValues?.map((value) => Variable(value))],
        )
        .getSingle()
        .then((row) => row.read<int>('count'));

    final documents = [
      ...result.map((row) => CollectionUtils.toDocument(collection, row.data)),
    ];

    return ListDocumentsResult(documents: documents, count: count);
  }

  /// Updates a document.
  ///
  /// Throws [VaneStackException] if:
  /// - Collection not found
  /// - Collection is a view (read-only)
  /// - Document not found
  /// - Validation fails
  Future<Document> update({
    required String collectionName,
    required String documentId,
    required Map<String, Object?> data,
    bool emitEvent = true,
  }) async {
    final collectionData =
        await (db.collections.select()
              ..where((tbl) => tbl.name.equals(collectionName)))
            .getSingleOrNull();

    if (collectionData == null) {
      throw VaneStackException(
        'Collection not found.',
        status: HttpStatus.notFound,
        code: DocumentsErrorCode.collectionNotFound,
      );
    }

    final collection = collectionData.toModel();

    if (collection is ViewCollection) {
      throw VaneStackException(
        'Cannot update documents in view collections. Views are read-only.',
        status: HttpStatus.forbidden,
        code: DocumentsErrorCode.viewIsReadOnly,
      );
    }

    final baseCollection = collection as BaseCollection;

    try {
      CollectionUtils.validateUpdate(baseCollection, data);
    } on FormatException catch (e) {
      throw VaneStackException(
        'Validation failed: ${e.message}',
        status: HttpStatus.badRequest,
        code: DocumentsErrorCode.validationFailed,
      );
    }

    final existingDoc = await db
        .customSelect(
          db.adaptPlaceholders(
            'SELECT * from "$collectionName" WHERE id = ?',
          ),
          variables: [Variable<String>(documentId)],
        )
        .getSingleOrNull();

    if (existingDoc == null) {
      throw VaneStackException(
        'Document not found.',
        status: HttpStatus.notFound,
        code: DocumentsErrorCode.documentNotFound,
      );
    }

    collectionsLogger.debug(
      'Updating document',
      context: 'collection=$collectionName, id=$documentId',
    );

    if (context.hooks != null) {
      final e = BeforeDocumentUpdateEvent(
        collectionName: collectionName,
        documentId: documentId,
        data: data,
      );
      await context.hooks!.runBeforeDocumentUpdate(e);
      data = e.data;
    }

    final oldDoc = CollectionUtils.toDocument(baseCollection, existingDoc.data);

    final timestamp = DateTime.now();
    final newDoc = oldDoc.copyWith(
      updatedAt: timestamp,
      data: {...oldDoc.data, ...data}..remove('id'),
    );

    final encodedData = CollectionUtils.documentToRow(baseCollection, newDoc);

    await db.customStatement(
      db.adaptPlaceholders(
        'UPDATE "$collectionName" SET ${encodedData.keys.map((k) => '"$k" = ?').join(', ')} WHERE "id" = ?',
      ),
      [...encodedData.values, documentId],
    );

    if (emitEvent && realtime != null) {
      realtime!.emit(
        DocumentTransport(
          collection: baseCollection,
          event: DocumentUpdatedEvent(
            channels: [
              '${baseCollection.name}.*',
              '${baseCollection.name}.*.updated',
              '${baseCollection.name}.$documentId',
              '${baseCollection.name}.$documentId.updated',
            ],
            oldDocument: oldDoc,
            newDocument: newDoc,
          ),
        ),
      );
    }

    collectionsLogger.info(
      'Document updated',
      context: 'collection=$collectionName, id=$documentId',
    );

    if (context.hooks != null) {
      await context.hooks!.runAfterDocumentUpdate(
        AfterDocumentUpdateEvent(
          collectionName: collectionName,
          result: newDoc,
        ),
      );
    }

    return newDoc;
  }

  /// Deletes a document.
  ///
  /// Throws [VaneStackException] if:
  /// - Collection not found
  /// - Collection is a view (read-only)
  /// - Document not found
  Future<void> delete({
    required String collectionName,
    required String documentId,
    bool emitEvent = true,
  }) async {
    final collectionData =
        await (db.collections.select()
              ..where((tbl) => tbl.name.equals(collectionName)))
            .getSingleOrNull();

    if (collectionData == null) {
      throw VaneStackException(
        'Collection not found.',
        status: HttpStatus.notFound,
        code: DocumentsErrorCode.collectionNotFound,
      );
    }

    final collection = collectionData.toModel();

    if (collection is ViewCollection) {
      throw VaneStackException(
        'Cannot delete documents from view collections. Views are read-only.',
        status: HttpStatus.forbidden,
        code: DocumentsErrorCode.viewIsReadOnly,
      );
    }

    final baseCollection = collection as BaseCollection;

    final row = await db
        .customSelect(
          db.adaptPlaceholders(
            'SELECT * from "$collectionName" WHERE id = ? LIMIT 1',
          ),
          variables: [Variable<String>(documentId)],
        )
        .getSingleOrNull();

    if (row == null) {
      throw VaneStackException(
        'Document not found.',
        status: HttpStatus.notFound,
        code: DocumentsErrorCode.documentNotFound,
      );
    }

    final document = CollectionUtils.toDocument(baseCollection, row.data);

    collectionsLogger.debug(
      'Deleting document',
      context: 'collection=$collectionName, id=$documentId',
    );

    if (context.hooks != null) {
      final e = BeforeDocumentDeleteEvent(
        collectionName: collectionName,
        documentId: documentId,
      );
      await context.hooks!.runBeforeDocumentDelete(e);
    }

    await db.customUpdate(
      db.adaptPlaceholders('DELETE FROM "$collectionName" WHERE id = ?'),
      variables: [Variable<String>(documentId)],
    );

    if (emitEvent && realtime != null) {
      realtime!.emit(
        DocumentTransport(
          collection: baseCollection,
          event: DocumentDeletedEvent(
            channels: [
              '${baseCollection.name}.*',
              '${baseCollection.name}.*.deleted',
              document.id,
              '${baseCollection.name}.${document.id}.deleted',
            ],
            document: document,
          ),
        ),
      );
    }

    collectionsLogger.info(
      'Document deleted',
      context: 'collection=$collectionName, id=$documentId',
    );

    if (context.hooks != null) {
      await context.hooks!.runAfterDocumentDelete(
        AfterDocumentDeleteEvent(
          collectionName: collectionName,
          documentId: documentId,
        ),
      );
    }
  }
}
