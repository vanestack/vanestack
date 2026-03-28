// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
// ignore_for_file: type=lint
// ignore_for_file: unused_element, unnecessary_cast, override_on_non_overriding_member
// ignore_for_file: strict_raw_type, inference_failure_on_untyped_parameter

part of 'attribute.dart';

class ForeignKeyMapper extends ClassMapperBase<ForeignKey> {
  ForeignKeyMapper._();

  static ForeignKeyMapper? _instance;
  static ForeignKeyMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = ForeignKeyMapper._());
    }
    return _instance!;
  }

  @override
  final String id = 'ForeignKey';

  static String _$table(ForeignKey v) => v.table;
  static const Field<ForeignKey, String> _f$table = Field('table', _$table);
  static String _$column(ForeignKey v) => v.column;
  static const Field<ForeignKey, String> _f$column = Field('column', _$column);
  static String? _$onDelete(ForeignKey v) => v.onDelete;
  static const Field<ForeignKey, String> _f$onDelete = Field(
    'onDelete',
    _$onDelete,
    key: r'on_delete',
    opt: true,
  );
  static String? _$onUpdate(ForeignKey v) => v.onUpdate;
  static const Field<ForeignKey, String> _f$onUpdate = Field(
    'onUpdate',
    _$onUpdate,
    key: r'on_update',
    opt: true,
  );

  @override
  final MappableFields<ForeignKey> fields = const {
    #table: _f$table,
    #column: _f$column,
    #onDelete: _f$onDelete,
    #onUpdate: _f$onUpdate,
  };

  static ForeignKey _instantiate(DecodingData data) {
    return ForeignKey(
      table: data.dec(_f$table),
      column: data.dec(_f$column),
      onDelete: data.dec(_f$onDelete),
      onUpdate: data.dec(_f$onUpdate),
    );
  }

  @override
  final Function instantiate = _instantiate;

  static ForeignKey fromJson(Map<String, dynamic> map) {
    return ensureInitialized().decodeMap<ForeignKey>(map);
  }

  static ForeignKey fromJsonString(String json) {
    return ensureInitialized().decodeJson<ForeignKey>(json);
  }
}

mixin ForeignKeyMappable {
  String toJsonString() {
    return ForeignKeyMapper.ensureInitialized().encodeJson<ForeignKey>(
      this as ForeignKey,
    );
  }

  Map<String, dynamic> toJson() {
    return ForeignKeyMapper.ensureInitialized().encodeMap<ForeignKey>(
      this as ForeignKey,
    );
  }

  ForeignKeyCopyWith<ForeignKey, ForeignKey, ForeignKey> get copyWith =>
      _ForeignKeyCopyWithImpl<ForeignKey, ForeignKey>(
        this as ForeignKey,
        $identity,
        $identity,
      );
  @override
  String toString() {
    return ForeignKeyMapper.ensureInitialized().stringifyValue(
      this as ForeignKey,
    );
  }

  @override
  bool operator ==(Object other) {
    return ForeignKeyMapper.ensureInitialized().equalsValue(
      this as ForeignKey,
      other,
    );
  }

  @override
  int get hashCode {
    return ForeignKeyMapper.ensureInitialized().hashValue(this as ForeignKey);
  }
}

extension ForeignKeyValueCopy<$R, $Out>
    on ObjectCopyWith<$R, ForeignKey, $Out> {
  ForeignKeyCopyWith<$R, ForeignKey, $Out> get $asForeignKey =>
      $base.as((v, t, t2) => _ForeignKeyCopyWithImpl<$R, $Out>(v, t, t2));
}

abstract class ForeignKeyCopyWith<$R, $In extends ForeignKey, $Out>
    implements ClassCopyWith<$R, $In, $Out> {
  $R call({String? table, String? column, String? onDelete, String? onUpdate});
  ForeignKeyCopyWith<$R2, $In, $Out2> $chain<$R2, $Out2>(Then<$Out2, $R2> t);
}

