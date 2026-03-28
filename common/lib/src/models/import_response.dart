import 'package:dart_mappable/dart_mappable.dart';

import '../mappers/datetime.dart';

part 'import_response.mapper.dart';

@MappableClass(includeCustomMappers: [SecondsDateTimeMapper()])
class ImportResponse with ImportResponseMappable {
  final List<String> created;
  final List<String> updated;
  final List<String> skipped;
  final List<ImportError> errors;
  final DateTime importedAt;

  ImportResponse({
    required this.created,
    required this.updated,
    required this.skipped,
    required this.errors,
    required this.importedAt,
  });
}

@MappableClass()
class ImportError with ImportErrorMappable {
  final String collection;
  final String error;

  ImportError({
    required this.collection,
    required this.error,
  });
}
