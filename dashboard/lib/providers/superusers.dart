import 'package:vanestack_client/vanestack_client.dart';
import 'package:jaspr_riverpod/jaspr_riverpod.dart';

import 'client.dart';

final superusersProvider = AsyncNotifierProvider.autoDispose(SuperusersProvider.new);

class SuperusersProvider extends AsyncNotifier<ListUsersResult> {
  @override
  Future<ListUsersResult> build() async {
    final client = ref.watch(clientProvider);
    return client.users.list(
      filter: Filter.where('super_user', isEqualTo: true).build(),
      orderBy: OrderBy('created_at', direction: SortDirection.desc).build(),
    );
  }

  Future<void> createSuperuser({
    String? id,
    String? name,
    required String email,
  }) async {
    final client = ref.read(clientProvider);

    await client.users.create(
      id: id,
      name: name,
      email: email,
      superUser: true,
    );

    ref.invalidateSelf();
  }

  Future<void> updateSuperuser({
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

  Future<void> deleteSuperuser({required String id}) async {
    final client = ref.read(clientProvider);

    await client.users.delete(userId: id);

    ref.invalidateSelf();
  }
}
