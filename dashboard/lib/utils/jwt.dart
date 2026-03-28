import 'dart:convert';

bool isJwtExpired(String jwt) {
  final parts = jwt.split('.');
  if (parts.length != 3) return true;

  // Decode the payload (base64url)
  final payload = parts[1];
  final normalized = base64Url.normalize(payload);
  final decoded = utf8.decode(base64Url.decode(normalized));
  final Map<String, dynamic> claims = jsonDecode(decoded);

  final exp = claims['exp'];
  if (exp == null) return false; // No expiry claim = never expires

  final expiryDate = DateTime.fromMillisecondsSinceEpoch(exp * 1000);
  return expiryDate.isBefore(DateTime.now());
}
