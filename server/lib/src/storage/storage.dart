import 'dart:typed_data';

abstract class Storage {
  Future<void> put(String bucket, String path, Stream<List<int>> bytes);
  Future<Uint8List?> get(String bucket, String path);
  Future<void> delete(String bucket, String path);
  Future<void> move(String bucket, String oldPath, String newPath);
  Future<int> getFileSize(String bucket, String path);
}
