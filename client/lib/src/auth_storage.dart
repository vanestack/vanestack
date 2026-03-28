abstract class AuthStorage {
  Future<void> save(String key, String value);
  Future<String?> read(String key);
  Future<void> delete(String key);
}

class MemoryAuthStorage extends AuthStorage {
  final Map<String, String> _storage = {};

  @override
  Future<void> delete(String key) async {
    _storage.remove(key);
  }

  @override
  Future<String?> read(String key) async {
    return _storage[key];
  }

  @override
  Future<void> save(String key, String value) async {
    _storage[key] = value;
  }
}
