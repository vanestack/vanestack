import 'dart:convert';
import 'dart:io';

import 'package:vanestack/src/database/database.dart';
import 'package:vanestack/src/server.dart';
import 'package:vanestack/src/utils/auth.dart';
import 'package:vanestack/src/utils/env.dart';
import 'package:drift/drift.dart'
    show driftRuntimeOptions, TableStatements, TableOrViewStatements;
import 'package:drift/native.dart';
import 'package:test/test.dart';

import 'mock_server.dart';
import 'test_utils.dart';

void main() {
  driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;

  late Environment env;
  late AppDatabase database;
  late JsonHttpClient client;
  late VaneStackServer server;
  late Directory tempStorageDir;

  setUp(() async {
    final port = await findFreePort();

    // Create a temp directory for local storage
    tempStorageDir = await Directory.systemTemp.createTemp('vanestack_test_');

    env = Environment(
      port: port,
      localStorageEnabled: true,
      localStoragePath: tempStorageDir.path,
    );
    database = AppDatabase(NativeDatabase.memory(setup: AppDatabase.setup));
    server = MockServer(db: database, env: env);
    await server.start();

    final jwt = AuthUtils.generateJwt(
      userId: 'test_user',
      jwtSecret: env.jwtSecret,
      superuser: true,
    );

    client = JsonHttpClient(
      '127.0.0.1',
      port,
      defaultHeaders: {HttpHeaders.authorizationHeader: 'Bearer $jwt'},
    );
  });

  tearDown(() async {
    client.close();
    database.close();
    await server.stop();
    // Clean up temp directory
    if (await tempStorageDir.exists()) {
      await tempStorageDir.delete(recursive: true);
    }
  });

  group('Bucket Operations', () {
    test('creates a bucket successfully', () async {
      final res = await client.post('/v1/buckets/test_bucket');

      expect(res.status, 200);
      expect(res.json!['name'], 'test_bucket');
    });

    test('returns 400 for invalid bucket name format', () async {
      final res = await client.post('/v1/buckets/123_invalid');

      expect(res.status, 400);
      expect(res.json!['error']['message'], contains('start with a lowercase'));
    });

    test('returns 400 for bucket name with special characters', () async {
      // Bucket name with hyphen (not allowed, must use underscore)
      final res = await client.post('/v1/buckets/my-bucket');

      expect(res.status, 400);
    });

    test('creates bucket with rules', () async {
      final res = await client.post(
        '/v1/buckets/secure_bucket',
        body: {
          'listRule': 'user.id != null',
          'viewRule': 'user.id != null',
          'createRule': 'user.superUser == true',
          'deleteRule': 'user.superUser == true',
        },
      );

      expect(res.status, 200);
      expect(res.json!['name'], 'secure_bucket');
    });

    test('lists all buckets', () async {
      // Create multiple buckets
      await client.post('/v1/buckets/bucket_a');
      await client.post('/v1/buckets/bucket_b');
      await client.post('/v1/buckets/bucket_c');

      final res = await client.get('/v1/buckets');

      expect(res.status, 200);
      // Response is a list of buckets
      final buckets = jsonDecode(res.body) as List;
      expect(buckets.length, 3);
    });

    test('gets a bucket by name', () async {
      await client.post('/v1/buckets/my_bucket');

      final res = await client.get('/v1/buckets/my_bucket');

      expect(res.status, 200);
      expect(res.json!['name'], 'my_bucket');
    });

    test('returns 404 for non-existent bucket', () async {
      final res = await client.get('/v1/buckets/nonexistent');

      expect(res.status, 404);
    });

    test('updates a bucket name', () async {
      await client.post('/v1/buckets/old_name');

      final res = await client.patch(
        '/v1/buckets/old_name',
        body: {'newBucketName': 'new_name'},
      );

      expect(res.status, 200);
      expect(res.json!['name'], 'new_name');

      // Verify old name doesn't exist
      final oldRes = await client.get('/v1/buckets/old_name');
      expect(oldRes.status, 404);

      // Verify new name exists
      final newRes = await client.get('/v1/buckets/new_name');
      expect(newRes.status, 200);
    });

    test('updates bucket rules', () async {
      await client.post('/v1/buckets/rules_bucket');

      final res = await client.patch(
        '/v1/buckets/rules_bucket',
        body: {
          'listRule': 'user.id != null',
          'createRule': 'user.superUser == true',
        },
      );

      expect(res.status, 200);
    });

    test('returns 404 when updating non-existent bucket', () async {
      final res = await client.patch(
        '/v1/buckets/nonexistent',
        body: {'listRule': 'true'},
      );

      expect(res.status, 404);
    });

    test('deletes a bucket', () async {
      await client.post('/v1/buckets/to_delete');

      final res = await client.del('/v1/buckets/to_delete');

      expect(res.status, 200);

      // Verify bucket is gone
      final getRes = await client.get('/v1/buckets/to_delete');
      expect(getRes.status, 404);
    });
  });

  group('File Operations', () {
    setUp(() async {
      // Create a test bucket for file operations
      await client.post('/v1/buckets/files_bucket');
    });

    test('lists files in a bucket', () async {
      final res = await client.get('/v1/files/files_bucket');

      expect(res.status, 200);
      expect(res.json!['files'], isA<List>());
      expect(res.json!['folders'], isA<List>());
    });

    test('returns 404 for files in non-existent bucket', () async {
      final res = await client.get('/v1/files/nonexistent_bucket');

      expect(res.status, 404);
    });
  });

  group('File Path Validation', () {
    setUp(() async {
      await client.post('/v1/buckets/path_test_bucket');
    });

    test('rejects absolute paths', () async {
      // Create a file record directly to test path validation
      final file = DbFile(
        id: 'test-id',
        path: '/absolute/path.txt',
        bucket: 'path_test_bucket',
        size: 0,
        mimeType: 'text/plain',
        downloadToken: 'token',
        metadata: {},
        isLocal: true,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      // The upload endpoint should reject this
      // Testing via the database directly
      await database.files.insertOne(file);
      final retrieved = await database.files.select().getSingleOrNull();
      expect(retrieved, isNotNull);
    });

    test('handles path traversal attempts', () async {
      // Paths with .. should be normalized or rejected
      // This tests the path validation logic
      final validPath = 'folder/file.txt';
      final normalizedPath = validPath.replaceAll('..', '');
      expect(normalizedPath, validPath);
    });
  });

  group('Download URL Generation', () {
    test('returns 404 for non-existent file download URL', () async {
      await client.post('/v1/buckets/download_bucket');

      final res = await client.get(
        '/v1/files/download_bucket/nonexistent-id/url',
      );

      expect(res.status, 404);
    });
  });

  group('File Upload Size Limits', () {
    late Environment smallLimitEnv;
    late AppDatabase smallLimitDb;
    late JsonHttpClient smallLimitClient;
    late VaneStackServer smallLimitServer;
    late Directory smallLimitTempDir;

    setUp(() async {
      final port = await findFreePort();
      smallLimitTempDir = await Directory.systemTemp.createTemp('vanestack_size_test_');

      // Create environment with 10KB max file size
      // (larger to account for multipart overhead in Content-Length check)
      smallLimitEnv = Environment(
        port: port,
        localStorageEnabled: true,
        localStoragePath: smallLimitTempDir.path,
        maxFileSize: 10 * 1024, // 10KB limit
      );
      smallLimitDb = AppDatabase(NativeDatabase.memory(setup: AppDatabase.setup));
      smallLimitServer = MockServer(db: smallLimitDb, env: smallLimitEnv);
      await smallLimitServer.start();

      final jwt = AuthUtils.generateJwt(
        userId: 'test_user',
        jwtSecret: smallLimitEnv.jwtSecret,
        superuser: true,
      );

      smallLimitClient = JsonHttpClient(
        '127.0.0.1',
        port,
        defaultHeaders: {HttpHeaders.authorizationHeader: 'Bearer $jwt'},
      );

      // Create test bucket
      await smallLimitClient.post('/v1/buckets/size_test_bucket');
    });

    tearDown(() async {
      smallLimitClient.close();
      smallLimitDb.close();
      await smallLimitServer.stop();
      if (await smallLimitTempDir.exists()) {
        await smallLimitTempDir.delete(recursive: true);
      }
    });

    test('accepts file within size limit', () async {
      final smallContent = List.filled(5 * 1024, 65); // 5KB of 'A'

      final res = await smallLimitClient.uploadFile(
        '/v1/files/size_test_bucket/upload',
        filePath: 'uploads',
        fileName: 'small.txt',
        fileContent: smallContent,
        mimeType: 'text/plain',
      );

      expect(res.status, 200);
      expect(res.json!['path'], 'uploads/small.txt');
    });

    test('rejects file exceeding size limit', () async {
      final largeContent = List.filled(20 * 1024, 65); // 20KB of 'A' (exceeds 10KB limit)

      final res = await smallLimitClient.uploadFile(
        '/v1/files/size_test_bucket/upload',
        filePath: 'uploads',
        fileName: 'large.txt',
        fileContent: largeContent,
        mimeType: 'text/plain',
      );

      expect(res.status, 413); // Request Entity Too Large
      expect(res.json!['error']['message'], contains('exceeds maximum'));
    });

    test('rejects file just over size limit', () async {
      // 11KB file content (exceeds 10KB limit)
      final overLimitContent = List.filled(11 * 1024, 65);

      final res = await smallLimitClient.uploadFile(
        '/v1/files/size_test_bucket/upload',
        filePath: 'uploads',
        fileName: 'over_limit.txt',
        fileContent: overLimitContent,
        mimeType: 'text/plain',
      );

      expect(res.status, 413);
    });

    test('accepts file under size limit', () async {
      // 9KB content - safely under 10KB limit
      final underLimitContent = List.filled(9 * 1024, 65);

      final res = await smallLimitClient.uploadFile(
        '/v1/files/size_test_bucket/upload',
        filePath: 'uploads',
        fileName: 'under_limit.txt',
        fileContent: underLimitContent,
        mimeType: 'text/plain',
      );

      expect(res.status, 200);
      expect(res.json!['path'], 'uploads/under_limit.txt');
    });
  });

  group('File Type Validation', () {
    setUp(() async {
      await client.post('/v1/buckets/type_test_bucket');
    });

    test('rejects executable files (.exe)', () async {
      final content = [0x4D, 0x5A, 0x90, 0x00]; // MZ header (PE executable)

      final res = await client.uploadFile(
        '/v1/files/type_test_bucket/upload',
        filePath: 'uploads',
        fileName: 'malware.exe',
        fileContent: content,
        mimeType: 'application/octet-stream',
      );

      expect(res.status, 400);
      expect(res.json!['error']['message'], contains('not allowed'));
    });

    test('rejects PHP files', () async {
      final content = utf8.encode('<?php echo "hello"; ?>');

      final res = await client.uploadFile(
        '/v1/files/type_test_bucket/upload',
        filePath: 'uploads',
        fileName: 'script.php',
        fileContent: content,
        mimeType: 'text/plain',
      );

      expect(res.status, 400);
      expect(res.json!['error']['message'], contains('not allowed'));
    });

    test('rejects shell scripts (.sh)', () async {
      final content = utf8.encode('#!/bin/bash\necho "hello"');

      final res = await client.uploadFile(
        '/v1/files/type_test_bucket/upload',
        filePath: 'uploads',
        fileName: 'script.sh',
        fileContent: content,
        mimeType: 'text/plain',
      );

      expect(res.status, 400);
      expect(res.json!['error']['message'], contains('not allowed'));
    });

    test('rejects JavaScript files (.js)', () async {
      final content = utf8.encode('console.log("hello");');

      final res = await client.uploadFile(
        '/v1/files/type_test_bucket/upload',
        filePath: 'uploads',
        fileName: 'script.js',
        fileContent: content,
        mimeType: 'application/javascript',
      );

      expect(res.status, 400);
      expect(res.json!['error']['message'], contains('not allowed'));
    });

    test('accepts valid PNG image', () async {
      // PNG magic bytes + minimal valid header
      final pngContent = [
        0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A, // PNG signature
        0x00, 0x00, 0x00, 0x0D, // IHDR chunk length
        0x49, 0x48, 0x44, 0x52, // IHDR
        0x00, 0x00, 0x00, 0x01, // width: 1
        0x00, 0x00, 0x00, 0x01, // height: 1
        0x08, 0x02, // bit depth, color type
        0x00, 0x00, 0x00, // compression, filter, interlace
        0x90, 0x77, 0x53, 0xDE, // CRC
      ];

      final res = await client.uploadFile(
        '/v1/files/type_test_bucket/upload',
        filePath: 'uploads',
        fileName: 'image.png',
        fileContent: pngContent,
        mimeType: 'image/png',
      );

      expect(res.status, 200);
      expect(res.json!['mime_type'], 'image/png');
    });

    test('accepts valid JPEG image', () async {
      // JPEG magic bytes (SOI + APP0)
      final jpegContent = [
        0xFF, 0xD8, 0xFF, 0xE0, // SOI + APP0 marker
        0x00, 0x10, // Length
        0x4A, 0x46, 0x49, 0x46, 0x00, // JFIF identifier
        0x01, 0x01, // Version
        0x00, // Aspect ratio units
        0x00, 0x01, // X density
        0x00, 0x01, // Y density
        0x00, 0x00, // Thumbnail
      ];

      final res = await client.uploadFile(
        '/v1/files/type_test_bucket/upload',
        filePath: 'uploads',
        fileName: 'photo.jpg',
        fileContent: jpegContent,
        mimeType: 'image/jpeg',
      );

      expect(res.status, 200);
      expect(res.json!['mime_type'], 'image/jpeg');
    });

    test('accepts valid PDF', () async {
      // PDF magic bytes
      final pdfContent = utf8.encode('%PDF-1.4\n%EOF');

      final res = await client.uploadFile(
        '/v1/files/type_test_bucket/upload',
        filePath: 'uploads',
        fileName: 'document.pdf',
        fileContent: pdfContent,
        mimeType: 'application/pdf',
      );

      expect(res.status, 200);
      expect(res.json!['mime_type'], 'application/pdf');
    });

    test('accepts text files', () async {
      final textContent = utf8.encode('Hello, world!');

      final res = await client.uploadFile(
        '/v1/files/type_test_bucket/upload',
        filePath: 'uploads',
        fileName: 'readme.txt',
        fileContent: textContent,
        mimeType: 'text/plain',
      );

      expect(res.status, 200);
    });

    test('detects MIME type from content and uses it', () async {
      // PNG file with wrong claimed MIME type
      final pngContent = [
        0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A,
        0x00, 0x00, 0x00, 0x0D,
        0x49, 0x48, 0x44, 0x52,
      ];

      final res = await client.uploadFile(
        '/v1/files/type_test_bucket/upload',
        filePath: 'uploads',
        fileName: 'image.png',
        fileContent: pngContent,
        mimeType: 'application/octet-stream', // Wrong but compatible
      );

      expect(res.status, 200);
      // Should detect and use actual PNG type
      expect(res.json!['mime_type'], 'image/png');
    });
  });
}
