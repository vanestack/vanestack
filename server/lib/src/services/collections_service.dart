import 'dart:io';

import 'package:vanestack_common/vanestack_common.dart';
import 'package:drift/drift.dart' hide Index;
import 'package:faker/faker.dart';
import 'package:uuid/uuid.dart';

import '../database/database.dart';
import '../utils/collection.dart';
import '../utils/collection_data.dart';
import '../utils/logger.dart';
import '../utils/tables.dart';
import 'context.dart';
import 'hooks.dart';

/// Service class for collection operations.
///
/// This service handles collection CRUD operations including DDL.
///
/// Can be used by:
/// - HTTP endpoints
/// - CLI commands
/// - Public API (`vanestack.collections.create()`, etc.)
class CollectionsService {
  final ServiceContext context;

  CollectionsService(this.context);

  AppDatabase get db => context.database;

  // ==================== Read Operations ====================

  /// Gets a collection by name.
  ///
  /// Returns `null` if collection not found.
  Future<Collection?> getByName(String name) async {
    if (name.isEmpty) {
      throw VaneStackException(
        'Collection name is required.',
        status: HttpStatus.badRequest,
      );
    }

    if (!isValidIdentifier(name)) {
      throw VaneStackException(
        'Invalid collection name: "$name". Collection names must be valid identifiers.',
        status: HttpStatus.badRequest,
      );
    }

    final collection = await db.managers.collections
        .filter((t) => t.name.equals(name))
        .getSingleOrNull();

    return collection?.toModel();
  }

  /// Lists all collections with optional pagination.
  Future<List<Collection>> list({int? limit = 10, int? offset = 0}) async {
    final query = db.collections.select();

    if (limit != null && limit > 0) {
      query.limit(limit, offset: offset ?? 0);
    }

    final results = await query.get();
    return results.map((data) => data.toModel()).toList();
  }

  /// Checks if a collection exists.
  Future<bool> exists(String name) async {
    if (!isValidIdentifier(name)) return false;

    final count = await db.collections
        .count(where: (t) => t.name.equals(name))
        .getSingle();

    return count > 0;
  }

  /// Gets the count of all collections.
  Future<int> count() async {
    return db.collections.count().getSingle();
  }

  /// Exports all collections.
  Future<ExportResponse> export() async {
    final collectionsData = await db.managers.collections.get();
    final collections = collectionsData.map((data) => data.toModel()).toList();

    return ExportResponse(
      collections: collections,
      exportedAt: DateTime.now(),
      version: '1.0',
    );
  }

  // ==================== Create Operations ====================

  /// Creates a new base collection with table, triggers, and indexes.
  ///
  /// Throws [VaneStackException] if:
  /// - Name is empty or invalid
  /// - No attributes provided
  /// - System column override attempted
  Future<BaseCollection> createBase({
    required String name,
    List<Attribute> attributes = const [],
    List<Index> indexes = const [],
    String? listRule,
    String? viewRule,
    String? createRule,
    String? updateRule,
    String? deleteRule,
  }) async {
    if (name.isEmpty) {
      throw VaneStackException(
        'Collection name is required.',
        status: HttpStatus.badRequest,
      );
    }

    if (!isValidIdentifier(name)) {
      throw VaneStackException(
        'Invalid collection name: "$name". Collection names must be valid identifiers.',
        status: HttpStatus.badRequest,
      );
    }

    if (attributes.isEmpty) {
      throw VaneStackException(
        'At least one attribute is required for base collections.',
        status: HttpStatus.badRequest,
      );
    }

    // Protect system columns from user modification
    const systemColumns = ['id', 'created_at', 'updated_at'];
    for (final attr in attributes) {
      if (systemColumns.contains(attr.name)) {
        throw VaneStackException(
          'Cannot override system column "${attr.name}". System columns (id, created_at, updated_at) are automatically managed.',
          status: HttpStatus.badRequest,
        );
      }
    }

    if (context.hooks != null) {
      final e = BeforeCollectionCreateEvent(name: name, attributes: attributes);
      await context.hooks!.runBeforeCollectionCreate(e);
      name = e.name;
      attributes = e.attributes;
    }

    // Add system columns to attributes list for storage
    final allAttributes = [
      TextAttribute(
        name: 'id',
        nullable: false,
        primaryKey: true,
        defaultValue: '(random_uuid_v7())',
      ),
      DateAttribute(
        name: 'created_at',
        nullable: false,
        defaultValue: '(unixepoch())',
      ),
      DateAttribute(
        name: 'updated_at',
        nullable: false,
        defaultValue: '(unixepoch())',
      ),
      ...attributes,
    ];

    collectionsLogger.debug('Creating base collection', context: 'name=$name');

    final createTableSQL = _buildCreateTableSQL(name, attributes);

    // Validate index columns before creating indexes
    for (final index in indexes) {
      _validateIndexColumns(index, allAttributes);
    }

    // Wrap all DDL operations in a transaction for atomicity
    final result = await db.transaction(() async {
      await db.customStatement(createTableSQL);
      await db.customStatement(_buildTriggersSQL(name));

      // Create indexes if provided
      if (indexes.isNotEmpty) {
        for (final index in indexes) {
          final indexSQL = _buildCreateIndexSQL(name, index);
          await db.customStatement(indexSQL);
        }
      }

      return await db.collections.insertReturning(
        CollectionsCompanion.insert(
          name: name,
          type: const Value('base'),
          listRule: Value(listRule),
          viewRule: Value(viewRule),
          createRule: Value(createRule),
          updateRule: Value(updateRule),
          deleteRule: Value(deleteRule),
          attributes: Value(allAttributes),
          indexes: Value(indexes),
        ),
      );
    });

    final baseCollection = result.toModel() as BaseCollection;

    collectionsLogger.info('Base collection created', context: 'name=$name');

    if (context.hooks != null) {
      await context.hooks!.runAfterCollectionCreate(
        AfterCollectionCreateEvent(result: baseCollection),
      );
    }

    return baseCollection;
  }

