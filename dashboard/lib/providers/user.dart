import 'package:jaspr_riverpod/jaspr_riverpod.dart';

import 'client.dart';

final userProvider = StreamProvider.autoDispose((ref) {
  final client = ref.watch(clientProvider);

  return client.onUserChanges;
});
