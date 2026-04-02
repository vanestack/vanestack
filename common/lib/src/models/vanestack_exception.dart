import 'dart:convert';

enum ErrorCode {
  missingRefreshToken('missing_refresh_token'),
  invalidRefreshToken('invalid_refresh_token'),
  expiredRefreshToken('expired_refresh_token'),
  userNotFound('user_not_found');

  final String value;
  const ErrorCode(this.value);

  static ErrorCode? fromString(String? value) {
    if (value == null) return null;
    for (final code in values) {
      if (code.value == value) return code;
    }
    return null;
  }
}

class VaneStackException implements Exception {
  final String message;
  final int status;
  final ErrorCode? code;

  VaneStackException(this.message, {this.status = 500, this.code});

  Map<String, Object> toJson() {
    return {
      'error': {
        'message': message,
        if (code case ErrorCode code?) 'code': code.value,
      },
    };
  }

  static VaneStackException fromJson(int status, String? json) {
    if (json == null || json.isEmpty) {
      return VaneStackException('Unknown error', status: status);
    }

    final data = jsonDecode(json);
    if (data case {'error': Map<String, Object?> error}) {
      return VaneStackException(
        error['message'] as String? ?? 'Unknown error',
        status: status,
        code: ErrorCode.fromString(error['code'] as String?),
      );
    }

    return VaneStackException('Unknown error', status: status);
  }

  @override
  String toString() {
    final codeStr = code != null ? ', code: ${code!.value}' : '';
    return 'VaneStackException: $message (status: $status$codeStr)';
  }
}
