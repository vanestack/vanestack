import 'package:dart_mappable/dart_mappable.dart';

import '../../vanestack_common.dart';
import 'document.dart';

part 'list_documents_result.mapper.dart';

@MappableClass()
class ListDocumentsResult with ListDocumentsResultMappable {
  final List<Document> documents;
  final int count;

  ListDocumentsResult({required this.documents, required this.count});
}
