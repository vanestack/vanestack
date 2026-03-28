import 'package:vanestack_common/vanestack_common.dart';
import 'package:dart_mappable/dart_mappable.dart';

part 'realtime_event.mapper.dart';

@MappableClass(discriminatorKey: 'type')
sealed class RealtimeEvent with RealtimeEventMappable {
  final List<String> channels;

  RealtimeEvent({required this.channels});

  factory RealtimeEvent.custom({
    required List<String> channels,
    required Map<String, Object?> data,
    String? rule,
  }) = CustomRealtimeEvent;
}

@MappableClass(discriminatorValue: 'custom')
class CustomRealtimeEvent extends RealtimeEvent
    with CustomRealtimeEventMappable {
  final Map<String, Object?> data;
  final String? rule;

  CustomRealtimeEvent({required this.data, required super.channels, this.rule});
}

@MappableClass(discriminatorValue: 'file')
sealed class FileEvent extends RealtimeEvent with FileEventMappable {
  FileEvent({required super.channels});
}

@MappableClass(discriminatorValue: 'file_uploaded')
class FileUploadedEvent extends FileEvent with FileUploadedEventMappable {
  final File file;

  FileUploadedEvent({required super.channels, required this.file});
}

@MappableClass(discriminatorValue: 'file_moved')
class FileMovedEvent extends FileEvent with FileMovedEventMappable {
  final File file;
  final String oldPath;

  FileMovedEvent({
    required super.channels,
    required this.file,
    required this.oldPath,
  });
}

@MappableClass(discriminatorValue: 'file_deleted')
class FileDeletedEvent extends FileEvent with FileDeletedEventMappable {
  final File file;

  FileDeletedEvent({required super.channels, required this.file});
}

@MappableClass(discriminatorValue: 'document')
sealed class DocumentEvent extends RealtimeEvent with DocumentEventMappable {
  DocumentEvent({required super.channels});
}

@MappableClass(discriminatorValue: 'document_created')
class DocumentCreatedEvent extends DocumentEvent
    with DocumentCreatedEventMappable {
  final Document document;

  DocumentCreatedEvent({required super.channels, required this.document});
}

@MappableClass(discriminatorValue: 'document_updated')
class DocumentUpdatedEvent extends DocumentEvent
    with DocumentUpdatedEventMappable {
  final Document newDocument;
  final Document? oldDocument;

  DocumentUpdatedEvent({
    required super.channels,
    required this.newDocument,
    this.oldDocument,
  });
}

@MappableClass(discriminatorValue: 'document_deleted')
class DocumentDeletedEvent extends DocumentEvent
    with DocumentDeletedEventMappable {
  final Document document;

  DocumentDeletedEvent({required super.channels, required this.document});
}
