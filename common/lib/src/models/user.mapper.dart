// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
// ignore_for_file: type=lint
// ignore_for_file: unused_element, unnecessary_cast, override_on_non_overriding_member
// ignore_for_file: strict_raw_type, inference_failure_on_untyped_parameter

part of 'user.dart';

class UserMapper extends ClassMapperBase<User> {
  UserMapper._();

  static UserMapper? _instance;
  static UserMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = UserMapper._());
      MapperContainer.globals.useAll([SecondsDateTimeMapper()]);
    }
    return _instance!;
  }

  @override
  final String id = 'User';

  static String _$id(User v) => v.id;
  static const Field<User, String> _f$id = Field('id', _$id);
  static String _$email(User v) => v.email;
  static const Field<User, String> _f$email = Field('email', _$email);
  static String? _$name(User v) => v.name;
  static const Field<User, String> _f$name = Field('name', _$name, opt: true);
  static List<String> _$providers(User v) => v.providers;
  static const Field<User, List<String>> _f$providers = Field(
    'providers',
    _$providers,
    opt: true,
    def: const [],
  );
  static DateTime _$createdAt(User v) => v.createdAt;
  static const Field<User, DateTime> _f$createdAt = Field(
    'createdAt',
    _$createdAt,
    key: r'created_at',
  );
  static DateTime _$updatedAt(User v) => v.updatedAt;
  static const Field<User, DateTime> _f$updatedAt = Field(
    'updatedAt',
    _$updatedAt,
    key: r'updated_at',
  );

  @override
  final MappableFields<User> fields = const {
    #id: _f$id,
    #email: _f$email,
    #name: _f$name,
    #providers: _f$providers,
    #createdAt: _f$createdAt,
    #updatedAt: _f$updatedAt,
  };

  static User _instantiate(DecodingData data) {
    return User(
      id: data.dec(_f$id),
      email: data.dec(_f$email),
      name: data.dec(_f$name),
      providers: data.dec(_f$providers),
      createdAt: data.dec(_f$createdAt),
      updatedAt: data.dec(_f$updatedAt),
    );
  }

  @override
  final Function instantiate = _instantiate;

  static User fromJson(Map<String, dynamic> map) {
    return ensureInitialized().decodeMap<User>(map);
  }

  static User fromJsonString(String json) {
    return ensureInitialized().decodeJson<User>(json);
  }
}

mixin UserMappable {
  String toJsonString() {
    return UserMapper.ensureInitialized().encodeJson<User>(this as User);
  }

  Map<String, dynamic> toJson() {
    return UserMapper.ensureInitialized().encodeMap<User>(this as User);
  }

  UserCopyWith<User, User, User> get copyWith =>
      _UserCopyWithImpl<User, User>(this as User, $identity, $identity);
  @override
  String toString() {
    return UserMapper.ensureInitialized().stringifyValue(this as User);
  }

  @override
  bool operator ==(Object other) {
    return UserMapper.ensureInitialized().equalsValue(this as User, other);
  }

  @override
  int get hashCode {
    return UserMapper.ensureInitialized().hashValue(this as User);
  }
}

extension UserValueCopy<$R, $Out> on ObjectCopyWith<$R, User, $Out> {
  UserCopyWith<$R, User, $Out> get $asUser =>
      $base.as((v, t, t2) => _UserCopyWithImpl<$R, $Out>(v, t, t2));
}

abstract class UserCopyWith<$R, $In extends User, $Out>
    implements ClassCopyWith<$R, $In, $Out> {
  ListCopyWith<$R, String, ObjectCopyWith<$R, String, String>> get providers;
  $R call({
    String? id,
    String? email,
    String? name,
    List<String>? providers,
    DateTime? createdAt,
    DateTime? updatedAt,
  });
  UserCopyWith<$R2, $In, $Out2> $chain<$R2, $Out2>(Then<$Out2, $R2> t);
}

class _UserCopyWithImpl<$R, $Out> extends ClassCopyWithBase<$R, User, $Out>
    implements UserCopyWith<$R, User, $Out> {
  _UserCopyWithImpl(super.value, super.then, super.then2);

  @override
  late final ClassMapperBase<User> $mapper = UserMapper.ensureInitialized();
  @override
  ListCopyWith<$R, String, ObjectCopyWith<$R, String, String>> get providers =>
      ListCopyWith(
        $value.providers,
        (v, t) => ObjectCopyWith(v, $identity, t),
        (v) => call(providers: v),
      );
  @override
  $R call({
    String? id,
    String? email,
    Object? name = $none,
    List<String>? providers,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) => $apply(
    FieldCopyWithData({
      if (id != null) #id: id,
      if (email != null) #email: email,
      if (name != $none) #name: name,
      if (providers != null) #providers: providers,
      if (createdAt != null) #createdAt: createdAt,
      if (updatedAt != null) #updatedAt: updatedAt,
    }),
  );
  @override
  User $make(CopyWithData data) => User(
    id: data.get(#id, or: $value.id),
    email: data.get(#email, or: $value.email),
    name: data.get(#name, or: $value.name),
    providers: data.get(#providers, or: $value.providers),
    createdAt: data.get(#createdAt, or: $value.createdAt),
    updatedAt: data.get(#updatedAt, or: $value.updatedAt),
  );

  @override
  UserCopyWith<$R2, User, $Out2> $chain<$R2, $Out2>(Then<$Out2, $R2> t) =>
      _UserCopyWithImpl<$R2, $Out2>($value, $cast, t);
}