  /// Creates a new view collection.
  ///
  /// Throws [VaneStackException] if:
  /// - Name is empty or invalid
  /// - viewQuery is empty or invalid
  /// - Write rules are provided
  /// - View query doesn't include 'id' column
  Future<ViewCollection> createView({
    required String name,
    required String viewQuery,
    String? listRule,
    String? viewRule,
  }) async {
    if (name.isEmpty) {
      throw VaneStackException(
        'Collection name is required.',
        status: HttpStatus.badRequest,
      );
    }

    if (!isValidIdentifier(name)) {
      throw VaneStackException(
        'Invalid collection name: "$name". Collection names must be valid identifiers.',
        status: HttpStatus.badRequest,
      );
    }

    if (viewQuery.trim().isEmpty) {
      throw VaneStackException(
        'viewQuery is required for view collections.',
        status: HttpStatus.badRequest,
      );
    }

    // Validate viewQuery is a SELECT statement
    _validateViewQuery(viewQuery);

    collectionsLogger.debug('Creating view collection', context: 'name=$name');

    if (context.hooks != null) {
      final e = BeforeCollectionCreateEvent(name: name, attributes: const []);
      await context.hooks!.runBeforeCollectionCreate(e);
      name = e.name;
    }

    // Wrap all operations in a transaction
    final result = await db.transaction(() async {
      // Create the view
      final createViewSQL = 'CREATE VIEW "$name" AS $viewQuery';
      try {
        await db.customStatement(createViewSQL);
      } on Exception catch (e, st) {
        collectionsLogger.error('Failed to create view "$name"', error: e, stackTrace: st);
        throw VaneStackException(
          'Failed to create view: ${e.toString()}',
          status: HttpStatus.badRequest,
        );
      }

      // Infer attributes from view schema using PRAGMA table_info
      final attributes = await _inferAttributesFromView(name, viewQuery);

      // Verify view has an id column
      final hasIdColumn = attributes.any((attr) => attr.name == 'id');
      if (!hasIdColumn) {
        // Drop the view we just created since it's invalid
        await db.customStatement('DROP VIEW "$name"');
        throw VaneStackException(
          'View query must include an "id" column in the result.',
          status: HttpStatus.badRequest,
        );
      }

      return await db.collections.insertReturning(
        CollectionsCompanion.insert(
          name: name,
          type: const Value('view'),
          viewQuery: Value(viewQuery),
          listRule: Value(listRule),
          viewRule: Value(viewRule),
          attributes: Value(attributes),
        ),
      );
    });

    final viewCollection = result.toModel() as ViewCollection;

    collectionsLogger.info('View collection created', context: 'name=$name');

    if (context.hooks != null) {
      await context.hooks!.runAfterCollectionCreate(
        AfterCollectionCreateEvent(result: viewCollection),
      );
    }

    return viewCollection;
  }

  // ==================== Update Operations ====================

  /// Updates a base collection's schema and/or rules.
  ///
  /// Throws [VaneStackException] if collection not found or validation fails.
  Future<BaseCollection> updateBase({
    required String name,
    String? newName,
    List<Attribute>? attributes,
    List<Index>? indexes,
    String? listRule,
    String? viewRule,
    String? createRule,
    String? updateRule,
    String? deleteRule,
  }) async {
    if (name.isEmpty) {
      throw VaneStackException(
        'Collection name is required.',
        status: HttpStatus.badRequest,
      );
    }

    if (!isValidIdentifier(name)) {
      throw VaneStackException(
        'Invalid collection name: "$name". Collection names must be valid identifiers.',
        status: HttpStatus.badRequest,
      );
    }

    if (newName != null && newName != name && !isValidIdentifier(newName)) {
      throw VaneStackException(
        'Invalid new collection name: "$newName". Collection names must be valid identifiers.',
        status: HttpStatus.badRequest,
      );
    }

    if (attributes != null && attributes.isEmpty) {
      throw VaneStackException(
        'At least one attribute is required.',
        status: HttpStatus.badRequest,
      );
    }

    // Protect system columns from user modification
    if (attributes != null) {
      const systemColumns = ['id', 'created_at', 'updated_at'];
      for (final attr in attributes) {
        if (systemColumns.contains(attr.name)) {
          throw VaneStackException(
            'Cannot override system column "${attr.name}". System columns (id, created_at, updated_at) are automatically managed.',
            status: HttpStatus.badRequest,
          );
        }
      }
    }

    // Check if collection exists
    final existingData = await db.managers.collections
        .filter((t) => t.name.equals(name))
        .getSingleOrNull();

    if (existingData == null) {
      throw VaneStackException(
        'Collection "$name" does not exist.',
        status: HttpStatus.notFound,
      );
    }

    final existing = existingData.toModel();
    if (existing is! BaseCollection) {
      throw VaneStackException(
        'Collection "$name" is not a base collection.',
        status: HttpStatus.badRequest,
      );
    }

    // Check if table exists
    final tableExists = await _tableExists(name);
    if (!tableExists) {
      throw VaneStackException(
        'Collection "$name" does not exist.',
        status: HttpStatus.notFound,
      );
    }

    collectionsLogger.debug('Updating base collection', context: 'name=$name');

    if (context.hooks != null) {
      final e = BeforeCollectionUpdateEvent(name: name);
      await context.hooks!.runBeforeCollectionUpdate(e);
    }

    // Wrap all operations in a transaction for atomicity
    return await db.transaction(() async {
      if (newName != null && newName != name) {
        await db.customStatement(
          'DROP TRIGGER IF EXISTS "${name}_update_timestamp";',
        );
        await db.customStatement('ALTER TABLE "$name" RENAME TO "$newName"');
        await db.customStatement(_buildTriggersSQL(newName));
      }

      final effectiveTableName = newName ?? name;

      // Get existing columns and indexes
      final existingColumns = await _getTableColumns(effectiveTableName);
      final existingIndexes = await _getTableIndexes(effectiveTableName);

      final systemColumns = [
        TextAttribute(
          name: 'id',
          nullable: false,
          primaryKey: true,
          defaultValue: '(random_uuid_v7())',
        ),
        DateAttribute(
          name: 'created_at',
          nullable: false,
          defaultValue: '(unixepoch())',
        ),
        DateAttribute(
          name: 'updated_at',
          nullable: false,
          defaultValue: '(unixepoch())',
        ),
      ];

      final userAttrs = attributes ?? [];
      final allAttributes = [
        ...systemColumns.where(
          (sys) => !userAttrs.any((user) => user.name == sys.name),
        ),
        ...userAttrs,
      ];

      // Update columns if provided
      if (attributes != null) {
        await _updateColumns(
          effectiveTableName,
          existingColumns,
          allAttributes,
          existing.attributes,
        );
      }

      // Update indexes if provided
      if (indexes != null) {
        // Validate index columns before updating indexes
        for (final index in indexes) {
          _validateIndexColumns(index, allAttributes);
        }
        await _updateIndexes(effectiveTableName, existingIndexes, indexes);
      }

      await db.customStatement(_buildTriggersSQL(effectiveTableName));

      await db.managers.collections
          .filter((t) => t.name.equals(name))
          .update(
            (t) => t(
              name: Value(effectiveTableName),
              updatedAt: Value(DateTime.now()),
              listRule: Value(listRule),
              viewRule: Value(viewRule),
              createRule: Value(createRule),
              updateRule: Value(updateRule),
              deleteRule: Value(deleteRule),
              attributes: Value.absentIfNull(
                attributes != null ? allAttributes : null,
              ),
              indexes: Value.absentIfNull(indexes),
            ),
          );

      final updatedCollection = await db.managers.collections
          .filter((t) => t.name.equals(effectiveTableName))
          .getSingle();

      final updatedBase = updatedCollection.toModel() as BaseCollection;

      collectionsLogger.info('Base collection updated', context: 'name=${updatedBase.name}');

      if (context.hooks != null) {
        await context.hooks!.runAfterCollectionUpdate(
          AfterCollectionUpdateEvent(result: updatedBase),
        );
      }

      return updatedBase;
    });
  }

