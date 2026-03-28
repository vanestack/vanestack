import 'package:vanestack_client/vanestack_client.dart';
import 'package:universal_web/web.dart';

class NoopAuthStorage extends AuthStorage {
  @override
  Future<void> delete(String key) async {}

  @override
  Future<String?> read(String key) async {
    return null;
  }

  @override
  Future<void> save(String key, String value) async {}
}

class LocalAuthStorage extends AuthStorage {
  @override
  Future<void> delete(String key) async {
    window.localStorage.removeItem(key);
  }

  @override
  Future<String?> read(String key) async {
    return window.localStorage.getItem(key);
  }

  @override
  Future<void> save(String key, String value) async {
    window.localStorage.setItem(key, value);
  }
}
