import 'package:vanestack_client/vanestack_client.dart';
import 'package:jaspr_riverpod/jaspr_riverpod.dart';

import 'client.dart';

final documentsProvider = AsyncNotifierProvider.autoDispose.family(
  DocumentsProvider.new,
);

class DocumentsProvider extends AsyncNotifier<ListDocumentsResult> {
  final String collectionName;

  DocumentsProvider(this.collectionName);

  @override
  Future<ListDocumentsResult> build() async {
    final page = ref.watch(documentsPageProvider(collectionName));
    final perPage = ref.watch(documentsRowsPerPageProvider(collectionName));
    final order = ref.watch(documentsOrderProvider(collectionName));
    final client = ref.watch(clientProvider);
    return client.documents.list(
      collectionName: collectionName,
      offset: page * perPage,
      limit: perPage,
      orderBy: OrderBy(order.$1, direction: order.$2).build(),
    );
  }

  Future<void> createDocument({required Map<String, Object?> data}) async {
    final client = ref.read(clientProvider);

    await client.documents.create(collectionName: collectionName, data: data);

    ref.invalidateSelf();
  }

  Future<void> updateDocument({
    required String id,
    required Map<String, Object?> data,
  }) async {
    final client = ref.read(clientProvider);

    await client.documents.update(
      collectionName: collectionName,
      documentId: id,
      data: data,
    );

    ref.invalidateSelf();
  }

  Future<void> deleteDocument({required String id}) async {
    final client = ref.read(clientProvider);

    await client.documents.delete(
      collectionName: collectionName,
      documentId: id,
    );

    ref.invalidateSelf();
  }
}

final documentsRowsPerPageProvider = NotifierProvider.autoDispose.family(
  DocumentsRowsPerPageProvider.new,
);

class DocumentsRowsPerPageProvider extends Notifier<int> {
  final String collectionName;
  DocumentsRowsPerPageProvider(this.collectionName);
  @override
  int build() {
    return 10;
  }

  void set(int rowsPerPage) {
    state = rowsPerPage;
  }
}

final documentsOrderProvider = NotifierProvider.autoDispose.family(
  DocumentsOrderProvider.new,
);

class DocumentsOrderProvider extends Notifier<(String, SortDirection)> {
  final String collectionName;
  DocumentsOrderProvider(this.collectionName);
  @override
  (String, SortDirection) build() {
    return ('id', SortDirection.desc);
  }

  void set((String, SortDirection) order) {
    state = order;
  }
}

final documentsPageProvider = NotifierProvider.autoDispose.family(DocumentsPageProvider.new);

class DocumentsPageProvider extends Notifier<int> {
  final String collectionName;
  DocumentsPageProvider(this.collectionName);

  @override
  int build() {
    return 0;
  }

  void set(int page) {
    state = page;
  }
}