  /// Updates a view collection's query and/or rules.
  ///
  /// Throws [VaneStackException] if collection not found or validation fails.
  Future<ViewCollection> updateView({
    required String name,
    String? newName,
    String? viewQuery,
    String? listRule,
    String? viewRule,
  }) async {
    if (name.isEmpty) {
      throw VaneStackException(
        'Collection name is required.',
        status: HttpStatus.badRequest,
      );
    }

    if (!isValidIdentifier(name)) {
      throw VaneStackException(
        'Invalid collection name: "$name". Collection names must be valid identifiers.',
        status: HttpStatus.badRequest,
      );
    }

    // Get existing collection
    final existingData = await db.managers.collections
        .filter((t) => t.name.equals(name))
        .getSingleOrNull();

    if (existingData == null) {
      throw VaneStackException(
        'Collection "$name" does not exist.',
        status: HttpStatus.notFound,
      );
    }

    final existing = existingData.toModel();
    if (existing is! ViewCollection) {
      throw VaneStackException(
        'Collection "$name" is not a view collection.',
        status: HttpStatus.badRequest,
      );
    }

    final effectiveName = newName ?? name;
    final effectiveViewQuery = viewQuery ?? existing.viewQuery;

    // Validate new viewQuery if provided
    if (viewQuery != null) {
      _validateViewQuery(viewQuery);
    }

    collectionsLogger.debug('Updating view collection', context: 'name=$name');

    if (context.hooks != null) {
      final e = BeforeCollectionUpdateEvent(name: name);
      await context.hooks!.runBeforeCollectionUpdate(e);
    }

    return await db.transaction(() async {
      // If viewQuery changed or name changed, we need to recreate the view
      if (viewQuery != null || (newName != null && newName != name)) {
        // Drop the old view
        await db.customStatement('DROP VIEW "$name"');

        // Create the new view
        try {
          await db.customStatement(
            'CREATE VIEW "$effectiveName" AS $effectiveViewQuery',
          );
        } on Exception catch (e, st) {
          collectionsLogger.error('Failed to recreate view "$effectiveName"', error: e, stackTrace: st);
          // Try to restore the old view if creation fails
          await db.customStatement(
            'CREATE VIEW "$name" AS ${existing.viewQuery}',
          );
          throw VaneStackException(
            'Failed to create view: ${e.toString()}',
            status: HttpStatus.badRequest,
          );
        }

        // Re-infer attributes from the new view
        final newAttributes = await _inferAttributesFromView(
          effectiveName,
          effectiveViewQuery,
        );

        // Verify new view has an id column
        final hasIdColumn = newAttributes.any((attr) => attr.name == 'id');
        if (!hasIdColumn) {
          // Drop the invalid view and restore the old one
          await db.customStatement('DROP VIEW "$effectiveName"');
          await db.customStatement(
            'CREATE VIEW "$name" AS ${existing.viewQuery}',
          );
          throw VaneStackException(
            'View query must include an "id" column in the result.',
            status: HttpStatus.badRequest,
          );
        }

        // Update the metadata
        await db.managers.collections
            .filter((t) => t.name.equals(name))
            .update(
              (t) => t(
                name: Value(effectiveName),
                updatedAt: Value(DateTime.now()),
                listRule: Value(listRule),
                viewRule: Value(viewRule),
                viewQuery: Value(effectiveViewQuery),
                attributes: Value(newAttributes),
              ),
            );
      } else {
        // Only updating rules, no view changes
        await db.managers.collections
            .filter((t) => t.name.equals(name))
            .update(
              (t) => t(
                updatedAt: Value(DateTime.now()),
                listRule: Value(listRule),
                viewRule: Value(viewRule),
              ),
            );
      }

      final updatedCollection = await db.managers.collections
          .filter((t) => t.name.equals(effectiveName))
          .getSingle();

      final updatedView = updatedCollection.toModel() as ViewCollection;

      collectionsLogger.info('View collection updated', context: 'name=${updatedView.name}');

      if (context.hooks != null) {
        await context.hooks!.runAfterCollectionUpdate(
          AfterCollectionUpdateEvent(result: updatedView),
        );
      }

      return updatedView;
    });
  }

  // ==================== Delete Operations ====================

  /// Deletes a collection (table/view and metadata).
  ///
  /// Throws [VaneStackException] if:
  /// - Collection not found
  /// - Base collection has dependent views
  Future<void> delete(String name) async {
    if (name.isEmpty) {
      throw VaneStackException(
        'Collection name is required.',
        status: HttpStatus.badRequest,
      );
    }

    if (!isValidIdentifier(name)) {
      throw VaneStackException(
        'Invalid collection name: "$name". Collection names must be valid identifiers.',
        status: HttpStatus.badRequest,
      );
    }

    // Check if collection exists
    final collectionData = await db.managers.collections
        .filter((t) => t.name.equals(name))
        .getSingleOrNull();

    if (collectionData == null) {
      throw VaneStackException(
        'Collection "$name" not found.',
        status: HttpStatus.notFound,
      );
    }

    final collection = collectionData.toModel();

    // For base collections, check for dependent views before deleting
    if (collection is BaseCollection) {
      final dependentViews = await _findDependentViews(name);
      if (dependentViews.isNotEmpty) {
        throw VaneStackException(
          'Cannot delete collection "$name" because it is referenced by view collection(s): ${dependentViews.join(", ")}. Delete the dependent views first.',
          status: HttpStatus.conflict,
        );
      }
    }

    collectionsLogger.debug('Deleting collection', context: 'name=$name');

    if (context.hooks != null) {
      final e = BeforeCollectionDeleteEvent(name: name);
      await context.hooks!.runBeforeCollectionDelete(e);
    }

    // Wrap delete operations in a transaction
    await db.transaction(() async {
      if (collection is ViewCollection) {
        // Drop the view
        await db.customStatement('DROP VIEW "$name"');
      } else {
        // Drop the trigger and table for base collections
        await db.customStatement(
          'DROP TRIGGER IF EXISTS "${name}_update_timestamp";',
        );
        await db.customStatement('DROP TABLE "$name"');
      }

      // Remove from collections metadata
      await db.collections.deleteWhere((tbl) => tbl.name.equals(name));
    });

    collectionsLogger.info('Collection deleted', context: 'name=$name');

    if (context.hooks != null) {
      await context.hooks!.runAfterCollectionDelete(
        AfterCollectionDeleteEvent(name: name),
      );
    }
  }

  // ==================== Import Operations ====================

