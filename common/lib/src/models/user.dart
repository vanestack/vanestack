import 'package:dart_mappable/dart_mappable.dart';

import '../mappers/datetime.dart';

part 'user.mapper.dart';

@MappableClass(includeCustomMappers: [SecondsDateTimeMapper()])
class User with UserMappable {
  final String id;
  final String email;
  final String? name;
  final List<String> providers;
  final DateTime createdAt;
  final DateTime updatedAt;

  User({
    required this.id,
    required this.email,
    this.name,
    this.providers = const [],
    required this.createdAt,
    required this.updatedAt,
  });
}
