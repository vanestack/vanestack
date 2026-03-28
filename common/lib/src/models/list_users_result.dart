import 'package:dart_mappable/dart_mappable.dart';

import '../../vanestack_common.dart';

part 'list_users_result.mapper.dart';

@MappableClass()
class ListUsersResult with ListUsersResultMappable {
  final List<User> users;
  final int count;

  ListUsersResult({required this.users, required this.count});
}
