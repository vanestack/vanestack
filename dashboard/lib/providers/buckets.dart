import 'package:vanestack_client/vanestack_client.dart';
import 'package:jaspr_riverpod/jaspr_riverpod.dart';

import 'client.dart';

final bucketsProvider = AsyncNotifierProvider.autoDispose(
  BucketsProvider.new,
);

class BucketsProvider extends AsyncNotifier<List<Bucket>> {
  @override
  Future<List<Bucket>> build() async {
    final client = ref.watch(clientProvider);
    return client.buckets.list();
  }

  Future<Bucket> createBucket({
    required String bucketName,
    String? listRule,
    String? viewRule,
    String? createRule,
    String? updateRule,
    String? deleteRule,
  }) async {
    final client = ref.read(clientProvider);

    final bucket = await client.buckets.create(
      bucket: bucketName,
      listRule: listRule,
      viewRule: viewRule,
      createRule: createRule,
      updateRule: updateRule,
      deleteRule: deleteRule,
    );

    await update((currentValue) => [...currentValue, bucket]);

    return bucket;
  }

  Future<Bucket> updateBucket(
    String bucketName, {
    String? newBucketName,
    String? listRule,
    String? viewRule,
    String? createRule,
    String? updateRule,
    String? deleteRule,
  }) async {
    final client = ref.read(clientProvider);

    final bucket = await client.buckets.update(
      bucket: bucketName,
      newBucketName: newBucketName,
      listRule: listRule,
      viewRule: viewRule,
      createRule: createRule,
      updateRule: updateRule,
      deleteRule: deleteRule,
    );

    await update((currentValue) {
      final index = currentValue.indexWhere(
        (element) => element.name == bucketName,
      );

      if (index == -1) return currentValue;
      final newList = [...currentValue];
      newList[index] = bucket;
      return newList;
    });

    return bucket;
  }

  Future<void> deleteBucket(String bucket) async {
    final client = ref.read(clientProvider);

    await client.buckets.delete(bucket: bucket);

    await update(
      (currentValue) => [
        ...currentValue.where(
          (b) => b.name != bucket,
        ),
      ],
    );
  }
}
