import 'package:drift/drift.dart' hide Index;
import 'package:vanestack_common/vanestack_common.dart';

import '../database/database.dart';
import '../utils/collection_data.dart';

/// In-memory cache of collection metadata.
///
/// Warmed up at server start and kept in sync by [CollectionsService] on every
/// create/update/delete. Callers that need up-to-date collection metadata for
/// reads (permission checks, validation, view-vs-base detection) can query the
/// cache synchronously instead of issuing a database round-trip per request.
class CollectionsCache {
  final Map<String, Collection> _byName = {};

  /// Loads every collection row into the cache. Call once before the server
  /// starts accepting requests.
  Future<void> warmUp(AppDatabase db) async {
    final rows = await db.collections.select().get();
    _byName
      ..clear()
      ..addEntries(rows.map((r) {
        final c = r.toModel();
        return MapEntry(c.name, c);
      }));
  }

  Collection? get(String name) => _byName[name];

  /// Returns the cached collection, or loads it from [db] on a miss and
  /// populates the cache. Use this when the caller needs to tolerate entries
  /// that were added to the collections table outside the normal service
  /// path (e.g. tests that seed directly, or a sibling process).
  Future<Collection?> resolve(String name, AppDatabase db) async {
    final cached = _byName[name];
    if (cached != null) return cached;

    final row = await (db.collections.select()
          ..where((tbl) => tbl.name.equals(name)))
        .getSingleOrNull();
    if (row == null) return null;

    final collection = row.toModel();
    _byName[collection.name] = collection;
    return collection;
  }

  List<Collection> list() => List.unmodifiable(_byName.values);

  Iterable<String> get names => _byName.keys;

  void put(Collection collection) {
    _byName[collection.name] = collection;
  }

  /// Updates an entry whose name may have changed. Removes [previousName] if
  /// it differs from the new collection's name.
  void replace({required String previousName, required Collection collection}) {
    if (previousName != collection.name) {
      _byName.remove(previousName);
    }
    _byName[collection.name] = collection;
  }

  void remove(String name) {
    _byName.remove(name);
  }
}
