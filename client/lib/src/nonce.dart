import 'dart:convert';
import 'dart:math';

import 'package:crypto/crypto.dart';

/// Generates a cryptographically random nonce and its SHA-256 hash.
///
/// Returns a record with:
/// - `raw`: the raw nonce string (sent to the server for verification)
/// - `hashed`: the SHA-256 hex digest (passed to the identity provider)
({String raw, String hashed}) generateNonce([int length = 32]) {
  final random = Random.secure();
  final raw = List.generate(
    length,
    (_) => random.nextInt(256),
  ).map((b) => b.toRadixString(16).padLeft(2, '0')).join();
  final hashed = sha256.convert(utf8.encode(raw)).toString();
  return (raw: raw, hashed: hashed);
}
