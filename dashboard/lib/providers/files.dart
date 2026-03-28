import 'package:vanestack_client/vanestack_client.dart';
import 'package:jaspr_riverpod/jaspr_riverpod.dart';

import 'client.dart';
import 'simple_notifier.dart';

final filesPageProvider = NotifierProvider(() => SimpleNotifier<int>(0));
final filesRowsPerPageProvider = NotifierProvider(
  () => SimpleNotifier<int>(10),
);

final filesOrderProvider = NotifierProvider(
  () => SimpleNotifier<(String, SortDirection)>(('path', SortDirection.desc)),
);

// Provider to track the current path in the file browser (per bucket)
final currentPathProvider = NotifierProvider.family<CurrentPathNotifier, String, String>(
  CurrentPathNotifier.new,
);

class CurrentPathNotifier extends Notifier<String> {
  CurrentPathNotifier(this.bucket);
  final String bucket;

  @override
  String build() => '';

  void set(String path) => state = path;
}

// Provider that fetches files for a bucket and extracts items at each path level
final listFilesProvider = FutureProvider.autoDispose.family<ListFilesResult, (String, String)>(
  (ref, args) async {
    final (bucket, prefix) = args;
    final client = ref.watch(clientProvider);

    return client.files.list(
      bucket: bucket,
      path: prefix,
    );
  },
);
