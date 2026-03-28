// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
// ignore_for_file: type=lint
// ignore_for_file: unused_element, unnecessary_cast, override_on_non_overriding_member
// ignore_for_file: strict_raw_type, inference_failure_on_untyped_parameter

part of 'dashboard_stats.dart';

class RequestPointMapper extends ClassMapperBase<RequestPoint> {
  RequestPointMapper._();

  static RequestPointMapper? _instance;
  static RequestPointMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = RequestPointMapper._());
      MapperContainer.globals.useAll([SecondsDateTimeMapper()]);
    }
    return _instance!;
  }

  @override
  final String id = 'RequestPoint';

  static DateTime _$date(RequestPoint v) => v.date;
  static const Field<RequestPoint, DateTime> _f$date = Field('date', _$date);
  static int _$count(RequestPoint v) => v.count;
  static const Field<RequestPoint, int> _f$count = Field('count', _$count);

  @override
  final MappableFields<RequestPoint> fields = const {
    #date: _f$date,
    #count: _f$count,
  };

  static RequestPoint _instantiate(DecodingData data) {
    return RequestPoint(date: data.dec(_f$date), count: data.dec(_f$count));
  }

  @override
  final Function instantiate = _instantiate;

  static RequestPoint fromJson(Map<String, dynamic> map) {
    return ensureInitialized().decodeMap<RequestPoint>(map);
  }

  static RequestPoint fromJsonString(String json) {
    return ensureInitialized().decodeJson<RequestPoint>(json);
  }
}

mixin RequestPointMappable {
  String toJsonString() {
    return RequestPointMapper.ensureInitialized().encodeJson<RequestPoint>(
      this as RequestPoint,
    );
  }

  Map<String, dynamic> toJson() {
    return RequestPointMapper.ensureInitialized().encodeMap<RequestPoint>(
      this as RequestPoint,
    );
  }

  RequestPointCopyWith<RequestPoint, RequestPoint, RequestPoint> get copyWith =>
      _RequestPointCopyWithImpl<RequestPoint, RequestPoint>(
        this as RequestPoint,
        $identity,
        $identity,
      );
  @override
  String toString() {
    return RequestPointMapper.ensureInitialized().stringifyValue(
      this as RequestPoint,
    );
  }

  @override
  bool operator ==(Object other) {
    return RequestPointMapper.ensureInitialized().equalsValue(
      this as RequestPoint,
      other,
    );
  }

  @override
  int get hashCode {
    return RequestPointMapper.ensureInitialized().hashValue(
      this as RequestPoint,
    );
  }
}

extension RequestPointValueCopy<$R, $Out>
    on ObjectCopyWith<$R, RequestPoint, $Out> {
  RequestPointCopyWith<$R, RequestPoint, $Out> get $asRequestPoint =>
      $base.as((v, t, t2) => _RequestPointCopyWithImpl<$R, $Out>(v, t, t2));
}

abstract class RequestPointCopyWith<$R, $In extends RequestPoint, $Out>
    implements ClassCopyWith<$R, $In, $Out> {
  $R call({DateTime? date, int? count});
  RequestPointCopyWith<$R2, $In, $Out2> $chain<$R2, $Out2>(Then<$Out2, $R2> t);
}

