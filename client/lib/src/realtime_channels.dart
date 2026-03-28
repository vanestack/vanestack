abstract class Channel {
  static CollectionChannel collection(
    String collection, {
    DocumentEventType type = DocumentEventType.all,
  }) => CollectionChannel(collection, type: type);

  static DocumentChannel document(
    String collection,
    String documentId, {
    DocumentEventType type = DocumentEventType.all,
  }) => DocumentChannel(
    collection: collection,
    documentId: documentId,
    type: type,
  );

  static BucketChannel bucket(
    String bucket, {
    FileEventType type = FileEventType.all,
  }) => BucketChannel(bucket, type: type);

  static FileChannel file(
    String bucket,
    String fileId, {
    FileEventType type = FileEventType.all,
  }) => FileChannel(bucket: bucket, fileId: fileId, type: type);

  static CustomChannel custom(String name) => CustomChannel(name);

  String build();
}

class CustomChannel extends Channel {
  final String name;

  CustomChannel(this.name);

  @override
  String build() => name;
}

enum DocumentEventType {
  all(null),
  create('created'),
  update('updated'),
  delete('deleted');

  final String? value;

  const DocumentEventType(this.value);
}

class CollectionChannel extends Channel {
  final String name;
  final DocumentEventType type;

  CollectionChannel(this.name, {this.type = DocumentEventType.all});

  @override
  String build() {
    return '$name.*${type.value != null ? '.${type.value}' : ''}';
  }
}

enum FileEventType {
  all(null),
  uploaded('uploaded'),
  moved('moved'),
  deleted('deleted');

  final String? value;

  const FileEventType(this.value);
}

class BucketChannel extends Channel {
  final String name;
  final FileEventType type;

  BucketChannel(this.name, {this.type = FileEventType.all});

  @override
  String build() {
    return '$name.*${type.value != null ? '.${type.value}' : ''}';
  }
}

class FileChannel extends Channel {
  final String bucket;
  final String fileId;
  final FileEventType type;

  FileChannel({
    required this.bucket,
    required this.fileId,
    this.type = FileEventType.all,
  });

  @override
  String build() {
    return '$bucket.$fileId${type.value != null ? '.${type.value}' : ''}';
  }
}

class DocumentChannel extends Channel {
  final String collection;
  final String documentId;
  final DocumentEventType type;

  DocumentChannel({
    required this.collection,
    required this.documentId,
    this.type = DocumentEventType.all,
  });

  @override
  String build() {
    return '$collection.$documentId${type.value != null ? '.${type.value}' : ''}';
  }
}
