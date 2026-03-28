// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
// ignore_for_file: type=lint
// ignore_for_file: unused_element, unnecessary_cast, override_on_non_overriding_member
// ignore_for_file: strict_raw_type, inference_failure_on_untyped_parameter

part of 's3_settings.dart';

class S3SettingsMapper extends ClassMapperBase<S3Settings> {
  S3SettingsMapper._();

  static S3SettingsMapper? _instance;
  static S3SettingsMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = S3SettingsMapper._());
    }
    return _instance!;
  }

  @override
  final String id = 'S3Settings';

  static String _$endpoint(S3Settings v) => v.endpoint;
  static const Field<S3Settings, String> _f$endpoint = Field(
    'endpoint',
    _$endpoint,
  );
  static String _$bucket(S3Settings v) => v.bucket;
  static const Field<S3Settings, String> _f$bucket = Field('bucket', _$bucket);
  static String _$region(S3Settings v) => v.region;
  static const Field<S3Settings, String> _f$region = Field('region', _$region);
  static String _$accessKey(S3Settings v) => v.accessKey;
  static const Field<S3Settings, String> _f$accessKey = Field(
    'accessKey',
    _$accessKey,
    key: r'access_key',
  );
  static String _$secretKey(S3Settings v) => v.secretKey;
  static const Field<S3Settings, String> _f$secretKey = Field(
    'secretKey',
    _$secretKey,
    key: r'secret_key',
  );
  static bool _$enabled(S3Settings v) => v.enabled;
  static const Field<S3Settings, bool> _f$enabled = Field(
    'enabled',
    _$enabled,
    opt: true,
    def: false,
  );

  @override
  final MappableFields<S3Settings> fields = const {
    #endpoint: _f$endpoint,
    #bucket: _f$bucket,
    #region: _f$region,
    #accessKey: _f$accessKey,
    #secretKey: _f$secretKey,
    #enabled: _f$enabled,
  };

  static S3Settings _instantiate(DecodingData data) {
    return S3Settings(
      endpoint: data.dec(_f$endpoint),
      bucket: data.dec(_f$bucket),
      region: data.dec(_f$region),
      accessKey: data.dec(_f$accessKey),
      secretKey: data.dec(_f$secretKey),
      enabled: data.dec(_f$enabled),
    );
  }

  @override
  final Function instantiate = _instantiate;

  static S3Settings fromJson(Map<String, dynamic> map) {
    return ensureInitialized().decodeMap<S3Settings>(map);
  }

  static S3Settings fromJsonString(String json) {
    return ensureInitialized().decodeJson<S3Settings>(json);
  }
}

mixin S3SettingsMappable {
  String toJsonString() {
    return S3SettingsMapper.ensureInitialized().encodeJson<S3Settings>(
      this as S3Settings,
    );
  }

  Map<String, dynamic> toJson() {
    return S3SettingsMapper.ensureInitialized().encodeMap<S3Settings>(
      this as S3Settings,
    );
  }

  S3SettingsCopyWith<S3Settings, S3Settings, S3Settings> get copyWith =>
      _S3SettingsCopyWithImpl<S3Settings, S3Settings>(
        this as S3Settings,
        $identity,
        $identity,
      );
  @override
  String toString() {
    return S3SettingsMapper.ensureInitialized().stringifyValue(
      this as S3Settings,
    );
  }

  @override
  bool operator ==(Object other) {
    return S3SettingsMapper.ensureInitialized().equalsValue(
      this as S3Settings,
      other,
    );
  }

  @override
  int get hashCode {
    return S3SettingsMapper.ensureInitialized().hashValue(this as S3Settings);
  }
}

extension S3SettingsValueCopy<$R, $Out>
    on ObjectCopyWith<$R, S3Settings, $Out> {
  S3SettingsCopyWith<$R, S3Settings, $Out> get $asS3Settings =>
      $base.as((v, t, t2) => _S3SettingsCopyWithImpl<$R, $Out>(v, t, t2));
}

abstract class S3SettingsCopyWith<$R, $In extends S3Settings, $Out>
    implements ClassCopyWith<$R, $In, $Out> {
  $R call({
    String? endpoint,
    String? bucket,
    String? region,
    String? accessKey,
    String? secretKey,
    bool? enabled,
  });
  S3SettingsCopyWith<$R2, $In, $Out2> $chain<$R2, $Out2>(Then<$Out2, $R2> t);
}

class _S3SettingsCopyWithImpl<$R, $Out>
    extends ClassCopyWithBase<$R, S3Settings, $Out>
    implements S3SettingsCopyWith<$R, S3Settings, $Out> {
  _S3SettingsCopyWithImpl(super.value, super.then, super.then2);

  @override
  late final ClassMapperBase<S3Settings> $mapper =
      S3SettingsMapper.ensureInitialized();
  @override
  $R call({
    String? endpoint,
    String? bucket,
    String? region,
    String? accessKey,
    String? secretKey,
    bool? enabled,
  }) => $apply(
    FieldCopyWithData({
      if (endpoint != null) #endpoint: endpoint,
      if (bucket != null) #bucket: bucket,
      if (region != null) #region: region,
      if (accessKey != null) #accessKey: accessKey,
      if (secretKey != null) #secretKey: secretKey,
      if (enabled != null) #enabled: enabled,
    }),
  );
  @override
  S3Settings $make(CopyWithData data) => S3Settings(
    endpoint: data.get(#endpoint, or: $value.endpoint),
    bucket: data.get(#bucket, or: $value.bucket),
    region: data.get(#region, or: $value.region),
    accessKey: data.get(#accessKey, or: $value.accessKey),
    secretKey: data.get(#secretKey, or: $value.secretKey),
    enabled: data.get(#enabled, or: $value.enabled),
  );

  @override
  S3SettingsCopyWith<$R2, S3Settings, $Out2> $chain<$R2, $Out2>(
    Then<$Out2, $R2> t,
  ) => _S3SettingsCopyWithImpl<$R2, $Out2>($value, $cast, t);
}

