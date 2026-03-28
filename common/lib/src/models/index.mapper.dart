// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
// ignore_for_file: type=lint
// ignore_for_file: unused_element, unnecessary_cast, override_on_non_overriding_member
// ignore_for_file: strict_raw_type, inference_failure_on_untyped_parameter

part of 'index.dart';

class IndexMapper extends ClassMapperBase<Index> {
  IndexMapper._();

  static IndexMapper? _instance;
  static IndexMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = IndexMapper._());
    }
    return _instance!;
  }

  @override
  final String id = 'Index';

  static String _$name(Index v) => v.name;
  static const Field<Index, String> _f$name = Field('name', _$name);
  static List<String> _$columns(Index v) => v.columns;
  static const Field<Index, List<String>> _f$columns = Field(
    'columns',
    _$columns,
  );
  static bool? _$unique(Index v) => v.unique;
  static const Field<Index, bool> _f$unique = Field(
    'unique',
    _$unique,
    opt: true,
  );
  static bool? _$ifNotExists(Index v) => v.ifNotExists;
  static const Field<Index, bool> _f$ifNotExists = Field(
    'ifNotExists',
    _$ifNotExists,
    key: r'if_not_exists',
    opt: true,
  );

  @override
  final MappableFields<Index> fields = const {
    #name: _f$name,
    #columns: _f$columns,
    #unique: _f$unique,
    #ifNotExists: _f$ifNotExists,
  };

  static Index _instantiate(DecodingData data) {
    return Index(
      name: data.dec(_f$name),
      columns: data.dec(_f$columns),
      unique: data.dec(_f$unique),
      ifNotExists: data.dec(_f$ifNotExists),
    );
  }

  @override
  final Function instantiate = _instantiate;

  static Index fromJson(Map<String, dynamic> map) {
    return ensureInitialized().decodeMap<Index>(map);
  }

  static Index fromJsonString(String json) {
    return ensureInitialized().decodeJson<Index>(json);
  }
}

mixin IndexMappable {
  String toJsonString() {
    return IndexMapper.ensureInitialized().encodeJson<Index>(this as Index);
  }

  Map<String, dynamic> toJson() {
    return IndexMapper.ensureInitialized().encodeMap<Index>(this as Index);
  }

  IndexCopyWith<Index, Index, Index> get copyWith =>
      _IndexCopyWithImpl<Index, Index>(this as Index, $identity, $identity);
  @override
  String toString() {
    return IndexMapper.ensureInitialized().stringifyValue(this as Index);
  }

  @override
  bool operator ==(Object other) {
    return IndexMapper.ensureInitialized().equalsValue(this as Index, other);
  }

  @override
  int get hashCode {
    return IndexMapper.ensureInitialized().hashValue(this as Index);
  }
}

extension IndexValueCopy<$R, $Out> on ObjectCopyWith<$R, Index, $Out> {
  IndexCopyWith<$R, Index, $Out> get $asIndex =>
      $base.as((v, t, t2) => _IndexCopyWithImpl<$R, $Out>(v, t, t2));
}

abstract class IndexCopyWith<$R, $In extends Index, $Out>
    implements ClassCopyWith<$R, $In, $Out> {
  ListCopyWith<$R, String, ObjectCopyWith<$R, String, String>> get columns;
  $R call({
    String? name,
    List<String>? columns,
    bool? unique,
    bool? ifNotExists,
  });
  IndexCopyWith<$R2, $In, $Out2> $chain<$R2, $Out2>(Then<$Out2, $R2> t);
}

class _IndexCopyWithImpl<$R, $Out> extends ClassCopyWithBase<$R, Index, $Out>
    implements IndexCopyWith<$R, Index, $Out> {
  _IndexCopyWithImpl(super.value, super.then, super.then2);

  @override
  late final ClassMapperBase<Index> $mapper = IndexMapper.ensureInitialized();
  @override
  ListCopyWith<$R, String, ObjectCopyWith<$R, String, String>> get columns =>
      ListCopyWith(
        $value.columns,
        (v, t) => ObjectCopyWith(v, $identity, t),
        (v) => call(columns: v),
      );
  @override
  $R call({
    String? name,
    List<String>? columns,
    Object? unique = $none,
    Object? ifNotExists = $none,
  }) => $apply(
    FieldCopyWithData({
      if (name != null) #name: name,
      if (columns != null) #columns: columns,
      if (unique != $none) #unique: unique,
      if (ifNotExists != $none) #ifNotExists: ifNotExists,
    }),
  );
  @override
  Index $make(CopyWithData data) => Index(
    name: data.get(#name, or: $value.name),
    columns: data.get(#columns, or: $value.columns),
    unique: data.get(#unique, or: $value.unique),
    ifNotExists: data.get(#ifNotExists, or: $value.ifNotExists),
  );

  @override
  IndexCopyWith<$R2, Index, $Out2> $chain<$R2, $Out2>(Then<$Out2, $R2> t) =>
      _IndexCopyWithImpl<$R2, $Out2>($value, $cast, t);
}

