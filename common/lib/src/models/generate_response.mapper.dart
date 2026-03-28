// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
// ignore_for_file: type=lint
// ignore_for_file: unused_element, unnecessary_cast, override_on_non_overriding_member
// ignore_for_file: strict_raw_type, inference_failure_on_untyped_parameter

part of 'generate_response.dart';

class GenerateResponseMapper extends ClassMapperBase<GenerateResponse> {
  GenerateResponseMapper._();

  static GenerateResponseMapper? _instance;
  static GenerateResponseMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = GenerateResponseMapper._());
    }
    return _instance!;
  }

  @override
  final String id = 'GenerateResponse';

  static int _$count(GenerateResponse v) => v.count;
  static const Field<GenerateResponse, int> _f$count = Field('count', _$count);

  @override
  final MappableFields<GenerateResponse> fields = const {#count: _f$count};

  static GenerateResponse _instantiate(DecodingData data) {
    return GenerateResponse(count: data.dec(_f$count));
  }

  @override
  final Function instantiate = _instantiate;

  static GenerateResponse fromJson(Map<String, dynamic> map) {
    return ensureInitialized().decodeMap<GenerateResponse>(map);
  }

  static GenerateResponse fromJsonString(String json) {
    return ensureInitialized().decodeJson<GenerateResponse>(json);
  }
}

mixin GenerateResponseMappable {
  String toJsonString() {
    return GenerateResponseMapper.ensureInitialized()
        .encodeJson<GenerateResponse>(this as GenerateResponse);
  }

  Map<String, dynamic> toJson() {
    return GenerateResponseMapper.ensureInitialized()
        .encodeMap<GenerateResponse>(this as GenerateResponse);
  }

  GenerateResponseCopyWith<GenerateResponse, GenerateResponse, GenerateResponse>
  get copyWith =>
      _GenerateResponseCopyWithImpl<GenerateResponse, GenerateResponse>(
        this as GenerateResponse,
        $identity,
        $identity,
      );
  @override
  String toString() {
    return GenerateResponseMapper.ensureInitialized().stringifyValue(
      this as GenerateResponse,
    );
  }

  @override
  bool operator ==(Object other) {
    return GenerateResponseMapper.ensureInitialized().equalsValue(
      this as GenerateResponse,
      other,
    );
  }

  @override
  int get hashCode {
    return GenerateResponseMapper.ensureInitialized().hashValue(
      this as GenerateResponse,
    );
  }
}

extension GenerateResponseValueCopy<$R, $Out>
    on ObjectCopyWith<$R, GenerateResponse, $Out> {
  GenerateResponseCopyWith<$R, GenerateResponse, $Out>
  get $asGenerateResponse =>
      $base.as((v, t, t2) => _GenerateResponseCopyWithImpl<$R, $Out>(v, t, t2));
}

abstract class GenerateResponseCopyWith<$R, $In extends GenerateResponse, $Out>
    implements ClassCopyWith<$R, $In, $Out> {
  $R call({int? count});
  GenerateResponseCopyWith<$R2, $In, $Out2> $chain<$R2, $Out2>(
    Then<$Out2, $R2> t,
  );
}

class _GenerateResponseCopyWithImpl<$R, $Out>
    extends ClassCopyWithBase<$R, GenerateResponse, $Out>
    implements GenerateResponseCopyWith<$R, GenerateResponse, $Out> {
  _GenerateResponseCopyWithImpl(super.value, super.then, super.then2);

  @override
  late final ClassMapperBase<GenerateResponse> $mapper =
      GenerateResponseMapper.ensureInitialized();
  @override
  $R call({int? count}) =>
      $apply(FieldCopyWithData({if (count != null) #count: count}));
  @override
  GenerateResponse $make(CopyWithData data) =>
      GenerateResponse(count: data.get(#count, or: $value.count));

  @override
  GenerateResponseCopyWith<$R2, GenerateResponse, $Out2> $chain<$R2, $Out2>(
    Then<$Out2, $R2> t,
  ) => _GenerateResponseCopyWithImpl<$R2, $Out2>($value, $cast, t);
}

