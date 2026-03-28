// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
// ignore_for_file: type=lint
// ignore_for_file: unused_element, unnecessary_cast, override_on_non_overriding_member
// ignore_for_file: strict_raw_type, inference_failure_on_untyped_parameter

part of 'realtime_event.dart';

class RealtimeEventMapper extends ClassMapperBase<RealtimeEvent> {
  RealtimeEventMapper._();

  static RealtimeEventMapper? _instance;
  static RealtimeEventMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = RealtimeEventMapper._());
      CustomRealtimeEventMapper.ensureInitialized();
      FileEventMapper.ensureInitialized();
      DocumentEventMapper.ensureInitialized();
    }
    return _instance!;
  }

  @override
  final String id = 'RealtimeEvent';

  static List<String> _$channels(RealtimeEvent v) => v.channels;
  static const Field<RealtimeEvent, List<String>> _f$channels = Field(
    'channels',
    _$channels,
  );

  @override
  final MappableFields<RealtimeEvent> fields = const {#channels: _f$channels};

  static RealtimeEvent _instantiate(DecodingData data) {
    throw MapperException.missingSubclass(
      'RealtimeEvent',
      'type',
      '${data.value['type']}',
    );
  }

  @override
  final Function instantiate = _instantiate;

  static RealtimeEvent fromJson(Map<String, dynamic> map) {
    return ensureInitialized().decodeMap<RealtimeEvent>(map);
  }

  static RealtimeEvent fromJsonString(String json) {
    return ensureInitialized().decodeJson<RealtimeEvent>(json);
  }
}

mixin RealtimeEventMappable {
  String toJsonString();
  Map<String, dynamic> toJson();
  RealtimeEventCopyWith<RealtimeEvent, RealtimeEvent, RealtimeEvent>
  get copyWith;
}

abstract class RealtimeEventCopyWith<$R, $In extends RealtimeEvent, $Out>
    implements ClassCopyWith<$R, $In, $Out> {
  ListCopyWith<$R, String, ObjectCopyWith<$R, String, String>?> get channels;
  $R call({List<String>? channels});
  RealtimeEventCopyWith<$R2, $In, $Out2> $chain<$R2, $Out2>(Then<$Out2, $R2> t);
}

class CustomRealtimeEventMapper
    extends SubClassMapperBase<CustomRealtimeEvent> {
  CustomRealtimeEventMapper._();

  static CustomRealtimeEventMapper? _instance;
  static CustomRealtimeEventMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = CustomRealtimeEventMapper._());
      RealtimeEventMapper.ensureInitialized().addSubMapper(_instance!);
    }
    return _instance!;
  }

  @override
  final String id = 'CustomRealtimeEvent';

  static Map<String, Object?> _$data(CustomRealtimeEvent v) => v.data;
  static const Field<CustomRealtimeEvent, Map<String, Object?>> _f$data = Field(
    'data',
    _$data,
  );
  static List<String> _$channels(CustomRealtimeEvent v) => v.channels;
  static const Field<CustomRealtimeEvent, List<String>> _f$channels = Field(
    'channels',
    _$channels,
  );
  static String? _$rule(CustomRealtimeEvent v) => v.rule;
  static const Field<CustomRealtimeEvent, String> _f$rule = Field(
    'rule',
    _$rule,
    opt: true,
  );

  @override
  final MappableFields<CustomRealtimeEvent> fields = const {
    #data: _f$data,
    #channels: _f$channels,
    #rule: _f$rule,
  };

  @override
  final String discriminatorKey = 'type';
  @override
  final dynamic discriminatorValue = 'custom';
  @override
  late final ClassMapperBase superMapper =
      RealtimeEventMapper.ensureInitialized();

  static CustomRealtimeEvent _instantiate(DecodingData data) {
    return CustomRealtimeEvent(
      data: data.dec(_f$data),
      channels: data.dec(_f$channels),
      rule: data.dec(_f$rule),
    );
  }

  @override
  final Function instantiate = _instantiate;

  static CustomRealtimeEvent fromJson(Map<String, dynamic> map) {
    return ensureInitialized().decodeMap<CustomRealtimeEvent>(map);
  }

  static CustomRealtimeEvent fromJsonString(String json) {
    return ensureInitialized().decodeJson<CustomRealtimeEvent>(json);
  }
}

mixin CustomRealtimeEventMappable {
  String toJsonString() {
    return CustomRealtimeEventMapper.ensureInitialized()
        .encodeJson<CustomRealtimeEvent>(this as CustomRealtimeEvent);
  }

  Map<String, dynamic> toJson() {
    return CustomRealtimeEventMapper.ensureInitialized()
        .encodeMap<CustomRealtimeEvent>(this as CustomRealtimeEvent);
  }

  CustomRealtimeEventCopyWith<
    CustomRealtimeEvent,
    CustomRealtimeEvent,
    CustomRealtimeEvent
  >
  get copyWith =>
      _CustomRealtimeEventCopyWithImpl<
        CustomRealtimeEvent,
        CustomRealtimeEvent
      >(this as CustomRealtimeEvent, $identity, $identity);
  @override
  String toString() {
    return CustomRealtimeEventMapper.ensureInitialized().stringifyValue(
      this as CustomRealtimeEvent,
    );
  }

  @override
  bool operator ==(Object other) {
    return CustomRealtimeEventMapper.ensureInitialized().equalsValue(
      this as CustomRealtimeEvent,
      other,
    );
  }

  @override
  int get hashCode {
    return CustomRealtimeEventMapper.ensureInitialized().hashValue(
      this as CustomRealtimeEvent,
    );
  }
}

extension CustomRealtimeEventValueCopy<$R, $Out>
    on ObjectCopyWith<$R, CustomRealtimeEvent, $Out> {
  CustomRealtimeEventCopyWith<$R, CustomRealtimeEvent, $Out>
  get $asCustomRealtimeEvent => $base.as(
    (v, t, t2) => _CustomRealtimeEventCopyWithImpl<$R, $Out>(v, t, t2),
  );
}

