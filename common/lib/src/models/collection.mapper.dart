// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
// ignore_for_file: type=lint
// ignore_for_file: unused_element, unnecessary_cast, override_on_non_overriding_member
// ignore_for_file: strict_raw_type, inference_failure_on_untyped_parameter

part of 'collection.dart';

class CollectionMapper extends ClassMapperBase<Collection> {
  CollectionMapper._();

  static CollectionMapper? _instance;
  static CollectionMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = CollectionMapper._());
      MapperContainer.globals.useAll([SecondsDateTimeMapper()]);
      BaseCollectionMapper.ensureInitialized();
      ViewCollectionMapper.ensureInitialized();
      AttributeMapper.ensureInitialized();
    }
    return _instance!;
  }

  @override
  final String id = 'Collection';

  static String _$name(Collection v) => v.name;
  static const Field<Collection, String> _f$name = Field('name', _$name);
  static List<Attribute> _$attributes(Collection v) => v.attributes;
  static const Field<Collection, List<Attribute>> _f$attributes = Field(
    'attributes',
    _$attributes,
    opt: true,
    def: const [],
  );
  static String? _$listRule(Collection v) => v.listRule;
  static const Field<Collection, String> _f$listRule = Field(
    'listRule',
    _$listRule,
    key: r'list_rule',
    opt: true,
  );
  static String? _$viewRule(Collection v) => v.viewRule;
  static const Field<Collection, String> _f$viewRule = Field(
    'viewRule',
    _$viewRule,
    key: r'view_rule',
    opt: true,
  );
  static DateTime _$createdAt(Collection v) => v.createdAt;
  static const Field<Collection, DateTime> _f$createdAt = Field(
    'createdAt',
    _$createdAt,
    key: r'created_at',
  );
  static DateTime _$updatedAt(Collection v) => v.updatedAt;
  static const Field<Collection, DateTime> _f$updatedAt = Field(
    'updatedAt',
    _$updatedAt,
    key: r'updated_at',
  );

  @override
  final MappableFields<Collection> fields = const {
    #name: _f$name,
    #attributes: _f$attributes,
    #listRule: _f$listRule,
    #viewRule: _f$viewRule,
    #createdAt: _f$createdAt,
    #updatedAt: _f$updatedAt,
  };

  static Collection _instantiate(DecodingData data) {
    throw MapperException.missingSubclass(
      'Collection',
      'type',
      '${data.value['type']}',
    );
  }

  @override
  final Function instantiate = _instantiate;

  static Collection fromJson(Map<String, dynamic> map) {
    return ensureInitialized().decodeMap<Collection>(map);
  }

  static Collection fromJsonString(String json) {
    return ensureInitialized().decodeJson<Collection>(json);
  }
}

mixin CollectionMappable {
  String toJsonString();
  Map<String, dynamic> toJson();
  CollectionCopyWith<Collection, Collection, Collection> get copyWith;
}

abstract class CollectionCopyWith<$R, $In extends Collection, $Out>
    implements ClassCopyWith<$R, $In, $Out> {
  ListCopyWith<$R, Attribute, ObjectCopyWith<$R, Attribute, Attribute>?>
  get attributes;
  $R call({
    String? name,
    List<Attribute>? attributes,
    String? listRule,
    String? viewRule,
    DateTime? createdAt,
    DateTime? updatedAt,
  });
  CollectionCopyWith<$R2, $In, $Out2> $chain<$R2, $Out2>(Then<$Out2, $R2> t);
}

class BaseCollectionMapper extends SubClassMapperBase<BaseCollection> {
  BaseCollectionMapper._();

