// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
// ignore_for_file: type=lint
// ignore_for_file: unused_element, unnecessary_cast, override_on_non_overriding_member
// ignore_for_file: strict_raw_type, inference_failure_on_untyped_parameter

part of 'settings.dart';

class SettingsMapper extends ClassMapperBase<Settings> {
  SettingsMapper._();

  static SettingsMapper? _instance;
  static SettingsMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = SettingsMapper._());
      MapperContainer.globals.useAll([SecondsDateTimeMapper()]);
      S3SettingsMapper.ensureInitialized();
      MailSettingsMapper.ensureInitialized();
      OAuthProviderListMapper.ensureInitialized();
    }
    return _instance!;
  }

  @override
  final String id = 'Settings';

  static int _$id(Settings v) => v.id;
  static const Field<Settings, int> _f$id = Field('id', _$id);
  static String _$appName(Settings v) => v.appName;
  static const Field<Settings, String> _f$appName = Field(
    'appName',
    _$appName,
    key: r'app_name',
  );
  static String _$siteUrl(Settings v) => v.siteUrl;
  static const Field<Settings, String> _f$siteUrl = Field(
    'siteUrl',
    _$siteUrl,
    key: r'site_url',
  );
  static List<String> _$redirectUrls(Settings v) => v.redirectUrls;
  static const Field<Settings, List<String>> _f$redirectUrls = Field(
    'redirectUrls',
    _$redirectUrls,
    key: r'redirect_urls',
    opt: true,
    def: const [],
  );
  static S3Settings? _$s3(Settings v) => v.s3;
  static const Field<Settings, S3Settings> _f$s3 = Field('s3', _$s3, opt: true);
  static MailSettings? _$mail(Settings v) => v.mail;
  static const Field<Settings, MailSettings> _f$mail = Field(
    'mail',
    _$mail,
    opt: true,
  );
  static OAuthProviderList _$oauthProviders(Settings v) => v.oauthProviders;
  static const Field<Settings, OAuthProviderList> _f$oauthProviders = Field(
    'oauthProviders',
    _$oauthProviders,
    key: r'oauth_providers',
    opt: true,
    def: const OAuthProviderList(),
  );
  static DateTime _$createdAt(Settings v) => v.createdAt;
  static const Field<Settings, DateTime> _f$createdAt = Field(
    'createdAt',
    _$createdAt,
    key: r'created_at',
  );
  static DateTime _$updatedAt(Settings v) => v.updatedAt;
  static const Field<Settings, DateTime> _f$updatedAt = Field(
    'updatedAt',
    _$updatedAt,
    key: r'updated_at',
  );

  @override
  final MappableFields<Settings> fields = const {
    #id: _f$id,
    #appName: _f$appName,
    #siteUrl: _f$siteUrl,
    #redirectUrls: _f$redirectUrls,
    #s3: _f$s3,
    #mail: _f$mail,
    #oauthProviders: _f$oauthProviders,
    #createdAt: _f$createdAt,
    #updatedAt: _f$updatedAt,
  };

  static Settings _instantiate(DecodingData data) {
    return Settings(
      id: data.dec(_f$id),
      appName: data.dec(_f$appName),
      siteUrl: data.dec(_f$siteUrl),
      redirectUrls: data.dec(_f$redirectUrls),
      s3: data.dec(_f$s3),
      mail: data.dec(_f$mail),
      oauthProviders: data.dec(_f$oauthProviders),
      createdAt: data.dec(_f$createdAt),
      updatedAt: data.dec(_f$updatedAt),
    );
  }

  @override
  final Function instantiate = _instantiate;

  static Settings fromJson(Map<String, dynamic> map) {
    return ensureInitialized().decodeMap<Settings>(map);
  }

  static Settings fromJsonString(String json) {
    return ensureInitialized().decodeJson<Settings>(json);
  }
}

mixin SettingsMappable {
  String toJsonString() {
    return SettingsMapper.ensureInitialized().encodeJson<Settings>(
      this as Settings,
    );
  }

  Map<String, dynamic> toJson() {
    return SettingsMapper.ensureInitialized().encodeMap<Settings>(
      this as Settings,
    );
  }

  SettingsCopyWith<Settings, Settings, Settings> get copyWith =>
      _SettingsCopyWithImpl<Settings, Settings>(
        this as Settings,
        $identity,
        $identity,
      );
  @override
  String toString() {
    return SettingsMapper.ensureInitialized().stringifyValue(this as Settings);
  }

  @override
  bool operator ==(Object other) {
    return SettingsMapper.ensureInitialized().equalsValue(
      this as Settings,
      other,
    );
  }

  @override
  int get hashCode {
    return SettingsMapper.ensureInitialized().hashValue(this as Settings);
  }
}