class _RequestPointCopyWithImpl<$R, $Out>
    extends ClassCopyWithBase<$R, RequestPoint, $Out>
    implements RequestPointCopyWith<$R, RequestPoint, $Out> {
  _RequestPointCopyWithImpl(super.value, super.then, super.then2);

  @override
  late final ClassMapperBase<RequestPoint> $mapper =
      RequestPointMapper.ensureInitialized();
  @override
  $R call({DateTime? date, int? count}) => $apply(
    FieldCopyWithData({
      if (date != null) #date: date,
      if (count != null) #count: count,
    }),
  );
  @override
  RequestPoint $make(CopyWithData data) => RequestPoint(
    date: data.get(#date, or: $value.date),
    count: data.get(#count, or: $value.count),
  );

  @override
  RequestPointCopyWith<$R2, RequestPoint, $Out2> $chain<$R2, $Out2>(
    Then<$Out2, $R2> t,
  ) => _RequestPointCopyWithImpl<$R2, $Out2>($value, $cast, t);
}

class DashboardStatsMapper extends ClassMapperBase<DashboardStats> {
  DashboardStatsMapper._();

  static DashboardStatsMapper? _instance;
  static DashboardStatsMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = DashboardStatsMapper._());
      RequestPointMapper.ensureInitialized();
    }
    return _instance!;
  }

  @override
  final String id = 'DashboardStats';

  static int _$totalUsers(DashboardStats v) => v.totalUsers;
  static const Field<DashboardStats, int> _f$totalUsers = Field(
    'totalUsers',
    _$totalUsers,
    key: r'total_users',
  );
  static int _$totalDocuments(DashboardStats v) => v.totalDocuments;
  static const Field<DashboardStats, int> _f$totalDocuments = Field(
    'totalDocuments',
    _$totalDocuments,
    key: r'total_documents',
  );
  static int _$totalFiles(DashboardStats v) => v.totalFiles;
  static const Field<DashboardStats, int> _f$totalFiles = Field(
    'totalFiles',
    _$totalFiles,
    key: r'total_files',
  );
  static int _$totalStorageBytes(DashboardStats v) => v.totalStorageBytes;
  static const Field<DashboardStats, int> _f$totalStorageBytes = Field(
    'totalStorageBytes',
    _$totalStorageBytes,
    key: r'total_storage_bytes',
  );
  static int _$totalRequests(DashboardStats v) => v.totalRequests;
  static const Field<DashboardStats, int> _f$totalRequests = Field(
    'totalRequests',
    _$totalRequests,
    key: r'total_requests',
  );
  static int _$requestsToday(DashboardStats v) => v.requestsToday;
  static const Field<DashboardStats, int> _f$requestsToday = Field(
    'requestsToday',
    _$requestsToday,
    key: r'requests_today',
  );
  static Map<String, int> _$statusBreakdown(DashboardStats v) =>
      v.statusBreakdown;
  static const Field<DashboardStats, Map<String, int>> _f$statusBreakdown =
      Field('statusBreakdown', _$statusBreakdown, key: r'status_breakdown');
  static List<RequestPoint> _$requestsPerDay(DashboardStats v) =>
      v.requestsPerDay;
  static const Field<DashboardStats, List<RequestPoint>> _f$requestsPerDay =
      Field('requestsPerDay', _$requestsPerDay, key: r'requests_per_day');

  @override
  final MappableFields<DashboardStats> fields = const {
    #totalUsers: _f$totalUsers,
    #totalDocuments: _f$totalDocuments,
    #totalFiles: _f$totalFiles,
    #totalStorageBytes: _f$totalStorageBytes,
    #totalRequests: _f$totalRequests,
    #requestsToday: _f$requestsToday,
    #statusBreakdown: _f$statusBreakdown,
    #requestsPerDay: _f$requestsPerDay,
  };

  static DashboardStats _instantiate(DecodingData data) {
    return DashboardStats(
      totalUsers: data.dec(_f$totalUsers),
      totalDocuments: data.dec(_f$totalDocuments),
      totalFiles: data.dec(_f$totalFiles),
      totalStorageBytes: data.dec(_f$totalStorageBytes),
      totalRequests: data.dec(_f$totalRequests),
      requestsToday: data.dec(_f$requestsToday),
      statusBreakdown: data.dec(_f$statusBreakdown),
      requestsPerDay: data.dec(_f$requestsPerDay),
    );
  }

  @override
  final Function instantiate = _instantiate;

  static DashboardStats fromJson(Map<String, dynamic> map) {
    return ensureInitialized().decodeMap<DashboardStats>(map);
  }

  static DashboardStats fromJsonString(String json) {
    return ensureInitialized().decodeJson<DashboardStats>(json);
  }
}

mixin DashboardStatsMappable {
  String toJsonString() {
    return DashboardStatsMapper.ensureInitialized().encodeJson<DashboardStats>(
      this as DashboardStats,
    );
  }

  Map<String, dynamic> toJson() {
    return DashboardStatsMapper.ensureInitialized().encodeMap<DashboardStats>(
      this as DashboardStats,
    );
  }

  DashboardStatsCopyWith<DashboardStats, DashboardStats, DashboardStats>
  get copyWith => _DashboardStatsCopyWithImpl<DashboardStats, DashboardStats>(
    this as DashboardStats,
    $identity,
    $identity,
  );
  @override
  String toString() {
    return DashboardStatsMapper.ensureInitialized().stringifyValue(
      this as DashboardStats,
    );
  }

  @override
  bool operator ==(Object other) {
    return DashboardStatsMapper.ensureInitialized().equalsValue(
      this as DashboardStats,
      other,
    );
  }

  @override
  int get hashCode {
    return DashboardStatsMapper.ensureInitialized().hashValue(
      this as DashboardStats,
    );
  }
}

