// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
// ignore_for_file: type=lint
// ignore_for_file: unused_element, unnecessary_cast, override_on_non_overriding_member
// ignore_for_file: strict_raw_type, inference_failure_on_untyped_parameter

part of 'list_documents_result.dart';

class ListDocumentsResultMapper extends ClassMapperBase<ListDocumentsResult> {
  ListDocumentsResultMapper._();

  static ListDocumentsResultMapper? _instance;
  static ListDocumentsResultMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = ListDocumentsResultMapper._());
      DocumentMapper.ensureInitialized();
    }
    return _instance!;
  }

  @override
  final String id = 'ListDocumentsResult';

  static List<Document> _$documents(ListDocumentsResult v) => v.documents;
  static const Field<ListDocumentsResult, List<Document>> _f$documents = Field(
    'documents',
    _$documents,
  );
  static int _$count(ListDocumentsResult v) => v.count;
  static const Field<ListDocumentsResult, int> _f$count = Field(
    'count',
    _$count,
  );

  @override
  final MappableFields<ListDocumentsResult> fields = const {
    #documents: _f$documents,
    #count: _f$count,
  };

  static ListDocumentsResult _instantiate(DecodingData data) {
    return ListDocumentsResult(
      documents: data.dec(_f$documents),
      count: data.dec(_f$count),
    );
  }

  @override
  final Function instantiate = _instantiate;

  static ListDocumentsResult fromJson(Map<String, dynamic> map) {
    return ensureInitialized().decodeMap<ListDocumentsResult>(map);
  }

  static ListDocumentsResult fromJsonString(String json) {
    return ensureInitialized().decodeJson<ListDocumentsResult>(json);
  }
}

mixin ListDocumentsResultMappable {
  String toJsonString() {
    return ListDocumentsResultMapper.ensureInitialized()
        .encodeJson<ListDocumentsResult>(this as ListDocumentsResult);
  }

  Map<String, dynamic> toJson() {
    return ListDocumentsResultMapper.ensureInitialized()
        .encodeMap<ListDocumentsResult>(this as ListDocumentsResult);
  }

  ListDocumentsResultCopyWith<
    ListDocumentsResult,
    ListDocumentsResult,
    ListDocumentsResult
  >
  get copyWith =>
      _ListDocumentsResultCopyWithImpl<
        ListDocumentsResult,
        ListDocumentsResult
      >(this as ListDocumentsResult, $identity, $identity);
  @override
  String toString() {
    return ListDocumentsResultMapper.ensureInitialized().stringifyValue(
      this as ListDocumentsResult,
    );
  }

  @override
  bool operator ==(Object other) {
    return ListDocumentsResultMapper.ensureInitialized().equalsValue(
      this as ListDocumentsResult,
      other,
    );
  }

  @override
  int get hashCode {
    return ListDocumentsResultMapper.ensureInitialized().hashValue(
      this as ListDocumentsResult,
    );
  }
}

extension ListDocumentsResultValueCopy<$R, $Out>
    on ObjectCopyWith<$R, ListDocumentsResult, $Out> {
  ListDocumentsResultCopyWith<$R, ListDocumentsResult, $Out>
  get $asListDocumentsResult => $base.as(
    (v, t, t2) => _ListDocumentsResultCopyWithImpl<$R, $Out>(v, t, t2),
  );
}

abstract class ListDocumentsResultCopyWith<
  $R,
  $In extends ListDocumentsResult,
  $Out
>
    implements ClassCopyWith<$R, $In, $Out> {
  ListCopyWith<$R, Document, DocumentCopyWith<$R, Document, Document>>
  get documents;
  $R call({List<Document>? documents, int? count});
  ListDocumentsResultCopyWith<$R2, $In, $Out2> $chain<$R2, $Out2>(
    Then<$Out2, $R2> t,
  );
}

class _ListDocumentsResultCopyWithImpl<$R, $Out>
    extends ClassCopyWithBase<$R, ListDocumentsResult, $Out>
    implements ListDocumentsResultCopyWith<$R, ListDocumentsResult, $Out> {
  _ListDocumentsResultCopyWithImpl(super.value, super.then, super.then2);

  @override
  late final ClassMapperBase<ListDocumentsResult> $mapper =
      ListDocumentsResultMapper.ensureInitialized();
  @override
  ListCopyWith<$R, Document, DocumentCopyWith<$R, Document, Document>>
  get documents => ListCopyWith(
    $value.documents,
    (v, t) => v.copyWith.$chain(t),
    (v) => call(documents: v),
  );
  @override
  $R call({List<Document>? documents, int? count}) => $apply(
    FieldCopyWithData({
      if (documents != null) #documents: documents,
      if (count != null) #count: count,
    }),
  );
  @override
  ListDocumentsResult $make(CopyWithData data) => ListDocumentsResult(
    documents: data.get(#documents, or: $value.documents),
    count: data.get(#count, or: $value.count),
  );

  @override
  ListDocumentsResultCopyWith<$R2, ListDocumentsResult, $Out2>
  $chain<$R2, $Out2>(Then<$Out2, $R2> t) =>
      _ListDocumentsResultCopyWithImpl<$R2, $Out2>($value, $cast, t);
}

