// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
// ignore_for_file: type=lint
// ignore_for_file: unused_element, unnecessary_cast, override_on_non_overriding_member
// ignore_for_file: strict_raw_type, inference_failure_on_untyped_parameter

part of 'file.dart';

class FileMapper extends ClassMapperBase<File> {
  FileMapper._();

  static FileMapper? _instance;
  static FileMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = FileMapper._());
      MapperContainer.globals.useAll([SecondsDateTimeMapper()]);
    }
    return _instance!;
  }

  @override
  final String id = 'File';

  static String _$id(File v) => v.id;
  static const Field<File, String> _f$id = Field('id', _$id);
  static String _$bucket(File v) => v.bucket;
  static const Field<File, String> _f$bucket = Field('bucket', _$bucket);
  static String _$mimeType(File v) => v.mimeType;
  static const Field<File, String> _f$mimeType = Field(
    'mimeType',
    _$mimeType,
    key: r'mime_type',
  );
  static String _$path(File v) => v.path;
  static const Field<File, String> _f$path = Field('path', _$path);
  static Map<String, Object?>? _$metadata(File v) => v.metadata;
  static const Field<File, Map<String, Object?>> _f$metadata = Field(
    'metadata',
    _$metadata,
    opt: true,
  );
  static int _$size(File v) => v.size;
  static const Field<File, int> _f$size = Field('size', _$size);
  static DateTime _$createdAt(File v) => v.createdAt;
  static const Field<File, DateTime> _f$createdAt = Field(
    'createdAt',
    _$createdAt,
    key: r'created_at',
  );
  static DateTime _$updatedAt(File v) => v.updatedAt;
  static const Field<File, DateTime> _f$updatedAt = Field(
    'updatedAt',
    _$updatedAt,
    key: r'updated_at',
  );

  @override
  final MappableFields<File> fields = const {
    #id: _f$id,
    #bucket: _f$bucket,
    #mimeType: _f$mimeType,
    #path: _f$path,
    #metadata: _f$metadata,
    #size: _f$size,
    #createdAt: _f$createdAt,
    #updatedAt: _f$updatedAt,
  };

  static File _instantiate(DecodingData data) {
    return File(
      id: data.dec(_f$id),
      bucket: data.dec(_f$bucket),
      mimeType: data.dec(_f$mimeType),
      path: data.dec(_f$path),
      metadata: data.dec(_f$metadata),
      size: data.dec(_f$size),
      createdAt: data.dec(_f$createdAt),
      updatedAt: data.dec(_f$updatedAt),
    );
  }

  @override
  final Function instantiate = _instantiate;

  static File fromJson(Map<String, dynamic> map) {
    return ensureInitialized().decodeMap<File>(map);
  }

  static File fromJsonString(String json) {
    return ensureInitialized().decodeJson<File>(json);
  }
}

mixin FileMappable {
  String toJsonString() {
    return FileMapper.ensureInitialized().encodeJson<File>(this as File);
  }

  Map<String, dynamic> toJson() {
    return FileMapper.ensureInitialized().encodeMap<File>(this as File);
  }

  FileCopyWith<File, File, File> get copyWith =>
      _FileCopyWithImpl<File, File>(this as File, $identity, $identity);
  @override
  String toString() {
    return FileMapper.ensureInitialized().stringifyValue(this as File);
  }

  @override
  bool operator ==(Object other) {
    return FileMapper.ensureInitialized().equalsValue(this as File, other);
  }

  @override
  int get hashCode {
    return FileMapper.ensureInitialized().hashValue(this as File);
  }
}

extension FileValueCopy<$R, $Out> on ObjectCopyWith<$R, File, $Out> {
  FileCopyWith<$R, File, $Out> get $asFile =>
      $base.as((v, t, t2) => _FileCopyWithImpl<$R, $Out>(v, t, t2));
}

abstract class FileCopyWith<$R, $In extends File, $Out>
    implements ClassCopyWith<$R, $In, $Out> {
  MapCopyWith<$R, String, Object?, ObjectCopyWith<$R, Object?, Object?>?>?
  get metadata;
  $R call({
    String? id,
    String? bucket,
    String? mimeType,
    String? path,
    Map<String, Object?>? metadata,
    int? size,
    DateTime? createdAt,
    DateTime? updatedAt,
  });
  FileCopyWith<$R2, $In, $Out2> $chain<$R2, $Out2>(Then<$Out2, $R2> t);
}

class _FileCopyWithImpl<$R, $Out> extends ClassCopyWithBase<$R, File, $Out>
    implements FileCopyWith<$R, File, $Out> {
  _FileCopyWithImpl(super.value, super.then, super.then2);

  @override
  late final ClassMapperBase<File> $mapper = FileMapper.ensureInitialized();
  @override
  MapCopyWith<$R, String, Object?, ObjectCopyWith<$R, Object?, Object?>?>?
  get metadata => $value.metadata != null
      ? MapCopyWith(
          $value.metadata!,
          (v, t) => ObjectCopyWith(v, $identity, t),
          (v) => call(metadata: v),
        )
      : null;
  @override
  $R call({
    String? id,
    String? bucket,
    String? mimeType,
    String? path,
    Object? metadata = $none,
    int? size,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) => $apply(
    FieldCopyWithData({
      if (id != null) #id: id,
      if (bucket != null) #bucket: bucket,
      if (mimeType != null) #mimeType: mimeType,
      if (path != null) #path: path,
      if (metadata != $none) #metadata: metadata,
      if (size != null) #size: size,
      if (createdAt != null) #createdAt: createdAt,
      if (updatedAt != null) #updatedAt: updatedAt,
    }),
  );
  @override
  File $make(CopyWithData data) => File(
    id: data.get(#id, or: $value.id),
    bucket: data.get(#bucket, or: $value.bucket),
    mimeType: data.get(#mimeType, or: $value.mimeType),
    path: data.get(#path, or: $value.path),
    metadata: data.get(#metadata, or: $value.metadata),
    size: data.get(#size, or: $value.size),
    createdAt: data.get(#createdAt, or: $value.createdAt),
    updatedAt: data.get(#updatedAt, or: $value.updatedAt),
  );

  @override
  FileCopyWith<$R2, File, $Out2> $chain<$R2, $Out2>(Then<$Out2, $R2> t) =>
      _FileCopyWithImpl<$R2, $Out2>($value, $cast, t);
}