  /// Imports collections from a list of collection data.
  ///
  /// Returns import results with created, updated, skipped, and errors.
  Future<ImportResponse> import({
    required List<Map<String, dynamic>> collections,
    bool overwrite = false,
  }) async {
    final created = <String>[];
    final updated = <String>[];
    final skipped = <String>[];
    final errors = <ImportError>[];

    await db.transaction(() async {
      collectionLoop:
      for (final collectionData in collections) {
        try {
          // Parse collection from map
          final collection = CollectionMapper.fromJson(collectionData);

          // Check if collection already exists
          final existing = await db.managers.collections
              .filter((t) => t.name.equals(collection.name))
              .getSingleOrNull();

          if (existing != null && !overwrite) {
            skipped.add(collection.name);
            continue;
          }

          // Validate collection name
          if (!isValidIdentifier(collection.name)) {
            errors.add(
              ImportError(
                collection: collection.name,
                error:
                    'Invalid collection name. Collection names must be valid identifiers.',
              ),
            );
            continue;
          }

          // Protect system columns for base collections only
          if (collection is BaseCollection) {
            const systemColumns = ['id', 'created_at', 'updated_at'];
            for (final attr in collection.attributes) {
              if (systemColumns.contains(attr.name)) {
                errors.add(
                  ImportError(
                    collection: collection.name,
                    error:
                        'Cannot override system column "${attr.name}". System columns (id, created_at, updated_at) are automatically managed.',
                  ),
                );
                continue collectionLoop;
              }
            }
          }

          // Validate view collections have viewQuery
          if (collection is ViewCollection) {
            if (collection.viewQuery.trim().isEmpty) {
              errors.add(
                ImportError(
                  collection: collection.name,
                  error: 'View collections must have a viewQuery.',
                ),
              );
              continue collectionLoop;
            }
          }

          if (existing != null && overwrite) {
            // Update existing collection
            await _importUpdateCollection(collection);
            updated.add(collection.name);
          } else {
            // Create new collection
            await _importCreateCollection(collection);
            created.add(collection.name);
          }
        } catch (e) {
          errors.add(
            ImportError(
              collection: collectionData['name']?.toString() ?? 'unknown',
              error: e.toString(),
            ),
          );
        }
      }
    });

    return ImportResponse(
      created: created,
      updated: updated,
      skipped: skipped,
      errors: errors,
      importedAt: DateTime.now(),
    );
  }

  // ==================== Generate Operations ====================

  /// Generates fake documents for a collection.
  ///
  /// Throws [VaneStackException] if:
  /// - Count is out of range (1-1000)
  /// - Collection not found or is a view
  Future<GenerateResponse> generate({
    required String collectionName,
    required int count,
  }) async {
    if (count < 1 || count > 1000) {
      throw VaneStackException(
        'Count must be between 1 and 1000.',
        status: HttpStatus.badRequest,
      );
    }

    final adminCollections = db.allTables.map((e) => e.actualTableName).toSet();
    if (adminCollections.contains(collectionName)) {
      throw VaneStackException(
        'Access to internal collections is denied.',
        status: HttpStatus.forbidden,
      );
    }

    final collectionData =
        await (db.collections.select()
              ..where((tbl) => tbl.name.equals(collectionName)))
            .getSingleOrNull();

    if (collectionData == null) {
      throw VaneStackException(
        'Collection not found.',
        status: HttpStatus.notFound,
      );
    }

    final collection = collectionData.toModel();

    // Block generate for view collections
    if (collection is ViewCollection) {
      throw VaneStackException(
        'Cannot generate documents for view collections. Views are read-only.',
        status: HttpStatus.forbidden,
      );
    }

    final baseCollection = collection as BaseCollection;

    final faker = Faker();
    final uuid = const Uuid();
    final created = await db.transaction(() async {
      var createdCount = 0;

      for (var i = 0; i < count; i++) {
        final timestamp = DateTime.now();
        final data = _generateFakeData(baseCollection.attributes, faker);

        final newDoc = Document(
          id: uuid.v7(),
          collection: baseCollection.name,
          createdAt: timestamp,
          updatedAt: timestamp,
          data: data,
        );

        final encodedData = CollectionUtils.documentToRow(
          baseCollection,
          newDoc,
        );

        await db.customInsert(
          'INSERT INTO "$collectionName" (${encodedData.keys.map((k) => '"$k"').join(', ')}) VALUES (${List.filled(encodedData.length, '?').join(', ')})',
          variables: [...encodedData.values.map((value) => Variable(value))],
        );

        createdCount++;
      }

      return createdCount;
    });

    return GenerateResponse(count: created);
  }

  // ==================== Private Helper Methods ====================

  /// Validates that all columns referenced in an index exist in the attributes list.
  void _validateIndexColumns(Index index, List<Attribute> attributes) {
    final attributeNames = attributes.map((a) => a.name).toSet();

    for (final column in index.columns) {
      if (!attributeNames.contains(column)) {
        throw VaneStackException(
          'Index "${index.name}" references non-existent column "$column".',
          status: HttpStatus.badRequest,
        );
      }
    }
  }

  void _validateViewQuery(String query) {
    final normalized = query.trim().toUpperCase();

    // Must start with SELECT
    if (!normalized.startsWith('SELECT')) {
      throw VaneStackException(
        'View query must be a SELECT statement.',
        status: HttpStatus.badRequest,
      );
    }

    // Cannot contain dangerous keywords
    const dangerousKeywords = [
      'INSERT',
      'UPDATE',
      'DELETE',
      'DROP',
      'CREATE',
      'ALTER',
      'TRUNCATE',
      'GRANT',
      'REVOKE',
      'ATTACH',
      'PRAGMA',
      'WITH',
      'LOAD',
    ];

    for (final keyword in dangerousKeywords) {
      final pattern = RegExp(r'\b' + keyword + r'\b', caseSensitive: false);
      if (pattern.hasMatch(query)) {
        throw VaneStackException(
          'View query cannot contain $keyword statements.',
          status: HttpStatus.badRequest,
        );
      }
    }

    // Cannot contain semicolons (no multiple statements)
    if (query.contains(';')) {
      throw VaneStackException(
        'View query cannot contain semicolons (no multiple statements allowed).',
        status: HttpStatus.badRequest,
      );
    }
  }

  Future<List<Attribute>> _inferAttributesFromView(
    String viewName,
    String viewQuery,
  ) async {
    final result = await db
        .customSelect('PRAGMA table_info("$viewName")')
        .get();

    // Try to resolve semantic types from the base collection
    final baseAttrMap = await _resolveBaseAttributes(viewQuery);

    final attributes = <Attribute>[];

    for (final row in result) {
      final name = row.read<String>('name');
      final type = row.read<String>('type').toUpperCase();
      final notNull = row.read<int>('notnull') == 1;
      final nullable = !notNull;

      // If the base collection has this column, use its semantic type
      final baseAttr = baseAttrMap[name];
      if (baseAttr != null) {
        final attribute = switch (baseAttr) {
          TextAttribute() => TextAttribute(name: name, nullable: nullable),
          IntAttribute() => IntAttribute(name: name, nullable: nullable),
          DoubleAttribute() => DoubleAttribute(name: name, nullable: nullable),
          BoolAttribute() => BoolAttribute(name: name, nullable: nullable),
          DateAttribute() => DateAttribute(name: name, nullable: nullable),
          JsonAttribute() => JsonAttribute(name: name, nullable: nullable),
        };
        attributes.add(attribute);
      } else {
        attributes.add(_sqliteTypeToAttribute(name, type, nullable));
      }
    }

    return attributes;
  }

