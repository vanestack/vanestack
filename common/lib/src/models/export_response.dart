import 'package:dart_mappable/dart_mappable.dart';

import '../../vanestack_common.dart';
import '../mappers/datetime.dart';

part 'export_response.mapper.dart';

@MappableClass(includeCustomMappers: [SecondsDateTimeMapper()])
class ExportResponse with ExportResponseMappable {
  final List<Collection> collections;
  final DateTime exportedAt;
  final String version;

  ExportResponse({
    required this.collections,
    required this.exportedAt,
    required this.version,
  });
}