abstract class CustomRealtimeEventCopyWith<
  $R,
  $In extends CustomRealtimeEvent,
  $Out
>
    implements RealtimeEventCopyWith<$R, $In, $Out> {
  MapCopyWith<$R, String, Object?, ObjectCopyWith<$R, Object?, Object?>?>
  get data;
  @override
  ListCopyWith<$R, String, ObjectCopyWith<$R, String, String>> get channels;
  @override
  $R call({Map<String, Object?>? data, List<String>? channels, String? rule});
  CustomRealtimeEventCopyWith<$R2, $In, $Out2> $chain<$R2, $Out2>(
    Then<$Out2, $R2> t,
  );
}

class _CustomRealtimeEventCopyWithImpl<$R, $Out>
    extends ClassCopyWithBase<$R, CustomRealtimeEvent, $Out>
    implements CustomRealtimeEventCopyWith<$R, CustomRealtimeEvent, $Out> {
  _CustomRealtimeEventCopyWithImpl(super.value, super.then, super.then2);

  @override
  late final ClassMapperBase<CustomRealtimeEvent> $mapper =
      CustomRealtimeEventMapper.ensureInitialized();
  @override
  MapCopyWith<$R, String, Object?, ObjectCopyWith<$R, Object?, Object?>?>
  get data => MapCopyWith(
    $value.data,
    (v, t) => ObjectCopyWith(v, $identity, t),
    (v) => call(data: v),
  );
  @override
  ListCopyWith<$R, String, ObjectCopyWith<$R, String, String>> get channels =>
      ListCopyWith(
        $value.channels,
        (v, t) => ObjectCopyWith(v, $identity, t),
        (v) => call(channels: v),
      );
  @override
  $R call({
    Map<String, Object?>? data,
    List<String>? channels,
    Object? rule = $none,
  }) => $apply(
    FieldCopyWithData({
      if (data != null) #data: data,
      if (channels != null) #channels: channels,
      if (rule != $none) #rule: rule,
    }),
  );
  @override
  CustomRealtimeEvent $make(CopyWithData data) => CustomRealtimeEvent(
    data: data.get(#data, or: $value.data),
    channels: data.get(#channels, or: $value.channels),
    rule: data.get(#rule, or: $value.rule),
  );

  @override
  CustomRealtimeEventCopyWith<$R2, CustomRealtimeEvent, $Out2>
  $chain<$R2, $Out2>(Then<$Out2, $R2> t) =>
      _CustomRealtimeEventCopyWithImpl<$R2, $Out2>($value, $cast, t);
}

class FileEventMapper extends SubClassMapperBase<FileEvent> {
  FileEventMapper._();

  static FileEventMapper? _instance;
  static FileEventMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = FileEventMapper._());
      RealtimeEventMapper.ensureInitialized().addSubMapper(_instance!);
      FileUploadedEventMapper.ensureInitialized();
      FileMovedEventMapper.ensureInitialized();
      FileDeletedEventMapper.ensureInitialized();
    }
    return _instance!;
  }

  @override
  final String id = 'FileEvent';

  static List<String> _$channels(FileEvent v) => v.channels;
  static const Field<FileEvent, List<String>> _f$channels = Field(
    'channels',
    _$channels,
  );

  @override
  final MappableFields<FileEvent> fields = const {#channels: _f$channels};

  @override
  final String discriminatorKey = 'type';
  @override
  final dynamic discriminatorValue = 'file';
  @override
  late final ClassMapperBase superMapper =
      RealtimeEventMapper.ensureInitialized();

  static FileEvent _instantiate(DecodingData data) {
    throw MapperException.missingSubclass(
      'FileEvent',
      'type',
      '${data.value['type']}',
    );
  }

  @override
  final Function instantiate = _instantiate;

  static FileEvent fromJson(Map<String, dynamic> map) {
    return ensureInitialized().decodeMap<FileEvent>(map);
  }

  static FileEvent fromJsonString(String json) {
    return ensureInitialized().decodeJson<FileEvent>(json);
  }
}

mixin FileEventMappable {
  String toJsonString();
  Map<String, dynamic> toJson();
  FileEventCopyWith<FileEvent, FileEvent, FileEvent> get copyWith;
}

abstract class FileEventCopyWith<$R, $In extends FileEvent, $Out>
    implements RealtimeEventCopyWith<$R, $In, $Out> {
  @override
  ListCopyWith<$R, String, ObjectCopyWith<$R, String, String>?> get channels;
  @override
  $R call({List<String>? channels});
  FileEventCopyWith<$R2, $In, $Out2> $chain<$R2, $Out2>(Then<$Out2, $R2> t);
}

class FileUploadedEventMapper extends SubClassMapperBase<FileUploadedEvent> {
  FileUploadedEventMapper._();

  static FileUploadedEventMapper? _instance;
  static FileUploadedEventMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = FileUploadedEventMapper._());
      FileEventMapper.ensureInitialized().addSubMapper(_instance!);
      FileMapper.ensureInitialized();
    }
    return _instance!;
  }

  @override
  final String id = 'FileUploadedEvent';

  static List<String> _$channels(FileUploadedEvent v) => v.channels;
  static const Field<FileUploadedEvent, List<String>> _f$channels = Field(
    'channels',
    _$channels,
  );
  static File _$file(FileUploadedEvent v) => v.file;
  static const Field<FileUploadedEvent, File> _f$file = Field('file', _$file);

  @override
  final MappableFields<FileUploadedEvent> fields = const {
    #channels: _f$channels,
    #file: _f$file,
  };

  @override
  final String discriminatorKey = 'type';
  @override
  final dynamic discriminatorValue = 'file_uploaded';
  @override
  late final ClassMapperBase superMapper = FileEventMapper.ensureInitialized();

  static FileUploadedEvent _instantiate(DecodingData data) {
    return FileUploadedEvent(
      channels: data.dec(_f$channels),
      file: data.dec(_f$file),
    );
  }

  @override
  final Function instantiate = _instantiate;

  static FileUploadedEvent fromJson(Map<String, dynamic> map) {
    return ensureInitialized().decodeMap<FileUploadedEvent>(map);
  }

  static FileUploadedEvent fromJsonString(String json) {
    return ensureInitialized().decodeJson<FileUploadedEvent>(json);
  }
}

