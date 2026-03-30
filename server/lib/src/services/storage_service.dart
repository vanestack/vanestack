import 'dart:io' hide File;

import 'package:drift/drift.dart';
import 'package:path/path.dart' as p;
import 'package:uuid/uuid.dart';
import 'package:vanestack_common/vanestack_common.dart';

import '../database/database.dart';
import '../realtime/realtime.dart';
import '../storage/local_storage.dart';
import '../storage/s3_storage.dart';
import '../storage/storage.dart';
import '../utils/extensions.dart';
import '../utils/file_validator.dart';
import '../utils/filter_parser.dart';
import '../utils/logger.dart';
import '../utils/order_clause_parser.dart';
import '../utils/s3.dart';
import '../utils/validation.dart';
import 'context.dart';
import 'hooks.dart';

/// Service class for storage operations (buckets and files).
///
/// This service handles bucket CRUD, file metadata, and file storage operations.
///
/// Can be used by:
/// - HTTP endpoints
/// - CLI commands
/// - Public API (`vanestack.storage.createBucket()`, etc.)
class StorageService {
  final ServiceContext context;

  StorageService(this.context);

  AppDatabase get db => context.database;
  RealtimeEventBus? get realtime => context.realtime;

  /// Gets the appropriate storage backend based on app settings.
  ///
  /// If S3 is configured and enabled, returns S3 storage.
  /// Otherwise returns local storage (if enabled via environment).
  ///
  /// Use [forceLocal] to always use local storage regardless of settings.
  Future<Storage> getStorage({bool forceLocal = false}) async {
    final settings = await (db.appSettings.select()..limit(1))
        .getSingleOrNull();

    // Check if we should use S3
    if (!forceLocal && settings?.s3 != null && settings!.s3!.enabled) {
      return S3Storage(client: S3Client(settings.s3!));
    }

    // Check if local storage is enabled
    if (!context.env.localStorageEnabled) {
      throw VaneStackException(
        'Local storage is disabled and S3 is not configured.',
        status: HttpStatus.serviceUnavailable,
      );
    }

    return LocalStorage(folder: context.env.localStoragePath);
  }

  // ==================== Bucket Operations ====================

  /// Creates a new bucket.
  ///
  /// Throws [VaneStackException] if:
  /// - Bucket name is empty or invalid
  Future<Bucket> createBucket({
    required String name,
    String? listRule,
    String? viewRule,
    String? createRule,
    String? updateRule,
    String? deleteRule,
  }) async {
    if (name.isEmpty) {
      throw VaneStackException(
        'Bucket name is required.',
        status: HttpStatus.badRequest,
      );
    }

    if (!validateUrlFriendlyName(name)) {
      throw VaneStackException(
        'Bucket name must start with a lowercase letter and contain only lowercase letters, numbers and underscores.',
        status: HttpStatus.badRequest,
      );
    }

    storageLogger.debug('Creating bucket', context: 'name=$name');

    final result = await db.buckets.insertReturning(
      BucketsCompanion.insert(
        name: name,
        listRule: Value.absentIfNull(listRule),
        viewRule: Value.absentIfNull(viewRule),
        createRule: Value.absentIfNull(createRule),
        updateRule: Value.absentIfNull(updateRule),
        deleteRule: Value.absentIfNull(deleteRule),
      ),
    );

    storageLogger.info('Bucket created', context: 'name=$name');

    return result;
  }

  /// Gets a bucket by name.
  ///
  /// Returns `null` if bucket not found.
  Future<Bucket?> getBucket(String name) async {
    if (name.isEmpty) {
      throw VaneStackException(
        'Bucket name is required.',
        status: HttpStatus.badRequest,
      );
    }

    return (db.buckets.select()..where((t) => t.name.equals(name)))
        .getSingleOrNull();
  }

  /// Lists all buckets.
  Future<List<Bucket>> listBuckets() async {
    return db.buckets.select().get();
  }