  /// Extracts the source table name from a view query's FROM clause
  /// and returns a map of column names to their semantic [Attribute] types.
  Future<Map<String, Attribute>> _resolveBaseAttributes(
    String viewQuery,
  ) async {
    final match = RegExp(
      r'FROM\s+"?(\w+)"?',
      caseSensitive: false,
    ).firstMatch(viewQuery);

    if (match == null) return {};

    final tableName = match.group(1)!;

    final collectionData = await db.managers.collections
        .filter((t) => t.name.equals(tableName))
        .getSingleOrNull();

    if (collectionData == null) return {};

    final collection = collectionData.toModel();
    final attrMap = <String, Attribute>{};
    for (final attr in collection.attributes) {
      attrMap[attr.name] = attr;
    }
    return attrMap;
  }

  Attribute _sqliteTypeToAttribute(String name, String sqlType, bool nullable) {
    if (sqlType.contains('INT')) {
      return IntAttribute(name: name, nullable: nullable);
    } else if (sqlType.contains('CHAR') ||
        sqlType.contains('CLOB') ||
        sqlType.contains('TEXT')) {
      return TextAttribute(name: name, nullable: nullable);
    } else if (sqlType.contains('BLOB') || sqlType.isEmpty) {
      return TextAttribute(name: name, nullable: nullable);
    } else if (sqlType.contains('REAL') ||
        sqlType.contains('FLOA') ||
        sqlType.contains('DOUB')) {
      return DoubleAttribute(name: name, nullable: nullable);
    } else {
      return TextAttribute(name: name, nullable: nullable);
    }
  }

  Future<List<String>> _findDependentViews(String tableName) async {
    // Get all view collections
    final viewCollections = await db.managers.collections
        .filter((t) => t.type.equals('view'))
        .get();

    final dependentViews = <String>[];

    for (final viewData in viewCollections) {
      final view = viewData.toModel();
      if (view is ViewCollection) {
        final queryUpper = view.viewQuery.toUpperCase();
        final tableNameUpper = tableName.toUpperCase();

        final pattern = RegExp(r'\b' + tableNameUpper + r'\b');
        if (pattern.hasMatch(queryUpper)) {
          dependentViews.add(view.name);
        }
      }
    }

    return dependentViews;
  }

  String _buildTriggersSQL(String tableName) {
    return '''
      CREATE TRIGGER IF NOT EXISTS "${tableName}_update_timestamp"
      AFTER UPDATE ON "$tableName"
      FOR EACH ROW
      BEGIN
        UPDATE "$tableName"
        SET updated_at = unixepoch()
        WHERE rowid = NEW.rowid;
      END;
    ''';
  }

  static const _validForeignKeyActions = {
    'CASCADE',
    'RESTRICT',
    'SET NULL',
    'NO ACTION',
    'SET DEFAULT',
  };

  /// Validates a foreign key action against a safe allowlist.
  void _validateForeignKeyAction(String? action, String context) {
    if (action == null) return;
    if (!_validForeignKeyActions.contains(action.toUpperCase())) {
      throw VaneStackException(
        'Invalid foreign key $context action: "$action". '
        'Allowed values: ${_validForeignKeyActions.join(', ')}',
        status: HttpStatus.badRequest,
      );
    }
  }

  /// Validates a CHECK constraint only contains safe characters.
  void _validateCheckConstraint(String constraint) {
    // Allow alphanumeric, spaces, parens, comparison operators, logical operators, quotes for literals
    final safe = RegExp(
      r'''^[a-zA-Z0-9_\s()><=!.'",%@\-+*/]+$''',
    );
    if (!safe.hasMatch(constraint)) {
      throw VaneStackException(
        'Invalid check constraint: contains disallowed characters.',
        status: HttpStatus.badRequest,
      );
    }

    // Block dangerous SQL keywords in check constraints
    final normalized = constraint.toUpperCase();
    const blocked = ['DROP', 'DELETE', 'INSERT', 'UPDATE', 'ALTER', 'CREATE', 'ATTACH', 'PRAGMA'];
    for (final keyword in blocked) {
      if (RegExp(r'\b' + keyword + r'\b').hasMatch(normalized)) {
        throw VaneStackException(
          'Check constraint cannot contain $keyword.',
          status: HttpStatus.badRequest,
        );
      }
    }
  }

  /// Escapes single quotes in a default value string.
  String _escapeDefaultValue(String value) {
    return value.replaceAll("'", "''");
  }

  String _buildCreateTableSQL(String tableName, List<Attribute> columns) {
    final columnDefs = <String>[];
    final primaryKeys = <String>[];

    final hasId = columns.any((c) => c.name == 'id');
    final hasCreatedAt = columns.any((c) => c.name == 'created_at');
    final hasUpdatedAt = columns.any((c) => c.name == 'updated_at');

    if (!hasId) {
      columnDefs.add(
        '"id" TEXT NOT NULL PRIMARY KEY DEFAULT (random_uuid_v7())',
      );
    }

    if (!hasCreatedAt) {
      columnDefs.add('"created_at" INTEGER NOT NULL DEFAULT (unixepoch())');
    }

    if (!hasUpdatedAt) {
      columnDefs.add('"updated_at" INTEGER NOT NULL DEFAULT (unixepoch())');
    }

    for (final col in columns) {
      final name = col.name;
      final type = _sqlType(col);
      final nullable = col.nullable;
      final unique = col.unique;
      final primaryKey = col.primaryKey;
      final defaultValue = col.defaultValue;
      final checkConstraint = col.checkConstraint;
      final foreignKey = col.foreignKey;

      if (!isValidIdentifier(name)) {
        throw Exception('Invalid attribute name: $name');
      }

      final parts = <String>['"$name"', type.toUpperCase()];

      if (primaryKey) {
        primaryKeys.add(name);
      }

      if (!nullable) {
        parts.add('NOT NULL');
      }

      if (unique && !primaryKey) {
        parts.add('UNIQUE');
      }

      if (defaultValue != null) {
        if (defaultValue is String &&
            !defaultValue.startsWith('(') &&
            !defaultValue.endsWith(')')) {
          parts.add("DEFAULT '${_escapeDefaultValue(defaultValue)}'");
        } else {
          parts.add('DEFAULT $defaultValue');
        }
      }

      if (checkConstraint != null) {
        _validateCheckConstraint(checkConstraint);
        parts.add('CHECK ($checkConstraint)');
      }

      if (foreignKey != null) {
        if (!isValidIdentifier(foreignKey.table)) {
          throw Exception(
            'Invalid foreign key table name: ${foreignKey.table}',
          );
        }
        if (!isValidIdentifier(foreignKey.column)) {
          throw Exception(
            'Invalid foreign key column name: ${foreignKey.column}',
          );
        }

        _validateForeignKeyAction(foreignKey.onDelete, 'ON DELETE');
        _validateForeignKeyAction(foreignKey.onUpdate, 'ON UPDATE');

        final fkParts = [
          'REFERENCES "${foreignKey.table}"("${foreignKey.column}")',
        ];

        if (foreignKey.onDelete != null) {
          fkParts.add('ON DELETE ${foreignKey.onDelete}');
        }

        if (foreignKey.onUpdate != null) {
          fkParts.add('ON UPDATE ${foreignKey.onUpdate}');
        }

        parts.add(fkParts.join(' '));
      }

      columnDefs.add(parts.join(' '));
    }

    if (primaryKeys.isNotEmpty && !primaryKeys.contains('id')) {
      final pkList = primaryKeys.map((pk) => '"$pk"').join(', ');
      columnDefs.add('PRIMARY KEY ($pkList)');
    }

    return 'CREATE TABLE IF NOT EXISTS "$tableName" (${columnDefs.join(', ')})';
  }