mixin FileUploadedEventMappable {
  String toJsonString() {
    return FileUploadedEventMapper.ensureInitialized()
        .encodeJson<FileUploadedEvent>(this as FileUploadedEvent);
  }

  Map<String, dynamic> toJson() {
    return FileUploadedEventMapper.ensureInitialized()
        .encodeMap<FileUploadedEvent>(this as FileUploadedEvent);
  }

  FileUploadedEventCopyWith<
    FileUploadedEvent,
    FileUploadedEvent,
    FileUploadedEvent
  >
  get copyWith =>
      _FileUploadedEventCopyWithImpl<FileUploadedEvent, FileUploadedEvent>(
        this as FileUploadedEvent,
        $identity,
        $identity,
      );
  @override
  String toString() {
    return FileUploadedEventMapper.ensureInitialized().stringifyValue(
      this as FileUploadedEvent,
    );
  }

  @override
  bool operator ==(Object other) {
    return FileUploadedEventMapper.ensureInitialized().equalsValue(
      this as FileUploadedEvent,
      other,
    );
  }

  @override
  int get hashCode {
    return FileUploadedEventMapper.ensureInitialized().hashValue(
      this as FileUploadedEvent,
    );
  }
}

extension FileUploadedEventValueCopy<$R, $Out>
    on ObjectCopyWith<$R, FileUploadedEvent, $Out> {
  FileUploadedEventCopyWith<$R, FileUploadedEvent, $Out>
  get $asFileUploadedEvent => $base.as(
    (v, t, t2) => _FileUploadedEventCopyWithImpl<$R, $Out>(v, t, t2),
  );
}

abstract class FileUploadedEventCopyWith<
  $R,
  $In extends FileUploadedEvent,
  $Out
>
    implements FileEventCopyWith<$R, $In, $Out> {
  @override
  ListCopyWith<$R, String, ObjectCopyWith<$R, String, String>> get channels;
  FileCopyWith<$R, File, File> get file;
  @override
  $R call({List<String>? channels, File? file});
  FileUploadedEventCopyWith<$R2, $In, $Out2> $chain<$R2, $Out2>(
    Then<$Out2, $R2> t,
  );
}

class _FileUploadedEventCopyWithImpl<$R, $Out>
    extends ClassCopyWithBase<$R, FileUploadedEvent, $Out>
    implements FileUploadedEventCopyWith<$R, FileUploadedEvent, $Out> {
  _FileUploadedEventCopyWithImpl(super.value, super.then, super.then2);

  @override
  late final ClassMapperBase<FileUploadedEvent> $mapper =
      FileUploadedEventMapper.ensureInitialized();
  @override
  ListCopyWith<$R, String, ObjectCopyWith<$R, String, String>> get channels =>
      ListCopyWith(
        $value.channels,
        (v, t) => ObjectCopyWith(v, $identity, t),
        (v) => call(channels: v),
      );
  @override
  FileCopyWith<$R, File, File> get file =>
      $value.file.copyWith.$chain((v) => call(file: v));
  @override
  $R call({List<String>? channels, File? file}) => $apply(
    FieldCopyWithData({
      if (channels != null) #channels: channels,
      if (file != null) #file: file,
    }),
  );
  @override
  FileUploadedEvent $make(CopyWithData data) => FileUploadedEvent(
    channels: data.get(#channels, or: $value.channels),
    file: data.get(#file, or: $value.file),
  );

  @override
  FileUploadedEventCopyWith<$R2, FileUploadedEvent, $Out2> $chain<$R2, $Out2>(
    Then<$Out2, $R2> t,
  ) => _FileUploadedEventCopyWithImpl<$R2, $Out2>($value, $cast, t);
}

class FileMovedEventMapper extends SubClassMapperBase<FileMovedEvent> {
  FileMovedEventMapper._();

  static FileMovedEventMapper? _instance;
  static FileMovedEventMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = FileMovedEventMapper._());
      FileEventMapper.ensureInitialized().addSubMapper(_instance!);
      FileMapper.ensureInitialized();
    }
    return _instance!;
  }

  @override
  final String id = 'FileMovedEvent';

  static List<String> _$channels(FileMovedEvent v) => v.channels;
  static const Field<FileMovedEvent, List<String>> _f$channels = Field(
    'channels',
    _$channels,
  );
  static File _$file(FileMovedEvent v) => v.file;
  static const Field<FileMovedEvent, File> _f$file = Field('file', _$file);
  static String _$oldPath(FileMovedEvent v) => v.oldPath;
  static const Field<FileMovedEvent, String> _f$oldPath = Field(
    'oldPath',
    _$oldPath,
    key: r'old_path',
  );

  @override
  final MappableFields<FileMovedEvent> fields = const {
    #channels: _f$channels,
    #file: _f$file,
    #oldPath: _f$oldPath,
  };

  @override
  final String discriminatorKey = 'type';
  @override
  final dynamic discriminatorValue = 'file_moved';
  @override
  late final ClassMapperBase superMapper = FileEventMapper.ensureInitialized();

  static FileMovedEvent _instantiate(DecodingData data) {
    return FileMovedEvent(
      channels: data.dec(_f$channels),
      file: data.dec(_f$file),
      oldPath: data.dec(_f$oldPath),
    );
  }

  @override
  final Function instantiate = _instantiate;

  static FileMovedEvent fromJson(Map<String, dynamic> map) {
    return ensureInitialized().decodeMap<FileMovedEvent>(map);
  }

  static FileMovedEvent fromJsonString(String json) {
    return ensureInitialized().decodeJson<FileMovedEvent>(json);
  }
}