extension SettingsValueCopy<$R, $Out> on ObjectCopyWith<$R, Settings, $Out> {
  SettingsCopyWith<$R, Settings, $Out> get $asSettings =>
      $base.as((v, t, t2) => _SettingsCopyWithImpl<$R, $Out>(v, t, t2));
}

abstract class SettingsCopyWith<$R, $In extends Settings, $Out>
    implements ClassCopyWith<$R, $In, $Out> {
  ListCopyWith<$R, String, ObjectCopyWith<$R, String, String>> get redirectUrls;
  S3SettingsCopyWith<$R, S3Settings, S3Settings>? get s3;
  MailSettingsCopyWith<$R, MailSettings, MailSettings>? get mail;
  OAuthProviderListCopyWith<$R, OAuthProviderList, OAuthProviderList>
  get oauthProviders;
  $R call({
    int? id,
    String? appName,
    String? siteUrl,
    List<String>? redirectUrls,
    S3Settings? s3,
    MailSettings? mail,
    OAuthProviderList? oauthProviders,
    DateTime? createdAt,
    DateTime? updatedAt,
  });
  SettingsCopyWith<$R2, $In, $Out2> $chain<$R2, $Out2>(Then<$Out2, $R2> t);
}

class _SettingsCopyWithImpl<$R, $Out>
    extends ClassCopyWithBase<$R, Settings, $Out>
    implements SettingsCopyWith<$R, Settings, $Out> {
  _SettingsCopyWithImpl(super.value, super.then, super.then2);

  @override
  late final ClassMapperBase<Settings> $mapper =
      SettingsMapper.ensureInitialized();
  @override
  ListCopyWith<$R, String, ObjectCopyWith<$R, String, String>>
  get redirectUrls => ListCopyWith(
    $value.redirectUrls,
    (v, t) => ObjectCopyWith(v, $identity, t),
    (v) => call(redirectUrls: v),
  );
  @override
  S3SettingsCopyWith<$R, S3Settings, S3Settings>? get s3 =>
      $value.s3?.copyWith.$chain((v) => call(s3: v));
  @override
  MailSettingsCopyWith<$R, MailSettings, MailSettings>? get mail =>
      $value.mail?.copyWith.$chain((v) => call(mail: v));
  @override
  OAuthProviderListCopyWith<$R, OAuthProviderList, OAuthProviderList>
  get oauthProviders =>
      $value.oauthProviders.copyWith.$chain((v) => call(oauthProviders: v));
  @override
  $R call({
    int? id,
    String? appName,
    String? siteUrl,
    List<String>? redirectUrls,
    Object? s3 = $none,
    Object? mail = $none,
    OAuthProviderList? oauthProviders,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) => $apply(
    FieldCopyWithData({
      if (id != null) #id: id,
      if (appName != null) #appName: appName,
      if (siteUrl != null) #siteUrl: siteUrl,
      if (redirectUrls != null) #redirectUrls: redirectUrls,
      if (s3 != $none) #s3: s3,
      if (mail != $none) #mail: mail,
      if (oauthProviders != null) #oauthProviders: oauthProviders,
      if (createdAt != null) #createdAt: createdAt,
      if (updatedAt != null) #updatedAt: updatedAt,
    }),
  );
  @override
  Settings $make(CopyWithData data) => Settings(
    id: data.get(#id, or: $value.id),
    appName: data.get(#appName, or: $value.appName),
    siteUrl: data.get(#siteUrl, or: $value.siteUrl),
    redirectUrls: data.get(#redirectUrls, or: $value.redirectUrls),
    s3: data.get(#s3, or: $value.s3),
    mail: data.get(#mail, or: $value.mail),
    oauthProviders: data.get(#oauthProviders, or: $value.oauthProviders),
    createdAt: data.get(#createdAt, or: $value.createdAt),
    updatedAt: data.get(#updatedAt, or: $value.updatedAt),
  );

  @override
  SettingsCopyWith<$R2, Settings, $Out2> $chain<$R2, $Out2>(
    Then<$Out2, $R2> t,
  ) => _SettingsCopyWithImpl<$R2, $Out2>($value, $cast, t);
}