  String _buildCreateIndexSQL(String tableName, Index index) {
    final indexName = index.name;
    final columns = index.columns;
    final unique = index.unique ?? false;
    final ifNotExists = index.ifNotExists ?? true;

    if (!isValidIdentifier(indexName)) {
      throw Exception('Invalid index name: $indexName');
    }

    for (final col in columns) {
      if (!isValidIdentifier(col)) {
        throw Exception('Invalid column name in index: $col');
      }
    }

    final uniqueClause = unique ? 'UNIQUE ' : '';
    final ifNotExistsClause = ifNotExists ? 'IF NOT EXISTS ' : '';
    final columnList = columns.map((col) => '"$col"').join(', ');

    return 'CREATE ${uniqueClause}INDEX $ifNotExistsClause"$indexName" ON "$tableName" ($columnList)';
  }

  String _sqlType(Attribute attribute) {
    return switch (attribute) {
      TextAttribute() => 'TEXT',
      IntAttribute() => 'INTEGER',
      DoubleAttribute() => 'REAL',
      BoolAttribute() => 'INTEGER',
      DateAttribute() => 'INTEGER',
      JsonAttribute() => 'TEXT',
    };
  }

  Future<bool> _tableExists(String tableName) async {
    final result = await db
        .customSelect(
          "SELECT name FROM sqlite_master WHERE type='table' AND name=?",
          variables: [Variable.withString(tableName)],
        )
        .get();
    return result.isNotEmpty;
  }

  Future<Map<String, _ColumnInfo>> _getTableColumns(String tableName) async {
    final result = await db
        .customSelect('PRAGMA table_info("$tableName")')
        .get();
    final columns = <String, _ColumnInfo>{};

    for (final row in result) {
      final name = row.read<String>('name');
      columns[name] = _ColumnInfo(
        name: name,
        type: row.read<String>('type'),
        notNull: row.read<int>('notnull') == 1,
        defaultValue: row.read<String?>('dflt_value'),
        primaryKey: row.read<int>('pk') > 0,
      );
    }

    return columns;
  }

  Future<Map<String, _IndexInfo>> _getTableIndexes(String tableName) async {
    final result = await db
        .customSelect('PRAGMA index_list("$tableName")')
        .get();
    final indexes = <String, _IndexInfo>{};

    for (final row in result) {
      final indexName = row.read<String>('name');
      final unique = row.read<int>('unique') == 1;

      // Get columns for this index
      final indexInfo = await db
          .customSelect('PRAGMA index_info("$indexName")')
          .get();

      final columns = <String>[];
      for (final info in indexInfo) {
        columns.add(info.read<String>('name'));
      }

      if (indexName.startsWith('sqlite_autoindex_')) {
        continue; // Skip autoindexes
      }

      indexes[indexName] = _IndexInfo(
        name: indexName,
        columns: columns,
        unique: unique,
      );
    }

    return indexes;
  }

  Future<void> _updateColumns(
    String tableName,
    Map<String, _ColumnInfo> existingColumns,
    List<Attribute> newColumns,
    List<Attribute>? existingAttributes,
  ) async {
    final newColumnNames = newColumns.map((c) => c.name).toSet();
    const systemColumnNames = {'id', 'created_at', 'updated_at'};

    // Build a map of existing attributes for quick lookup
    final existingAttrMap = <String, Attribute>{};
    if (existingAttributes != null) {
      for (final attr in existingAttributes) {
        existingAttrMap[attr.name] = attr;
      }
    }

    final columnsToAdd = <Attribute>[];
    final columnsToModify = <Attribute>[];

    for (final col in newColumns) {
      if (!isValidIdentifier(col.name)) {
        throw Exception('Invalid attribute name: ${col.name}');
      }

      final existing = existingColumns[col.name];
      final existingAttr = existingAttrMap[col.name];

      if (existing == null) {
        columnsToAdd.add(col);
      } else {
        if (_columnNeedsModification(existing, col, existingAttr)) {
          columnsToModify.add(col);
        }
      }
    }

    final columnsToRemove = existingColumns.keys
        .where((name) => !newColumnNames.contains(name))
        .toList();

    if (columnsToRemove.isNotEmpty || columnsToModify.isNotEmpty) {
      await _recreateTableWithNewSchema(
        tableName,
        existingColumns,
        columnsToRemove,
        newColumns,
      );
    } else {
      for (final col in columnsToAdd) {
        final statement = _buildAddColumnSQL(tableName, col);
        await db.customStatement(statement);
      }
    }

    for (final sysCol in systemColumnNames) {
      if (!existingColumns.containsKey(sysCol)) {
        final col = newColumns.firstWhere((c) => c.name == sysCol);
        final statement = _buildAddColumnSQL(tableName, col);
        await db.customStatement(statement);
      }
    }
  }

  bool _columnNeedsModification(
    _ColumnInfo existing,
    Attribute newCol,
    Attribute? existingAttr,
  ) {
    final newType = _sqlType(newCol);
    if (existing.type.toUpperCase() != newType.toUpperCase()) {
      return true;
    }

    if (existing.notNull != !newCol.nullable) {
      return true;
    }

    // Check unique constraint (using stored attribute metadata)
    if (existingAttr != null && existingAttr.unique != newCol.unique) {
      return true;
    }

    // Check foreign key changes
    if (existingAttr != null) {
      final existingFk = existingAttr.foreignKey;
      final newFk = newCol.foreignKey;

      if ((existingFk == null) != (newFk == null)) {
        return true;
      }

      if (existingFk != null && newFk != null) {
        if (existingFk.table != newFk.table ||
            existingFk.column != newFk.column ||
            existingFk.onDelete != newFk.onDelete ||
            existingFk.onUpdate != newFk.onUpdate) {
          return true;
        }
      }
    }

    // Check constraint changes
    if (existingAttr != null &&
        existingAttr.checkConstraint != newCol.checkConstraint) {
      return true;
    }

    // Check default value changes
    final existingDefault = existing.defaultValue;
    final newDefault = newCol.defaultValue?.toString();

    if ((existingDefault == null) != (newDefault == null)) {
      return true;
    }

    if (existingDefault != null && newDefault != null) {
      // Normalize: SQLite may store 'value' while we have value
      final normalizedExisting = existingDefault.replaceAll("'", '');
      final normalizedNew = newDefault.replaceAll("'", '');
      if (normalizedExisting != normalizedNew) {
        return true;
      }
    }

    return false;
  }

