// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
// ignore_for_file: type=lint
// ignore_for_file: unused_element, unnecessary_cast, override_on_non_overriding_member
// ignore_for_file: strict_raw_type, inference_failure_on_untyped_parameter

part of 'oauth_provider.dart';

class OAuthProviderMapper extends ClassMapperBase<OAuthProvider> {
  OAuthProviderMapper._();

  static OAuthProviderMapper? _instance;
  static OAuthProviderMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = OAuthProviderMapper._());
    }
    return _instance!;
  }

  @override
  final String id = 'OAuthProvider';

  static String _$clientId(OAuthProvider v) => v.clientId;
  static const Field<OAuthProvider, String> _f$clientId = Field(
    'clientId',
    _$clientId,
    key: r'client_id',
  );
  static String _$clientSecret(OAuthProvider v) => v.clientSecret;
  static const Field<OAuthProvider, String> _f$clientSecret = Field(
    'clientSecret',
    _$clientSecret,
    key: r'client_secret',
  );
  static bool _$enabled(OAuthProvider v) => v.enabled;
  static const Field<OAuthProvider, bool> _f$enabled = Field(
    'enabled',
    _$enabled,
    opt: true,
    def: true,
  );

  @override
  final MappableFields<OAuthProvider> fields = const {
    #clientId: _f$clientId,
    #clientSecret: _f$clientSecret,
    #enabled: _f$enabled,
  };

  static OAuthProvider _instantiate(DecodingData data) {
    return OAuthProvider(
      clientId: data.dec(_f$clientId),
      clientSecret: data.dec(_f$clientSecret),
      enabled: data.dec(_f$enabled),
    );
  }

  @override
  final Function instantiate = _instantiate;

  static OAuthProvider fromJson(Map<String, dynamic> map) {
    return ensureInitialized().decodeMap<OAuthProvider>(map);
  }

  static OAuthProvider fromJsonString(String json) {
    return ensureInitialized().decodeJson<OAuthProvider>(json);
  }
}

mixin OAuthProviderMappable {
  String toJsonString() {
    return OAuthProviderMapper.ensureInitialized().encodeJson<OAuthProvider>(
      this as OAuthProvider,
    );
  }

  Map<String, dynamic> toJson() {
    return OAuthProviderMapper.ensureInitialized().encodeMap<OAuthProvider>(
      this as OAuthProvider,
    );
  }

  OAuthProviderCopyWith<OAuthProvider, OAuthProvider, OAuthProvider>
  get copyWith => _OAuthProviderCopyWithImpl<OAuthProvider, OAuthProvider>(
    this as OAuthProvider,
    $identity,
    $identity,
  );
  @override
  String toString() {
    return OAuthProviderMapper.ensureInitialized().stringifyValue(
      this as OAuthProvider,
    );
  }

  @override
  bool operator ==(Object other) {
    return OAuthProviderMapper.ensureInitialized().equalsValue(
      this as OAuthProvider,
      other,
    );
  }

  @override
  int get hashCode {
    return OAuthProviderMapper.ensureInitialized().hashValue(
      this as OAuthProvider,
    );
  }
}

extension OAuthProviderValueCopy<$R, $Out>
    on ObjectCopyWith<$R, OAuthProvider, $Out> {
  OAuthProviderCopyWith<$R, OAuthProvider, $Out> get $asOAuthProvider =>
      $base.as((v, t, t2) => _OAuthProviderCopyWithImpl<$R, $Out>(v, t, t2));
}

abstract class OAuthProviderCopyWith<$R, $In extends OAuthProvider, $Out>
    implements ClassCopyWith<$R, $In, $Out> {
  $R call({String? clientId, String? clientSecret, bool? enabled});
  OAuthProviderCopyWith<$R2, $In, $Out2> $chain<$R2, $Out2>(Then<$Out2, $R2> t);
}

