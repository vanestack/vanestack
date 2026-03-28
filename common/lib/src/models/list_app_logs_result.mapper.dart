// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
// ignore_for_file: type=lint
// ignore_for_file: unused_element, unnecessary_cast, override_on_non_overriding_member
// ignore_for_file: strict_raw_type, inference_failure_on_untyped_parameter

part of 'list_app_logs_result.dart';

class ListAppLogsResultMapper extends ClassMapperBase<ListAppLogsResult> {
  ListAppLogsResultMapper._();

  static ListAppLogsResultMapper? _instance;
  static ListAppLogsResultMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = ListAppLogsResultMapper._());
      AppLogMapper.ensureInitialized();
    }
    return _instance!;
  }

  @override
  final String id = 'ListAppLogsResult';

  static List<AppLog> _$logs(ListAppLogsResult v) => v.logs;
  static const Field<ListAppLogsResult, List<AppLog>> _f$logs = Field(
    'logs',
    _$logs,
  );
  static int _$count(ListAppLogsResult v) => v.count;
  static const Field<ListAppLogsResult, int> _f$count = Field('count', _$count);

  @override
  final MappableFields<ListAppLogsResult> fields = const {
    #logs: _f$logs,
    #count: _f$count,
  };

  static ListAppLogsResult _instantiate(DecodingData data) {
    return ListAppLogsResult(
      logs: data.dec(_f$logs),
      count: data.dec(_f$count),
    );
  }

  @override
  final Function instantiate = _instantiate;

  static ListAppLogsResult fromJson(Map<String, dynamic> map) {
    return ensureInitialized().decodeMap<ListAppLogsResult>(map);
  }

  static ListAppLogsResult fromJsonString(String json) {
    return ensureInitialized().decodeJson<ListAppLogsResult>(json);
  }
}

mixin ListAppLogsResultMappable {
  String toJsonString() {
    return ListAppLogsResultMapper.ensureInitialized()
        .encodeJson<ListAppLogsResult>(this as ListAppLogsResult);
  }

  Map<String, dynamic> toJson() {
    return ListAppLogsResultMapper.ensureInitialized()
        .encodeMap<ListAppLogsResult>(this as ListAppLogsResult);
  }

  ListAppLogsResultCopyWith<
    ListAppLogsResult,
    ListAppLogsResult,
    ListAppLogsResult
  >
  get copyWith =>
      _ListAppLogsResultCopyWithImpl<ListAppLogsResult, ListAppLogsResult>(
        this as ListAppLogsResult,
        $identity,
        $identity,
      );
  @override
  String toString() {
    return ListAppLogsResultMapper.ensureInitialized().stringifyValue(
      this as ListAppLogsResult,
    );
  }

  @override
  bool operator ==(Object other) {
    return ListAppLogsResultMapper.ensureInitialized().equalsValue(
      this as ListAppLogsResult,
      other,
    );
  }

  @override
  int get hashCode {
    return ListAppLogsResultMapper.ensureInitialized().hashValue(
      this as ListAppLogsResult,
    );
  }
}

extension ListAppLogsResultValueCopy<$R, $Out>
    on ObjectCopyWith<$R, ListAppLogsResult, $Out> {
  ListAppLogsResultCopyWith<$R, ListAppLogsResult, $Out>
  get $asListAppLogsResult => $base.as(
    (v, t, t2) => _ListAppLogsResultCopyWithImpl<$R, $Out>(v, t, t2),
  );
}

abstract class ListAppLogsResultCopyWith<
  $R,
  $In extends ListAppLogsResult,
  $Out
>
    implements ClassCopyWith<$R, $In, $Out> {
  ListCopyWith<$R, AppLog, AppLogCopyWith<$R, AppLog, AppLog>> get logs;
  $R call({List<AppLog>? logs, int? count});
  ListAppLogsResultCopyWith<$R2, $In, $Out2> $chain<$R2, $Out2>(
    Then<$Out2, $R2> t,
  );
}

class _ListAppLogsResultCopyWithImpl<$R, $Out>
    extends ClassCopyWithBase<$R, ListAppLogsResult, $Out>
    implements ListAppLogsResultCopyWith<$R, ListAppLogsResult, $Out> {
  _ListAppLogsResultCopyWithImpl(super.value, super.then, super.then2);

  @override
  late final ClassMapperBase<ListAppLogsResult> $mapper =
      ListAppLogsResultMapper.ensureInitialized();
  @override
  ListCopyWith<$R, AppLog, AppLogCopyWith<$R, AppLog, AppLog>> get logs =>
      ListCopyWith(
        $value.logs,
        (v, t) => v.copyWith.$chain(t),
        (v) => call(logs: v),
      );
  @override
  $R call({List<AppLog>? logs, int? count}) => $apply(
    FieldCopyWithData({
      if (logs != null) #logs: logs,
      if (count != null) #count: count,
    }),
  );
  @override
  ListAppLogsResult $make(CopyWithData data) => ListAppLogsResult(
    logs: data.get(#logs, or: $value.logs),
    count: data.get(#count, or: $value.count),
  );

  @override
  ListAppLogsResultCopyWith<$R2, ListAppLogsResult, $Out2> $chain<$R2, $Out2>(
    Then<$Out2, $R2> t,
  ) => _ListAppLogsResultCopyWithImpl<$R2, $Out2>($value, $cast, t);
}

