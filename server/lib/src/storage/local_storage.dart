import 'dart:io';
import 'dart:typed_data';

import 'package:path/path.dart';

import '../utils/logger.dart';
import 'storage.dart';

class LocalStorage extends Storage {
  final String folder;

  LocalStorage({required this.folder});

  @override
  Future<void> delete(String bucket, String path) async {
    storageLogger.debug('Deleting file', context: 'bucket=$bucket, path=$path');
    final file = File(join(folder, bucket, path));
    if (await file.exists()) {
      if (file.parent.listSync().length == 1) {
        // If this is the only file in the folder, delete the folder as well
        await file.parent.delete(recursive: true);
      } else {
        await file.delete();
      }
      storageLogger.info('File deleted', context: 'bucket=$bucket, path=$path');
    } else {
      storageLogger.debug(
        'File not found for deletion',
        context: 'bucket=$bucket, path=$path',
      );
    }
  }

  @override
  Future<Uint8List?> get(String bucket, String path) async {
    storageLogger.debug('Getting file', context: 'bucket=$bucket, path=$path');
    final file = File(join(folder, bucket, path));
    final exists = await file.exists();
    if (exists) {
      return file.readAsBytes();
    } else {
      storageLogger.debug(
        'File not found',
        context: 'bucket=$bucket, path=$path',
      );
      return null;
    }
  }

  @override
  Future<void> put(String bucket, String path, Stream<List<int>> bytes) async {
    storageLogger.debug('Storing file', context: 'bucket=$bucket, path=$path');
    final file = File(join(folder, bucket, path));
    await file.create(recursive: true);
    final sink = file.openWrite();
    await bytes.pipe(sink);
    await sink.close();
    storageLogger.info('File stored', context: 'bucket=$bucket, path=$path');
  }

  @override
  Future<void> move(String bucket, String oldPath, String newPath) async {
    storageLogger.debug(
      'Moving file',
      context: 'bucket=$bucket, from=$oldPath, to=$newPath',
    );
    final oldFile = File(join(folder, bucket, oldPath));
    final newFile = File(join(folder, bucket, newPath));
    await oldFile.rename(newFile.path);
    storageLogger.info(
      'File moved',
      context: 'bucket=$bucket, from=$oldPath, to=$newPath',
    );
  }

  @override
  Future<int> getFileSize(String bucket, String path) {
    final file = File(join(folder, bucket, path));
    return file.length();
  }
}
