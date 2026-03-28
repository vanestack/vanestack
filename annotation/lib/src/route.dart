import 'http_method.dart';

class Route {
  final String path;
  final bool ignoreForClient;
  final HttpMethod method;
  final bool requireAuth;
  final bool requireSuperUserAuth;
  const Route({
    required this.path,
    required this.method,
    this.requireAuth = false,
    this.requireSuperUserAuth = false,
    this.ignoreForClient = false,
  });
}