mixin FileMovedEventMappable {
  String toJsonString() {
    return FileMovedEventMapper.ensureInitialized().encodeJson<FileMovedEvent>(
      this as FileMovedEvent,
    );
  }

  Map<String, dynamic> toJson() {
    return FileMovedEventMapper.ensureInitialized().encodeMap<FileMovedEvent>(
      this as FileMovedEvent,
    );
  }

  FileMovedEventCopyWith<FileMovedEvent, FileMovedEvent, FileMovedEvent>
  get copyWith => _FileMovedEventCopyWithImpl<FileMovedEvent, FileMovedEvent>(
    this as FileMovedEvent,
    $identity,
    $identity,
  );
  @override
  String toString() {
    return FileMovedEventMapper.ensureInitialized().stringifyValue(
      this as FileMovedEvent,
    );
  }

  @override
  bool operator ==(Object other) {
    return FileMovedEventMapper.ensureInitialized().equalsValue(
      this as FileMovedEvent,
      other,
    );
  }

  @override
  int get hashCode {
    return FileMovedEventMapper.ensureInitialized().hashValue(
      this as FileMovedEvent,
    );
  }
}

extension FileMovedEventValueCopy<$R, $Out>
    on ObjectCopyWith<$R, FileMovedEvent, $Out> {
  FileMovedEventCopyWith<$R, FileMovedEvent, $Out> get $asFileMovedEvent =>
      $base.as((v, t, t2) => _FileMovedEventCopyWithImpl<$R, $Out>(v, t, t2));
}

abstract class FileMovedEventCopyWith<$R, $In extends FileMovedEvent, $Out>
    implements FileEventCopyWith<$R, $In, $Out> {
  @override
  ListCopyWith<$R, String, ObjectCopyWith<$R, String, String>> get channels;
  FileCopyWith<$R, File, File> get file;
  @override
  $R call({List<String>? channels, File? file, String? oldPath});
  FileMovedEventCopyWith<$R2, $In, $Out2> $chain<$R2, $Out2>(
    Then<$Out2, $R2> t,
  );
}

class _FileMovedEventCopyWithImpl<$R, $Out>
    extends ClassCopyWithBase<$R, FileMovedEvent, $Out>
    implements FileMovedEventCopyWith<$R, FileMovedEvent, $Out> {
  _FileMovedEventCopyWithImpl(super.value, super.then, super.then2);

  @override
  late final ClassMapperBase<FileMovedEvent> $mapper =
      FileMovedEventMapper.ensureInitialized();
  @override
  ListCopyWith<$R, String, ObjectCopyWith<$R, String, String>> get channels =>
      ListCopyWith(
        $value.channels,
        (v, t) => ObjectCopyWith(v, $identity, t),
        (v) => call(channels: v),
      );
  @override
  FileCopyWith<$R, File, File> get file =>
      $value.file.copyWith.$chain((v) => call(file: v));
  @override
  $R call({List<String>? channels, File? file, String? oldPath}) => $apply(
    FieldCopyWithData({
      if (channels != null) #channels: channels,
      if (file != null) #file: file,
      if (oldPath != null) #oldPath: oldPath,
    }),
  );
  @override
  FileMovedEvent $make(CopyWithData data) => FileMovedEvent(
    channels: data.get(#channels, or: $value.channels),
    file: data.get(#file, or: $value.file),
    oldPath: data.get(#oldPath, or: $value.oldPath),
  );

  @override
  FileMovedEventCopyWith<$R2, FileMovedEvent, $Out2> $chain<$R2, $Out2>(
    Then<$Out2, $R2> t,
  ) => _FileMovedEventCopyWithImpl<$R2, $Out2>($value, $cast, t);
}

class FileDeletedEventMapper extends SubClassMapperBase<FileDeletedEvent> {
  FileDeletedEventMapper._();

  static FileDeletedEventMapper? _instance;
  static FileDeletedEventMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = FileDeletedEventMapper._());
      FileEventMapper.ensureInitialized().addSubMapper(_instance!);
      FileMapper.ensureInitialized();
    }
    return _instance!;
  }

  @override
  final String id = 'FileDeletedEvent';

  static List<String> _$channels(FileDeletedEvent v) => v.channels;
  static const Field<FileDeletedEvent, List<String>> _f$channels = Field(
    'channels',
    _$channels,
  );
  static File _$file(FileDeletedEvent v) => v.file;
  static const Field<FileDeletedEvent, File> _f$file = Field('file', _$file);

  @override
  final MappableFields<FileDeletedEvent> fields = const {
    #channels: _f$channels,
    #file: _f$file,
  };

  @override
  final String discriminatorKey = 'type';
  @override
  final dynamic discriminatorValue = 'file_deleted';
  @override
  late final ClassMapperBase superMapper = FileEventMapper.ensureInitialized();

  static FileDeletedEvent _instantiate(DecodingData data) {
    return FileDeletedEvent(
      channels: data.dec(_f$channels),
      file: data.dec(_f$file),
    );
  }

  @override
  final Function instantiate = _instantiate;

  static FileDeletedEvent fromJson(Map<String, dynamic> map) {
    return ensureInitialized().decodeMap<FileDeletedEvent>(map);
  }

  static FileDeletedEvent fromJsonString(String json) {
    return ensureInitialized().decodeJson<FileDeletedEvent>(json);
  }
}

