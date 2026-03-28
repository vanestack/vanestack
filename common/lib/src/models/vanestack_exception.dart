import 'dart:convert';

class VaneStackException implements Exception {
  final String message;
  final int status;

  VaneStackException(this.message, {this.status = 500});

  Map<String, Object> toJson() {
    return {
      'error': {'message': message},
    };
  }

  static VaneStackException fromJson(int status, String? json) {
    if (json == null || json.isEmpty) {
      return VaneStackException('Unknown error', status: status);
    }

    final data = jsonDecode(json);
    if (data case {'error': {'message': String message}}) {
      return VaneStackException(message, status: status);
    }

    return VaneStackException('Unknown error', status: status);
  }

  @override
  String toString() {
    return 'VaneStackException: $message (status: $status)';
  }
}