class _ForeignKeyCopyWithImpl<$R, $Out>
    extends ClassCopyWithBase<$R, ForeignKey, $Out>
    implements ForeignKeyCopyWith<$R, ForeignKey, $Out> {
  _ForeignKeyCopyWithImpl(super.value, super.then, super.then2);

  @override
  late final ClassMapperBase<ForeignKey> $mapper =
      ForeignKeyMapper.ensureInitialized();
  @override
  $R call({
    String? table,
    String? column,
    Object? onDelete = $none,
    Object? onUpdate = $none,
  }) => $apply(
    FieldCopyWithData({
      if (table != null) #table: table,
      if (column != null) #column: column,
      if (onDelete != $none) #onDelete: onDelete,
      if (onUpdate != $none) #onUpdate: onUpdate,
    }),
  );
  @override
  ForeignKey $make(CopyWithData data) => ForeignKey(
    table: data.get(#table, or: $value.table),
    column: data.get(#column, or: $value.column),
    onDelete: data.get(#onDelete, or: $value.onDelete),
    onUpdate: data.get(#onUpdate, or: $value.onUpdate),
  );

  @override
  ForeignKeyCopyWith<$R2, ForeignKey, $Out2> $chain<$R2, $Out2>(
    Then<$Out2, $R2> t,
  ) => _ForeignKeyCopyWithImpl<$R2, $Out2>($value, $cast, t);
}

class AttributeMapper extends ClassMapperBase<Attribute> {
  AttributeMapper._();

  static AttributeMapper? _instance;
  static AttributeMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = AttributeMapper._());
      TextAttributeMapper.ensureInitialized();
      IntAttributeMapper.ensureInitialized();
      BoolAttributeMapper.ensureInitialized();
      DateAttributeMapper.ensureInitialized();
      DoubleAttributeMapper.ensureInitialized();
      JsonAttributeMapper.ensureInitialized();
      ForeignKeyMapper.ensureInitialized();
    }
    return _instance!;
  }

  @override
  final String id = 'Attribute';

  static String _$name(Attribute v) => v.name;
  static const Field<Attribute, String> _f$name = Field('name', _$name);
  static bool _$nullable(Attribute v) => v.nullable;
  static const Field<Attribute, bool> _f$nullable = Field(
    'nullable',
    _$nullable,
    opt: true,
    def: true,
  );
  static bool _$unique(Attribute v) => v.unique;
  static const Field<Attribute, bool> _f$unique = Field(
    'unique',
    _$unique,
    opt: true,
    def: false,
  );
  static bool _$primaryKey(Attribute v) => v.primaryKey;
  static const Field<Attribute, bool> _f$primaryKey = Field(
    'primaryKey',
    _$primaryKey,
    key: r'primary_key',
    opt: true,
    def: false,
  );
  static Object? _$defaultValue(Attribute v) => v.defaultValue;
  static const Field<Attribute, Object> _f$defaultValue = Field(
    'defaultValue',
    _$defaultValue,
    key: r'default_value',
    opt: true,
  );
  static String? _$checkConstraint(Attribute v) => v.checkConstraint;
  static const Field<Attribute, String> _f$checkConstraint = Field(
    'checkConstraint',
    _$checkConstraint,
    key: r'check_constraint',
    opt: true,
  );
  static ForeignKey? _$foreignKey(Attribute v) => v.foreignKey;
  static const Field<Attribute, ForeignKey> _f$foreignKey = Field(
    'foreignKey',
    _$foreignKey,
    key: r'foreign_key',
    opt: true,
  );

  @override
  final MappableFields<Attribute> fields = const {
    #name: _f$name,
    #nullable: _f$nullable,
    #unique: _f$unique,
    #primaryKey: _f$primaryKey,
    #defaultValue: _f$defaultValue,
    #checkConstraint: _f$checkConstraint,
    #foreignKey: _f$foreignKey,
  };

  static Attribute _instantiate(DecodingData data) {
    throw MapperException.missingSubclass(
      'Attribute',
      'type',
      '${data.value['type']}',
    );
  }

  @override
  final Function instantiate = _instantiate;

  static Attribute fromJson(Map<String, dynamic> map) {
    return ensureInitialized().decodeMap<Attribute>(map);
  }

  static Attribute fromJsonString(String json) {
    return ensureInitialized().decodeJson<Attribute>(json);
  }
}

mixin AttributeMappable {
  String toJsonString();
  Map<String, dynamic> toJson();
  AttributeCopyWith<Attribute, Attribute, Attribute> get copyWith;
}

abstract class AttributeCopyWith<$R, $In extends Attribute, $Out>
    implements ClassCopyWith<$R, $In, $Out> {
  ForeignKeyCopyWith<$R, ForeignKey, ForeignKey>? get foreignKey;
  $R call({
    String? name,
    bool? nullable,
    bool? unique,
    bool? primaryKey,
    Object? defaultValue,
    String? checkConstraint,
    ForeignKey? foreignKey,
  });
  AttributeCopyWith<$R2, $In, $Out2> $chain<$R2, $Out2>(Then<$Out2, $R2> t);
}

class TextAttributeMapper extends SubClassMapperBase<TextAttribute> {
  TextAttributeMapper._();

  static TextAttributeMapper? _instance;
  static TextAttributeMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = TextAttributeMapper._());
      AttributeMapper.ensureInitialized().addSubMapper(_instance!);
      ForeignKeyMapper.ensureInitialized();
    }
    return _instance!;
  }

  @override
  final String id = 'TextAttribute';

  static String _$name(TextAttribute v) => v.name;
  static const Field<TextAttribute, String> _f$name = Field('name', _$name);
  static bool _$nullable(TextAttribute v) => v.nullable;
  static const Field<TextAttribute, bool> _f$nullable = Field(
    'nullable',
    _$nullable,
    opt: true,
    def: true,
  );
  static bool _$unique(TextAttribute v) => v.unique;
  static const Field<TextAttribute, bool> _f$unique = Field(
    'unique',
    _$unique,
    opt: true,
    def: false,
  );
  static bool _$primaryKey(TextAttribute v) => v.primaryKey;
  static const Field<TextAttribute, bool> _f$primaryKey = Field(
    'primaryKey',
    _$primaryKey,
    key: r'primary_key',
    opt: true,
    def: false,
  );
  static Object? _$defaultValue(TextAttribute v) => v.defaultValue;
  static const Field<TextAttribute, Object> _f$defaultValue = Field(
    'defaultValue',
    _$defaultValue,
    key: r'default_value',
    opt: true,
  );
  static String? _$checkConstraint(TextAttribute v) => v.checkConstraint;
  static const Field<TextAttribute, String> _f$checkConstraint = Field(
    'checkConstraint',
    _$checkConstraint,
    key: r'check_constraint',
    opt: true,
  );
  static ForeignKey? _$foreignKey(TextAttribute v) => v.foreignKey;
  static const Field<TextAttribute, ForeignKey> _f$foreignKey = Field(
    'foreignKey',
    _$foreignKey,
    key: r'foreign_key',
    opt: true,
  );

  @override
  final MappableFields<TextAttribute> fields = const {
    #name: _f$name,
    #nullable: _f$nullable,
    #unique: _f$unique,
    #primaryKey: _f$primaryKey,
    #defaultValue: _f$defaultValue,
    #checkConstraint: _f$checkConstraint,
    #foreignKey: _f$foreignKey,
  };

  @override
  final String discriminatorKey = 'type';
  @override
  final dynamic discriminatorValue = 'TEXT';
  @override
  late final ClassMapperBase superMapper = AttributeMapper.ensureInitialized();

  static TextAttribute _instantiate(DecodingData data) {
    return TextAttribute(
      name: data.dec(_f$name),
      nullable: data.dec(_f$nullable),
      unique: data.dec(_f$unique),
      primaryKey: data.dec(_f$primaryKey),
      defaultValue: data.dec(_f$defaultValue),
      checkConstraint: data.dec(_f$checkConstraint),
      foreignKey: data.dec(_f$foreignKey),
    );
  }

  @override
  final Function instantiate = _instantiate;

  static TextAttribute fromJson(Map<String, dynamic> map) {
    return ensureInitialized().decodeMap<TextAttribute>(map);
  }

  static TextAttribute fromJsonString(String json) {
    return ensureInitialized().decodeJson<TextAttribute>(json);
  }
}

mixin TextAttributeMappable {
  String toJsonString() {
    return TextAttributeMapper.ensureInitialized().encodeJson<TextAttribute>(
      this as TextAttribute,
    );
  }

  Map<String, dynamic> toJson() {
    return TextAttributeMapper.ensureInitialized().encodeMap<TextAttribute>(
      this as TextAttribute,
    );
  }

  TextAttributeCopyWith<TextAttribute, TextAttribute, TextAttribute>
  get copyWith => _TextAttributeCopyWithImpl<TextAttribute, TextAttribute>(
    this as TextAttribute,
    $identity,
    $identity,
  );
  @override
  String toString() {
    return TextAttributeMapper.ensureInitialized().stringifyValue(
      this as TextAttribute,
    );
  }

  @override
  bool operator ==(Object other) {
    return TextAttributeMapper.ensureInitialized().equalsValue(
      this as TextAttribute,
      other,
    );
  }

  @override
  int get hashCode {
    return TextAttributeMapper.ensureInitialized().hashValue(
      this as TextAttribute,
    );
  }
}

extension TextAttributeValueCopy<$R, $Out>
    on ObjectCopyWith<$R, TextAttribute, $Out> {
  TextAttributeCopyWith<$R, TextAttribute, $Out> get $asTextAttribute =>
      $base.as((v, t, t2) => _TextAttributeCopyWithImpl<$R, $Out>(v, t, t2));
}

