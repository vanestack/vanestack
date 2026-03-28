// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
// ignore_for_file: type=lint
// ignore_for_file: unused_element, unnecessary_cast, override_on_non_overriding_member
// ignore_for_file: strict_raw_type, inference_failure_on_untyped_parameter

part of 'list_users_result.dart';

class ListUsersResultMapper extends ClassMapperBase<ListUsersResult> {
  ListUsersResultMapper._();

  static ListUsersResultMapper? _instance;
  static ListUsersResultMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = ListUsersResultMapper._());
      UserMapper.ensureInitialized();
    }
    return _instance!;
  }

  @override
  final String id = 'ListUsersResult';

  static List<User> _$users(ListUsersResult v) => v.users;
  static const Field<ListUsersResult, List<User>> _f$users = Field(
    'users',
    _$users,
  );
  static int _$count(ListUsersResult v) => v.count;
  static const Field<ListUsersResult, int> _f$count = Field('count', _$count);

  @override
  final MappableFields<ListUsersResult> fields = const {
    #users: _f$users,
    #count: _f$count,
  };

  static ListUsersResult _instantiate(DecodingData data) {
    return ListUsersResult(
      users: data.dec(_f$users),
      count: data.dec(_f$count),
    );
  }

  @override
  final Function instantiate = _instantiate;

  static ListUsersResult fromJson(Map<String, dynamic> map) {
    return ensureInitialized().decodeMap<ListUsersResult>(map);
  }

  static ListUsersResult fromJsonString(String json) {
    return ensureInitialized().decodeJson<ListUsersResult>(json);
  }
}

mixin ListUsersResultMappable {
  String toJsonString() {
    return ListUsersResultMapper.ensureInitialized()
        .encodeJson<ListUsersResult>(this as ListUsersResult);
  }

  Map<String, dynamic> toJson() {
    return ListUsersResultMapper.ensureInitialized().encodeMap<ListUsersResult>(
      this as ListUsersResult,
    );
  }

  ListUsersResultCopyWith<ListUsersResult, ListUsersResult, ListUsersResult>
  get copyWith =>
      _ListUsersResultCopyWithImpl<ListUsersResult, ListUsersResult>(
        this as ListUsersResult,
        $identity,
        $identity,
      );
  @override
  String toString() {
    return ListUsersResultMapper.ensureInitialized().stringifyValue(
      this as ListUsersResult,
    );
  }

  @override
  bool operator ==(Object other) {
    return ListUsersResultMapper.ensureInitialized().equalsValue(
      this as ListUsersResult,
      other,
    );
  }

  @override
  int get hashCode {
    return ListUsersResultMapper.ensureInitialized().hashValue(
      this as ListUsersResult,
    );
  }
}

extension ListUsersResultValueCopy<$R, $Out>
    on ObjectCopyWith<$R, ListUsersResult, $Out> {
  ListUsersResultCopyWith<$R, ListUsersResult, $Out> get $asListUsersResult =>
      $base.as((v, t, t2) => _ListUsersResultCopyWithImpl<$R, $Out>(v, t, t2));
}

abstract class ListUsersResultCopyWith<$R, $In extends ListUsersResult, $Out>
    implements ClassCopyWith<$R, $In, $Out> {
  ListCopyWith<$R, User, UserCopyWith<$R, User, User>> get users;
  $R call({List<User>? users, int? count});
  ListUsersResultCopyWith<$R2, $In, $Out2> $chain<$R2, $Out2>(
    Then<$Out2, $R2> t,
  );
}

class _ListUsersResultCopyWithImpl<$R, $Out>
    extends ClassCopyWithBase<$R, ListUsersResult, $Out>
    implements ListUsersResultCopyWith<$R, ListUsersResult, $Out> {
  _ListUsersResultCopyWithImpl(super.value, super.then, super.then2);

  @override
  late final ClassMapperBase<ListUsersResult> $mapper =
      ListUsersResultMapper.ensureInitialized();
  @override
  ListCopyWith<$R, User, UserCopyWith<$R, User, User>> get users =>
      ListCopyWith(
        $value.users,
        (v, t) => v.copyWith.$chain(t),
        (v) => call(users: v),
      );
  @override
  $R call({List<User>? users, int? count}) => $apply(
    FieldCopyWithData({
      if (users != null) #users: users,
      if (count != null) #count: count,
    }),
  );
  @override
  ListUsersResult $make(CopyWithData data) => ListUsersResult(
    users: data.get(#users, or: $value.users),
    count: data.get(#count, or: $value.count),
  );

  @override
  ListUsersResultCopyWith<$R2, ListUsersResult, $Out2> $chain<$R2, $Out2>(
    Then<$Out2, $R2> t,
  ) => _ListUsersResultCopyWithImpl<$R2, $Out2>($value, $cast, t);
}

