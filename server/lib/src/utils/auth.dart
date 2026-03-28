import 'dart:convert';
import 'dart:isolate';
import 'dart:math';
import 'dart:typed_data';

import 'package:dart_jsonwebtoken/dart_jsonwebtoken.dart';
import 'package:hashlib/hashlib.dart';

class AuthUtils {
  static Uint8List _generateSalt([int length = 16]) {
    final rnd = Random.secure();
    return Uint8List.fromList(
      List<int>.generate(length, (_) => rnd.nextInt(256)),
    );
  }

  /// Hash a password with Argon2id in a background isolate
  static Future<String> hashPassword(String password) {
    return Isolate.run(() {
      final salt = _generateSalt();
      final argon2 = Argon2(
        iterations: 2,
        memorySizeKB: 19456,
        parallelism: 1,
        hashLength: 32,
        salt: salt,
      );
      final hash = argon2.convert(utf8.encode(password));
      return '${base64Encode(salt)}:${base64Encode(Uint8List.fromList(hash.bytes))}';
    });
  }

  /// Verify a password against a stored Argon2id hash in a background isolate
  static Future<bool> verifyPassword(String password, String storedHash) {
    return Isolate.run(() {
      final parts = storedHash.split(':');
      if (parts.length != 2) return false;

      final salt = base64Decode(parts[0]);
      final originalHash = base64Decode(parts[1]);
      final argon2 = Argon2(
        iterations: 2,
        memorySizeKB: 19456,
        parallelism: 1,
        hashLength: 32,
        salt: salt,
      );
      final newHash = argon2.convert(utf8.encode(password)).bytes;

      // Constant-time comparison to prevent timing attacks
      if (originalHash.length != newHash.length) return false;
      int diff = 0;
      for (int i = 0; i < originalHash.length; i++) {
        diff |= originalHash[i] ^ newHash[i];
      }
      return diff == 0;
    });
  }

  /// Generates a signed JWT for a user
  static String generateJwt({
    required String userId,
    required String jwtSecret,
    String? email,
    bool superuser = false,
    Duration expiry = const Duration(minutes: 10),
  }) {
    final jwt = JWT({
      'sub': userId, // Subject (user ID)
      'email': email, // Optional user info
      'superUser': superuser,
      'iat': DateTime.now().millisecondsSinceEpoch ~/ 1000, // issued at
    }, issuer: 'vanestack');

    // Sign the JWT with a secret key and set expiry
    return jwt.sign(
      SecretKey(jwtSecret),
      expiresIn: expiry,
      algorithm: JWTAlgorithm.HS256,
    );
  }

  /// Verifies and decodes a JWT
  static Map<String, Object?>? verifyJwt(String token, String jwtSecret) {
    try {
      final jwt = JWT.verify(token, SecretKey(jwtSecret));
      return Map<String, Object?>.from(jwt.payload as Map);
    } on JWTExpiredException {
      rethrow;
    } on JWTException {
      return null;
    }
  }

  /// Generate a random refresh token (opaque string)
  static String generateRandomToken({int length = 32}) {
    final random = Random.secure();
    final bytes = List<int>.generate(length, (_) => random.nextInt(256));
    return base64UrlEncode(bytes);
  }

  static String? validatePasswordStrength(String password) {
    // Minimum and recommended requirements
    const minLength = 8;

    // 1️⃣ Check length
    if (password.length < minLength) {
      return 'Password must be at least $minLength characters long.';
    }

    // 2️⃣ Check for uppercase
    if (!RegExp(r'[A-Z]').hasMatch(password)) {
      return 'Password must contain at least one uppercase letter.';
    }

    // 3️⃣ Check for lowercase
    if (!RegExp(r'[a-z]').hasMatch(password)) {
      return 'Password must contain at least one lowercase letter.';
    }

    // 4️⃣ Check for number
    if (!RegExp(r'[0-9]').hasMatch(password)) {
      return 'Password must contain at least one number.';
    }

    // 5️⃣ Check for special character
    if (!RegExp(r'[!@#$%^&*(),.?":{}|<>_\-+=~`;/\\\[\]]').hasMatch(password)) {
      return 'Password must contain at least one special character.';
    }

    // 6️⃣ Check for common patterns (optional, basic examples)
    final lower = password.toLowerCase();
    const commonWords = ['password', '1234', 'qwerty', 'admin', 'letmein'];
    if (commonWords.any((word) => lower.contains(word))) {
      return 'Password is too common or easy to guess.';
    }

    // ✅ If all checks passed
    return null; // null = valid (common Flutter convention)
  }
}