  /// Updates a bucket.
  ///
  /// Throws [VaneStackException] if:
  /// - Bucket name is empty
  /// - New bucket name is invalid
  /// - Bucket not found
  Future<Bucket> updateBucket({
    required String name,
    String? newBucketName,
    String? listRule,
    String? viewRule,
    String? createRule,
    String? updateRule,
    String? deleteRule,
  }) async {
    if (name.isEmpty) {
      throw VaneStackException(
        'Bucket name is required.',
        status: HttpStatus.badRequest,
      );
    }

    if (newBucketName != null && !validateUrlFriendlyName(newBucketName)) {
      throw VaneStackException(
        'Bucket name must start with a lowercase letter and contain only lowercase letters, numbers and underscores.',
        status: HttpStatus.badRequest,
      );
    }

    final query = db.buckets.update()..where((b) => b.name.equals(name));
    final results = await query.writeReturning(
      BucketsCompanion(
        name: Value.absentIfNull(newBucketName),
        listRule: Value.absentIfNull(listRule),
        viewRule: Value.absentIfNull(viewRule),
        createRule: Value.absentIfNull(createRule),
        updateRule: Value.absentIfNull(updateRule),
        deleteRule: Value.absentIfNull(deleteRule),
      ),
    );

    if (results.isEmpty) {
      throw VaneStackException(
        'Bucket not found.',
        status: HttpStatus.notFound,
      );
    }

    if (newBucketName != null && newBucketName != name) {
      await (db.files.update()..where((b) => b.bucket.equals(name))).write(
        FilesCompanion(bucket: Value(newBucketName)),
      );
    }

    return results.first;
  }

  /// Deletes a bucket and all its files from the database.
  ///
  /// Note: This only deletes database records. To delete actual files
  /// from storage, use the endpoint handler which interacts with the
  /// Storage backend.
  Future<void> deleteBucket(String name) async {
    if (name.isEmpty) {
      throw VaneStackException(
        'Bucket name is required.',
        status: HttpStatus.badRequest,
      );
    }

    await db.buckets.deleteWhere((t) => t.name.equals(name));
    await db.files.deleteWhere((t) => t.bucket.equals(name));

    storageLogger.info('Bucket deleted', context: 'name=$name');
  }

  /// Gets all files in a bucket (for deletion purposes).
  Future<List<DbFile>> getFilesInBucket(String bucketName) async {
    return (db.files.select()..where((t) => t.bucket.equals(bucketName))).get();
  }

  // ==================== File Metadata Operations ====================

  /// Creates a file in the database.
  Future<void> createFile(DbFile file) async {
    await db.files.insertOne(file);
  }

  /// Gets a file by bucket and path.
  Future<DbFile?> getFileByPath({
    required String bucket,
    required String path,
  }) async {
    return (db.files.select()
          ..where((t) => t.bucket.equals(bucket) & t.path.equals(path)))
        .getSingleOrNull();
  }

  /// Gets a file by ID.
  Future<DbFile?> getFileById(String id) async {
    return (db.files.select()..where((t) => t.id.equals(id))).getSingleOrNull();
  }

  /// Gets a file by download token.
  Future<DbFile?> getFileByToken(String token) async {
    return (db.files.select()..where((t) => t.downloadToken.equals(token)))
        .getSingleOrNull();
  }

