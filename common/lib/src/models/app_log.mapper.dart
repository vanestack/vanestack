// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
// ignore_for_file: type=lint
// ignore_for_file: unused_element, unnecessary_cast, override_on_non_overriding_member
// ignore_for_file: strict_raw_type, inference_failure_on_untyped_parameter

part of 'app_log.dart';

class AppLogMapper extends ClassMapperBase<AppLog> {
  AppLogMapper._();

  static AppLogMapper? _instance;
  static AppLogMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = AppLogMapper._());
      MapperContainer.globals.useAll([SecondsDateTimeMapper()]);
      LogLevelMapper.ensureInitialized();
      LogSourceMapper.ensureInitialized();
    }
    return _instance!;
  }

  @override
  final String id = 'AppLog';

  static int _$id(AppLog v) => v.id;
  static const Field<AppLog, int> _f$id = Field('id', _$id);
  static LogLevel _$level(AppLog v) => v.level;
  static const Field<AppLog, LogLevel> _f$level = Field('level', _$level);
  static LogSource _$source(AppLog v) => v.source;
  static const Field<AppLog, LogSource> _f$source = Field('source', _$source);
  static String? _$customSource(AppLog v) => v.customSource;
  static const Field<AppLog, String> _f$customSource = Field(
    'customSource',
    _$customSource,
    key: r'custom_source',
    opt: true,
  );
  static String _$message(AppLog v) => v.message;
  static const Field<AppLog, String> _f$message = Field('message', _$message);
  static String? _$context(AppLog v) => v.context;
  static const Field<AppLog, String> _f$context = Field(
    'context',
    _$context,
    opt: true,
  );
  static String? _$userId(AppLog v) => v.userId;
  static const Field<AppLog, String> _f$userId = Field(
    'userId',
    _$userId,
    key: r'user_id',
    opt: true,
  );
  static String? _$error(AppLog v) => v.error;
  static const Field<AppLog, String> _f$error = Field(
    'error',
    _$error,
    opt: true,
  );
  static String? _$stackTrace(AppLog v) => v.stackTrace;
  static const Field<AppLog, String> _f$stackTrace = Field(
    'stackTrace',
    _$stackTrace,
    key: r'stack_trace',
    opt: true,
  );
  static DateTime _$createdAt(AppLog v) => v.createdAt;
  static const Field<AppLog, DateTime> _f$createdAt = Field(
    'createdAt',
    _$createdAt,
    key: r'created_at',
  );

  @override
  final MappableFields<AppLog> fields = const {
    #id: _f$id,
    #level: _f$level,
    #source: _f$source,
    #customSource: _f$customSource,
    #message: _f$message,
    #context: _f$context,
    #userId: _f$userId,
    #error: _f$error,
    #stackTrace: _f$stackTrace,
    #createdAt: _f$createdAt,
  };

  static AppLog _instantiate(DecodingData data) {
    return AppLog(
      id: data.dec(_f$id),
      level: data.dec(_f$level),
      source: data.dec(_f$source),
      customSource: data.dec(_f$customSource),
      message: data.dec(_f$message),
      context: data.dec(_f$context),
      userId: data.dec(_f$userId),
      error: data.dec(_f$error),
      stackTrace: data.dec(_f$stackTrace),
      createdAt: data.dec(_f$createdAt),
    );
  }

  @override
  final Function instantiate = _instantiate;

  static AppLog fromJson(Map<String, dynamic> map) {
    return ensureInitialized().decodeMap<AppLog>(map);
  }

  static AppLog fromJsonString(String json) {
    return ensureInitialized().decodeJson<AppLog>(json);
  }
}

mixin AppLogMappable {
  String toJsonString() {
    return AppLogMapper.ensureInitialized().encodeJson<AppLog>(this as AppLog);
  }

  Map<String, dynamic> toJson() {
    return AppLogMapper.ensureInitialized().encodeMap<AppLog>(this as AppLog);
  }

  AppLogCopyWith<AppLog, AppLog, AppLog> get copyWith =>
      _AppLogCopyWithImpl<AppLog, AppLog>(this as AppLog, $identity, $identity);
  @override
  String toString() {
    return AppLogMapper.ensureInitialized().stringifyValue(this as AppLog);
  }

  @override
  bool operator ==(Object other) {
    return AppLogMapper.ensureInitialized().equalsValue(this as AppLog, other);
  }

  @override
  int get hashCode {
    return AppLogMapper.ensureInitialized().hashValue(this as AppLog);
  }
}

extension AppLogValueCopy<$R, $Out> on ObjectCopyWith<$R, AppLog, $Out> {
  AppLogCopyWith<$R, AppLog, $Out> get $asAppLog =>
      $base.as((v, t, t2) => _AppLogCopyWithImpl<$R, $Out>(v, t, t2));
}

abstract class AppLogCopyWith<$R, $In extends AppLog, $Out>
    implements ClassCopyWith<$R, $In, $Out> {
  $R call({
    int? id,
    LogLevel? level,
    LogSource? source,
    String? customSource,
    String? message,
    String? context,
    String? userId,
    String? error,
    String? stackTrace,
    DateTime? createdAt,
  });
  AppLogCopyWith<$R2, $In, $Out2> $chain<$R2, $Out2>(Then<$Out2, $R2> t);
}

class _AppLogCopyWithImpl<$R, $Out> extends ClassCopyWithBase<$R, AppLog, $Out>
    implements AppLogCopyWith<$R, AppLog, $Out> {
  _AppLogCopyWithImpl(super.value, super.then, super.then2);

  @override
  late final ClassMapperBase<AppLog> $mapper = AppLogMapper.ensureInitialized();
  @override
  $R call({
    int? id,
    LogLevel? level,
    LogSource? source,
    Object? customSource = $none,
    String? message,
    Object? context = $none,
    Object? userId = $none,
    Object? error = $none,
    Object? stackTrace = $none,
    DateTime? createdAt,
  }) => $apply(
    FieldCopyWithData({
      if (id != null) #id: id,
      if (level != null) #level: level,
      if (source != null) #source: source,
      if (customSource != $none) #customSource: customSource,
      if (message != null) #message: message,
      if (context != $none) #context: context,
      if (userId != $none) #userId: userId,
      if (error != $none) #error: error,
      if (stackTrace != $none) #stackTrace: stackTrace,
      if (createdAt != null) #createdAt: createdAt,
    }),
  );
  @override
  AppLog $make(CopyWithData data) => AppLog(
    id: data.get(#id, or: $value.id),
    level: data.get(#level, or: $value.level),
    source: data.get(#source, or: $value.source),
    customSource: data.get(#customSource, or: $value.customSource),
    message: data.get(#message, or: $value.message),
    context: data.get(#context, or: $value.context),
    userId: data.get(#userId, or: $value.userId),
    error: data.get(#error, or: $value.error),
    stackTrace: data.get(#stackTrace, or: $value.stackTrace),
    createdAt: data.get(#createdAt, or: $value.createdAt),
  );

  @override
  AppLogCopyWith<$R2, AppLog, $Out2> $chain<$R2, $Out2>(Then<$Out2, $R2> t) =>
      _AppLogCopyWithImpl<$R2, $Out2>($value, $cast, t);
}