mixin FileDeletedEventMappable {
  String toJsonString() {
    return FileDeletedEventMapper.ensureInitialized()
        .encodeJson<FileDeletedEvent>(this as FileDeletedEvent);
  }

  Map<String, dynamic> toJson() {
    return FileDeletedEventMapper.ensureInitialized()
        .encodeMap<FileDeletedEvent>(this as FileDeletedEvent);
  }

  FileDeletedEventCopyWith<FileDeletedEvent, FileDeletedEvent, FileDeletedEvent>
  get copyWith =>
      _FileDeletedEventCopyWithImpl<FileDeletedEvent, FileDeletedEvent>(
        this as FileDeletedEvent,
        $identity,
        $identity,
      );
  @override
  String toString() {
    return FileDeletedEventMapper.ensureInitialized().stringifyValue(
      this as FileDeletedEvent,
    );
  }

  @override
  bool operator ==(Object other) {
    return FileDeletedEventMapper.ensureInitialized().equalsValue(
      this as FileDeletedEvent,
      other,
    );
  }

  @override
  int get hashCode {
    return FileDeletedEventMapper.ensureInitialized().hashValue(
      this as FileDeletedEvent,
    );
  }
}

extension FileDeletedEventValueCopy<$R, $Out>
    on ObjectCopyWith<$R, FileDeletedEvent, $Out> {
  FileDeletedEventCopyWith<$R, FileDeletedEvent, $Out>
  get $asFileDeletedEvent =>
      $base.as((v, t, t2) => _FileDeletedEventCopyWithImpl<$R, $Out>(v, t, t2));
}

abstract class FileDeletedEventCopyWith<$R, $In extends FileDeletedEvent, $Out>
    implements FileEventCopyWith<$R, $In, $Out> {
  @override
  ListCopyWith<$R, String, ObjectCopyWith<$R, String, String>> get channels;
  FileCopyWith<$R, File, File> get file;
  @override
  $R call({List<String>? channels, File? file});
  FileDeletedEventCopyWith<$R2, $In, $Out2> $chain<$R2, $Out2>(
    Then<$Out2, $R2> t,
  );
}

class _FileDeletedEventCopyWithImpl<$R, $Out>
    extends ClassCopyWithBase<$R, FileDeletedEvent, $Out>
    implements FileDeletedEventCopyWith<$R, FileDeletedEvent, $Out> {
  _FileDeletedEventCopyWithImpl(super.value, super.then, super.then2);

  @override
  late final ClassMapperBase<FileDeletedEvent> $mapper =
      FileDeletedEventMapper.ensureInitialized();
  @override
  ListCopyWith<$R, String, ObjectCopyWith<$R, String, String>> get channels =>
      ListCopyWith(
        $value.channels,
        (v, t) => ObjectCopyWith(v, $identity, t),
        (v) => call(channels: v),
      );
  @override
  FileCopyWith<$R, File, File> get file =>
      $value.file.copyWith.$chain((v) => call(file: v));
  @override
  $R call({List<String>? channels, File? file}) => $apply(
    FieldCopyWithData({
      if (channels != null) #channels: channels,
      if (file != null) #file: file,
    }),
  );
  @override
  FileDeletedEvent $make(CopyWithData data) => FileDeletedEvent(
    channels: data.get(#channels, or: $value.channels),
    file: data.get(#file, or: $value.file),
  );

  @override
  FileDeletedEventCopyWith<$R2, FileDeletedEvent, $Out2> $chain<$R2, $Out2>(
    Then<$Out2, $R2> t,
  ) => _FileDeletedEventCopyWithImpl<$R2, $Out2>($value, $cast, t);
}

class DocumentEventMapper extends SubClassMapperBase<DocumentEvent> {
  DocumentEventMapper._();

  static DocumentEventMapper? _instance;
  static DocumentEventMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = DocumentEventMapper._());
      RealtimeEventMapper.ensureInitialized().addSubMapper(_instance!);
      DocumentCreatedEventMapper.ensureInitialized();
      DocumentUpdatedEventMapper.ensureInitialized();
      DocumentDeletedEventMapper.ensureInitialized();
    }
    return _instance!;
  }

  @override
  final String id = 'DocumentEvent';

  static List<String> _$channels(DocumentEvent v) => v.channels;
  static const Field<DocumentEvent, List<String>> _f$channels = Field(
    'channels',
    _$channels,
  );

  @override
  final MappableFields<DocumentEvent> fields = const {#channels: _f$channels};

  @override
  final String discriminatorKey = 'type';
  @override
  final dynamic discriminatorValue = 'document';
  @override
  late final ClassMapperBase superMapper =
      RealtimeEventMapper.ensureInitialized();

  static DocumentEvent _instantiate(DecodingData data) {
    throw MapperException.missingSubclass(
      'DocumentEvent',
      'type',
      '${data.value['type']}',
    );
  }

  @override
  final Function instantiate = _instantiate;

  static DocumentEvent fromJson(Map<String, dynamic> map) {
    return ensureInitialized().decodeMap<DocumentEvent>(map);
  }

  static DocumentEvent fromJsonString(String json) {
    return ensureInitialized().decodeJson<DocumentEvent>(json);
  }
}

mixin DocumentEventMappable {
  String toJsonString();
  Map<String, dynamic> toJson();
  DocumentEventCopyWith<DocumentEvent, DocumentEvent, DocumentEvent>
  get copyWith;
}

abstract class DocumentEventCopyWith<$R, $In extends DocumentEvent, $Out>
    implements RealtimeEventCopyWith<$R, $In, $Out> {
  @override
  ListCopyWith<$R, String, ObjectCopyWith<$R, String, String>?> get channels;
  @override
  $R call({List<String>? channels});
  DocumentEventCopyWith<$R2, $In, $Out2> $chain<$R2, $Out2>(Then<$Out2, $R2> t);
}

