// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
// ignore_for_file: type=lint
// ignore_for_file: unused_element, unnecessary_cast, override_on_non_overriding_member
// ignore_for_file: strict_raw_type, inference_failure_on_untyped_parameter

part of 'document.dart';

class DocumentMapper extends ClassMapperBase<Document> {
  DocumentMapper._();

  static DocumentMapper? _instance;
  static DocumentMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = DocumentMapper._());
      MapperContainer.globals.useAll([SecondsDateTimeMapper()]);
    }
    return _instance!;
  }

  @override
  final String id = 'Document';

  static String _$id(Document v) => v.id;
  static const Field<Document, String> _f$id = Field('id', _$id);
  static String _$collection(Document v) => v.collection;
  static const Field<Document, String> _f$collection = Field(
    'collection',
    _$collection,
  );
  static DateTime? _$createdAt(Document v) => v.createdAt;
  static const Field<Document, DateTime> _f$createdAt = Field(
    'createdAt',
    _$createdAt,
    key: r'created_at',
    opt: true,
  );
  static DateTime? _$updatedAt(Document v) => v.updatedAt;
  static const Field<Document, DateTime> _f$updatedAt = Field(
    'updatedAt',
    _$updatedAt,
    key: r'updated_at',
    opt: true,
  );
  static Map<String, Object?> _$data(Document v) => v.data;
  static const Field<Document, Map<String, Object?>> _f$data = Field(
    'data',
    _$data,
    opt: true,
    def: const {},
  );

  @override
  final MappableFields<Document> fields = const {
    #id: _f$id,
    #collection: _f$collection,
    #createdAt: _f$createdAt,
    #updatedAt: _f$updatedAt,
    #data: _f$data,
  };

  static Document _instantiate(DecodingData data) {
    return Document(
      id: data.dec(_f$id),
      collection: data.dec(_f$collection),
      createdAt: data.dec(_f$createdAt),
      updatedAt: data.dec(_f$updatedAt),
      data: data.dec(_f$data),
    );
  }

  @override
  final Function instantiate = _instantiate;

  static Document fromJson(Map<String, dynamic> map) {
    return ensureInitialized().decodeMap<Document>(map);
  }

  static Document fromJsonString(String json) {
    return ensureInitialized().decodeJson<Document>(json);
  }
}

mixin DocumentMappable {
  String toJsonString() {
    return DocumentMapper.ensureInitialized().encodeJson<Document>(
      this as Document,
    );
  }

  Map<String, dynamic> toJson() {
    return DocumentMapper.ensureInitialized().encodeMap<Document>(
      this as Document,
    );
  }

  DocumentCopyWith<Document, Document, Document> get copyWith =>
      _DocumentCopyWithImpl<Document, Document>(
        this as Document,
        $identity,
        $identity,
      );
  @override
  String toString() {
    return DocumentMapper.ensureInitialized().stringifyValue(this as Document);
  }

  @override
  bool operator ==(Object other) {
    return DocumentMapper.ensureInitialized().equalsValue(
      this as Document,
      other,
    );
  }

  @override
  int get hashCode {
    return DocumentMapper.ensureInitialized().hashValue(this as Document);
  }
}

extension DocumentValueCopy<$R, $Out> on ObjectCopyWith<$R, Document, $Out> {
  DocumentCopyWith<$R, Document, $Out> get $asDocument =>
      $base.as((v, t, t2) => _DocumentCopyWithImpl<$R, $Out>(v, t, t2));
}

abstract class DocumentCopyWith<$R, $In extends Document, $Out>
    implements ClassCopyWith<$R, $In, $Out> {
  MapCopyWith<$R, String, Object?, ObjectCopyWith<$R, Object?, Object?>?>
  get data;
  $R call({
    String? id,
    String? collection,
    DateTime? createdAt,
    DateTime? updatedAt,
    Map<String, Object?>? data,
  });
  DocumentCopyWith<$R2, $In, $Out2> $chain<$R2, $Out2>(Then<$Out2, $R2> t);
}

class _DocumentCopyWithImpl<$R, $Out>
    extends ClassCopyWithBase<$R, Document, $Out>
    implements DocumentCopyWith<$R, Document, $Out> {
  _DocumentCopyWithImpl(super.value, super.then, super.then2);

  @override
  late final ClassMapperBase<Document> $mapper =
      DocumentMapper.ensureInitialized();
  @override
  MapCopyWith<$R, String, Object?, ObjectCopyWith<$R, Object?, Object?>?>
  get data => MapCopyWith(
    $value.data,
    (v, t) => ObjectCopyWith(v, $identity, t),
    (v) => call(data: v),
  );
  @override
  $R call({
    String? id,
    String? collection,
    Object? createdAt = $none,
    Object? updatedAt = $none,
    Map<String, Object?>? data,
  }) => $apply(
    FieldCopyWithData({
      if (id != null) #id: id,
      if (collection != null) #collection: collection,
      if (createdAt != $none) #createdAt: createdAt,
      if (updatedAt != $none) #updatedAt: updatedAt,
      if (data != null) #data: data,
    }),
  );
  @override
  Document $make(CopyWithData data) => Document(
    id: data.get(#id, or: $value.id),
    collection: data.get(#collection, or: $value.collection),
    createdAt: data.get(#createdAt, or: $value.createdAt),
    updatedAt: data.get(#updatedAt, or: $value.updatedAt),
    data: data.get(#data, or: $value.data),
  );

  @override
  DocumentCopyWith<$R2, Document, $Out2> $chain<$R2, $Out2>(
    Then<$Out2, $R2> t,
  ) => _DocumentCopyWithImpl<$R2, $Out2>($value, $cast, t);
}

