// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
// ignore_for_file: type=lint
// ignore_for_file: unused_element, unnecessary_cast, override_on_non_overriding_member
// ignore_for_file: strict_raw_type, inference_failure_on_untyped_parameter

part of 'mail_settings.dart';

class MailSettingsMapper extends ClassMapperBase<MailSettings> {
  MailSettingsMapper._();

  static MailSettingsMapper? _instance;
  static MailSettingsMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = MailSettingsMapper._());
    }
    return _instance!;
  }

  @override
  final String id = 'MailSettings';

  static String _$smtpServer(MailSettings v) => v.smtpServer;
  static const Field<MailSettings, String> _f$smtpServer = Field(
    'smtpServer',
    _$smtpServer,
    key: r'smtp_server',
  );
  static String _$fromAddress(MailSettings v) => v.fromAddress;
  static const Field<MailSettings, String> _f$fromAddress = Field(
    'fromAddress',
    _$fromAddress,
    key: r'from_address',
  );
  static String _$fromName(MailSettings v) => v.fromName;
  static const Field<MailSettings, String> _f$fromName = Field(
    'fromName',
    _$fromName,
    key: r'from_name',
  );
  static int _$smtpPort(MailSettings v) => v.smtpPort;
  static const Field<MailSettings, int> _f$smtpPort = Field(
    'smtpPort',
    _$smtpPort,
    key: r'smtp_port',
    opt: true,
    def: 587,
  );
  static String? _$username(MailSettings v) => v.username;
  static const Field<MailSettings, String> _f$username = Field(
    'username',
    _$username,
    opt: true,
  );
  static String? _$password(MailSettings v) => v.password;
  static const Field<MailSettings, String> _f$password = Field(
    'password',
    _$password,
    opt: true,
  );
  static bool _$useSsl(MailSettings v) => v.useSsl;
  static const Field<MailSettings, bool> _f$useSsl = Field(
    'useSsl',
    _$useSsl,
    key: r'use_ssl',
    opt: true,
    def: false,
  );
  static String? _$otpTemplate(MailSettings v) => v.otpTemplate;
  static const Field<MailSettings, String> _f$otpTemplate = Field(
    'otpTemplate',
    _$otpTemplate,
    key: r'otp_template',
    opt: true,
  );
  static String? _$resetPasswordTemplate(MailSettings v) =>
      v.resetPasswordTemplate;
  static const Field<MailSettings, String> _f$resetPasswordTemplate = Field(
    'resetPasswordTemplate',
    _$resetPasswordTemplate,
    key: r'reset_password_template',
    opt: true,
  );

  @override
  final MappableFields<MailSettings> fields = const {
    #smtpServer: _f$smtpServer,
    #fromAddress: _f$fromAddress,
    #fromName: _f$fromName,
    #smtpPort: _f$smtpPort,
    #username: _f$username,
    #password: _f$password,
    #useSsl: _f$useSsl,
    #otpTemplate: _f$otpTemplate,
    #resetPasswordTemplate: _f$resetPasswordTemplate,
  };

  static MailSettings _instantiate(DecodingData data) {
    return MailSettings(
      smtpServer: data.dec(_f$smtpServer),
      fromAddress: data.dec(_f$fromAddress),
      fromName: data.dec(_f$fromName),
      smtpPort: data.dec(_f$smtpPort),
      username: data.dec(_f$username),
      password: data.dec(_f$password),
      useSsl: data.dec(_f$useSsl),
      otpTemplate: data.dec(_f$otpTemplate),
      resetPasswordTemplate: data.dec(_f$resetPasswordTemplate),
    );
  }

  @override
  final Function instantiate = _instantiate;

  static MailSettings fromJson(Map<String, dynamic> map) {
    return ensureInitialized().decodeMap<MailSettings>(map);
  }

  static MailSettings fromJsonString(String json) {
    return ensureInitialized().decodeJson<MailSettings>(json);
  }
}