class _OAuthProviderCopyWithImpl<$R, $Out>
    extends ClassCopyWithBase<$R, OAuthProvider, $Out>
    implements OAuthProviderCopyWith<$R, OAuthProvider, $Out> {
  _OAuthProviderCopyWithImpl(super.value, super.then, super.then2);

  @override
  late final ClassMapperBase<OAuthProvider> $mapper =
      OAuthProviderMapper.ensureInitialized();
  @override
  $R call({String? clientId, String? clientSecret, bool? enabled}) => $apply(
    FieldCopyWithData({
      if (clientId != null) #clientId: clientId,
      if (clientSecret != null) #clientSecret: clientSecret,
      if (enabled != null) #enabled: enabled,
    }),
  );
  @override
  OAuthProvider $make(CopyWithData data) => OAuthProvider(
    clientId: data.get(#clientId, or: $value.clientId),
    clientSecret: data.get(#clientSecret, or: $value.clientSecret),
    enabled: data.get(#enabled, or: $value.enabled),
  );

  @override
  OAuthProviderCopyWith<$R2, OAuthProvider, $Out2> $chain<$R2, $Out2>(
    Then<$Out2, $R2> t,
  ) => _OAuthProviderCopyWithImpl<$R2, $Out2>($value, $cast, t);
}

class OAuthProviderListMapper extends ClassMapperBase<OAuthProviderList> {
  OAuthProviderListMapper._();

  static OAuthProviderListMapper? _instance;
  static OAuthProviderListMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = OAuthProviderListMapper._());
      OAuthProviderMapper.ensureInitialized();
    }
    return _instance!;
  }

  @override
  final String id = 'OAuthProviderList';

  static OAuthProvider? _$google(OAuthProviderList v) => v.google;
  static const Field<OAuthProviderList, OAuthProvider> _f$google = Field(
    'google',
    _$google,
    opt: true,
  );
  static OAuthProvider? _$apple(OAuthProviderList v) => v.apple;
  static const Field<OAuthProviderList, OAuthProvider> _f$apple = Field(
    'apple',
    _$apple,
    opt: true,
  );
  static OAuthProvider? _$facebook(OAuthProviderList v) => v.facebook;
  static const Field<OAuthProviderList, OAuthProvider> _f$facebook = Field(
    'facebook',
    _$facebook,
    opt: true,
  );
  static OAuthProvider? _$github(OAuthProviderList v) => v.github;
  static const Field<OAuthProviderList, OAuthProvider> _f$github = Field(
    'github',
    _$github,
    opt: true,
  );
  static OAuthProvider? _$linkedin(OAuthProviderList v) => v.linkedin;
  static const Field<OAuthProviderList, OAuthProvider> _f$linkedin = Field(
    'linkedin',
    _$linkedin,
    opt: true,
  );
  static OAuthProvider? _$slack(OAuthProviderList v) => v.slack;
  static const Field<OAuthProviderList, OAuthProvider> _f$slack = Field(
    'slack',
    _$slack,
    opt: true,
  );
  static OAuthProvider? _$spotify(OAuthProviderList v) => v.spotify;
  static const Field<OAuthProviderList, OAuthProvider> _f$spotify = Field(
    'spotify',
    _$spotify,
    opt: true,
  );
  static OAuthProvider? _$reddit(OAuthProviderList v) => v.reddit;
  static const Field<OAuthProviderList, OAuthProvider> _f$reddit = Field(
    'reddit',
    _$reddit,
    opt: true,
  );
  static OAuthProvider? _$twitch(OAuthProviderList v) => v.twitch;
  static const Field<OAuthProviderList, OAuthProvider> _f$twitch = Field(
    'twitch',
    _$twitch,
    opt: true,
  );
  static OAuthProvider? _$discord(OAuthProviderList v) => v.discord;
  static const Field<OAuthProviderList, OAuthProvider> _f$discord = Field(
    'discord',
    _$discord,
    opt: true,
  );

  @override
  final MappableFields<OAuthProviderList> fields = const {
    #google: _f$google,
    #apple: _f$apple,
    #facebook: _f$facebook,
    #github: _f$github,
    #linkedin: _f$linkedin,
    #slack: _f$slack,
    #spotify: _f$spotify,
    #reddit: _f$reddit,
    #twitch: _f$twitch,
    #discord: _f$discord,
  };

  static OAuthProviderList _instantiate(DecodingData data) {
    return OAuthProviderList(
      google: data.dec(_f$google),
      apple: data.dec(_f$apple),
      facebook: data.dec(_f$facebook),
      github: data.dec(_f$github),
      linkedin: data.dec(_f$linkedin),
      slack: data.dec(_f$slack),
      spotify: data.dec(_f$spotify),
      reddit: data.dec(_f$reddit),
      twitch: data.dec(_f$twitch),
      discord: data.dec(_f$discord),
    );
  }

  @override
  final Function instantiate = _instantiate;

  static OAuthProviderList fromJson(Map<String, dynamic> map) {
    return ensureInitialized().decodeMap<OAuthProviderList>(map);
  }

  static OAuthProviderList fromJsonString(String json) {
    return ensureInitialized().decodeJson<OAuthProviderList>(json);
  }
}