  /// Lists raw DbFile records in a bucket with optional filtering and pagination.
  Future<(List<DbFile> files, List<String> folders)> listFiles({
    required String bucket,
    String? path,
    String? filter,
    String? orderBy,
    int? limit = 10,
    int offset = 0,
  }) async {
    final bucketEntity = await getBucket(bucket);

    if (bucketEntity == null) {
      throw VaneStackException(
        'Bucket not found.',
        status: HttpStatus.notFound,
      );
    }

    final currentPath = path ?? '';
    final depth = currentPath.length + 1;

    final query = db.files.select();

    query.where(
      (t) => Expression.and([
        t.bucket.equals(bucket),
        t.path.like('%.create_folder').not(),
        t.path.like('$currentPath%'),
        t.path.substr(depth).like('%/%').not(),
      ]),
    );

    if (limit != null) {
      query.limit(limit, offset: offset);
    }

    if (orderBy != null) {
      final (_, clauses) = OrderClauseParser(orderBy).parse();

      query.orderBy([
        for (final clause in clauses)
          (t) => OrderingTerm(
            expression: t.columnsByName[clause.$1]!,
            mode: clause.$2 == 'ASC' ? OrderingMode.asc : OrderingMode.desc,
          ),
      ]);
    }

    final variables = <Object?>[];
    if (filter != null) {
      final (whereClause, paramValues) = FilterParser(
        filter,
        allowedFields: {
          'id',
          'path',
          'bucket',
          'size',
          'mime_type',
          'created_at',
        },
      ).parse();

      if (whereClause.isNotEmpty) {
        query.where((_) => CustomExpression<bool>(whereClause));
        variables.addAll(paramValues);
      }
    }

    final sqlQuery = query.constructQuery();

    final files = await db
        .customSelect(
          sqlQuery.sql,
          variables: [
            ...sqlQuery.introducedVariables,
            ...variables.map((value) => Variable(value)),
          ],
        )
        .map((row) => db.files.map(row.data))
        .get();

    // Get folders
    final folders = db.files.selectOnly(distinct: true);
    final folderName = db.files.path.substrExpr(
      Constant(depth),
      db.files.path.substr(depth).instrExpr(Constant('/')) - Constant(1),
    );

    folders.addColumns([folderName]);
    folders.where(
      Expression.and([
        db.files.bucket.equals(bucket),
        folderName.equals('.').not(),
        db.files.path.like('$currentPath%'),
        db.files.path.substr(depth).like('%/%'),
      ]),
    );

    if (limit != null) {
      folders.limit(limit, offset: offset);
    }

    final folderList = await folders.get();
    final folderNames =
        folderList.map((row) => row.read<String>(folderName)).nonNulls.toList()
          ..sort();

    return (files, folderNames);
  }

  // ==================== File Storage Operations ====================

  /// Uploads a file to storage and creates a database record.
  ///
  /// [bucket] - The bucket name to upload to.
  /// [path] - The destination path in the bucket.
  /// [filename] - The original filename (used for extension validation and MIME detection).
  /// [data] - The file data as a stream.
  /// [mimeType] - The MIME type of the file (defaults to application/octet-stream).
  /// [metadata] - Optional metadata to attach to the file.
  ///
  /// Returns the created file record.
  Future<DbFile> uploadFile({
    required String bucket,
    required String path,
    required String filename,
    required Stream<List<int>> data,
    String mimeType = 'application/octet-stream',
    Map<String, String>? metadata,
  }) async {
    // Validate bucket exists
    final bucketEntity = await getBucket(bucket);
    if (bucketEntity == null) {
      throw VaneStackException(
        'Bucket not found.',
        status: HttpStatus.notFound,
      );
    }

    storageLogger.debug(
      'Uploading file',
      context: 'bucket=$bucket, path=$path',
    );

    if (context.hooks != null) {
      final e = BeforeFileUploadEvent(
        bucket: bucket,
        path: path,
        mimeType: mimeType,
      );
      await context.hooks!.runBeforeFileUpload(e);
      bucket = e.bucket;
      path = e.path;
      mimeType = e.mimeType;
    }

    // Normalize and validate path
    final safePath = p.normalize(path);
    if (safePath.isEmpty ||
        p.isAbsolute(safePath) ||
        safePath.contains('..') ||
        safePath.startsWith('/')) {
      throw VaneStackException('Invalid path.', status: HttpStatus.badRequest);
    }

    // Block dangerous file extensions
    if (!FileValidator.isExtensionAllowed(filename)) {
      throw VaneStackException(
        'File type not allowed.',
        status: HttpStatus.badRequest,
      );
    }

    // Upload to storage
    final storage = await getStorage();
    final isLocal = storage is LocalStorage;

    await storage.put(bucket, safePath, data);

    try {
      final fileSize = await storage.getFileSize(bucket, safePath);
      final maxFileSize = context.env.maxFileSize;

      // Validate actual file size after upload
      if (fileSize > maxFileSize) {
        throw VaneStackException(
          'File size exceeds maximum allowed size of ${_formatBytes(maxFileSize)}.',
          status: HttpStatus.requestEntityTooLarge,
        );
      }

      // Validate file content matches claimed MIME type (magic bytes check)
      final fileContent = await storage.get(bucket, safePath);
      if (fileContent != null && fileContent.isNotEmpty) {
        final validationError = FileValidator.validate(
          filename: filename,
          claimedMimeType: mimeType,
          headerBytes: fileContent.length > 16
              ? fileContent.sublist(0, 16)
              : fileContent,
        );
        if (validationError != null) {
          throw VaneStackException(
            validationError,
            status: HttpStatus.badRequest,
          );
        }
      }

      // Update MIME type based on detected content
      final detectedMimeType = FileValidator.detectMimeType(
        filename,
        fileContent,
      );
      final finalMimeType = detectedMimeType != 'application/octet-stream'
          ? detectedMimeType
          : mimeType;

      // Create database record
      final timestamp = DateTime.now();
      final dbFile = DbFile(
        isLocal: isLocal,
        id: const Uuid().v7(),
        path: safePath,
        bucket: bucket,
        size: fileSize,
        mimeType: finalMimeType,
        downloadToken: const Uuid().v4(),
        metadata: metadata ?? {},
        createdAt: timestamp,
        updatedAt: timestamp,
      );

      await createFile(dbFile);

      storageLogger.info(
        'File uploaded',
        context: 'bucket=$bucket, path=$safePath, size=$fileSize',
      );

      if (realtime != null) {
        realtime!.emit(
          FileTransport(
            bucket: bucketEntity,
            file: dbFile,
            event: FileUploadedEvent(
              channels: [
                '${bucketEntity.name}.*',
                '${bucketEntity.name}.*.uploaded',
                '${bucketEntity.name}.${dbFile.id}',
                '${bucketEntity.name}.${dbFile.id}.uploaded',
              ],
              file: dbFile.toPublic(),
            ),
          ),
        );
      }

      if (context.hooks != null) {
        await context.hooks!.runAfterFileUpload(
          AfterFileUploadEvent(result: dbFile),
        );
      }

      return dbFile;
    } catch (e) {
      await storage.delete(bucket, safePath);
      rethrow;
    }
  }

