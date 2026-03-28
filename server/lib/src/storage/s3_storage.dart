import 'dart:io';
import 'dart:typed_data';

import 'package:vanestack_common/vanestack_common.dart';

import '../utils/logger.dart';
import '../utils/s3.dart';
import 'storage.dart';

class S3Storage extends Storage {
  final S3Client _client;

  S3Storage({required S3Client client}) : _client = client;

  @override
  Future<void> delete(String bucket, String path) async {
    storageLogger.debug(
      'Deleting S3 object',
      context: 'bucket=$bucket, path=$path',
    );
    await _client.deleteObject('$bucket/$path');
    storageLogger.info(
      'S3 object deleted',
      context: 'bucket=$bucket, path=$path',
    );
  }

  @override
  Future<Uint8List?> get(String bucket, String path) async {
    storageLogger.debug(
      'Getting S3 object',
      context: 'bucket=$bucket, path=$path',
    );
    return _client.getObject('$bucket/$path');
  }

  @override
  Future<int> getFileSize(String bucket, String path) async {
    final size = await _client.getObjectSize('$bucket/$path');
    if (size == null) {
      storageLogger.warn(
        'S3 object not found',
        context: 'bucket=$bucket, path=$path',
      );
      throw VaneStackException(
        'File not found: $bucket/$path',
        status: HttpStatus.notFound,
      );
    }

    return size;
  }

  @override
  Future<void> move(String bucket, String oldPath, String newPath) async {
    storageLogger.debug(
      'Moving S3 object',
      context: 'bucket=$bucket, from=$oldPath, to=$newPath',
    );
    await _client.moveObject('$bucket/$oldPath', '$bucket/$newPath');
    storageLogger.info(
      'S3 object moved',
      context: 'bucket=$bucket, from=$oldPath, to=$newPath',
    );
  }

  @override
  Future<void> put(String bucket, String path, Stream<List<int>> bytes) async {
    storageLogger.debug(
      'Uploading S3 object',
      context: 'bucket=$bucket, path=$path',
    );

    // Buffer into memory — S3 PUT requires Content-Length and multipart
    // part streams don't expose their size upfront.
    final builder = BytesBuilder(copy: false);
    await for (final chunk in bytes) {
      builder.add(chunk);
    }
    final payload = builder.takeBytes();

    await _client.putObject(
      '$bucket/$path',
      Stream.value(payload),
      payload.length,
    );
    storageLogger.info(
      'S3 object uploaded',
      context: 'bucket=$bucket, path=$path, size=${payload.length}',
    );
  }
}
