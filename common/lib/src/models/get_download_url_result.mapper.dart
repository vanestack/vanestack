// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
// ignore_for_file: type=lint
// ignore_for_file: unused_element, unnecessary_cast, override_on_non_overriding_member
// ignore_for_file: strict_raw_type, inference_failure_on_untyped_parameter

part of 'get_download_url_result.dart';

class GetDownloadUrlResultMapper extends ClassMapperBase<GetDownloadUrlResult> {
  GetDownloadUrlResultMapper._();

  static GetDownloadUrlResultMapper? _instance;
  static GetDownloadUrlResultMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = GetDownloadUrlResultMapper._());
    }
    return _instance!;
  }

  @override
  final String id = 'GetDownloadUrlResult';

  static String _$url(GetDownloadUrlResult v) => v.url;
  static const Field<GetDownloadUrlResult, String> _f$url = Field('url', _$url);

  @override
  final MappableFields<GetDownloadUrlResult> fields = const {#url: _f$url};

  static GetDownloadUrlResult _instantiate(DecodingData data) {
    return GetDownloadUrlResult(url: data.dec(_f$url));
  }

  @override
  final Function instantiate = _instantiate;

  static GetDownloadUrlResult fromJson(Map<String, dynamic> map) {
    return ensureInitialized().decodeMap<GetDownloadUrlResult>(map);
  }

  static GetDownloadUrlResult fromJsonString(String json) {
    return ensureInitialized().decodeJson<GetDownloadUrlResult>(json);
  }
}

mixin GetDownloadUrlResultMappable {
  String toJsonString() {
    return GetDownloadUrlResultMapper.ensureInitialized()
        .encodeJson<GetDownloadUrlResult>(this as GetDownloadUrlResult);
  }

  Map<String, dynamic> toJson() {
    return GetDownloadUrlResultMapper.ensureInitialized()
        .encodeMap<GetDownloadUrlResult>(this as GetDownloadUrlResult);
  }

  GetDownloadUrlResultCopyWith<
    GetDownloadUrlResult,
    GetDownloadUrlResult,
    GetDownloadUrlResult
  >
  get copyWith =>
      _GetDownloadUrlResultCopyWithImpl<
        GetDownloadUrlResult,
        GetDownloadUrlResult
      >(this as GetDownloadUrlResult, $identity, $identity);
  @override
  String toString() {
    return GetDownloadUrlResultMapper.ensureInitialized().stringifyValue(
      this as GetDownloadUrlResult,
    );
  }

  @override
  bool operator ==(Object other) {
    return GetDownloadUrlResultMapper.ensureInitialized().equalsValue(
      this as GetDownloadUrlResult,
      other,
    );
  }

  @override
  int get hashCode {
    return GetDownloadUrlResultMapper.ensureInitialized().hashValue(
      this as GetDownloadUrlResult,
    );
  }
}

extension GetDownloadUrlResultValueCopy<$R, $Out>
    on ObjectCopyWith<$R, GetDownloadUrlResult, $Out> {
  GetDownloadUrlResultCopyWith<$R, GetDownloadUrlResult, $Out>
  get $asGetDownloadUrlResult => $base.as(
    (v, t, t2) => _GetDownloadUrlResultCopyWithImpl<$R, $Out>(v, t, t2),
  );
}

abstract class GetDownloadUrlResultCopyWith<
  $R,
  $In extends GetDownloadUrlResult,
  $Out
>
    implements ClassCopyWith<$R, $In, $Out> {
  $R call({String? url});
  GetDownloadUrlResultCopyWith<$R2, $In, $Out2> $chain<$R2, $Out2>(
    Then<$Out2, $R2> t,
  );
}

class _GetDownloadUrlResultCopyWithImpl<$R, $Out>
    extends ClassCopyWithBase<$R, GetDownloadUrlResult, $Out>
    implements GetDownloadUrlResultCopyWith<$R, GetDownloadUrlResult, $Out> {
  _GetDownloadUrlResultCopyWithImpl(super.value, super.then, super.then2);

  @override
  late final ClassMapperBase<GetDownloadUrlResult> $mapper =
      GetDownloadUrlResultMapper.ensureInitialized();
  @override
  $R call({String? url}) =>
      $apply(FieldCopyWithData({if (url != null) #url: url}));
  @override
  GetDownloadUrlResult $make(CopyWithData data) =>
      GetDownloadUrlResult(url: data.get(#url, or: $value.url));

  @override
  GetDownloadUrlResultCopyWith<$R2, GetDownloadUrlResult, $Out2>
  $chain<$R2, $Out2>(Then<$Out2, $R2> t) =>
      _GetDownloadUrlResultCopyWithImpl<$R2, $Out2>($value, $cast, t);
}