class DocumentCreatedEventMapper
    extends SubClassMapperBase<DocumentCreatedEvent> {
  DocumentCreatedEventMapper._();

  static DocumentCreatedEventMapper? _instance;
  static DocumentCreatedEventMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = DocumentCreatedEventMapper._());
      DocumentEventMapper.ensureInitialized().addSubMapper(_instance!);
      DocumentMapper.ensureInitialized();
    }
    return _instance!;
  }

  @override
  final String id = 'DocumentCreatedEvent';

  static List<String> _$channels(DocumentCreatedEvent v) => v.channels;
  static const Field<DocumentCreatedEvent, List<String>> _f$channels = Field(
    'channels',
    _$channels,
  );
  static Document _$document(DocumentCreatedEvent v) => v.document;
  static const Field<DocumentCreatedEvent, Document> _f$document = Field(
    'document',
    _$document,
  );

  @override
  final MappableFields<DocumentCreatedEvent> fields = const {
    #channels: _f$channels,
    #document: _f$document,
  };

  @override
  final String discriminatorKey = 'type';
  @override
  final dynamic discriminatorValue = 'document_created';
  @override
  late final ClassMapperBase superMapper =
      DocumentEventMapper.ensureInitialized();

  static DocumentCreatedEvent _instantiate(DecodingData data) {
    return DocumentCreatedEvent(
      channels: data.dec(_f$channels),
      document: data.dec(_f$document),
    );
  }

  @override
  final Function instantiate = _instantiate;

  static DocumentCreatedEvent fromJson(Map<String, dynamic> map) {
    return ensureInitialized().decodeMap<DocumentCreatedEvent>(map);
  }

  static DocumentCreatedEvent fromJsonString(String json) {
    return ensureInitialized().decodeJson<DocumentCreatedEvent>(json);
  }
}

mixin DocumentCreatedEventMappable {
  String toJsonString() {
    return DocumentCreatedEventMapper.ensureInitialized()
        .encodeJson<DocumentCreatedEvent>(this as DocumentCreatedEvent);
  }

  Map<String, dynamic> toJson() {
    return DocumentCreatedEventMapper.ensureInitialized()
        .encodeMap<DocumentCreatedEvent>(this as DocumentCreatedEvent);
  }

  DocumentCreatedEventCopyWith<
    DocumentCreatedEvent,
    DocumentCreatedEvent,
    DocumentCreatedEvent
  >
  get copyWith =>
      _DocumentCreatedEventCopyWithImpl<
        DocumentCreatedEvent,
        DocumentCreatedEvent
      >(this as DocumentCreatedEvent, $identity, $identity);
  @override
  String toString() {
    return DocumentCreatedEventMapper.ensureInitialized().stringifyValue(
      this as DocumentCreatedEvent,
    );
  }

  @override
  bool operator ==(Object other) {
    return DocumentCreatedEventMapper.ensureInitialized().equalsValue(
      this as DocumentCreatedEvent,
      other,
    );
  }

  @override
  int get hashCode {
    return DocumentCreatedEventMapper.ensureInitialized().hashValue(
      this as DocumentCreatedEvent,
    );
  }
}

extension DocumentCreatedEventValueCopy<$R, $Out>
    on ObjectCopyWith<$R, DocumentCreatedEvent, $Out> {
  DocumentCreatedEventCopyWith<$R, DocumentCreatedEvent, $Out>
  get $asDocumentCreatedEvent => $base.as(
    (v, t, t2) => _DocumentCreatedEventCopyWithImpl<$R, $Out>(v, t, t2),
  );
}

abstract class DocumentCreatedEventCopyWith<
  $R,
  $In extends DocumentCreatedEvent,
  $Out
>
    implements DocumentEventCopyWith<$R, $In, $Out> {
  @override
  ListCopyWith<$R, String, ObjectCopyWith<$R, String, String>> get channels;
  DocumentCopyWith<$R, Document, Document> get document;
  @override
  $R call({List<String>? channels, Document? document});
  DocumentCreatedEventCopyWith<$R2, $In, $Out2> $chain<$R2, $Out2>(
    Then<$Out2, $R2> t,
  );
}

class _DocumentCreatedEventCopyWithImpl<$R, $Out>
    extends ClassCopyWithBase<$R, DocumentCreatedEvent, $Out>
    implements DocumentCreatedEventCopyWith<$R, DocumentCreatedEvent, $Out> {
  _DocumentCreatedEventCopyWithImpl(super.value, super.then, super.then2);

  @override
  late final ClassMapperBase<DocumentCreatedEvent> $mapper =
      DocumentCreatedEventMapper.ensureInitialized();
  @override
  ListCopyWith<$R, String, ObjectCopyWith<$R, String, String>> get channels =>
      ListCopyWith(
        $value.channels,
        (v, t) => ObjectCopyWith(v, $identity, t),
        (v) => call(channels: v),
      );
  @override
  DocumentCopyWith<$R, Document, Document> get document =>
      $value.document.copyWith.$chain((v) => call(document: v));
  @override
  $R call({List<String>? channels, Document? document}) => $apply(
    FieldCopyWithData({
      if (channels != null) #channels: channels,
      if (document != null) #document: document,
    }),
  );
  @override
  DocumentCreatedEvent $make(CopyWithData data) => DocumentCreatedEvent(
    channels: data.get(#channels, or: $value.channels),
    document: data.get(#document, or: $value.document),
  );

  @override
  DocumentCreatedEventCopyWith<$R2, DocumentCreatedEvent, $Out2>
  $chain<$R2, $Out2>(Then<$Out2, $R2> t) =>
      _DocumentCreatedEventCopyWithImpl<$R2, $Out2>($value, $cast, t);
}

class DocumentUpdatedEventMapper
    extends SubClassMapperBase<DocumentUpdatedEvent> {
  DocumentUpdatedEventMapper._();

  static DocumentUpdatedEventMapper? _instance;
  static DocumentUpdatedEventMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = DocumentUpdatedEventMapper._());
      DocumentEventMapper.ensureInitialized().addSubMapper(_instance!);
      DocumentMapper.ensureInitialized();
    }
    return _instance!;
  }

  @override
  final String id = 'DocumentUpdatedEvent';

  static List<String> _$channels(DocumentUpdatedEvent v) => v.channels;
  static const Field<DocumentUpdatedEvent, List<String>> _f$channels = Field(
    'channels',
    _$channels,
  );
  static Document _$newDocument(DocumentUpdatedEvent v) => v.newDocument;
  static const Field<DocumentUpdatedEvent, Document> _f$newDocument = Field(
    'newDocument',
    _$newDocument,
    key: r'new_document',
  );
  static Document? _$oldDocument(DocumentUpdatedEvent v) => v.oldDocument;
  static const Field<DocumentUpdatedEvent, Document> _f$oldDocument = Field(
    'oldDocument',
    _$oldDocument,
    key: r'old_document',
    opt: true,
  );

  @override
  final MappableFields<DocumentUpdatedEvent> fields = const {
    #channels: _f$channels,
    #newDocument: _f$newDocument,
    #oldDocument: _f$oldDocument,
  };

  @override
  final String discriminatorKey = 'type';
  @override
  final dynamic discriminatorValue = 'document_updated';
  @override
  late final ClassMapperBase superMapper =
      DocumentEventMapper.ensureInitialized();

  static DocumentUpdatedEvent _instantiate(DecodingData data) {
    return DocumentUpdatedEvent(
      channels: data.dec(_f$channels),
      newDocument: data.dec(_f$newDocument),
      oldDocument: data.dec(_f$oldDocument),
    );
  }

  @override
  final Function instantiate = _instantiate;

  static DocumentUpdatedEvent fromJson(Map<String, dynamic> map) {
    return ensureInitialized().decodeMap<DocumentUpdatedEvent>(map);
  }

  static DocumentUpdatedEvent fromJsonString(String json) {
    return ensureInitialized().decodeJson<DocumentUpdatedEvent>(json);
  }
}