  static String _formatBytes(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    if (bytes < 1024 * 1024 * 1024) {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    }
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
  }

  /// Moves a file to a new path in storage and updates the database record.
  ///
  /// [fileId] - The ID of the file to move.
  /// [destination] - The new path for the file.
  ///
  /// Returns the updated file record.
  Future<DbFile> moveFile({
    required String fileId,
    required String destination,
  }) async {
    final file = await getFileById(fileId);
    if (file == null) {
      throw VaneStackException('File not found.', status: HttpStatus.notFound);
    }

    // Normalize and validate destination
    final safeDest = p.normalize(destination);
    if (safeDest.isEmpty ||
        p.isAbsolute(safeDest) ||
        safeDest.contains('..') ||
        safeDest.startsWith('/')) {
      throw VaneStackException(
        'Invalid destination path.',
        status: HttpStatus.badRequest,
      );
    }

    // Move in storage
    final storage = await getStorage(forceLocal: file.isLocal);
    await storage.move(file.bucket, file.path, safeDest);

    // Update database record
    final updated = await (db.files.update()..where((t) => t.id.equals(fileId)))
        .writeReturning(
          FilesCompanion(
            path: Value(safeDest),
            updatedAt: Value(DateTime.now()),
          ),
        )
        .then((results) => results.firstOrNull);

    final result = updated ?? file.copyWith(path: safeDest);

    if (realtime != null) {
      final bucketEntity = await getBucket(file.bucket);
      if (bucketEntity != null) {
        realtime!.emit(
          FileTransport(
            bucket: bucketEntity,
            file: result,
            event: FileMovedEvent(
              channels: [
                '${bucketEntity.name}.*',
                '${bucketEntity.name}.*.moved',
                '${bucketEntity.name}.${file.id}',
                '${bucketEntity.name}.${file.id}.moved',
              ],
              file: result.toPublic(),
              oldPath: file.path,
            ),
          ),
        );
      }
    }

    return result;
  }