  static BaseCollectionMapper? _instance;
  static BaseCollectionMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = BaseCollectionMapper._());
      CollectionMapper.ensureInitialized().addSubMapper(_instance!);
      AttributeMapper.ensureInitialized();
      IndexMapper.ensureInitialized();
    }
    return _instance!;
  }

  @override
  final String id = 'BaseCollection';

  static String _$name(BaseCollection v) => v.name;
  static const Field<BaseCollection, String> _f$name = Field('name', _$name);
  static List<Attribute> _$attributes(BaseCollection v) => v.attributes;
  static const Field<BaseCollection, List<Attribute>> _f$attributes = Field(
    'attributes',
    _$attributes,
    opt: true,
    def: const [],
  );
  static List<Index> _$indexes(BaseCollection v) => v.indexes;
  static const Field<BaseCollection, List<Index>> _f$indexes = Field(
    'indexes',
    _$indexes,
    opt: true,
    def: const [],
  );
  static String? _$listRule(BaseCollection v) => v.listRule;
  static const Field<BaseCollection, String> _f$listRule = Field(
    'listRule',
    _$listRule,
    key: r'list_rule',
    opt: true,
  );
  static String? _$viewRule(BaseCollection v) => v.viewRule;
  static const Field<BaseCollection, String> _f$viewRule = Field(
    'viewRule',
    _$viewRule,
    key: r'view_rule',
    opt: true,
  );
  static String? _$createRule(BaseCollection v) => v.createRule;
  static const Field<BaseCollection, String> _f$createRule = Field(
    'createRule',
    _$createRule,
    key: r'create_rule',
    opt: true,
  );
  static String? _$updateRule(BaseCollection v) => v.updateRule;
  static const Field<BaseCollection, String> _f$updateRule = Field(
    'updateRule',
    _$updateRule,
    key: r'update_rule',
    opt: true,
  );
  static String? _$deleteRule(BaseCollection v) => v.deleteRule;
  static const Field<BaseCollection, String> _f$deleteRule = Field(
    'deleteRule',
    _$deleteRule,
    key: r'delete_rule',
    opt: true,
  );
  static DateTime _$createdAt(BaseCollection v) => v.createdAt;
  static const Field<BaseCollection, DateTime> _f$createdAt = Field(
    'createdAt',
    _$createdAt,
    key: r'created_at',
  );
  static DateTime _$updatedAt(BaseCollection v) => v.updatedAt;
  static const Field<BaseCollection, DateTime> _f$updatedAt = Field(
    'updatedAt',
    _$updatedAt,
    key: r'updated_at',
  );

  @override
  final MappableFields<BaseCollection> fields = const {
    #name: _f$name,
    #attributes: _f$attributes,
    #indexes: _f$indexes,
    #listRule: _f$listRule,
    #viewRule: _f$viewRule,
    #createRule: _f$createRule,
    #updateRule: _f$updateRule,
    #deleteRule: _f$deleteRule,
    #createdAt: _f$createdAt,
    #updatedAt: _f$updatedAt,
  };

  @override
  final String discriminatorKey = 'type';
  @override
  final dynamic discriminatorValue = 'base';
  @override
  late final ClassMapperBase superMapper = CollectionMapper.ensureInitialized();

  static BaseCollection _instantiate(DecodingData data) {
    return BaseCollection(
      name: data.dec(_f$name),
      attributes: data.dec(_f$attributes),
      indexes: data.dec(_f$indexes),
      listRule: data.dec(_f$listRule),
      viewRule: data.dec(_f$viewRule),
      createRule: data.dec(_f$createRule),
      updateRule: data.dec(_f$updateRule),
      deleteRule: data.dec(_f$deleteRule),
      createdAt: data.dec(_f$createdAt),
      updatedAt: data.dec(_f$updatedAt),
    );
  }

  @override
  final Function instantiate = _instantiate;

  static BaseCollection fromJson(Map<String, dynamic> map) {
    return ensureInitialized().decodeMap<BaseCollection>(map);
  }

  static BaseCollection fromJsonString(String json) {
    return ensureInitialized().decodeJson<BaseCollection>(json);
  }
}