mixin OAuthProviderListMappable {
  String toJsonString() {
    return OAuthProviderListMapper.ensureInitialized()
        .encodeJson<OAuthProviderList>(this as OAuthProviderList);
  }

  Map<String, dynamic> toJson() {
    return OAuthProviderListMapper.ensureInitialized()
        .encodeMap<OAuthProviderList>(this as OAuthProviderList);
  }

  OAuthProviderListCopyWith<
    OAuthProviderList,
    OAuthProviderList,
    OAuthProviderList
  >
  get copyWith =>
      _OAuthProviderListCopyWithImpl<OAuthProviderList, OAuthProviderList>(
        this as OAuthProviderList,
        $identity,
        $identity,
      );
  @override
  String toString() {
    return OAuthProviderListMapper.ensureInitialized().stringifyValue(
      this as OAuthProviderList,
    );
  }

  @override
  bool operator ==(Object other) {
    return OAuthProviderListMapper.ensureInitialized().equalsValue(
      this as OAuthProviderList,
      other,
    );
  }

  @override
  int get hashCode {
    return OAuthProviderListMapper.ensureInitialized().hashValue(
      this as OAuthProviderList,
    );
  }
}

extension OAuthProviderListValueCopy<$R, $Out>
    on ObjectCopyWith<$R, OAuthProviderList, $Out> {
  OAuthProviderListCopyWith<$R, OAuthProviderList, $Out>
  get $asOAuthProviderList => $base.as(
    (v, t, t2) => _OAuthProviderListCopyWithImpl<$R, $Out>(v, t, t2),
  );
}

abstract class OAuthProviderListCopyWith<
  $R,
  $In extends OAuthProviderList,
  $Out
>
    implements ClassCopyWith<$R, $In, $Out> {
  OAuthProviderCopyWith<$R, OAuthProvider, OAuthProvider>? get google;
  OAuthProviderCopyWith<$R, OAuthProvider, OAuthProvider>? get apple;
  OAuthProviderCopyWith<$R, OAuthProvider, OAuthProvider>? get facebook;
  OAuthProviderCopyWith<$R, OAuthProvider, OAuthProvider>? get github;
  OAuthProviderCopyWith<$R, OAuthProvider, OAuthProvider>? get linkedin;
  OAuthProviderCopyWith<$R, OAuthProvider, OAuthProvider>? get slack;
  OAuthProviderCopyWith<$R, OAuthProvider, OAuthProvider>? get spotify;
  OAuthProviderCopyWith<$R, OAuthProvider, OAuthProvider>? get reddit;
  OAuthProviderCopyWith<$R, OAuthProvider, OAuthProvider>? get twitch;
  OAuthProviderCopyWith<$R, OAuthProvider, OAuthProvider>? get discord;
  $R call({
    OAuthProvider? google,
    OAuthProvider? apple,
    OAuthProvider? facebook,
    OAuthProvider? github,
    OAuthProvider? linkedin,
    OAuthProvider? slack,
    OAuthProvider? spotify,
    OAuthProvider? reddit,
    OAuthProvider? twitch,
    OAuthProvider? discord,
  });
  OAuthProviderListCopyWith<$R2, $In, $Out2> $chain<$R2, $Out2>(
    Then<$Out2, $R2> t,
  );
}