  /// Moves a file identified by bucket and path.
  Future<DbFile> moveFileByPath({
    required String bucket,
    required String path,
    required String destination,
  }) async {
    final file = await getFileByPath(bucket: bucket, path: path);
    if (file == null) {
      throw VaneStackException('File not found.', status: HttpStatus.notFound);
    }
    return moveFile(fileId: file.id, destination: destination);
  }

  /// Deletes a file from storage and removes the database record.
  ///
  /// [fileId] - The ID of the file to delete.
  Future<void> deleteFile(String fileId) async {
    final file = await getFileById(fileId);
    if (file == null) {
      throw VaneStackException('File not found.', status: HttpStatus.notFound);
    }

    if (context.hooks != null) {
      final e = BeforeFileDeleteEvent(fileId: fileId);
      await context.hooks!.runBeforeFileDelete(e);
    }

    // Delete from storage
    final storage = await getStorage(forceLocal: file.isLocal);
    await storage.delete(file.bucket, file.path);

    // Delete from database
    await db.files.deleteWhere((t) => t.id.equals(fileId));

    storageLogger.info(
      'File deleted',
      context: 'bucket=${file.bucket}, path=${file.path}',
    );

    if (realtime != null) {
      final bucketEntity = await getBucket(file.bucket);
      if (bucketEntity != null) {
        realtime!.emit(
          FileTransport(
            bucket: bucketEntity,
            file: file,
            event: FileDeletedEvent(
              channels: [
                '${bucketEntity.name}.*',
                '${bucketEntity.name}.*.deleted',
                '${bucketEntity.name}.${file.id}',
                '${bucketEntity.name}.${file.id}.deleted',
              ],
              file: file.toPublic(),
            ),
          ),
        );
      }
    }

    if (context.hooks != null) {
      await context.hooks!.runAfterFileDelete(
        AfterFileDeleteEvent(fileId: fileId),
      );
    }
  }

  /// Deletes a file identified by bucket and path from storage and database.
  Future<void> deleteFileByPath({
    required String bucket,
    required String path,
  }) async {
    final file = await getFileByPath(bucket: bucket, path: path);
    if (file == null) {
      throw VaneStackException('File not found.', status: HttpStatus.notFound);
    }

    // Delete from storage
    final storage = await getStorage(forceLocal: file.isLocal);
    await storage.delete(file.bucket, file.path);

    // Delete from database
    await db.files.deleteWhere((t) => t.id.equals(file.id));
  }

  /// Gets the file contents from storage.
  ///
  /// Returns the file bytes, or null if not found.
  Future<Uint8List?> getFileContents(String fileId) async {
    final file = await getFileById(fileId);
    if (file == null) {
      return null;
    }

    final storage = await getStorage(forceLocal: file.isLocal);
    return storage.get(file.bucket, file.path);
  }

  /// Gets the file contents by bucket and path.
  Future<Uint8List?> getFileContentsByPath({
    required String bucket,
    required String path,
  }) async {
    final file = await getFileByPath(bucket: bucket, path: path);
    if (file == null) {
      return null;
    }

    final storage = await getStorage(forceLocal: file.isLocal);
    return storage.get(file.bucket, file.path);
  }

  /// Gets the download URL for a file.
  ///
  /// Constructs a URL with the file's download token.
  /// Throws [VaneStackException] if bucket, file, or settings not found.
  Future<String> getDownloadUrl({
    required String bucketName,
    required String fileId,
  }) async {
    final file = await getFileById(fileId);

    if (file == null || file.bucket != bucketName) {
      throw VaneStackException('File not found.', status: HttpStatus.notFound);
    }

    final token = file.downloadToken;

    final settings = await (db.appSettings.select()..limit(1))
        .getSingleOrNull();

    if (settings == null) {
      throw VaneStackException(
        'App settings not found.',
        status: HttpStatus.internalServerError,
      );
    }

    final uri = Uri.parse(settings.siteUrl).replace(
      path: '/v1/files/$bucketName/$fileId',
      queryParameters: {'token': token},
    );

    return uri.toString();
  }
}

extension _InstrExpression on Expression<String> {
  Expression<int> instrExpr(Expression<String> string) {
    return FunctionCallExpression('INSTR', [this, string]);
  }
}