mixin BaseCollectionMappable {
  String toJsonString() {
    return BaseCollectionMapper.ensureInitialized().encodeJson<BaseCollection>(
      this as BaseCollection,
    );
  }

  Map<String, dynamic> toJson() {
    return BaseCollectionMapper.ensureInitialized().encodeMap<BaseCollection>(
      this as BaseCollection,
    );
  }

  BaseCollectionCopyWith<BaseCollection, BaseCollection, BaseCollection>
  get copyWith => _BaseCollectionCopyWithImpl<BaseCollection, BaseCollection>(
    this as BaseCollection,
    $identity,
    $identity,
  );
  @override
  String toString() {
    return BaseCollectionMapper.ensureInitialized().stringifyValue(
      this as BaseCollection,
    );
  }

  @override
  bool operator ==(Object other) {
    return BaseCollectionMapper.ensureInitialized().equalsValue(
      this as BaseCollection,
      other,
    );
  }

  @override
  int get hashCode {
    return BaseCollectionMapper.ensureInitialized().hashValue(
      this as BaseCollection,
    );
  }
}

extension BaseCollectionValueCopy<$R, $Out>
    on ObjectCopyWith<$R, BaseCollection, $Out> {
  BaseCollectionCopyWith<$R, BaseCollection, $Out> get $asBaseCollection =>
      $base.as((v, t, t2) => _BaseCollectionCopyWithImpl<$R, $Out>(v, t, t2));
}

abstract class BaseCollectionCopyWith<$R, $In extends BaseCollection, $Out>
    implements CollectionCopyWith<$R, $In, $Out> {
  @override
  ListCopyWith<$R, Attribute, ObjectCopyWith<$R, Attribute, Attribute>>
  get attributes;
  ListCopyWith<$R, Index, IndexCopyWith<$R, Index, Index>> get indexes;
  @override
  $R call({
    String? name,
    List<Attribute>? attributes,
    List<Index>? indexes,
    String? listRule,
    String? viewRule,
    String? createRule,
    String? updateRule,
    String? deleteRule,
    DateTime? createdAt,
    DateTime? updatedAt,
  });
  BaseCollectionCopyWith<$R2, $In, $Out2> $chain<$R2, $Out2>(
    Then<$Out2, $R2> t,
  );
}