  Future<void> _updateIndexes(
    String tableName,
    Map<String, _IndexInfo> existingIndexes,
    List<Index> newIndexes,
  ) async {
    final newIndexNames = newIndexes.map((i) => i.name).toSet();

    for (final index in newIndexes) {
      if (!isValidIdentifier(index.name)) {
        throw Exception('Invalid index name: ${index.name}');
      }

      for (final col in index.columns) {
        if (!isValidIdentifier(col)) {
          throw Exception('Invalid attribute name in index: $col');
        }
      }

      final existing = existingIndexes[index.name];

      if (existing == null) {
        await db.customStatement(_buildCreateIndexSQL(tableName, index));
      } else {
        if (_indexNeedsUpdate(existing, index)) {
          await db.customStatement('DROP INDEX "${index.name}"');
          await db.customStatement(_buildCreateIndexSQL(tableName, index));
        }
      }
    }

    final indexesToRemove = existingIndexes.keys
        .where((name) => !newIndexNames.contains(name))
        .toList();

    for (final indexName in indexesToRemove) {
      await db.customStatement('DROP INDEX "$indexName"');
    }
  }

  bool _indexNeedsUpdate(_IndexInfo existing, Index newIndex) {
    if (existing.unique != (newIndex.unique ?? false)) {
      return true;
    }

    if (existing.columns.length != newIndex.columns.length) {
      return true;
    }

    for (var i = 0; i < existing.columns.length; i++) {
      if (existing.columns[i] != newIndex.columns[i]) {
        return true;
      }
    }

    return false;
  }

  String _buildAddColumnSQL(String tableName, Attribute column) {
    final name = column.name;
    final type = _sqlType(column);
    final nullable = column.nullable;
    final defaultValue = column.defaultValue;

    final parts = <String>['"$name"', type.toUpperCase()];

    if (!nullable) {
      parts.add('NOT NULL');
    }

    if (defaultValue != null) {
      if (defaultValue is String &&
          !defaultValue.startsWith('(') &&
          !defaultValue.endsWith(')')) {
        parts.add("DEFAULT '${_escapeDefaultValue(defaultValue)}'");
      } else {
        parts.add('DEFAULT $defaultValue');
      }
    }

    return 'ALTER TABLE "$tableName" ADD COLUMN ${parts.join(' ')}';
  }

  Future<void> _recreateTableWithNewSchema(
    String tableName,
    Map<String, _ColumnInfo> existingColumns,
    List<String> columnsToRemove,
    List<Attribute> newColumns,
  ) async {
    final tempTableName =
        '${tableName}_temp_${DateTime.now().millisecondsSinceEpoch}';

    final columnsToKeep = existingColumns.keys
        .where((name) => !columnsToRemove.contains(name))
        .toList();

    if (columnsToKeep.isEmpty && newColumns.isEmpty) {
      throw Exception('Cannot remove all attributes from collection.');
    }

    final columnDefs = <String>[];
    final primaryKeys = <String>[];

    for (final col in newColumns) {
      final name = col.name;
      final type = _sqlType(col);
      final nullable = col.nullable;
      final unique = col.unique;
      final primaryKey = col.primaryKey;
      final defaultValue = col.defaultValue;
      final checkConstraint = col.checkConstraint;
      final foreignKey = col.foreignKey;

      final parts = <String>['"$name"', type.toUpperCase()];

      if (primaryKey) {
        primaryKeys.add(name);
      }

      if (!nullable) {
        parts.add('NOT NULL');
      }

      if (unique && !primaryKey) {
        parts.add('UNIQUE');
      }

      if (defaultValue != null) {
        if (defaultValue is String &&
            !defaultValue.startsWith('(') &&
            !defaultValue.endsWith(')')) {
          parts.add("DEFAULT '${_escapeDefaultValue(defaultValue)}'");
        } else {
          parts.add('DEFAULT $defaultValue');
        }
      }

      if (checkConstraint != null) {
        _validateCheckConstraint(checkConstraint);
        parts.add('CHECK ($checkConstraint)');
      }

      if (foreignKey != null) {
        if (!isValidIdentifier(foreignKey.table)) {
          throw Exception(
            'Invalid foreign key table name: ${foreignKey.table}',
          );
        }
        if (!isValidIdentifier(foreignKey.column)) {
          throw Exception(
            'Invalid foreign key column name: ${foreignKey.column}',
          );
        }

        _validateForeignKeyAction(foreignKey.onDelete, 'ON DELETE');
        _validateForeignKeyAction(foreignKey.onUpdate, 'ON UPDATE');

        final fkParts = [
          'REFERENCES "${foreignKey.table}"("${foreignKey.column}")',
        ];

        if (foreignKey.onDelete != null) {
          fkParts.add('ON DELETE ${foreignKey.onDelete}');
        }

        if (foreignKey.onUpdate != null) {
          fkParts.add('ON UPDATE ${foreignKey.onUpdate}');
        }

        parts.add(fkParts.join(' '));
      }

      columnDefs.add(parts.join(' '));
    }

    if (primaryKeys.isNotEmpty) {
      final pkList = primaryKeys.map((pk) => '"$pk"').join(', ');
      columnDefs.add('PRIMARY KEY ($pkList)');
    }

    await db.customStatement(
      'CREATE TABLE "$tempTableName" (${columnDefs.join(', ')})',
    );

    if (columnsToKeep.isNotEmpty) {
      final columnList = columnsToKeep.map((c) => '"$c"').join(', ');
      await db.customStatement(
        'INSERT INTO "$tempTableName" ($columnList) SELECT $columnList FROM "$tableName"',
      );
    }

    await db.customStatement('DROP TABLE "$tableName"');
    await db.customStatement(
      'ALTER TABLE "$tempTableName" RENAME TO "$tableName"',
    );
  }

  // Import helper methods
  Future<void> _importCreateCollection(Collection collection) async {
    switch (collection) {
      case BaseCollection():
        await _importCreateBaseCollection(collection);
      case ViewCollection():
        await _importCreateViewCollection(collection);
    }
  }

  Future<void> _importCreateBaseCollection(BaseCollection collection) async {
    // Validate index columns before creating indexes
    for (final index in collection.indexes) {
      _validateIndexColumns(index, collection.attributes);
    }

    final createTableSQL = _buildCreateTableSQL(
      collection.name,
      collection.attributes,
    );

    await db.customStatement(createTableSQL);
    await db.customStatement(_buildTriggersSQL(collection.name));

    if (collection.indexes.isNotEmpty) {
      for (final index in collection.indexes) {
        final indexSQL = _buildCreateIndexSQL(collection.name, index);
        await db.customStatement(indexSQL);
      }
    }

    await db.collections.insertReturning(
      CollectionsCompanion.insert(
        name: collection.name,
        type: const Value('base'),
        listRule: Value(collection.listRule),
        viewRule: Value(collection.viewRule),
        createRule: Value(collection.createRule),
        updateRule: Value(collection.updateRule),
        deleteRule: Value(collection.deleteRule),
        attributes: Value(collection.attributes),
        indexes: Value(collection.indexes),
      ),
    );
  }