class _OAuthProviderListCopyWithImpl<$R, $Out>
    extends ClassCopyWithBase<$R, OAuthProviderList, $Out>
    implements OAuthProviderListCopyWith<$R, OAuthProviderList, $Out> {
  _OAuthProviderListCopyWithImpl(super.value, super.then, super.then2);

  @override
  late final ClassMapperBase<OAuthProviderList> $mapper =
      OAuthProviderListMapper.ensureInitialized();
  @override
  OAuthProviderCopyWith<$R, OAuthProvider, OAuthProvider>? get google =>
      $value.google?.copyWith.$chain((v) => call(google: v));
  @override
  OAuthProviderCopyWith<$R, OAuthProvider, OAuthProvider>? get apple =>
      $value.apple?.copyWith.$chain((v) => call(apple: v));
  @override
  OAuthProviderCopyWith<$R, OAuthProvider, OAuthProvider>? get facebook =>
      $value.facebook?.copyWith.$chain((v) => call(facebook: v));
  @override
  OAuthProviderCopyWith<$R, OAuthProvider, OAuthProvider>? get github =>
      $value.github?.copyWith.$chain((v) => call(github: v));
  @override
  OAuthProviderCopyWith<$R, OAuthProvider, OAuthProvider>? get linkedin =>
      $value.linkedin?.copyWith.$chain((v) => call(linkedin: v));
  @override
  OAuthProviderCopyWith<$R, OAuthProvider, OAuthProvider>? get slack =>
      $value.slack?.copyWith.$chain((v) => call(slack: v));
  @override
  OAuthProviderCopyWith<$R, OAuthProvider, OAuthProvider>? get spotify =>
      $value.spotify?.copyWith.$chain((v) => call(spotify: v));
  @override
  OAuthProviderCopyWith<$R, OAuthProvider, OAuthProvider>? get reddit =>
      $value.reddit?.copyWith.$chain((v) => call(reddit: v));
  @override
  OAuthProviderCopyWith<$R, OAuthProvider, OAuthProvider>? get twitch =>
      $value.twitch?.copyWith.$chain((v) => call(twitch: v));
  @override
  OAuthProviderCopyWith<$R, OAuthProvider, OAuthProvider>? get discord =>
      $value.discord?.copyWith.$chain((v) => call(discord: v));
  @override
  $R call({
    Object? google = $none,
    Object? apple = $none,
    Object? facebook = $none,
    Object? github = $none,
    Object? linkedin = $none,
    Object? slack = $none,
    Object? spotify = $none,
    Object? reddit = $none,
    Object? twitch = $none,
    Object? discord = $none,
  }) => $apply(
    FieldCopyWithData({
      if (google != $none) #google: google,
      if (apple != $none) #apple: apple,
      if (facebook != $none) #facebook: facebook,
      if (github != $none) #github: github,
      if (linkedin != $none) #linkedin: linkedin,
      if (slack != $none) #slack: slack,
      if (spotify != $none) #spotify: spotify,
      if (reddit != $none) #reddit: reddit,
      if (twitch != $none) #twitch: twitch,
      if (discord != $none) #discord: discord,
    }),
  );
  @override
  OAuthProviderList $make(CopyWithData data) => OAuthProviderList(
    google: data.get(#google, or: $value.google),
    apple: data.get(#apple, or: $value.apple),
    facebook: data.get(#facebook, or: $value.facebook),
    github: data.get(#github, or: $value.github),
    linkedin: data.get(#linkedin, or: $value.linkedin),
    slack: data.get(#slack, or: $value.slack),
    spotify: data.get(#spotify, or: $value.spotify),
    reddit: data.get(#reddit, or: $value.reddit),
    twitch: data.get(#twitch, or: $value.twitch),
    discord: data.get(#discord, or: $value.discord),
  );

  @override
  OAuthProviderListCopyWith<$R2, OAuthProviderList, $Out2> $chain<$R2, $Out2>(
    Then<$Out2, $R2> t,
  ) => _OAuthProviderListCopyWithImpl<$R2, $Out2>($value, $cast, t);
}

