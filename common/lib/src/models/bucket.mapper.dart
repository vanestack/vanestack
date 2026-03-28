// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
// ignore_for_file: type=lint
// ignore_for_file: unused_element, unnecessary_cast, override_on_non_overriding_member
// ignore_for_file: strict_raw_type, inference_failure_on_untyped_parameter

part of 'bucket.dart';

class BucketMapper extends ClassMapperBase<Bucket> {
  BucketMapper._();

  static BucketMapper? _instance;
  static BucketMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = BucketMapper._());
      MapperContainer.globals.useAll([SecondsDateTimeMapper()]);
    }
    return _instance!;
  }

  @override
  final String id = 'Bucket';

  static String _$name(Bucket v) => v.name;
  static const Field<Bucket, String> _f$name = Field('name', _$name);
  static String? _$listRule(Bucket v) => v.listRule;
  static const Field<Bucket, String> _f$listRule = Field(
    'listRule',
    _$listRule,
    key: r'list_rule',
    opt: true,
  );
  static String? _$viewRule(Bucket v) => v.viewRule;
  static const Field<Bucket, String> _f$viewRule = Field(
    'viewRule',
    _$viewRule,
    key: r'view_rule',
    opt: true,
  );
  static String? _$createRule(Bucket v) => v.createRule;
  static const Field<Bucket, String> _f$createRule = Field(
    'createRule',
    _$createRule,
    key: r'create_rule',
    opt: true,
  );
  static String? _$deleteRule(Bucket v) => v.deleteRule;
  static const Field<Bucket, String> _f$deleteRule = Field(
    'deleteRule',
    _$deleteRule,
    key: r'delete_rule',
    opt: true,
  );
  static String? _$updateRule(Bucket v) => v.updateRule;
  static const Field<Bucket, String> _f$updateRule = Field(
    'updateRule',
    _$updateRule,
    key: r'update_rule',
    opt: true,
  );
  static DateTime _$createdAt(Bucket v) => v.createdAt;
  static const Field<Bucket, DateTime> _f$createdAt = Field(
    'createdAt',
    _$createdAt,
    key: r'created_at',
  );
  static DateTime _$updatedAt(Bucket v) => v.updatedAt;
  static const Field<Bucket, DateTime> _f$updatedAt = Field(
    'updatedAt',
    _$updatedAt,
    key: r'updated_at',
  );

  @override
  final MappableFields<Bucket> fields = const {
    #name: _f$name,
    #listRule: _f$listRule,
    #viewRule: _f$viewRule,
    #createRule: _f$createRule,
    #deleteRule: _f$deleteRule,
    #updateRule: _f$updateRule,
    #createdAt: _f$createdAt,
    #updatedAt: _f$updatedAt,
  };

  static Bucket _instantiate(DecodingData data) {
    return Bucket(
      name: data.dec(_f$name),
      listRule: data.dec(_f$listRule),
      viewRule: data.dec(_f$viewRule),
      createRule: data.dec(_f$createRule),
      deleteRule: data.dec(_f$deleteRule),
      updateRule: data.dec(_f$updateRule),
      createdAt: data.dec(_f$createdAt),
      updatedAt: data.dec(_f$updatedAt),
    );
  }

  @override
  final Function instantiate = _instantiate;

  static Bucket fromJson(Map<String, dynamic> map) {
    return ensureInitialized().decodeMap<Bucket>(map);
  }

  static Bucket fromJsonString(String json) {
    return ensureInitialized().decodeJson<Bucket>(json);
  }
}

mixin BucketMappable {
  String toJsonString() {
    return BucketMapper.ensureInitialized().encodeJson<Bucket>(this as Bucket);
  }

  Map<String, dynamic> toJson() {
    return BucketMapper.ensureInitialized().encodeMap<Bucket>(this as Bucket);
  }

  BucketCopyWith<Bucket, Bucket, Bucket> get copyWith =>
      _BucketCopyWithImpl<Bucket, Bucket>(this as Bucket, $identity, $identity);
  @override
  String toString() {
    return BucketMapper.ensureInitialized().stringifyValue(this as Bucket);
  }

  @override
  bool operator ==(Object other) {
    return BucketMapper.ensureInitialized().equalsValue(this as Bucket, other);
  }

  @override
  int get hashCode {
    return BucketMapper.ensureInitialized().hashValue(this as Bucket);
  }
}

extension BucketValueCopy<$R, $Out> on ObjectCopyWith<$R, Bucket, $Out> {
  BucketCopyWith<$R, Bucket, $Out> get $asBucket =>
      $base.as((v, t, t2) => _BucketCopyWithImpl<$R, $Out>(v, t, t2));
}

abstract class BucketCopyWith<$R, $In extends Bucket, $Out>
    implements ClassCopyWith<$R, $In, $Out> {
  $R call({
    String? name,
    String? listRule,
    String? viewRule,
    String? createRule,
    String? deleteRule,
    String? updateRule,
    DateTime? createdAt,
    DateTime? updatedAt,
  });
  BucketCopyWith<$R2, $In, $Out2> $chain<$R2, $Out2>(Then<$Out2, $R2> t);
}

class _BucketCopyWithImpl<$R, $Out> extends ClassCopyWithBase<$R, Bucket, $Out>
    implements BucketCopyWith<$R, Bucket, $Out> {
  _BucketCopyWithImpl(super.value, super.then, super.then2);

  @override
  late final ClassMapperBase<Bucket> $mapper = BucketMapper.ensureInitialized();
  @override
  $R call({
    String? name,
    Object? listRule = $none,
    Object? viewRule = $none,
    Object? createRule = $none,
    Object? deleteRule = $none,
    Object? updateRule = $none,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) => $apply(
    FieldCopyWithData({
      if (name != null) #name: name,
      if (listRule != $none) #listRule: listRule,
      if (viewRule != $none) #viewRule: viewRule,
      if (createRule != $none) #createRule: createRule,
      if (deleteRule != $none) #deleteRule: deleteRule,
      if (updateRule != $none) #updateRule: updateRule,
      if (createdAt != null) #createdAt: createdAt,
      if (updatedAt != null) #updatedAt: updatedAt,
    }),
  );
  @override
  Bucket $make(CopyWithData data) => Bucket(
    name: data.get(#name, or: $value.name),
    listRule: data.get(#listRule, or: $value.listRule),
    viewRule: data.get(#viewRule, or: $value.viewRule),
    createRule: data.get(#createRule, or: $value.createRule),
    deleteRule: data.get(#deleteRule, or: $value.deleteRule),
    updateRule: data.get(#updateRule, or: $value.updateRule),
    createdAt: data.get(#createdAt, or: $value.createdAt),
    updatedAt: data.get(#updatedAt, or: $value.updatedAt),
  );

  @override
  BucketCopyWith<$R2, Bucket, $Out2> $chain<$R2, $Out2>(Then<$Out2, $R2> t) =>
      _BucketCopyWithImpl<$R2, $Out2>($value, $cast, t);
}