mixin DocumentUpdatedEventMappable {
  String toJsonString() {
    return DocumentUpdatedEventMapper.ensureInitialized()
        .encodeJson<DocumentUpdatedEvent>(this as DocumentUpdatedEvent);
  }

  Map<String, dynamic> toJson() {
    return DocumentUpdatedEventMapper.ensureInitialized()
        .encodeMap<DocumentUpdatedEvent>(this as DocumentUpdatedEvent);
  }

  DocumentUpdatedEventCopyWith<
    DocumentUpdatedEvent,
    DocumentUpdatedEvent,
    DocumentUpdatedEvent
  >
  get copyWith =>
      _DocumentUpdatedEventCopyWithImpl<
        DocumentUpdatedEvent,
        DocumentUpdatedEvent
      >(this as DocumentUpdatedEvent, $identity, $identity);
  @override
  String toString() {
    return DocumentUpdatedEventMapper.ensureInitialized().stringifyValue(
      this as DocumentUpdatedEvent,
    );
  }

  @override
  bool operator ==(Object other) {
    return DocumentUpdatedEventMapper.ensureInitialized().equalsValue(
      this as DocumentUpdatedEvent,
      other,
    );
  }

  @override
  int get hashCode {
    return DocumentUpdatedEventMapper.ensureInitialized().hashValue(
      this as DocumentUpdatedEvent,
    );
  }
}

extension DocumentUpdatedEventValueCopy<$R, $Out>
    on ObjectCopyWith<$R, DocumentUpdatedEvent, $Out> {
  DocumentUpdatedEventCopyWith<$R, DocumentUpdatedEvent, $Out>
  get $asDocumentUpdatedEvent => $base.as(
    (v, t, t2) => _DocumentUpdatedEventCopyWithImpl<$R, $Out>(v, t, t2),
  );
}

abstract class DocumentUpdatedEventCopyWith<
  $R,
  $In extends DocumentUpdatedEvent,
  $Out
>
    implements DocumentEventCopyWith<$R, $In, $Out> {
  @override
  ListCopyWith<$R, String, ObjectCopyWith<$R, String, String>> get channels;
  DocumentCopyWith<$R, Document, Document> get newDocument;
  DocumentCopyWith<$R, Document, Document>? get oldDocument;
  @override
  $R call({
    List<String>? channels,
    Document? newDocument,
    Document? oldDocument,
  });
  DocumentUpdatedEventCopyWith<$R2, $In, $Out2> $chain<$R2, $Out2>(
    Then<$Out2, $R2> t,
  );
}