class _BaseCollectionCopyWithImpl<$R, $Out>
    extends ClassCopyWithBase<$R, BaseCollection, $Out>
    implements BaseCollectionCopyWith<$R, BaseCollection, $Out> {
  _BaseCollectionCopyWithImpl(super.value, super.then, super.then2);

  @override
  late final ClassMapperBase<BaseCollection> $mapper =
      BaseCollectionMapper.ensureInitialized();
  @override
  ListCopyWith<$R, Attribute, ObjectCopyWith<$R, Attribute, Attribute>>
  get attributes => ListCopyWith(
    $value.attributes,
    (v, t) => ObjectCopyWith(v, $identity, t),
    (v) => call(attributes: v),
  );
  @override
  ListCopyWith<$R, Index, IndexCopyWith<$R, Index, Index>> get indexes =>
      ListCopyWith(
        $value.indexes,
        (v, t) => v.copyWith.$chain(t),
        (v) => call(indexes: v),
      );
  @override
  $R call({
    String? name,
    List<Attribute>? attributes,
    List<Index>? indexes,
    Object? listRule = $none,
    Object? viewRule = $none,
    Object? createRule = $none,
    Object? updateRule = $none,
    Object? deleteRule = $none,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) => $apply(
    FieldCopyWithData({
      if (name != null) #name: name,
      if (attributes != null) #attributes: attributes,
      if (indexes != null) #indexes: indexes,
      if (listRule != $none) #listRule: listRule,
      if (viewRule != $none) #viewRule: viewRule,
      if (createRule != $none) #createRule: createRule,
      if (updateRule != $none) #updateRule: updateRule,
      if (deleteRule != $none) #deleteRule: deleteRule,
      if (createdAt != null) #createdAt: createdAt,
      if (updatedAt != null) #updatedAt: updatedAt,
    }),
  );
  @override
  BaseCollection $make(CopyWithData data) => BaseCollection(
    name: data.get(#name, or: $value.name),
    attributes: data.get(#attributes, or: $value.attributes),
    indexes: data.get(#indexes, or: $value.indexes),
    listRule: data.get(#listRule, or: $value.listRule),
    viewRule: data.get(#viewRule, or: $value.viewRule),
    createRule: data.get(#createRule, or: $value.createRule),
    updateRule: data.get(#updateRule, or: $value.updateRule),
    deleteRule: data.get(#deleteRule, or: $value.deleteRule),
    createdAt: data.get(#createdAt, or: $value.createdAt),
    updatedAt: data.get(#updatedAt, or: $value.updatedAt),
  );

  @override
  BaseCollectionCopyWith<$R2, BaseCollection, $Out2> $chain<$R2, $Out2>(
    Then<$Out2, $R2> t,
  ) => _BaseCollectionCopyWithImpl<$R2, $Out2>($value, $cast, t);
}

class ViewCollectionMapper extends SubClassMapperBase<ViewCollection> {
  ViewCollectionMapper._();

  static ViewCollectionMapper? _instance;
  static ViewCollectionMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = ViewCollectionMapper._());
      CollectionMapper.ensureInitialized().addSubMapper(_instance!);
      AttributeMapper.ensureInitialized();
    }
    return _instance!;
  }

  @override
  final String id = 'ViewCollection';

  static String _$name(ViewCollection v) => v.name;
  static const Field<ViewCollection, String> _f$name = Field('name', _$name);
  static List<Attribute> _$attributes(ViewCollection v) => v.attributes;
  static const Field<ViewCollection, List<Attribute>> _f$attributes = Field(
    'attributes',
    _$attributes,
    opt: true,
    def: const [],
  );
  static String? _$listRule(ViewCollection v) => v.listRule;
  static const Field<ViewCollection, String> _f$listRule = Field(
    'listRule',
    _$listRule,
    key: r'list_rule',
    opt: true,
  );
  static String? _$viewRule(ViewCollection v) => v.viewRule;
  static const Field<ViewCollection, String> _f$viewRule = Field(
    'viewRule',
    _$viewRule,
    key: r'view_rule',
    opt: true,
  );
  static String _$viewQuery(ViewCollection v) => v.viewQuery;
  static const Field<ViewCollection, String> _f$viewQuery = Field(
    'viewQuery',
    _$viewQuery,
    key: r'view_query',
  );
  static DateTime _$createdAt(ViewCollection v) => v.createdAt;
  static const Field<ViewCollection, DateTime> _f$createdAt = Field(
    'createdAt',
    _$createdAt,
    key: r'created_at',
  );
  static DateTime _$updatedAt(ViewCollection v) => v.updatedAt;
  static const Field<ViewCollection, DateTime> _f$updatedAt = Field(
    'updatedAt',
    _$updatedAt,
    key: r'updated_at',
  );

  @override
  final MappableFields<ViewCollection> fields = const {
    #name: _f$name,
    #attributes: _f$attributes,
    #listRule: _f$listRule,
    #viewRule: _f$viewRule,
    #viewQuery: _f$viewQuery,
    #createdAt: _f$createdAt,
    #updatedAt: _f$updatedAt,
  };

  @override
  final String discriminatorKey = 'type';
  @override
  final dynamic discriminatorValue = 'view';
  @override
  late final ClassMapperBase superMapper = CollectionMapper.ensureInitialized();

  static ViewCollection _instantiate(DecodingData data) {
    return ViewCollection(
      name: data.dec(_f$name),
      attributes: data.dec(_f$attributes),
      listRule: data.dec(_f$listRule),
      viewRule: data.dec(_f$viewRule),
      viewQuery: data.dec(_f$viewQuery),
      createdAt: data.dec(_f$createdAt),
      updatedAt: data.dec(_f$updatedAt),
    );
  }

  @override
  final Function instantiate = _instantiate;

  static ViewCollection fromJson(Map<String, dynamic> map) {
    return ensureInitialized().decodeMap<ViewCollection>(map);
  }

  static ViewCollection fromJsonString(String json) {
    return ensureInitialized().decodeJson<ViewCollection>(json);
  }
}

mixin ViewCollectionMappable {
  String toJsonString() {
    return ViewCollectionMapper.ensureInitialized().encodeJson<ViewCollection>(
      this as ViewCollection,
    );
  }

  Map<String, dynamic> toJson() {
    return ViewCollectionMapper.ensureInitialized().encodeMap<ViewCollection>(
      this as ViewCollection,
    );
  }

  ViewCollectionCopyWith<ViewCollection, ViewCollection, ViewCollection>
  get copyWith => _ViewCollectionCopyWithImpl<ViewCollection, ViewCollection>(
    this as ViewCollection,
    $identity,
    $identity,
  );
  @override
  String toString() {
    return ViewCollectionMapper.ensureInitialized().stringifyValue(
      this as ViewCollection,
    );
  }

  @override
  bool operator ==(Object other) {
    return ViewCollectionMapper.ensureInitialized().equalsValue(
      this as ViewCollection,
      other,
    );
  }

  @override
  int get hashCode {
    return ViewCollectionMapper.ensureInitialized().hashValue(
      this as ViewCollection,
    );
  }
}

extension ViewCollectionValueCopy<$R, $Out>
    on ObjectCopyWith<$R, ViewCollection, $Out> {
  ViewCollectionCopyWith<$R, ViewCollection, $Out> get $asViewCollection =>
      $base.as((v, t, t2) => _ViewCollectionCopyWithImpl<$R, $Out>(v, t, t2));
}

abstract class ViewCollectionCopyWith<$R, $In extends ViewCollection, $Out>
    implements CollectionCopyWith<$R, $In, $Out> {
  @override
  ListCopyWith<$R, Attribute, ObjectCopyWith<$R, Attribute, Attribute>>
  get attributes;
  @override
  $R call({
    String? name,
    List<Attribute>? attributes,
    String? listRule,
    String? viewRule,
    String? viewQuery,
    DateTime? createdAt,
    DateTime? updatedAt,
  });
  ViewCollectionCopyWith<$R2, $In, $Out2> $chain<$R2, $Out2>(
    Then<$Out2, $R2> t,
  );
}

class _ViewCollectionCopyWithImpl<$R, $Out>
    extends ClassCopyWithBase<$R, ViewCollection, $Out>
    implements ViewCollectionCopyWith<$R, ViewCollection, $Out> {
  _ViewCollectionCopyWithImpl(super.value, super.then, super.then2);

  @override
  late final ClassMapperBase<ViewCollection> $mapper =
      ViewCollectionMapper.ensureInitialized();
  @override
  ListCopyWith<$R, Attribute, ObjectCopyWith<$R, Attribute, Attribute>>
  get attributes => ListCopyWith(
    $value.attributes,
    (v, t) => ObjectCopyWith(v, $identity, t),
    (v) => call(attributes: v),
  );
  @override
  $R call({
    String? name,
    List<Attribute>? attributes,
    Object? listRule = $none,
    Object? viewRule = $none,
    String? viewQuery,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) => $apply(
    FieldCopyWithData({
      if (name != null) #name: name,
      if (attributes != null) #attributes: attributes,
      if (listRule != $none) #listRule: listRule,
      if (viewRule != $none) #viewRule: viewRule,
      if (viewQuery != null) #viewQuery: viewQuery,
      if (createdAt != null) #createdAt: createdAt,
      if (updatedAt != null) #updatedAt: updatedAt,
    }),
  );
  @override
  ViewCollection $make(CopyWithData data) => ViewCollection(
    name: data.get(#name, or: $value.name),
    attributes: data.get(#attributes, or: $value.attributes),
    listRule: data.get(#listRule, or: $value.listRule),
    viewRule: data.get(#viewRule, or: $value.viewRule),
    viewQuery: data.get(#viewQuery, or: $value.viewQuery),
    createdAt: data.get(#createdAt, or: $value.createdAt),
    updatedAt: data.get(#updatedAt, or: $value.updatedAt),
  );

  @override
  ViewCollectionCopyWith<$R2, ViewCollection, $Out2> $chain<$R2, $Out2>(
    Then<$Out2, $R2> t,
  ) => _ViewCollectionCopyWithImpl<$R2, $Out2>($value, $cast, t);
}

