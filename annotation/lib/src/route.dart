import 'http_method.dart';

/// Annotation to define a server route with metadata for authentication and client generation.
/// [requireSuperUserAuth] indicates that the route requires superuser privileges.
/// [ignoreForClient] indicates that the route should not be included in the generated client SDK.
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
