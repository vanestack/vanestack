import 'package:uuid/validation.dart';

import 'reactive/form.dart';

/// A validator function that validates a value and optionally accesses the parent form.
///
/// The [form] parameter is provided for cross-field validation. It may be null
/// if the field is not yet attached to a form.
typedef Validator<T> = String? Function(T value, Form? form);

// Validator factories for common validation patterns

/// Creates a required validator.
Validator<String> required([String? message]) {
  return (value, _) => value.trim().isEmpty ? (message ?? 'This field is required') : null;
}

/// Creates an email validator.
Validator<String> email([String? message]) {
  return (value, _) {
    if (value.isEmpty) return null;
    final emailRegex = RegExp(r"^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$");
    return emailRegex.hasMatch(value) ? null : (message ?? 'Invalid email address');
  };
}

/// Creates a minimum length validator.
Validator<String> minLength(int length, [String? message]) {
  return (value, _) {
    if (value.isEmpty) return null;
    return value.length < length ? (message ?? 'Must be at least $length characters') : null;
  };
}

/// Creates a password strength validator.
Validator<String> passwordStrength([String? message]) {
  return (value, _) {
    if (value.isEmpty) return null;
    final error = validatePassword(value);
    return error != null ? (message ?? error) : null;
  };
}

/// Creates a maximum length validator.
Validator<String> maxLength(int length, [String? message]) {
  return (value, _) {
    if (value.isEmpty) return null;
    return value.length > length ? (message ?? 'Must be at most $length characters') : null;
  };
}

/// Creates a regex pattern validator.
Validator<String> pattern(RegExp regex, [String? message]) {
  return (value, _) {
    if (value.isEmpty) return null;
    return regex.hasMatch(value) ? null : (message ?? 'Invalid format');
  };
}

/// Creates a URL validator.
Validator<String> url([String? message]) {
  return (value, _) {
    if (value.isEmpty) return null;
    final uri = Uri.tryParse(value);
    if (uri == null || !uri.isAbsolute) {
      return message ?? 'Please enter a valid URL';
    }
    return null;
  };
}

/// Creates a URL-friendly name validator.
///
/// Validates that the value only contains lowercase letters, numbers,
/// hyphens, and underscores. Must start with a letter.
/// No spaces or special characters allowed.
Validator<String> urlFriendly([String? message]) {
  return (value, _) {
    if (value.isEmpty) return null;
    // Must start with a letter, contain only lowercase letters, numbers, underscores
    final regex = RegExp(r'^[a-z][a-z0-9_]*$');
    if (!regex.hasMatch(value)) {
      return message ?? 'Must start with a letter and contain only lowercase letters, numbers and underscores';
    }
    return null;
  };
}

/// Creates a UUID validator.
Validator<String> uuid([String? message]) {
  return (value, _) {
    if (value.isEmpty) return null;
    return UuidValidation.isValidUUID(fromString: value) ? null : (message ?? 'Invalid UUID');
  };
}

/// Composes multiple validators into a single validator.
///
/// Runs validators in order and returns the first error, or null if all pass.
Validator<T> compose<T>(List<Validator<T>> validators) {
  return (value, form) {
    for (final validator in validators) {
      final result = validator(value, form);
      if (result != null) return result;
    }
    return null;
  };
}

// Cross-field validators

/// Creates a validator that checks if the value matches another field.
///
/// Usage:
/// ```dart
/// 'confirmPassword': FormControl<String>(
///   initialValue: '',
///   validators: [matches('newPassword', 'Passwords do not match')],
/// ),
/// ```
Validator<String> matches(String fieldPath, [String? message]) {
  return (value, form) {
    if (value.isEmpty || form == null) return null;
    final otherValue = form.getControl<String>(fieldPath)?.value ?? '';
    if (value != otherValue) {
      return message ?? 'Values do not match';
    }
    return null;
  };
}

/// Creates a validator that checks if the value is different from another field.
Validator<String> differentFrom(String fieldPath, [String? message]) {
  return (value, form) {
    if (value.isEmpty || form == null) return null;
    final otherValue = form.getControl<String>(fieldPath)?.value ?? '';
    if (value == otherValue) {
      return message ?? 'Values must be different';
    }
    return null;
  };
}

String? validateEmail(String value) {
  final emailRegex = RegExp(r"^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$");
  return emailRegex.hasMatch(value) ? null : 'Invalid email address';
}

String? validateUuid(String value) {
  return UuidValidation.isValidUUID(fromString: value) ? null : 'Invalid UUID';
}

String? validateUrl(String value) {
  final uri = Uri.tryParse(value);
  if (uri == null || (!uri.isAbsolute)) {
    return 'Please enter a valid URL';
  }
  return null;
}

String? validateRequired(String value) {
  return value.trim().isEmpty ? 'This field is required' : null;
}

String? validatePassword(String value) {
  if (value.isEmpty) {
    return null;
  }

  if (value.length < 8) {
    return 'Password must be at least 8 characters long';
  }

  if (!RegExp(r'[A-Z]').hasMatch(value)) {
    return 'Password must contain at least one uppercase letter';
  }

  if (!RegExp(r'[a-z]').hasMatch(value)) {
    return 'Password must contain at least one lowercase letter';
  }

  if (!RegExp(r'[0-9]').hasMatch(value)) {
    return 'Password must contain at least one digit';
  }

  if (!RegExp(r'[!@#\$&*~]').hasMatch(value)) {
    return 'Password must contain at least one special character (!@#\$&*~)';
  }

  return null;
}