mixin MailSettingsMappable {
  String toJsonString() {
    return MailSettingsMapper.ensureInitialized().encodeJson<MailSettings>(
      this as MailSettings,
    );
  }

  Map<String, dynamic> toJson() {
    return MailSettingsMapper.ensureInitialized().encodeMap<MailSettings>(
      this as MailSettings,
    );
  }

  MailSettingsCopyWith<MailSettings, MailSettings, MailSettings> get copyWith =>
      _MailSettingsCopyWithImpl<MailSettings, MailSettings>(
        this as MailSettings,
        $identity,
        $identity,
      );
  @override
  String toString() {
    return MailSettingsMapper.ensureInitialized().stringifyValue(
      this as MailSettings,
    );
  }

  @override
  bool operator ==(Object other) {
    return MailSettingsMapper.ensureInitialized().equalsValue(
      this as MailSettings,
      other,
    );
  }

  @override
  int get hashCode {
    return MailSettingsMapper.ensureInitialized().hashValue(
      this as MailSettings,
    );
  }
}

extension MailSettingsValueCopy<$R, $Out>
    on ObjectCopyWith<$R, MailSettings, $Out> {
  MailSettingsCopyWith<$R, MailSettings, $Out> get $asMailSettings =>
      $base.as((v, t, t2) => _MailSettingsCopyWithImpl<$R, $Out>(v, t, t2));
}

abstract class MailSettingsCopyWith<$R, $In extends MailSettings, $Out>
    implements ClassCopyWith<$R, $In, $Out> {
  $R call({
    String? smtpServer,
    String? fromAddress,
    String? fromName,
    int? smtpPort,
    String? username,
    String? password,
    bool? useSsl,
    String? otpTemplate,
    String? resetPasswordTemplate,
  });
  MailSettingsCopyWith<$R2, $In, $Out2> $chain<$R2, $Out2>(Then<$Out2, $R2> t);
}

class _MailSettingsCopyWithImpl<$R, $Out>
    extends ClassCopyWithBase<$R, MailSettings, $Out>
    implements MailSettingsCopyWith<$R, MailSettings, $Out> {
  _MailSettingsCopyWithImpl(super.value, super.then, super.then2);

  @override
  late final ClassMapperBase<MailSettings> $mapper =
      MailSettingsMapper.ensureInitialized();
  @override
  $R call({
    String? smtpServer,
    String? fromAddress,
    String? fromName,
    int? smtpPort,
    Object? username = $none,
    Object? password = $none,
    bool? useSsl,
    Object? otpTemplate = $none,
    Object? resetPasswordTemplate = $none,
  }) => $apply(
    FieldCopyWithData({
      if (smtpServer != null) #smtpServer: smtpServer,
      if (fromAddress != null) #fromAddress: fromAddress,
      if (fromName != null) #fromName: fromName,
      if (smtpPort != null) #smtpPort: smtpPort,
      if (username != $none) #username: username,
      if (password != $none) #password: password,
      if (useSsl != null) #useSsl: useSsl,
      if (otpTemplate != $none) #otpTemplate: otpTemplate,
      if (resetPasswordTemplate != $none)
        #resetPasswordTemplate: resetPasswordTemplate,
    }),
  );
  @override
  MailSettings $make(CopyWithData data) => MailSettings(
    smtpServer: data.get(#smtpServer, or: $value.smtpServer),
    fromAddress: data.get(#fromAddress, or: $value.fromAddress),
    fromName: data.get(#fromName, or: $value.fromName),
    smtpPort: data.get(#smtpPort, or: $value.smtpPort),
    username: data.get(#username, or: $value.username),
    password: data.get(#password, or: $value.password),
    useSsl: data.get(#useSsl, or: $value.useSsl),
    otpTemplate: data.get(#otpTemplate, or: $value.otpTemplate),
    resetPasswordTemplate: data.get(
      #resetPasswordTemplate,
      or: $value.resetPasswordTemplate,
    ),
  );

  @override
  MailSettingsCopyWith<$R2, MailSettings, $Out2> $chain<$R2, $Out2>(
    Then<$Out2, $R2> t,
  ) => _MailSettingsCopyWithImpl<$R2, $Out2>($value, $cast, t);
}

