import 'package:collection/collection.dart';
import 'package:vanestack_client/vanestack_client.dart';
import 'package:jaspr_riverpod/jaspr_riverpod.dart';

import 'client.dart';

final collectionsProvider = AsyncNotifierProvider.autoDispose(
  CollectionsProvider.new,
);

final collectionByIdProvider = FutureProvider.family<Collection?, String>(
  (ref, collectionName) {
    return ref.watch(
      collectionsProvider.selectAsync(
        (p) => p.firstWhereOrNull((e) => e.name == collectionName),
      ),
    );
  },
);

class CollectionsProvider extends AsyncNotifier<List<Collection>> {
  @override
  Future<List<Collection>> build() async {
    final client = ref.watch(clientProvider);
    return client.collections.list();
  }

  Future<void> createBaseCollection({
    required String name,
    required List<Attribute> attributes,
    required List<Index> indexes,
    String? listRule,
    String? viewRule,
    String? createRule,
    String? updateRule,
    String? deleteRule,
  }) async {
    final client = ref.read(clientProvider);

    final created = await client.collections.create(
      name: name,
      type: 'base',
      attributes: attributes,
      indexes: indexes,
      listRule: listRule,
      viewRule: viewRule,
      createRule: createRule,
      updateRule: updateRule,
      deleteRule: deleteRule,
    );

    await update((currentValue) => [...currentValue, created]);
  }

  Future<void> createViewCollection({
    required String name,
    required String viewQuery,
    String? listRule,
    String? viewRule,
  }) async {
    final client = ref.read(clientProvider);

    final created = await client.collections.create(
      name: name,
      type: 'view',
      viewQuery: viewQuery,
      listRule: listRule,
      viewRule: viewRule,
    );

    await update((currentValue) => [...currentValue, created]);
  }

  Future<void> updateBaseCollection({
    required String collectionName,
    String? newName,
    required List<Attribute> attributes,
    required List<Index> indexes,
    String? listRule,
    String? viewRule,
    String? createRule,
    String? updateRule,
    String? deleteRule,
  }) async {
    final client = ref.read(clientProvider);

    final updated = await client.collections.update(
      collectionName: collectionName,
      newCollectionName: newName,
      attributes: attributes,
      indexes: indexes,
      listRule: listRule,
      viewRule: viewRule,
      createRule: createRule,
      updateRule: updateRule,
      deleteRule: deleteRule,
    );

    await update((currentValue) {
      final index = currentValue.indexWhere(
        (element) => element.name == collectionName,
      );

      if (index == -1) return currentValue;
      final newList = [...currentValue];
      newList[index] = updated;
      return newList;
    });
  }

  Future<void> updateViewCollection({
    required String collectionName,
    String? newName,
    required String viewQuery,
    String? listRule,
    String? viewRule,
  }) async {
    final client = ref.read(clientProvider);

    final updated = await client.collections.update(
      collectionName: collectionName,
      newCollectionName: newName,
      viewQuery: viewQuery,
      listRule: listRule,
      viewRule: viewRule,
    );

    await update((currentValue) {
      final index = currentValue.indexWhere(
        (element) => element.name == collectionName,
      );

      if (index == -1) return currentValue;
      final newList = [...currentValue];
      newList[index] = updated;
      return newList;
    });
  }

  Future<void> deleteCollection(String collectionName) async {
    final client = ref.read(clientProvider);

    await client.collections.delete(collectionName: collectionName);

    await update(
      (currentValue) => [
        ...currentValue.where(
          (collection) => collection.name != collectionName,
        ),
      ],
    );
  }
}
