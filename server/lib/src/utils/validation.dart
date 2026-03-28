import 'package:uuid/validation.dart';

bool validateEmail(String email) {
  // Basic RFC 5322–compatible email pattern
  final emailRegex = RegExp(
    r"^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$",
  );
  return emailRegex.hasMatch(email.trim());
}

bool validateUuid(String uuid) {
  return UuidValidation.isValidUUID(fromString: uuid);
}

/// Validates that a name is URL-friendly.
///
/// Must start with a lowercase letter and contain only lowercase letters,
/// numbers, hyphens, and underscores. No spaces or special characters.
bool validateUrlFriendlyName(String name) {
  if (name.isEmpty) return false;
  final regex = RegExp(r'^[a-z][a-z0-9_]*$');
  return regex.hasMatch(name);
}