class _DocumentUpdatedEventCopyWithImpl<$R, $Out>
    extends ClassCopyWithBase<$R, DocumentUpdatedEvent, $Out>
    implements DocumentUpdatedEventCopyWith<$R, DocumentUpdatedEvent, $Out> {
  _DocumentUpdatedEventCopyWithImpl(super.value, super.then, super.then2);

  @override
  late final ClassMapperBase<DocumentUpdatedEvent> $mapper =
      DocumentUpdatedEventMapper.ensureInitialized();
  @override
  ListCopyWith<$R, String, ObjectCopyWith<$R, String, String>> get channels =>
      ListCopyWith(
        $value.channels,
        (v, t) => ObjectCopyWith(v, $identity, t),
        (v) => call(channels: v),
      );
  @override
  DocumentCopyWith<$R, Document, Document> get newDocument =>
      $value.newDocument.copyWith.$chain((v) => call(newDocument: v));
  @override
  DocumentCopyWith<$R, Document, Document>? get oldDocument =>
      $value.oldDocument?.copyWith.$chain((v) => call(oldDocument: v));
  @override
  $R call({
    List<String>? channels,
    Document? newDocument,
    Object? oldDocument = $none,
  }) => $apply(
    FieldCopyWithData({
      if (channels != null) #channels: channels,
      if (newDocument != null) #newDocument: newDocument,
      if (oldDocument != $none) #oldDocument: oldDocument,
    }),
  );
  @override
  DocumentUpdatedEvent $make(CopyWithData data) => DocumentUpdatedEvent(
    channels: data.get(#channels, or: $value.channels),
    newDocument: data.get(#newDocument, or: $value.newDocument),
    oldDocument: data.get(#oldDocument, or: $value.oldDocument),
  );

  @override
  DocumentUpdatedEventCopyWith<$R2, DocumentUpdatedEvent, $Out2>
  $chain<$R2, $Out2>(Then<$Out2, $R2> t) =>
      _DocumentUpdatedEventCopyWithImpl<$R2, $Out2>($value, $cast, t);
}

class DocumentDeletedEventMapper
    extends SubClassMapperBase<DocumentDeletedEvent> {
  DocumentDeletedEventMapper._();

  static DocumentDeletedEventMapper? _instance;
  static DocumentDeletedEventMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = DocumentDeletedEventMapper._());
      DocumentEventMapper.ensureInitialized().addSubMapper(_instance!);
      DocumentMapper.ensureInitialized();
    }
    return _instance!;
  }

  @override
  final String id = 'DocumentDeletedEvent';

  static List<String> _$channels(DocumentDeletedEvent v) => v.channels;
  static const Field<DocumentDeletedEvent, List<String>> _f$channels = Field(
    'channels',
    _$channels,
  );
  static Document _$document(DocumentDeletedEvent v) => v.document;
  static const Field<DocumentDeletedEvent, Document> _f$document = Field(
    'document',
    _$document,
  );

  @override
  final MappableFields<DocumentDeletedEvent> fields = const {
    #channels: _f$channels,
    #document: _f$document,
  };

  @override
  final String discriminatorKey = 'type';
  @override
  final dynamic discriminatorValue = 'document_deleted';
  @override
  late final ClassMapperBase superMapper =
      DocumentEventMapper.ensureInitialized();

  static DocumentDeletedEvent _instantiate(DecodingData data) {
    return DocumentDeletedEvent(
      channels: data.dec(_f$channels),
      document: data.dec(_f$document),
    );
  }

  @override
  final Function instantiate = _instantiate;

  static DocumentDeletedEvent fromJson(Map<String, dynamic> map) {
    return ensureInitialized().decodeMap<DocumentDeletedEvent>(map);
  }

  static DocumentDeletedEvent fromJsonString(String json) {
    return ensureInitialized().decodeJson<DocumentDeletedEvent>(json);
  }
}

mixin DocumentDeletedEventMappable {
  String toJsonString() {
    return DocumentDeletedEventMapper.ensureInitialized()
        .encodeJson<DocumentDeletedEvent>(this as DocumentDeletedEvent);
  }

  Map<String, dynamic> toJson() {
    return DocumentDeletedEventMapper.ensureInitialized()
        .encodeMap<DocumentDeletedEvent>(this as DocumentDeletedEvent);
  }

  DocumentDeletedEventCopyWith<
    DocumentDeletedEvent,
    DocumentDeletedEvent,
    DocumentDeletedEvent
  >
  get copyWith =>
      _DocumentDeletedEventCopyWithImpl<
        DocumentDeletedEvent,
        DocumentDeletedEvent
      >(this as DocumentDeletedEvent, $identity, $identity);
  @override
  String toString() {
    return DocumentDeletedEventMapper.ensureInitialized().stringifyValue(
      this as DocumentDeletedEvent,
    );
  }

  @override
  bool operator ==(Object other) {
    return DocumentDeletedEventMapper.ensureInitialized().equalsValue(
      this as DocumentDeletedEvent,
      other,
    );
  }

  @override
  int get hashCode {
    return DocumentDeletedEventMapper.ensureInitialized().hashValue(
      this as DocumentDeletedEvent,
    );
  }
}

extension DocumentDeletedEventValueCopy<$R, $Out>
    on ObjectCopyWith<$R, DocumentDeletedEvent, $Out> {
  DocumentDeletedEventCopyWith<$R, DocumentDeletedEvent, $Out>
  get $asDocumentDeletedEvent => $base.as(
    (v, t, t2) => _DocumentDeletedEventCopyWithImpl<$R, $Out>(v, t, t2),
  );
}

abstract class DocumentDeletedEventCopyWith<
  $R,
  $In extends DocumentDeletedEvent,
  $Out
>
    implements DocumentEventCopyWith<$R, $In, $Out> {
  @override
  ListCopyWith<$R, String, ObjectCopyWith<$R, String, String>> get channels;
  DocumentCopyWith<$R, Document, Document> get document;
  @override
  $R call({List<String>? channels, Document? document});
  DocumentDeletedEventCopyWith<$R2, $In, $Out2> $chain<$R2, $Out2>(
    Then<$Out2, $R2> t,
  );
}

class _DocumentDeletedEventCopyWithImpl<$R, $Out>
    extends ClassCopyWithBase<$R, DocumentDeletedEvent, $Out>
    implements DocumentDeletedEventCopyWith<$R, DocumentDeletedEvent, $Out> {
  _DocumentDeletedEventCopyWithImpl(super.value, super.then, super.then2);

  @override
  late final ClassMapperBase<DocumentDeletedEvent> $mapper =
      DocumentDeletedEventMapper.ensureInitialized();
  @override
  ListCopyWith<$R, String, ObjectCopyWith<$R, String, String>> get channels =>
      ListCopyWith(
        $value.channels,
        (v, t) => ObjectCopyWith(v, $identity, t),
        (v) => call(channels: v),
      );
  @override
  DocumentCopyWith<$R, Document, Document> get document =>
      $value.document.copyWith.$chain((v) => call(document: v));
  @override
  $R call({List<String>? channels, Document? document}) => $apply(
    FieldCopyWithData({
      if (channels != null) #channels: channels,
      if (document != null) #document: document,
    }),
  );
  @override
  DocumentDeletedEvent $make(CopyWithData data) => DocumentDeletedEvent(
    channels: data.get(#channels, or: $value.channels),
    document: data.get(#document, or: $value.document),
  );

  @override
  DocumentDeletedEventCopyWith<$R2, DocumentDeletedEvent, $Out2>
  $chain<$R2, $Out2>(Then<$Out2, $R2> t) =>
      _DocumentDeletedEventCopyWithImpl<$R2, $Out2>($value, $cast, t);
}