extension DashboardStatsValueCopy<$R, $Out>
    on ObjectCopyWith<$R, DashboardStats, $Out> {
  DashboardStatsCopyWith<$R, DashboardStats, $Out> get $asDashboardStats =>
      $base.as((v, t, t2) => _DashboardStatsCopyWithImpl<$R, $Out>(v, t, t2));
}

abstract class DashboardStatsCopyWith<$R, $In extends DashboardStats, $Out>
    implements ClassCopyWith<$R, $In, $Out> {
  MapCopyWith<$R, String, int, ObjectCopyWith<$R, int, int>>
  get statusBreakdown;
  ListCopyWith<
    $R,
    RequestPoint,
    RequestPointCopyWith<$R, RequestPoint, RequestPoint>
  >
  get requestsPerDay;
  $R call({
    int? totalUsers,
    int? totalDocuments,
    int? totalFiles,
    int? totalStorageBytes,
    int? totalRequests,
    int? requestsToday,
    Map<String, int>? statusBreakdown,
    List<RequestPoint>? requestsPerDay,
  });
  DashboardStatsCopyWith<$R2, $In, $Out2> $chain<$R2, $Out2>(
    Then<$Out2, $R2> t,
  );
}

class _DashboardStatsCopyWithImpl<$R, $Out>
    extends ClassCopyWithBase<$R, DashboardStats, $Out>
    implements DashboardStatsCopyWith<$R, DashboardStats, $Out> {
  _DashboardStatsCopyWithImpl(super.value, super.then, super.then2);

  @override
  late final ClassMapperBase<DashboardStats> $mapper =
      DashboardStatsMapper.ensureInitialized();
  @override
  MapCopyWith<$R, String, int, ObjectCopyWith<$R, int, int>>
  get statusBreakdown => MapCopyWith(
    $value.statusBreakdown,
    (v, t) => ObjectCopyWith(v, $identity, t),
    (v) => call(statusBreakdown: v),
  );
  @override
  ListCopyWith<
    $R,
    RequestPoint,
    RequestPointCopyWith<$R, RequestPoint, RequestPoint>
  >
  get requestsPerDay => ListCopyWith(
    $value.requestsPerDay,
    (v, t) => v.copyWith.$chain(t),
    (v) => call(requestsPerDay: v),
  );
  @override
  $R call({
    int? totalUsers,
    int? totalDocuments,
    int? totalFiles,
    int? totalStorageBytes,
    int? totalRequests,
    int? requestsToday,
    Map<String, int>? statusBreakdown,
    List<RequestPoint>? requestsPerDay,
  }) => $apply(
    FieldCopyWithData({
      if (totalUsers != null) #totalUsers: totalUsers,
      if (totalDocuments != null) #totalDocuments: totalDocuments,
      if (totalFiles != null) #totalFiles: totalFiles,
      if (totalStorageBytes != null) #totalStorageBytes: totalStorageBytes,
      if (totalRequests != null) #totalRequests: totalRequests,
      if (requestsToday != null) #requestsToday: requestsToday,
      if (statusBreakdown != null) #statusBreakdown: statusBreakdown,
      if (requestsPerDay != null) #requestsPerDay: requestsPerDay,
    }),
  );
  @override
  DashboardStats $make(CopyWithData data) => DashboardStats(
    totalUsers: data.get(#totalUsers, or: $value.totalUsers),
    totalDocuments: data.get(#totalDocuments, or: $value.totalDocuments),
    totalFiles: data.get(#totalFiles, or: $value.totalFiles),
    totalStorageBytes: data.get(
      #totalStorageBytes,
      or: $value.totalStorageBytes,
    ),
    totalRequests: data.get(#totalRequests, or: $value.totalRequests),
    requestsToday: data.get(#requestsToday, or: $value.requestsToday),
    statusBreakdown: data.get(#statusBreakdown, or: $value.statusBreakdown),
    requestsPerDay: data.get(#requestsPerDay, or: $value.requestsPerDay),
  );

  @override
  DashboardStatsCopyWith<$R2, DashboardStats, $Out2> $chain<$R2, $Out2>(
    Then<$Out2, $R2> t,
  ) => _DashboardStatsCopyWithImpl<$R2, $Out2>($value, $cast, t);
}

