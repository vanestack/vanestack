import 'dart:convert';

import 'package:http/http.dart' as http;

/// Cache for JWKS (JSON Web Key Sets) with TTL
class JwksCache {
  static final Map<String, _CachedJwks> _cache = {};
  static const Duration _ttl = Duration(hours: 1);

  static const Map<String, String> _jwksUrls = {
    'google': 'https://www.googleapis.com/oauth2/v3/certs',
    'apple': 'https://appleid.apple.com/auth/keys',
    'facebook': 'https://www.facebook.com/.well-known/oauth/openid/jwks/',
  };

  /// Fetches JWKS for a provider, using cache if available
  static Future<Map<String, dynamic>> getJwks(String provider) async {
    final cached = _cache[provider];
    if (cached != null && !cached.isExpired) {
      return cached.jwks;
    }

    final url = _jwksUrls[provider];
    if (url == null) {
      throw Exception('Unknown JWKS provider: $provider');
    }

    final response = await http.get(Uri.parse(url));
    if (response.statusCode != 200) {
      throw Exception('Failed to fetch JWKS: ${response.statusCode}');
    }

    final jwks = jsonDecode(response.body) as Map<String, dynamic>;
    _cache[provider] = _CachedJwks(jwks, DateTime.now().add(_ttl));
    return jwks;
  }

  /// Finds a key in JWKS by key ID (kid)
  static Map<String, dynamic>? findKey(Map<String, dynamic> jwks, String kid) {
    final keys = jwks['keys'] as List?;
    if (keys == null) return null;

    for (final key in keys) {
      if (key is Map<String, dynamic> && key['kid'] == kid) {
        return key;
      }
    }
    return null;
  }

  /// Clears the cache (useful for testing)
  static void clearCache() {
    _cache.clear();
  }
}

class _CachedJwks {
  final Map<String, dynamic> jwks;
  final DateTime expiresAt;

  _CachedJwks(this.jwks, this.expiresAt);

  bool get isExpired => DateTime.now().isAfter(expiresAt);
}