abstract class TextAttributeCopyWith<$R, $In extends TextAttribute, $Out>
    implements AttributeCopyWith<$R, $In, $Out> {
  @override
  ForeignKeyCopyWith<$R, ForeignKey, ForeignKey>? get foreignKey;
  @override
  $R call({
    String? name,
    bool? nullable,
    bool? unique,
    bool? primaryKey,
    Object? defaultValue,
    String? checkConstraint,
    ForeignKey? foreignKey,
  });
  TextAttributeCopyWith<$R2, $In, $Out2> $chain<$R2, $Out2>(Then<$Out2, $R2> t);
}

class _TextAttributeCopyWithImpl<$R, $Out>
    extends ClassCopyWithBase<$R, TextAttribute, $Out>
    implements TextAttributeCopyWith<$R, TextAttribute, $Out> {
  _TextAttributeCopyWithImpl(super.value, super.then, super.then2);

  @override
  late final ClassMapperBase<TextAttribute> $mapper =
      TextAttributeMapper.ensureInitialized();
  @override
  ForeignKeyCopyWith<$R, ForeignKey, ForeignKey>? get foreignKey =>
      $value.foreignKey?.copyWith.$chain((v) => call(foreignKey: v));
  @override
  $R call({
    String? name,
    bool? nullable,
    bool? unique,
    bool? primaryKey,
    Object? defaultValue = $none,
    Object? checkConstraint = $none,
    Object? foreignKey = $none,
  }) => $apply(
    FieldCopyWithData({
      if (name != null) #name: name,
      if (nullable != null) #nullable: nullable,
      if (unique != null) #unique: unique,
      if (primaryKey != null) #primaryKey: primaryKey,
      if (defaultValue != $none) #defaultValue: defaultValue,
      if (checkConstraint != $none) #checkConstraint: checkConstraint,
      if (foreignKey != $none) #foreignKey: foreignKey,
    }),
  );
  @override
  TextAttribute $make(CopyWithData data) => TextAttribute(
    name: data.get(#name, or: $value.name),
    nullable: data.get(#nullable, or: $value.nullable),
    unique: data.get(#unique, or: $value.unique),
    primaryKey: data.get(#primaryKey, or: $value.primaryKey),
    defaultValue: data.get(#defaultValue, or: $value.defaultValue),
    checkConstraint: data.get(#checkConstraint, or: $value.checkConstraint),
    foreignKey: data.get(#foreignKey, or: $value.foreignKey),
  );

  @override
  TextAttributeCopyWith<$R2, TextAttribute, $Out2> $chain<$R2, $Out2>(
    Then<$Out2, $R2> t,
  ) => _TextAttributeCopyWithImpl<$R2, $Out2>($value, $cast, t);
}

class IntAttributeMapper extends SubClassMapperBase<IntAttribute> {
  IntAttributeMapper._();

  static IntAttributeMapper? _instance;
  static IntAttributeMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = IntAttributeMapper._());
      AttributeMapper.ensureInitialized().addSubMapper(_instance!);
      ForeignKeyMapper.ensureInitialized();
    }
    return _instance!;
  }

  @override
  final String id = 'IntAttribute';

  static String _$name(IntAttribute v) => v.name;
  static const Field<IntAttribute, String> _f$name = Field('name', _$name);
  static bool _$nullable(IntAttribute v) => v.nullable;
  static const Field<IntAttribute, bool> _f$nullable = Field(
    'nullable',
    _$nullable,
    opt: true,
    def: true,
  );
  static bool _$unique(IntAttribute v) => v.unique;
  static const Field<IntAttribute, bool> _f$unique = Field(
    'unique',
    _$unique,
    opt: true,
    def: false,
  );
  static bool _$primaryKey(IntAttribute v) => v.primaryKey;
  static const Field<IntAttribute, bool> _f$primaryKey = Field(
    'primaryKey',
    _$primaryKey,
    key: r'primary_key',
    opt: true,
    def: false,
  );
  static Object? _$defaultValue(IntAttribute v) => v.defaultValue;
  static const Field<IntAttribute, Object> _f$defaultValue = Field(
    'defaultValue',
    _$defaultValue,
    key: r'default_value',
    opt: true,
  );
  static String? _$checkConstraint(IntAttribute v) => v.checkConstraint;
  static const Field<IntAttribute, String> _f$checkConstraint = Field(
    'checkConstraint',
    _$checkConstraint,
    key: r'check_constraint',
    opt: true,
  );
  static ForeignKey? _$foreignKey(IntAttribute v) => v.foreignKey;
  static const Field<IntAttribute, ForeignKey> _f$foreignKey = Field(
    'foreignKey',
    _$foreignKey,
    key: r'foreign_key',
    opt: true,
  );

  @override
  final MappableFields<IntAttribute> fields = const {
    #name: _f$name,
    #nullable: _f$nullable,
    #unique: _f$unique,
    #primaryKey: _f$primaryKey,
    #defaultValue: _f$defaultValue,
    #checkConstraint: _f$checkConstraint,
    #foreignKey: _f$foreignKey,
  };

  @override
  final String discriminatorKey = 'type';
  @override
  final dynamic discriminatorValue = 'INTEGER';
  @override
  late final ClassMapperBase superMapper = AttributeMapper.ensureInitialized();

  static IntAttribute _instantiate(DecodingData data) {
    return IntAttribute(
      name: data.dec(_f$name),
      nullable: data.dec(_f$nullable),
      unique: data.dec(_f$unique),
      primaryKey: data.dec(_f$primaryKey),
      defaultValue: data.dec(_f$defaultValue),
      checkConstraint: data.dec(_f$checkConstraint),
      foreignKey: data.dec(_f$foreignKey),
    );
  }

  @override
  final Function instantiate = _instantiate;

  static IntAttribute fromJson(Map<String, dynamic> map) {
    return ensureInitialized().decodeMap<IntAttribute>(map);
  }

  static IntAttribute fromJsonString(String json) {
    return ensureInitialized().decodeJson<IntAttribute>(json);
  }
}

mixin IntAttributeMappable {
  String toJsonString() {
    return IntAttributeMapper.ensureInitialized().encodeJson<IntAttribute>(
      this as IntAttribute,
    );
  }

  Map<String, dynamic> toJson() {
    return IntAttributeMapper.ensureInitialized().encodeMap<IntAttribute>(
      this as IntAttribute,
    );
  }

  IntAttributeCopyWith<IntAttribute, IntAttribute, IntAttribute> get copyWith =>
      _IntAttributeCopyWithImpl<IntAttribute, IntAttribute>(
        this as IntAttribute,
        $identity,
        $identity,
      );
  @override
  String toString() {
    return IntAttributeMapper.ensureInitialized().stringifyValue(
      this as IntAttribute,
    );
  }

  @override
  bool operator ==(Object other) {
    return IntAttributeMapper.ensureInitialized().equalsValue(
      this as IntAttribute,
      other,
    );
  }

  @override
  int get hashCode {
    return IntAttributeMapper.ensureInitialized().hashValue(
      this as IntAttribute,
    );
  }
}

extension IntAttributeValueCopy<$R, $Out>
    on ObjectCopyWith<$R, IntAttribute, $Out> {
  IntAttributeCopyWith<$R, IntAttribute, $Out> get $asIntAttribute =>
      $base.as((v, t, t2) => _IntAttributeCopyWithImpl<$R, $Out>(v, t, t2));
}

abstract class IntAttributeCopyWith<$R, $In extends IntAttribute, $Out>
    implements AttributeCopyWith<$R, $In, $Out> {
  @override
  ForeignKeyCopyWith<$R, ForeignKey, ForeignKey>? get foreignKey;
  @override
  $R call({
    String? name,
    bool? nullable,
    bool? unique,
    bool? primaryKey,
    Object? defaultValue,
    String? checkConstraint,
    ForeignKey? foreignKey,
  });
  IntAttributeCopyWith<$R2, $In, $Out2> $chain<$R2, $Out2>(Then<$Out2, $R2> t);
}

class _IntAttributeCopyWithImpl<$R, $Out>
    extends ClassCopyWithBase<$R, IntAttribute, $Out>
    implements IntAttributeCopyWith<$R, IntAttribute, $Out> {
  _IntAttributeCopyWithImpl(super.value, super.then, super.then2);

  @override
  late final ClassMapperBase<IntAttribute> $mapper =
      IntAttributeMapper.ensureInitialized();
  @override
  ForeignKeyCopyWith<$R, ForeignKey, ForeignKey>? get foreignKey =>
      $value.foreignKey?.copyWith.$chain((v) => call(foreignKey: v));
  @override
  $R call({
    String? name,
    bool? nullable,
    bool? unique,
    bool? primaryKey,
    Object? defaultValue = $none,
    Object? checkConstraint = $none,
    Object? foreignKey = $none,
  }) => $apply(
    FieldCopyWithData({
      if (name != null) #name: name,
      if (nullable != null) #nullable: nullable,
      if (unique != null) #unique: unique,
      if (primaryKey != null) #primaryKey: primaryKey,
      if (defaultValue != $none) #defaultValue: defaultValue,
      if (checkConstraint != $none) #checkConstraint: checkConstraint,
      if (foreignKey != $none) #foreignKey: foreignKey,
    }),
  );
  @override
  IntAttribute $make(CopyWithData data) => IntAttribute(
    name: data.get(#name, or: $value.name),
    nullable: data.get(#nullable, or: $value.nullable),
    unique: data.get(#unique, or: $value.unique),
    primaryKey: data.get(#primaryKey, or: $value.primaryKey),
    defaultValue: data.get(#defaultValue, or: $value.defaultValue),
    checkConstraint: data.get(#checkConstraint, or: $value.checkConstraint),
    foreignKey: data.get(#foreignKey, or: $value.foreignKey),
  );

  @override
  IntAttributeCopyWith<$R2, IntAttribute, $Out2> $chain<$R2, $Out2>(
    Then<$Out2, $R2> t,
  ) => _IntAttributeCopyWithImpl<$R2, $Out2>($value, $cast, t);
}

class BoolAttributeMapper extends SubClassMapperBase<BoolAttribute> {
  BoolAttributeMapper._();

  static BoolAttributeMapper? _instance;
  static BoolAttributeMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = BoolAttributeMapper._());
      AttributeMapper.ensureInitialized().addSubMapper(_instance!);
      ForeignKeyMapper.ensureInitialized();
    }
    return _instance!;
  }

  @override
  final String id = 'BoolAttribute';

  static String _$name(BoolAttribute v) => v.name;
  static const Field<BoolAttribute, String> _f$name = Field('name', _$name);
  static bool _$nullable(BoolAttribute v) => v.nullable;
  static const Field<BoolAttribute, bool> _f$nullable = Field(
    'nullable',
    _$nullable,
    opt: true,
    def: true,
  );
  static bool _$unique(BoolAttribute v) => v.unique;
  static const Field<BoolAttribute, bool> _f$unique = Field(
    'unique',
    _$unique,
    opt: true,
    def: false,
  );
  static bool _$primaryKey(BoolAttribute v) => v.primaryKey;
  static const Field<BoolAttribute, bool> _f$primaryKey = Field(
    'primaryKey',
    _$primaryKey,
    key: r'primary_key',
    opt: true,
    def: false,
  );
  static Object? _$defaultValue(BoolAttribute v) => v.defaultValue;
  static const Field<BoolAttribute, Object> _f$defaultValue = Field(
    'defaultValue',
    _$defaultValue,
    key: r'default_value',
    opt: true,
  );
  static String? _$checkConstraint(BoolAttribute v) => v.checkConstraint;
  static const Field<BoolAttribute, String> _f$checkConstraint = Field(
    'checkConstraint',
    _$checkConstraint,
    key: r'check_constraint',
    opt: true,
  );
  static ForeignKey? _$foreignKey(BoolAttribute v) => v.foreignKey;
  static const Field<BoolAttribute, ForeignKey> _f$foreignKey = Field(
    'foreignKey',
    _$foreignKey,
    key: r'foreign_key',
    opt: true,
  );

  @override
  final MappableFields<BoolAttribute> fields = const {
    #name: _f$name,
    #nullable: _f$nullable,
    #unique: _f$unique,
    #primaryKey: _f$primaryKey,
    #defaultValue: _f$defaultValue,
    #checkConstraint: _f$checkConstraint,
    #foreignKey: _f$foreignKey,
  };

  @override
  final String discriminatorKey = 'type';
  @override
  final dynamic discriminatorValue = 'BOOL';
  @override
  late final ClassMapperBase superMapper = AttributeMapper.ensureInitialized();

  static BoolAttribute _instantiate(DecodingData data) {
    return BoolAttribute(
      name: data.dec(_f$name),
      nullable: data.dec(_f$nullable),
      unique: data.dec(_f$unique),
      primaryKey: data.dec(_f$primaryKey),
      defaultValue: data.dec(_f$defaultValue),
      checkConstraint: data.dec(_f$checkConstraint),
      foreignKey: data.dec(_f$foreignKey),
    );
  }

  @override
  final Function instantiate = _instantiate;

  static BoolAttribute fromJson(Map<String, dynamic> map) {
    return ensureInitialized().decodeMap<BoolAttribute>(map);
  }

  static BoolAttribute fromJsonString(String json) {
    return ensureInitialized().decodeJson<BoolAttribute>(json);
  }
}

mixin BoolAttributeMappable {
  String toJsonString() {
    return BoolAttributeMapper.ensureInitialized().encodeJson<BoolAttribute>(
      this as BoolAttribute,
    );
  }

  Map<String, dynamic> toJson() {
    return BoolAttributeMapper.ensureInitialized().encodeMap<BoolAttribute>(
      this as BoolAttribute,
    );
  }

  BoolAttributeCopyWith<BoolAttribute, BoolAttribute, BoolAttribute>
  get copyWith => _BoolAttributeCopyWithImpl<BoolAttribute, BoolAttribute>(
    this as BoolAttribute,
    $identity,
    $identity,
  );
  @override
  String toString() {
    return BoolAttributeMapper.ensureInitialized().stringifyValue(
      this as BoolAttribute,
    );
  }

  @override
  bool operator ==(Object other) {
    return BoolAttributeMapper.ensureInitialized().equalsValue(
      this as BoolAttribute,
      other,
    );
  }

  @override
  int get hashCode {
    return BoolAttributeMapper.ensureInitialized().hashValue(
      this as BoolAttribute,
    );
  }
}

extension BoolAttributeValueCopy<$R, $Out>
    on ObjectCopyWith<$R, BoolAttribute, $Out> {
  BoolAttributeCopyWith<$R, BoolAttribute, $Out> get $asBoolAttribute =>
      $base.as((v, t, t2) => _BoolAttributeCopyWithImpl<$R, $Out>(v, t, t2));
}

abstract class BoolAttributeCopyWith<$R, $In extends BoolAttribute, $Out>
    implements AttributeCopyWith<$R, $In, $Out> {
  @override
  ForeignKeyCopyWith<$R, ForeignKey, ForeignKey>? get foreignKey;
  @override
  $R call({
    String? name,
    bool? nullable,
    bool? unique,
    bool? primaryKey,
    Object? defaultValue,
    String? checkConstraint,
    ForeignKey? foreignKey,
  });
  BoolAttributeCopyWith<$R2, $In, $Out2> $chain<$R2, $Out2>(Then<$Out2, $R2> t);
}

class _BoolAttributeCopyWithImpl<$R, $Out>
    extends ClassCopyWithBase<$R, BoolAttribute, $Out>
    implements BoolAttributeCopyWith<$R, BoolAttribute, $Out> {
  _BoolAttributeCopyWithImpl(super.value, super.then, super.then2);

  @override
  late final ClassMapperBase<BoolAttribute> $mapper =
      BoolAttributeMapper.ensureInitialized();
  @override
  ForeignKeyCopyWith<$R, ForeignKey, ForeignKey>? get foreignKey =>
      $value.foreignKey?.copyWith.$chain((v) => call(foreignKey: v));
  @override
  $R call({
    String? name,
    bool? nullable,
    bool? unique,
    bool? primaryKey,
    Object? defaultValue = $none,
    Object? checkConstraint = $none,
    Object? foreignKey = $none,
  }) => $apply(
    FieldCopyWithData({
      if (name != null) #name: name,
      if (nullable != null) #nullable: nullable,
      if (unique != null) #unique: unique,
      if (primaryKey != null) #primaryKey: primaryKey,
      if (defaultValue != $none) #defaultValue: defaultValue,
      if (checkConstraint != $none) #checkConstraint: checkConstraint,
      if (foreignKey != $none) #foreignKey: foreignKey,
    }),
  );
  @override
  BoolAttribute $make(CopyWithData data) => BoolAttribute(
    name: data.get(#name, or: $value.name),
    nullable: data.get(#nullable, or: $value.nullable),
    unique: data.get(#unique, or: $value.unique),
    primaryKey: data.get(#primaryKey, or: $value.primaryKey),
    defaultValue: data.get(#defaultValue, or: $value.defaultValue),
    checkConstraint: data.get(#checkConstraint, or: $value.checkConstraint),
    foreignKey: data.get(#foreignKey, or: $value.foreignKey),
  );

  @override
  BoolAttributeCopyWith<$R2, BoolAttribute, $Out2> $chain<$R2, $Out2>(
    Then<$Out2, $R2> t,
  ) => _BoolAttributeCopyWithImpl<$R2, $Out2>($value, $cast, t);
}

class DateAttributeMapper extends SubClassMapperBase<DateAttribute> {
  DateAttributeMapper._();

  static DateAttributeMapper? _instance;
  static DateAttributeMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = DateAttributeMapper._());
      AttributeMapper.ensureInitialized().addSubMapper(_instance!);
      ForeignKeyMapper.ensureInitialized();
    }
    return _instance!;
  }

  @override
  final String id = 'DateAttribute';

  static String _$name(DateAttribute v) => v.name;
  static const Field<DateAttribute, String> _f$name = Field('name', _$name);
  static bool _$nullable(DateAttribute v) => v.nullable;
  static const Field<DateAttribute, bool> _f$nullable = Field(
    'nullable',
    _$nullable,
    opt: true,
    def: true,
  );
  static bool _$unique(DateAttribute v) => v.unique;
  static const Field<DateAttribute, bool> _f$unique = Field(
    'unique',
    _$unique,
    opt: true,
    def: false,
  );
  static bool _$primaryKey(DateAttribute v) => v.primaryKey;
  static const Field<DateAttribute, bool> _f$primaryKey = Field(
    'primaryKey',
    _$primaryKey,
    key: r'primary_key',
    opt: true,
    def: false,
  );
  static Object? _$defaultValue(DateAttribute v) => v.defaultValue;
  static const Field<DateAttribute, Object> _f$defaultValue = Field(
    'defaultValue',
    _$defaultValue,
    key: r'default_value',
    opt: true,
  );
  static String? _$checkConstraint(DateAttribute v) => v.checkConstraint;
  static const Field<DateAttribute, String> _f$checkConstraint = Field(
    'checkConstraint',
    _$checkConstraint,
    key: r'check_constraint',
    opt: true,
  );
  static ForeignKey? _$foreignKey(DateAttribute v) => v.foreignKey;
  static const Field<DateAttribute, ForeignKey> _f$foreignKey = Field(
    'foreignKey',
    _$foreignKey,
    key: r'foreign_key',
    opt: true,
  );

  @override
  final MappableFields<DateAttribute> fields = const {
    #name: _f$name,
    #nullable: _f$nullable,
    #unique: _f$unique,
    #primaryKey: _f$primaryKey,
    #defaultValue: _f$defaultValue,
    #checkConstraint: _f$checkConstraint,
    #foreignKey: _f$foreignKey,
  };

  @override
  final String discriminatorKey = 'type';
  @override
  final dynamic discriminatorValue = 'DATE';
  @override
  late final ClassMapperBase superMapper = AttributeMapper.ensureInitialized();

  static DateAttribute _instantiate(DecodingData data) {
    return DateAttribute(
      name: data.dec(_f$name),
      nullable: data.dec(_f$nullable),
      unique: data.dec(_f$unique),
      primaryKey: data.dec(_f$primaryKey),
      defaultValue: data.dec(_f$defaultValue),
      checkConstraint: data.dec(_f$checkConstraint),
      foreignKey: data.dec(_f$foreignKey),
    );
  }

  @override
  final Function instantiate = _instantiate;

  static DateAttribute fromJson(Map<String, dynamic> map) {
    return ensureInitialized().decodeMap<DateAttribute>(map);
  }

  static DateAttribute fromJsonString(String json) {
    return ensureInitialized().decodeJson<DateAttribute>(json);
  }
}

mixin DateAttributeMappable {
  String toJsonString() {
    return DateAttributeMapper.ensureInitialized().encodeJson<DateAttribute>(
      this as DateAttribute,
    );
  }

  Map<String, dynamic> toJson() {
    return DateAttributeMapper.ensureInitialized().encodeMap<DateAttribute>(
      this as DateAttribute,
    );
  }

  DateAttributeCopyWith<DateAttribute, DateAttribute, DateAttribute>
  get copyWith => _DateAttributeCopyWithImpl<DateAttribute, DateAttribute>(
    this as DateAttribute,
    $identity,
    $identity,
  );
  @override
  String toString() {
    return DateAttributeMapper.ensureInitialized().stringifyValue(
      this as DateAttribute,
    );
  }

  @override
  bool operator ==(Object other) {
    return DateAttributeMapper.ensureInitialized().equalsValue(
      this as DateAttribute,
      other,
    );
  }

  @override
  int get hashCode {
    return DateAttributeMapper.ensureInitialized().hashValue(
      this as DateAttribute,
    );
  }
}

extension DateAttributeValueCopy<$R, $Out>
    on ObjectCopyWith<$R, DateAttribute, $Out> {
  DateAttributeCopyWith<$R, DateAttribute, $Out> get $asDateAttribute =>
      $base.as((v, t, t2) => _DateAttributeCopyWithImpl<$R, $Out>(v, t, t2));
}

abstract class DateAttributeCopyWith<$R, $In extends DateAttribute, $Out>
    implements AttributeCopyWith<$R, $In, $Out> {
  @override
  ForeignKeyCopyWith<$R, ForeignKey, ForeignKey>? get foreignKey;
  @override
  $R call({
    String? name,
    bool? nullable,
    bool? unique,
    bool? primaryKey,
    Object? defaultValue,
    String? checkConstraint,
    ForeignKey? foreignKey,
  });
  DateAttributeCopyWith<$R2, $In, $Out2> $chain<$R2, $Out2>(Then<$Out2, $R2> t);
}

class _DateAttributeCopyWithImpl<$R, $Out>
    extends ClassCopyWithBase<$R, DateAttribute, $Out>
    implements DateAttributeCopyWith<$R, DateAttribute, $Out> {
  _DateAttributeCopyWithImpl(super.value, super.then, super.then2);

  @override
  late final ClassMapperBase<DateAttribute> $mapper =
      DateAttributeMapper.ensureInitialized();
  @override
  ForeignKeyCopyWith<$R, ForeignKey, ForeignKey>? get foreignKey =>
      $value.foreignKey?.copyWith.$chain((v) => call(foreignKey: v));
  @override
  $R call({
    String? name,
    bool? nullable,
    bool? unique,
    bool? primaryKey,
    Object? defaultValue = $none,
    Object? checkConstraint = $none,
    Object? foreignKey = $none,
  }) => $apply(
    FieldCopyWithData({
      if (name != null) #name: name,
      if (nullable != null) #nullable: nullable,
      if (unique != null) #unique: unique,
      if (primaryKey != null) #primaryKey: primaryKey,
      if (defaultValue != $none) #defaultValue: defaultValue,
      if (checkConstraint != $none) #checkConstraint: checkConstraint,
      if (foreignKey != $none) #foreignKey: foreignKey,
    }),
  );
  @override
  DateAttribute $make(CopyWithData data) => DateAttribute(
    name: data.get(#name, or: $value.name),
    nullable: data.get(#nullable, or: $value.nullable),
    unique: data.get(#unique, or: $value.unique),
    primaryKey: data.get(#primaryKey, or: $value.primaryKey),
    defaultValue: data.get(#defaultValue, or: $value.defaultValue),
    checkConstraint: data.get(#checkConstraint, or: $value.checkConstraint),
    foreignKey: data.get(#foreignKey, or: $value.foreignKey),
  );

  @override
  DateAttributeCopyWith<$R2, DateAttribute, $Out2> $chain<$R2, $Out2>(
    Then<$Out2, $R2> t,
  ) => _DateAttributeCopyWithImpl<$R2, $Out2>($value, $cast, t);
}

class DoubleAttributeMapper extends SubClassMapperBase<DoubleAttribute> {
  DoubleAttributeMapper._();

  static DoubleAttributeMapper? _instance;
  static DoubleAttributeMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = DoubleAttributeMapper._());
      AttributeMapper.ensureInitialized().addSubMapper(_instance!);
      ForeignKeyMapper.ensureInitialized();
    }
    return _instance!;
  }

  @override
  final String id = 'DoubleAttribute';

  static String _$name(DoubleAttribute v) => v.name;
  static const Field<DoubleAttribute, String> _f$name = Field('name', _$name);
  static bool _$nullable(DoubleAttribute v) => v.nullable;
  static const Field<DoubleAttribute, bool> _f$nullable = Field(
    'nullable',
    _$nullable,
    opt: true,
    def: true,
  );
  static bool _$unique(DoubleAttribute v) => v.unique;
  static const Field<DoubleAttribute, bool> _f$unique = Field(
    'unique',
    _$unique,
    opt: true,
    def: false,
  );
  static bool _$primaryKey(DoubleAttribute v) => v.primaryKey;
  static const Field<DoubleAttribute, bool> _f$primaryKey = Field(
    'primaryKey',
    _$primaryKey,
    key: r'primary_key',
    opt: true,
    def: false,
  );
  static Object? _$defaultValue(DoubleAttribute v) => v.defaultValue;
  static const Field<DoubleAttribute, Object> _f$defaultValue = Field(
    'defaultValue',
    _$defaultValue,
    key: r'default_value',
    opt: true,
  );
  static String? _$checkConstraint(DoubleAttribute v) => v.checkConstraint;
  static const Field<DoubleAttribute, String> _f$checkConstraint = Field(
    'checkConstraint',
    _$checkConstraint,
    key: r'check_constraint',
    opt: true,
  );
  static ForeignKey? _$foreignKey(DoubleAttribute v) => v.foreignKey;
  static const Field<DoubleAttribute, ForeignKey> _f$foreignKey = Field(
    'foreignKey',
    _$foreignKey,
    key: r'foreign_key',
    opt: true,
  );

  @override
  final MappableFields<DoubleAttribute> fields = const {
    #name: _f$name,
    #nullable: _f$nullable,
    #unique: _f$unique,
    #primaryKey: _f$primaryKey,
    #defaultValue: _f$defaultValue,
    #checkConstraint: _f$checkConstraint,
    #foreignKey: _f$foreignKey,
  };

  @override
  final String discriminatorKey = 'type';
  @override
  final dynamic discriminatorValue = 'REAL';
  @override
  late final ClassMapperBase superMapper = AttributeMapper.ensureInitialized();

  static DoubleAttribute _instantiate(DecodingData data) {
    return DoubleAttribute(
      name: data.dec(_f$name),
      nullable: data.dec(_f$nullable),
      unique: data.dec(_f$unique),
      primaryKey: data.dec(_f$primaryKey),
      defaultValue: data.dec(_f$defaultValue),
      checkConstraint: data.dec(_f$checkConstraint),
      foreignKey: data.dec(_f$foreignKey),
    );
  }

  @override
  final Function instantiate = _instantiate;

  static DoubleAttribute fromJson(Map<String, dynamic> map) {
    return ensureInitialized().decodeMap<DoubleAttribute>(map);
  }

  static DoubleAttribute fromJsonString(String json) {
    return ensureInitialized().decodeJson<DoubleAttribute>(json);
  }
}

mixin DoubleAttributeMappable {
  String toJsonString() {
    return DoubleAttributeMapper.ensureInitialized()
        .encodeJson<DoubleAttribute>(this as DoubleAttribute);
  }

  Map<String, dynamic> toJson() {
    return DoubleAttributeMapper.ensureInitialized().encodeMap<DoubleAttribute>(
      this as DoubleAttribute,
    );
  }

  DoubleAttributeCopyWith<DoubleAttribute, DoubleAttribute, DoubleAttribute>
  get copyWith =>
      _DoubleAttributeCopyWithImpl<DoubleAttribute, DoubleAttribute>(
        this as DoubleAttribute,
        $identity,
        $identity,
      );
  @override
  String toString() {
    return DoubleAttributeMapper.ensureInitialized().stringifyValue(
      this as DoubleAttribute,
    );
  }

  @override
  bool operator ==(Object other) {
    return DoubleAttributeMapper.ensureInitialized().equalsValue(
      this as DoubleAttribute,
      other,
    );
  }

  @override
  int get hashCode {
    return DoubleAttributeMapper.ensureInitialized().hashValue(
      this as DoubleAttribute,
    );
  }
}

extension DoubleAttributeValueCopy<$R, $Out>
    on ObjectCopyWith<$R, DoubleAttribute, $Out> {
  DoubleAttributeCopyWith<$R, DoubleAttribute, $Out> get $asDoubleAttribute =>
      $base.as((v, t, t2) => _DoubleAttributeCopyWithImpl<$R, $Out>(v, t, t2));
}

abstract class DoubleAttributeCopyWith<$R, $In extends DoubleAttribute, $Out>
    implements AttributeCopyWith<$R, $In, $Out> {
  @override
  ForeignKeyCopyWith<$R, ForeignKey, ForeignKey>? get foreignKey;
  @override
  $R call({
    String? name,
    bool? nullable,
    bool? unique,
    bool? primaryKey,
    Object? defaultValue,
    String? checkConstraint,
    ForeignKey? foreignKey,
  });
  DoubleAttributeCopyWith<$R2, $In, $Out2> $chain<$R2, $Out2>(
    Then<$Out2, $R2> t,
  );
}

class _DoubleAttributeCopyWithImpl<$R, $Out>
    extends ClassCopyWithBase<$R, DoubleAttribute, $Out>
    implements DoubleAttributeCopyWith<$R, DoubleAttribute, $Out> {
  _DoubleAttributeCopyWithImpl(super.value, super.then, super.then2);

  @override
  late final ClassMapperBase<DoubleAttribute> $mapper =
      DoubleAttributeMapper.ensureInitialized();
  @override
  ForeignKeyCopyWith<$R, ForeignKey, ForeignKey>? get foreignKey =>
      $value.foreignKey?.copyWith.$chain((v) => call(foreignKey: v));
  @override
  $R call({
    String? name,
    bool? nullable,
    bool? unique,
    bool? primaryKey,
    Object? defaultValue = $none,
    Object? checkConstraint = $none,
    Object? foreignKey = $none,
  }) => $apply(
    FieldCopyWithData({
      if (name != null) #name: name,
      if (nullable != null) #nullable: nullable,
      if (unique != null) #unique: unique,
      if (primaryKey != null) #primaryKey: primaryKey,
      if (defaultValue != $none) #defaultValue: defaultValue,
      if (checkConstraint != $none) #checkConstraint: checkConstraint,
      if (foreignKey != $none) #foreignKey: foreignKey,
    }),
  );
  @override
  DoubleAttribute $make(CopyWithData data) => DoubleAttribute(
    name: data.get(#name, or: $value.name),
    nullable: data.get(#nullable, or: $value.nullable),
    unique: data.get(#unique, or: $value.unique),
    primaryKey: data.get(#primaryKey, or: $value.primaryKey),
    defaultValue: data.get(#defaultValue, or: $value.defaultValue),
    checkConstraint: data.get(#checkConstraint, or: $value.checkConstraint),
    foreignKey: data.get(#foreignKey, or: $value.foreignKey),
  );

  @override
  DoubleAttributeCopyWith<$R2, DoubleAttribute, $Out2> $chain<$R2, $Out2>(
    Then<$Out2, $R2> t,
  ) => _DoubleAttributeCopyWithImpl<$R2, $Out2>($value, $cast, t);
}

class JsonAttributeMapper extends SubClassMapperBase<JsonAttribute> {
  JsonAttributeMapper._();

  static JsonAttributeMapper? _instance;
  static JsonAttributeMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = JsonAttributeMapper._());
      AttributeMapper.ensureInitialized().addSubMapper(_instance!);
      ForeignKeyMapper.ensureInitialized();
    }
    return _instance!;
  }

  @override
  final String id = 'JsonAttribute';

  static String _$name(JsonAttribute v) => v.name;
  static const Field<JsonAttribute, String> _f$name = Field('name', _$name);
  static bool _$nullable(JsonAttribute v) => v.nullable;
  static const Field<JsonAttribute, bool> _f$nullable = Field(
    'nullable',
    _$nullable,
    opt: true,
    def: true,
  );
  static bool _$unique(JsonAttribute v) => v.unique;
  static const Field<JsonAttribute, bool> _f$unique = Field(
    'unique',
    _$unique,
    opt: true,
    def: false,
  );
  static bool _$primaryKey(JsonAttribute v) => v.primaryKey;
  static const Field<JsonAttribute, bool> _f$primaryKey = Field(
    'primaryKey',
    _$primaryKey,
    key: r'primary_key',
    opt: true,
    def: false,
  );
  static Object? _$defaultValue(JsonAttribute v) => v.defaultValue;
  static const Field<JsonAttribute, Object> _f$defaultValue = Field(
    'defaultValue',
    _$defaultValue,
    key: r'default_value',
    opt: true,
  );
  static String? _$checkConstraint(JsonAttribute v) => v.checkConstraint;
  static const Field<JsonAttribute, String> _f$checkConstraint = Field(
    'checkConstraint',
    _$checkConstraint,
    key: r'check_constraint',
    opt: true,
  );
  static ForeignKey? _$foreignKey(JsonAttribute v) => v.foreignKey;
  static const Field<JsonAttribute, ForeignKey> _f$foreignKey = Field(
    'foreignKey',
    _$foreignKey,
    key: r'foreign_key',
    opt: true,
  );

  @override
  final MappableFields<JsonAttribute> fields = const {
    #name: _f$name,
    #nullable: _f$nullable,
    #unique: _f$unique,
    #primaryKey: _f$primaryKey,
    #defaultValue: _f$defaultValue,
    #checkConstraint: _f$checkConstraint,
    #foreignKey: _f$foreignKey,
  };

  @override
  final String discriminatorKey = 'type';
  @override
  final dynamic discriminatorValue = 'JSON';
  @override
  late final ClassMapperBase superMapper = AttributeMapper.ensureInitialized();

  static JsonAttribute _instantiate(DecodingData data) {
    return JsonAttribute(
      name: data.dec(_f$name),
      nullable: data.dec(_f$nullable),
      unique: data.dec(_f$unique),
      primaryKey: data.dec(_f$primaryKey),
      defaultValue: data.dec(_f$defaultValue),
      checkConstraint: data.dec(_f$checkConstraint),
      foreignKey: data.dec(_f$foreignKey),
    );
  }

  @override
  final Function instantiate = _instantiate;

  static JsonAttribute fromJson(Map<String, dynamic> map) {
    return ensureInitialized().decodeMap<JsonAttribute>(map);
  }

  static JsonAttribute fromJsonString(String json) {
    return ensureInitialized().decodeJson<JsonAttribute>(json);
  }
}

mixin JsonAttributeMappable {
  String toJsonString() {
    return JsonAttributeMapper.ensureInitialized().encodeJson<JsonAttribute>(
      this as JsonAttribute,
    );
  }

  Map<String, dynamic> toJson() {
    return JsonAttributeMapper.ensureInitialized().encodeMap<JsonAttribute>(
      this as JsonAttribute,
    );
  }

  JsonAttributeCopyWith<JsonAttribute, JsonAttribute, JsonAttribute>
  get copyWith => _JsonAttributeCopyWithImpl<JsonAttribute, JsonAttribute>(
    this as JsonAttribute,
    $identity,
    $identity,
  );
  @override
  String toString() {
    return JsonAttributeMapper.ensureInitialized().stringifyValue(
      this as JsonAttribute,
    );
  }

  @override
  bool operator ==(Object other) {
    return JsonAttributeMapper.ensureInitialized().equalsValue(
      this as JsonAttribute,
      other,
    );
  }

  @override
  int get hashCode {
    return JsonAttributeMapper.ensureInitialized().hashValue(
      this as JsonAttribute,
    );
  }
}

extension JsonAttributeValueCopy<$R, $Out>
    on ObjectCopyWith<$R, JsonAttribute, $Out> {
  JsonAttributeCopyWith<$R, JsonAttribute, $Out> get $asJsonAttribute =>
      $base.as((v, t, t2) => _JsonAttributeCopyWithImpl<$R, $Out>(v, t, t2));
}

abstract class JsonAttributeCopyWith<$R, $In extends JsonAttribute, $Out>
    implements AttributeCopyWith<$R, $In, $Out> {
  @override
  ForeignKeyCopyWith<$R, ForeignKey, ForeignKey>? get foreignKey;
  @override
  $R call({
    String? name,
    bool? nullable,
    bool? unique,
    bool? primaryKey,
    Object? defaultValue,
    String? checkConstraint,
    ForeignKey? foreignKey,
  });
  JsonAttributeCopyWith<$R2, $In, $Out2> $chain<$R2, $Out2>(Then<$Out2, $R2> t);
}

class _JsonAttributeCopyWithImpl<$R, $Out>
    extends ClassCopyWithBase<$R, JsonAttribute, $Out>
    implements JsonAttributeCopyWith<$R, JsonAttribute, $Out> {
  _JsonAttributeCopyWithImpl(super.value, super.then, super.then2);

  @override
  late final ClassMapperBase<JsonAttribute> $mapper =
      JsonAttributeMapper.ensureInitialized();
  @override
  ForeignKeyCopyWith<$R, ForeignKey, ForeignKey>? get foreignKey =>
      $value.foreignKey?.copyWith.$chain((v) => call(foreignKey: v));
  @override
  $R call({
    String? name,
    bool? nullable,
    bool? unique,
    bool? primaryKey,
    Object? defaultValue = $none,
    Object? checkConstraint = $none,
    Object? foreignKey = $none,
  }) => $apply(
    FieldCopyWithData({
      if (name != null) #name: name,
      if (nullable != null) #nullable: nullable,
      if (unique != null) #unique: unique,
      if (primaryKey != null) #primaryKey: primaryKey,
      if (defaultValue != $none) #defaultValue: defaultValue,
      if (checkConstraint != $none) #checkConstraint: checkConstraint,
      if (foreignKey != $none) #foreignKey: foreignKey,
    }),
  );
  @override
  JsonAttribute $make(CopyWithData data) => JsonAttribute(
    name: data.get(#name, or: $value.name),
    nullable: data.get(#nullable, or: $value.nullable),
    unique: data.get(#unique, or: $value.unique),
    primaryKey: data.get(#primaryKey, or: $value.primaryKey),
    defaultValue: data.get(#defaultValue, or: $value.defaultValue),
    checkConstraint: data.get(#checkConstraint, or: $value.checkConstraint),
    foreignKey: data.get(#foreignKey, or: $value.foreignKey),
  );

  @override
  JsonAttributeCopyWith<$R2, JsonAttribute, $Out2> $chain<$R2, $Out2>(
    Then<$Out2, $R2> t,
  ) => _JsonAttributeCopyWithImpl<$R2, $Out2>($value, $cast, t);
}