  Future<void> _importCreateViewCollection(ViewCollection collection) async {
    await db.customStatement(
      'CREATE VIEW "${collection.name}" AS ${collection.viewQuery}',
    );

    await db.collections.insertReturning(
      CollectionsCompanion.insert(
        name: collection.name,
        type: const Value('view'),
        viewQuery: Value(collection.viewQuery),
        listRule: Value(collection.listRule),
        viewRule: Value(collection.viewRule),
        attributes: Value(collection.attributes),
        indexes: const Value([]),
      ),
    );
  }

  Future<void> _importUpdateCollection(Collection collection) async {
    switch (collection) {
      case BaseCollection():
        await _importUpdateBaseCollection(collection);
      case ViewCollection():
        await _importUpdateViewCollection(collection);
    }
  }

  Future<void> _importUpdateBaseCollection(BaseCollection collection) async {
    // Validate index columns before creating indexes
    for (final index in collection.indexes) {
      _validateIndexColumns(index, collection.attributes);
    }

    await db.customStatement(
      'DROP TRIGGER IF EXISTS "${collection.name}_update_timestamp";',
    );
    await db.customStatement('DROP TABLE IF EXISTS "${collection.name}"');

    final createTableSQL = _buildCreateTableSQL(
      collection.name,
      collection.attributes,
    );

    await db.customStatement(createTableSQL);
    await db.customStatement(_buildTriggersSQL(collection.name));

    if (collection.indexes.isNotEmpty) {
      for (final index in collection.indexes) {
        final indexSQL = _buildCreateIndexSQL(collection.name, index);
        await db.customStatement(indexSQL);
      }
    }

    await db.managers.collections
        .filter((t) => t.name.equals(collection.name))
        .update(
          (t) => t(
            updatedAt: Value(DateTime.now()),
            type: const Value('base'),
            listRule: Value(collection.listRule),
            viewRule: Value(collection.viewRule),
            createRule: Value(collection.createRule),
            updateRule: Value(collection.updateRule),
            deleteRule: Value(collection.deleteRule),
            attributes: Value(collection.attributes),
            indexes: Value(collection.indexes),
          ),
        );
  }

  Future<void> _importUpdateViewCollection(ViewCollection collection) async {
    await db.customStatement('DROP VIEW IF EXISTS "${collection.name}"');

    await db.customStatement(
      'CREATE VIEW "${collection.name}" AS ${collection.viewQuery}',
    );

    await db.managers.collections
        .filter((t) => t.name.equals(collection.name))
        .update(
          (t) => t(
            updatedAt: Value(DateTime.now()),
            type: const Value('view'),
            viewQuery: Value(collection.viewQuery),
            listRule: Value(collection.listRule),
            viewRule: Value(collection.viewRule),
            attributes: Value(collection.attributes),
            indexes: const Value([]),
          ),
        );
  }

  // Generate helper methods
  Map<String, Object?> _generateFakeData(
    List<Attribute> attributes,
    Faker faker,
  ) {
    final data = <String, Object?>{};

    for (final attr in attributes) {
      if (['id', 'created_at', 'updated_at'].contains(attr.name)) {
        continue;
      }

      data[attr.name] = _generateValueForAttribute(attr, faker);
    }

    return data;
  }

  Object? _generateValueForAttribute(Attribute attr, Faker faker) {
    if (attr.nullable && faker.randomGenerator.boolean()) {
      return null;
    }

    final name = attr.name.toLowerCase();

    return switch (attr) {
      TextAttribute() => _generateTextValue(name, faker),
      IntAttribute() => _generateIntValue(name, faker),
      DoubleAttribute() => faker.randomGenerator.decimal(scale: 1000, min: 0),
      BoolAttribute() => faker.randomGenerator.boolean(),
      DateAttribute() => faker.date.dateTime(
        minYear: 1980,
        maxYear: DateTime.now().year,
      ),
      JsonAttribute() => _generateJsonValue(faker),
    };
  }

  String _generateTextValue(String fieldName, Faker faker) {
    if (fieldName.contains('email')) {
      return faker.internet.email();
    }
    if (fieldName.contains('first') && fieldName.contains('name')) {
      return faker.person.firstName();
    }
    if (fieldName.contains('last') && fieldName.contains('name')) {
      return faker.person.lastName();
    }
    if (fieldName == 'name' || fieldName.contains('username')) {
      return faker.person.name();
    }
    if (fieldName.contains('phone') || fieldName.contains('tel')) {
      return faker.phoneNumber.us();
    }
    if (fieldName.contains('address') || fieldName.contains('street')) {
      return faker.address.streetAddress();
    }
    if (fieldName.contains('city')) {
      return faker.address.city();
    }
    if (fieldName.contains('country')) {
      return faker.address.country();
    }
    if (fieldName.contains('state') || fieldName.contains('province')) {
      return faker.address.state();
    }
    if (fieldName.contains('zip') || fieldName.contains('postal')) {
      return faker.address.zipCode();
    }
    if (fieldName.contains('title')) {
      return faker.lorem.sentence();
    }
    if (fieldName.contains('description') ||
        fieldName.contains('content') ||
        fieldName.contains('bio') ||
        fieldName.contains('summary')) {
      return faker.lorem.sentences(3).join(' ');
    }
    if (fieldName.contains('url') || fieldName.contains('website')) {
      return faker.internet.httpsUrl();
    }
    if (fieldName.contains('company') || fieldName.contains('organization')) {
      return faker.company.name();
    }
    if (fieldName.contains('job') || fieldName.contains('position')) {
      return faker.job.title();
    }
    if (fieldName.contains('color')) {
      return faker.color.color();
    }
    if (fieldName.contains('image') || fieldName.contains('avatar')) {
      return 'https://picsum.photos/seed/${faker.randomGenerator.integer(10000)}/200/200';
    }

    return faker.lorem
        .words(faker.randomGenerator.integer(3, min: 1))
        .join(' ');
  }

  int _generateIntValue(String fieldName, Faker faker) {
    if (fieldName.contains('age')) {
      return faker.randomGenerator.integer(80, min: 18);
    }
    if (fieldName.contains('year')) {
      return faker.randomGenerator.integer(2025, min: 1950);
    }
    if (fieldName.contains('quantity') || fieldName.contains('count')) {
      return faker.randomGenerator.integer(100, min: 1);
    }
    if (fieldName.contains('price') || fieldName.contains('amount')) {
      return faker.randomGenerator.integer(10000, min: 1);
    }
    if (fieldName.contains('rating') || fieldName.contains('score')) {
      return faker.randomGenerator.integer(5, min: 1);
    }

    return faker.randomGenerator.integer(1000);
  }

  Map<String, Object?> _generateJsonValue(Faker faker) {
    return {
      'key': faker.lorem.word(),
      'value': faker.lorem.sentence(),
      'count': faker.randomGenerator.integer(100),
    };
  }
}

// Private helper classes
class _ColumnInfo {
  final String name;
  final String type;
  final bool notNull;
  final String? defaultValue;
  final bool primaryKey;

  _ColumnInfo({
    required this.name,
    required this.type,
    required this.notNull,
    this.defaultValue,
    required this.primaryKey,
  });
}

class _IndexInfo {
  final String name;
  final List<String> columns;
  final bool unique;

  _IndexInfo({required this.name, required this.columns, required this.unique});
}
