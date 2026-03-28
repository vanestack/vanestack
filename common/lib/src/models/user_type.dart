import 'package:dart_mappable/dart_mappable.dart';

part 'user_type.mapper.dart';

@MappableEnum()
enum UserType { admin, user, guest }
