// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
// ignore_for_file: type=lint
// ignore_for_file: unused_element, unnecessary_cast, override_on_non_overriding_member
// ignore_for_file: strict_raw_type, inference_failure_on_untyped_parameter

part of 'import_response.dart';

class ImportResponseMapper extends ClassMapperBase<ImportResponse> {
  ImportResponseMapper._();

  static ImportResponseMapper? _instance;
  static ImportResponseMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = ImportResponseMapper._());
      MapperContainer.globals.useAll([SecondsDateTimeMapper()]);
      ImportErrorMapper.ensureInitialized();
    }
    return _instance!;
  }

  @override
  final String id = 'ImportResponse';

  static List<String> _$created(ImportResponse v) => v.created;
  static const Field<ImportResponse, List<String>> _f$created = Field(
    'created',
    _$created,
  );
  static List<String> _$updated(ImportResponse v) => v.updated;
  static const Field<ImportResponse, List<String>> _f$updated = Field(
    'updated',
    _$updated,
  );
  static List<String> _$skipped(ImportResponse v) => v.skipped;
  static const Field<ImportResponse, List<String>> _f$skipped = Field(
    'skipped',
    _$skipped,
  );
  static List<ImportError> _$errors(ImportResponse v) => v.errors;
  static const Field<ImportResponse, List<ImportError>> _f$errors = Field(
    'errors',
    _$errors,
  );
  static DateTime _$importedAt(ImportResponse v) => v.importedAt;
  static const Field<ImportResponse, DateTime> _f$importedAt = Field(
    'importedAt',
    _$importedAt,
    key: r'imported_at',
  );

  @override
  final MappableFields<ImportResponse> fields = const {
    #created: _f$created,
    #updated: _f$updated,
    #skipped: _f$skipped,
    #errors: _f$errors,
    #importedAt: _f$importedAt,
  };

  static ImportResponse _instantiate(DecodingData data) {
    return ImportResponse(
      created: data.dec(_f$created),
      updated: data.dec(_f$updated),
      skipped: data.dec(_f$skipped),
      errors: data.dec(_f$errors),
      importedAt: data.dec(_f$importedAt),
    );
  }

  @override
  final Function instantiate = _instantiate;

  static ImportResponse fromJson(Map<String, dynamic> map) {
    return ensureInitialized().decodeMap<ImportResponse>(map);
  }

  static ImportResponse fromJsonString(String json) {
    return ensureInitialized().decodeJson<ImportResponse>(json);
  }
}

mixin ImportResponseMappable {
  String toJsonString() {
    return ImportResponseMapper.ensureInitialized().encodeJson<ImportResponse>(
      this as ImportResponse,
    );
  }

  Map<String, dynamic> toJson() {
    return ImportResponseMapper.ensureInitialized().encodeMap<ImportResponse>(
      this as ImportResponse,
    );
  }

  ImportResponseCopyWith<ImportResponse, ImportResponse, ImportResponse>
  get copyWith => _ImportResponseCopyWithImpl<ImportResponse, ImportResponse>(
    this as ImportResponse,
    $identity,
    $identity,
  );
  @override
  String toString() {
    return ImportResponseMapper.ensureInitialized().stringifyValue(
      this as ImportResponse,
    );
  }

  @override
  bool operator ==(Object other) {
    return ImportResponseMapper.ensureInitialized().equalsValue(
      this as ImportResponse,
      other,
    );
  }

  @override
  int get hashCode {
    return ImportResponseMapper.ensureInitialized().hashValue(
      this as ImportResponse,
    );
  }
}

extension ImportResponseValueCopy<$R, $Out>
    on ObjectCopyWith<$R, ImportResponse, $Out> {
  ImportResponseCopyWith<$R, ImportResponse, $Out> get $asImportResponse =>
      $base.as((v, t, t2) => _ImportResponseCopyWithImpl<$R, $Out>(v, t, t2));
}

abstract class ImportResponseCopyWith<$R, $In extends ImportResponse, $Out>
    implements ClassCopyWith<$R, $In, $Out> {
  ListCopyWith<$R, String, ObjectCopyWith<$R, String, String>> get created;
  ListCopyWith<$R, String, ObjectCopyWith<$R, String, String>> get updated;
  ListCopyWith<$R, String, ObjectCopyWith<$R, String, String>> get skipped;
  ListCopyWith<
    $R,
    ImportError,
    ImportErrorCopyWith<$R, ImportError, ImportError>
  >
  get errors;
  $R call({
    List<String>? created,
    List<String>? updated,
    List<String>? skipped,
    List<ImportError>? errors,
    DateTime? importedAt,
  });
  ImportResponseCopyWith<$R2, $In, $Out2> $chain<$R2, $Out2>(
    Then<$Out2, $R2> t,
  );
}

