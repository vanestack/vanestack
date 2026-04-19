import 'package:vanestack_client/vanestack_client.dart';

import 'package:jaspr_riverpod/jaspr_riverpod.dart';

import 'client.dart';
import '../providers/simple_notifier.dart';

final usersProvider = AsyncNotifierProvider.autoDispose(UsersProvider.new);
final usersPageProvider = NotifierProvider(() => SimpleNotifier<int>(0));
final usersRowsPerPageProvider = NotifierProvider(
  () => SimpleNotifier<int>(10),
);

final usersOrderProvider = NotifierProvider(
  () => SimpleNotifier<(String, SortDirection)>(('id', SortDirection.desc)),
);

class UsersProvider extends AsyncNotifier<ListUsersResult> {
  @override
  Future<ListUsersResult> build() async {
    final page = ref.watch(usersPageProvider);
    final perPage = ref.watch(usersRowsPerPageProvider);
    final order = ref.watch(usersOrderProvider);
    final client = ref.watch(clientProvider);
    return client.users.list(
      offset: page * perPage,
      limit: perPage,
      filter: Filter.where('super_user', isEqualTo: false).build(),
      orderBy: OrderBy(order.$1, direction: order.$2).build(),
    );
  }

  Future<void> createUser({
    String? id,
    String? name,
    required String email,
    String? password,
  }) async {
    final client = ref.read(clientProvider);

    await client.users.create(
      name: name,
      email: email,
      password: password,
      id: id,
    );

    ref.invalidateSelf();
  }

  Future<void> updateUser({
    required String id,
    String? name,
    String? email,
    String? password,
  }) async {
    final client = ref.read(clientProvider);

    await client.users.update(
      userId: id,
      name: name,
      email: email,
      password: password,
    );

    ref.invalidateSelf();
  }

  Future<void> deleteUser({required String id}) async {
    final client = ref.read(clientProvider);

    await client.users.delete(userId: id);

    ref.invalidateSelf();
  }
}
