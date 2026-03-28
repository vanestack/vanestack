// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
// ignore_for_file: type=lint
// ignore_for_file: unused_element, unnecessary_cast, override_on_non_overriding_member
// ignore_for_file: strict_raw_type, inference_failure_on_untyped_parameter

part of 'list_files_result.dart';

class ListFilesResultMapper extends ClassMapperBase<ListFilesResult> {
  ListFilesResultMapper._();

  static ListFilesResultMapper? _instance;
  static ListFilesResultMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = ListFilesResultMapper._());
      FileMapper.ensureInitialized();
    }
    return _instance!;
  }

  @override
  final String id = 'ListFilesResult';

  static List<File> _$files(ListFilesResult v) => v.files;
  static const Field<ListFilesResult, List<File>> _f$files = Field(
    'files',
    _$files,
  );
  static List<String> _$folders(ListFilesResult v) => v.folders;
  static const Field<ListFilesResult, List<String>> _f$folders = Field(
    'folders',
    _$folders,
  );

  @override
  final MappableFields<ListFilesResult> fields = const {
    #files: _f$files,
    #folders: _f$folders,
  };

  static ListFilesResult _instantiate(DecodingData data) {
    return ListFilesResult(
      files: data.dec(_f$files),
      folders: data.dec(_f$folders),
    );
  }

  @override
  final Function instantiate = _instantiate;

  static ListFilesResult fromJson(Map<String, dynamic> map) {
    return ensureInitialized().decodeMap<ListFilesResult>(map);
  }

  static ListFilesResult fromJsonString(String json) {
    return ensureInitialized().decodeJson<ListFilesResult>(json);
  }
}

mixin ListFilesResultMappable {
  String toJsonString() {
    return ListFilesResultMapper.ensureInitialized()
        .encodeJson<ListFilesResult>(this as ListFilesResult);
  }

  Map<String, dynamic> toJson() {
    return ListFilesResultMapper.ensureInitialized().encodeMap<ListFilesResult>(
      this as ListFilesResult,
    );
  }

  ListFilesResultCopyWith<ListFilesResult, ListFilesResult, ListFilesResult>
  get copyWith =>
      _ListFilesResultCopyWithImpl<ListFilesResult, ListFilesResult>(
        this as ListFilesResult,
        $identity,
        $identity,
      );
  @override
  String toString() {
    return ListFilesResultMapper.ensureInitialized().stringifyValue(
      this as ListFilesResult,
    );
  }

  @override
  bool operator ==(Object other) {
    return ListFilesResultMapper.ensureInitialized().equalsValue(
      this as ListFilesResult,
      other,
    );
  }

  @override
  int get hashCode {
    return ListFilesResultMapper.ensureInitialized().hashValue(
      this as ListFilesResult,
    );
  }
}

extension ListFilesResultValueCopy<$R, $Out>
    on ObjectCopyWith<$R, ListFilesResult, $Out> {
  ListFilesResultCopyWith<$R, ListFilesResult, $Out> get $asListFilesResult =>
      $base.as((v, t, t2) => _ListFilesResultCopyWithImpl<$R, $Out>(v, t, t2));
}

abstract class ListFilesResultCopyWith<$R, $In extends ListFilesResult, $Out>
    implements ClassCopyWith<$R, $In, $Out> {
  ListCopyWith<$R, File, FileCopyWith<$R, File, File>> get files;
  ListCopyWith<$R, String, ObjectCopyWith<$R, String, String>> get folders;
  $R call({List<File>? files, List<String>? folders});
  ListFilesResultCopyWith<$R2, $In, $Out2> $chain<$R2, $Out2>(
    Then<$Out2, $R2> t,
  );
}

class _ListFilesResultCopyWithImpl<$R, $Out>
    extends ClassCopyWithBase<$R, ListFilesResult, $Out>
    implements ListFilesResultCopyWith<$R, ListFilesResult, $Out> {
  _ListFilesResultCopyWithImpl(super.value, super.then, super.then2);

  @override
  late final ClassMapperBase<ListFilesResult> $mapper =
      ListFilesResultMapper.ensureInitialized();
  @override
  ListCopyWith<$R, File, FileCopyWith<$R, File, File>> get files =>
      ListCopyWith(
        $value.files,
        (v, t) => v.copyWith.$chain(t),
        (v) => call(files: v),
      );
  @override
  ListCopyWith<$R, String, ObjectCopyWith<$R, String, String>> get folders =>
      ListCopyWith(
        $value.folders,
        (v, t) => ObjectCopyWith(v, $identity, t),
        (v) => call(folders: v),
      );
  @override
  $R call({List<File>? files, List<String>? folders}) => $apply(
    FieldCopyWithData({
      if (files != null) #files: files,
      if (folders != null) #folders: folders,
    }),
  );
  @override
  ListFilesResult $make(CopyWithData data) => ListFilesResult(
    files: data.get(#files, or: $value.files),
    folders: data.get(#folders, or: $value.folders),
  );

  @override
  ListFilesResultCopyWith<$R2, ListFilesResult, $Out2> $chain<$R2, $Out2>(
    Then<$Out2, $R2> t,
  ) => _ListFilesResultCopyWithImpl<$R2, $Out2>($value, $cast, t);
}

