import 'package:vanestack_common/vanestack_common.dart';
import 'package:dart_jsonwebtoken/dart_jsonwebtoken.dart';
import 'package:shelf/shelf.dart';

import '../utils/auth.dart';
import '../utils/extensions.dart';

const _jwtCacheMaxSize = 256;
final _jwtCache = <String, ({Map<String, Object?> payload, int expSec})>{};

Middleware decodeJwt() => (final innerHandler) {
  return (final request) async {
    final jwt = request.bearerToken;
    final secret = request.env.jwtSecret;

    String? userId;
    UserType userType = UserType.guest;

    try {
      // Only attempt JWT verification if token looks like a JWT (3 dot-separated parts).
      // Opaque tokens (e.g. refresh tokens) are passed through as guest.
      final isJwtFormat = jwt != null && jwt.split('.').length == 3;

      Map<String, Object?>? payload;
      if (isJwtFormat) {
        final cached = _jwtCache[jwt];
        final nowSec = DateTime.now().millisecondsSinceEpoch ~/ 1000;
        if (cached != null && cached.expSec > nowSec) {
          payload = cached.payload;
        } else {
          if (cached != null) _jwtCache.remove(jwt);
          payload = AuthUtils.verifyJwt(jwt, secret);
          if (payload != null) {
            final exp = payload['exp'] as int? ?? nowSec + 3600;
            if (_jwtCache.length >= _jwtCacheMaxSize) _jwtCache.clear();
            _jwtCache[jwt] = (payload: payload, expSec: exp);
          }
        }
      }

      // If a JWT-format token was provided but verification failed, reject it
      if (isJwtFormat && payload == null) {
        return response(401, error: 'Invalid token.');
      }

      if (payload?['sub'] case String v) {
        userId = v;
      }

      if (userId != null) {
        if (payload?['superUser'] case bool? superUser) {
          userType = (superUser ?? false) ? UserType.admin : UserType.user;
        }
      }
    } on JWTExpiredException {
      return response(401, error: 'JWT has expired.');
    }

    return await innerHandler(
      request.change(context: {'userId': ?userId, 'userType': userType}),
    );
  };
};
