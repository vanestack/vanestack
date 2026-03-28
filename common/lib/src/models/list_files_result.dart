import 'package:dart_mappable/dart_mappable.dart';

import '../../vanestack_common.dart';

part 'list_files_result.mapper.dart';

@MappableClass()
class ListFilesResult with ListFilesResultMappable {
  final List<File> files;
  final List<String> folders;

  ListFilesResult({required this.files, required this.folders});
}