class _ImportResponseCopyWithImpl<$R, $Out>
    extends ClassCopyWithBase<$R, ImportResponse, $Out>
    implements ImportResponseCopyWith<$R, ImportResponse, $Out> {
  _ImportResponseCopyWithImpl(super.value, super.then, super.then2);

  @override
  late final ClassMapperBase<ImportResponse> $mapper =
      ImportResponseMapper.ensureInitialized();
  @override
  ListCopyWith<$R, String, ObjectCopyWith<$R, String, String>> get created =>
      ListCopyWith(
        $value.created,
        (v, t) => ObjectCopyWith(v, $identity, t),
        (v) => call(created: v),
      );
  @override
  ListCopyWith<$R, String, ObjectCopyWith<$R, String, String>> get updated =>
      ListCopyWith(
        $value.updated,
        (v, t) => ObjectCopyWith(v, $identity, t),
        (v) => call(updated: v),
      );
  @override
  ListCopyWith<$R, String, ObjectCopyWith<$R, String, String>> get skipped =>
      ListCopyWith(
        $value.skipped,
        (v, t) => ObjectCopyWith(v, $identity, t),
        (v) => call(skipped: v),
      );
  @override
  ListCopyWith<
    $R,
    ImportError,
    ImportErrorCopyWith<$R, ImportError, ImportError>
  >
  get errors => ListCopyWith(
    $value.errors,
    (v, t) => v.copyWith.$chain(t),
    (v) => call(errors: v),
  );
  @override
  $R call({
    List<String>? created,
    List<String>? updated,
    List<String>? skipped,
    List<ImportError>? errors,
    DateTime? importedAt,
  }) => $apply(
    FieldCopyWithData({
      if (created != null) #created: created,
      if (updated != null) #updated: updated,
      if (skipped != null) #skipped: skipped,
      if (errors != null) #errors: errors,
      if (importedAt != null) #importedAt: importedAt,
    }),
  );
  @override
  ImportResponse $make(CopyWithData data) => ImportResponse(
    created: data.get(#created, or: $value.created),
    updated: data.get(#updated, or: $value.updated),
    skipped: data.get(#skipped, or: $value.skipped),
    errors: data.get(#errors, or: $value.errors),
    importedAt: data.get(#importedAt, or: $value.importedAt),
  );

  @override
  ImportResponseCopyWith<$R2, ImportResponse, $Out2> $chain<$R2, $Out2>(
    Then<$Out2, $R2> t,
  ) => _ImportResponseCopyWithImpl<$R2, $Out2>($value, $cast, t);
}

class ImportErrorMapper extends ClassMapperBase<ImportError> {
  ImportErrorMapper._();

  static ImportErrorMapper? _instance;
  static ImportErrorMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = ImportErrorMapper._());
    }
    return _instance!;
  }

  @override
  final String id = 'ImportError';

  static String _$collection(ImportError v) => v.collection;
  static const Field<ImportError, String> _f$collection = Field(
    'collection',
    _$collection,
  );
  static String _$error(ImportError v) => v.error;
  static const Field<ImportError, String> _f$error = Field('error', _$error);

  @override
  final MappableFields<ImportError> fields = const {
    #collection: _f$collection,
    #error: _f$error,
  };

  static ImportError _instantiate(DecodingData data) {
    return ImportError(
      collection: data.dec(_f$collection),
      error: data.dec(_f$error),
    );
  }

  @override
  final Function instantiate = _instantiate;

  static ImportError fromJson(Map<String, dynamic> map) {
    return ensureInitialized().decodeMap<ImportError>(map);
  }

  static ImportError fromJsonString(String json) {
    return ensureInitialized().decodeJson<ImportError>(json);
  }
}

mixin ImportErrorMappable {
  String toJsonString() {
    return ImportErrorMapper.ensureInitialized().encodeJson<ImportError>(
      this as ImportError,
    );
  }

  Map<String, dynamic> toJson() {
    return ImportErrorMapper.ensureInitialized().encodeMap<ImportError>(
      this as ImportError,
    );
  }

  ImportErrorCopyWith<ImportError, ImportError, ImportError> get copyWith =>
      _ImportErrorCopyWithImpl<ImportError, ImportError>(
        this as ImportError,
        $identity,
        $identity,
      );
  @override
  String toString() {
    return ImportErrorMapper.ensureInitialized().stringifyValue(
      this as ImportError,
    );
  }

  @override
  bool operator ==(Object other) {
    return ImportErrorMapper.ensureInitialized().equalsValue(
      this as ImportError,
      other,
    );
  }

  @override
  int get hashCode {
    return ImportErrorMapper.ensureInitialized().hashValue(this as ImportError);
  }
}

extension ImportErrorValueCopy<$R, $Out>
    on ObjectCopyWith<$R, ImportError, $Out> {
  ImportErrorCopyWith<$R, ImportError, $Out> get $asImportError =>
      $base.as((v, t, t2) => _ImportErrorCopyWithImpl<$R, $Out>(v, t, t2));
}

abstract class ImportErrorCopyWith<$R, $In extends ImportError, $Out>
    implements ClassCopyWith<$R, $In, $Out> {
  $R call({String? collection, String? error});
  ImportErrorCopyWith<$R2, $In, $Out2> $chain<$R2, $Out2>(Then<$Out2, $R2> t);
}

class _ImportErrorCopyWithImpl<$R, $Out>
    extends ClassCopyWithBase<$R, ImportError, $Out>
    implements ImportErrorCopyWith<$R, ImportError, $Out> {
  _ImportErrorCopyWithImpl(super.value, super.then, super.then2);

  @override
  late final ClassMapperBase<ImportError> $mapper =
      ImportErrorMapper.ensureInitialized();
  @override
  $R call({String? collection, String? error}) => $apply(
    FieldCopyWithData({
      if (collection != null) #collection: collection,
      if (error != null) #error: error,
    }),
  );
  @override
  ImportError $make(CopyWithData data) => ImportError(
    collection: data.get(#collection, or: $value.collection),
    error: data.get(#error, or: $value.error),
  );

  @override
  ImportErrorCopyWith<$R2, ImportError, $Out2> $chain<$R2, $Out2>(
    Then<$Out2, $R2> t,
  ) => _ImportErrorCopyWithImpl<$R2, $Out2>($value, $cast, t);
}

