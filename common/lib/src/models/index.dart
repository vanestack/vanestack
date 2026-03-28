import 'package:dart_mappable/dart_mappable.dart';

part 'index.mapper.dart';

@MappableClass()
class Index with IndexMappable {
  final String name;
  final List<String> columns;
  final bool? unique;
  final bool? ifNotExists;

  Index({
    required this.name,
    required this.columns,
    this.unique,
    this.ifNotExists,
  });
}
