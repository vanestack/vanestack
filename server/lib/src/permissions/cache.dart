/// A simple key-value cache with a maximum size of 30 elements.
/// When the cache exceeds the limit, the oldest entry is removed.
class SimpleCache<K, V> {
  static const int _maxSize = 30;
  final _cache = <K, V>{};

  /// Retrieves a value by key, or null if not present.
  V? get(K key) => _cache[key];

  /// Adds or updates a key-value pair in the cache.
  void set(K key, V value) {
    // Remove existing key to refresh insertion order.
    if (_cache.containsKey(key)) {
      _cache.remove(key);
    }

    // Add the new value.
    _cache[key] = value;

    // If cache exceeds max size, remove the oldest entry.
    if (_cache.length > _maxSize) {
      final oldestKey = _cache.keys.first;
      _cache.remove(oldestKey);
    }
  }

  /// Removes a specific key from the cache.
  void remove(K key) {
    _cache.remove(key);
  }

  /// Clears all cached entries.
  void clear() {
    _cache.clear();
  }

  /// Returns the current number of cached items.
  int get length => _cache.length;

  /// Returns true if the cache contains the key.
  bool containsKey(K key) => _cache.containsKey(key);

  @override
  String toString() => _cache.toString();
}
