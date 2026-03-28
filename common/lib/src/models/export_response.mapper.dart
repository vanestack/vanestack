// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
// ignore_for_file: type=lint
// ignore_for_file: unused_element, unnecessary_cast, override_on_non_overriding_member
// ignore_for_file: strict_raw_type, inference_failure_on_untyped_parameter

part of 'export_response.dart';

class ExportResponseMapper extends ClassMapperBase<ExportResponse> {
  ExportResponseMapper._();

  static ExportResponseMapper? _instance;
  static ExportResponseMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = ExportResponseMapper._());
      MapperContainer.globals.useAll([SecondsDateTimeMapper()]);
      CollectionMapper.ensureInitialized();
    }
    return _instance!;
  }

  @override
  final String id = 'ExportResponse';

  static List<Collection> _$collections(ExportResponse v) => v.collections;
  static const Field<ExportResponse, List<Collection>> _f$collections = Field(
    'collections',
    _$collections,
  );
  static DateTime _$exportedAt(ExportResponse v) => v.exportedAt;
  static const Field<ExportResponse, DateTime> _f$exportedAt = Field(
    'exportedAt',
    _$exportedAt,
    key: r'exported_at',
  );
  static String _$version(ExportResponse v) => v.version;
  static const Field<ExportResponse, String> _f$version = Field(
    'version',
    _$version,
  );

  @override
  final MappableFields<ExportResponse> fields = const {
    #collections: _f$collections,
    #exportedAt: _f$exportedAt,
    #version: _f$version,
  };

  static ExportResponse _instantiate(DecodingData data) {
    return ExportResponse(
      collections: data.dec(_f$collections),
      exportedAt: data.dec(_f$exportedAt),
      version: data.dec(_f$version),
    );
  }

  @override
  final Function instantiate = _instantiate;

  static ExportResponse fromJson(Map<String, dynamic> map) {
    return ensureInitialized().decodeMap<ExportResponse>(map);
  }

  static ExportResponse fromJsonString(String json) {
    return ensureInitialized().decodeJson<ExportResponse>(json);
  }
}

mixin ExportResponseMappable {
  String toJsonString() {
    return ExportResponseMapper.ensureInitialized().encodeJson<ExportResponse>(
      this as ExportResponse,
    );
  }

  Map<String, dynamic> toJson() {
    return ExportResponseMapper.ensureInitialized().encodeMap<ExportResponse>(
      this as ExportResponse,
    );
  }

  ExportResponseCopyWith<ExportResponse, ExportResponse, ExportResponse>
  get copyWith => _ExportResponseCopyWithImpl<ExportResponse, ExportResponse>(
    this as ExportResponse,
    $identity,
    $identity,
  );
  @override
  String toString() {
    return ExportResponseMapper.ensureInitialized().stringifyValue(
      this as ExportResponse,
    );
  }

  @override
  bool operator ==(Object other) {
    return ExportResponseMapper.ensureInitialized().equalsValue(
      this as ExportResponse,
      other,
    );
  }

  @override
  int get hashCode {
    return ExportResponseMapper.ensureInitialized().hashValue(
      this as ExportResponse,
    );
  }
}

extension ExportResponseValueCopy<$R, $Out>
    on ObjectCopyWith<$R, ExportResponse, $Out> {
  ExportResponseCopyWith<$R, ExportResponse, $Out> get $asExportResponse =>
      $base.as((v, t, t2) => _ExportResponseCopyWithImpl<$R, $Out>(v, t, t2));
}

abstract class ExportResponseCopyWith<$R, $In extends ExportResponse, $Out>
    implements ClassCopyWith<$R, $In, $Out> {
  ListCopyWith<$R, Collection, ObjectCopyWith<$R, Collection, Collection>>
  get collections;
  $R call({
    List<Collection>? collections,
    DateTime? exportedAt,
    String? version,
  });
  ExportResponseCopyWith<$R2, $In, $Out2> $chain<$R2, $Out2>(
    Then<$Out2, $R2> t,
  );
}

class _ExportResponseCopyWithImpl<$R, $Out>
    extends ClassCopyWithBase<$R, ExportResponse, $Out>
    implements ExportResponseCopyWith<$R, ExportResponse, $Out> {
  _ExportResponseCopyWithImpl(super.value, super.then, super.then2);

  @override
  late final ClassMapperBase<ExportResponse> $mapper =
      ExportResponseMapper.ensureInitialized();
  @override
  ListCopyWith<$R, Collection, ObjectCopyWith<$R, Collection, Collection>>
  get collections => ListCopyWith(
    $value.collections,
    (v, t) => ObjectCopyWith(v, $identity, t),
    (v) => call(collections: v),
  );
  @override
  $R call({
    List<Collection>? collections,
    DateTime? exportedAt,
    String? version,
  }) => $apply(
    FieldCopyWithData({
      if (collections != null) #collections: collections,
      if (exportedAt != null) #exportedAt: exportedAt,
      if (version != null) #version: version,
    }),
  );
  @override
  ExportResponse $make(CopyWithData data) => ExportResponse(
    collections: data.get(#collections, or: $value.collections),
    exportedAt: data.get(#exportedAt, or: $value.exportedAt),
    version: data.get(#version, or: $value.version),
  );

  @override
  ExportResponseCopyWith<$R2, ExportResponse, $Out2> $chain<$R2, $Out2>(
    Then<$Out2, $R2> t,
  ) => _ExportResponseCopyWithImpl<$R2, $Out2>($value, $cast, t);
}

