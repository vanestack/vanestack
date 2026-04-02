import 'dart:convert';

sealed class VaneStackErrorCode {
  const VaneStackErrorCode();
  String get value;
}

enum AuthErrorCode implements VaneStackErrorCode {
  // Sign-in / registration
  invalidCredentials('auth.invalid_credentials'),
  userNotRegisteredWithPassword('auth.user_not_registered_with_password'),
  weakPassword('auth.weak_password'),
  invalidEmail('auth.invalid_email'),

  // Tokens
  userNotFound('auth.user_not_found'),
  missingRefreshToken('auth.missing_refresh_token'),
  invalidRefreshToken('auth.invalid_refresh_token'),
  expiredRefreshToken('auth.expired_refresh_token'),
  missingAccessToken('auth.missing_access_token'),
  invalidAccessToken('auth.invalid_access_token'),

  // OTP
  invalidOtp('auth.invalid_otp'),
  expiredOtp('auth.expired_otp'),

  // Password reset
  invalidResetToken('auth.invalid_reset_token'),
  expiredResetToken('auth.expired_reset_token'),
  samePassword('auth.same_password'),

  // OAuth / ID token
  providerNotConfigured('auth.provider_not_configured'),
  providerDisabled('auth.provider_disabled'),
  emailNotVerified('auth.email_not_verified'),
  emailNotProvided('auth.email_not_provided'),
  invalidRedirectUrl('auth.invalid_redirect_url'),
  invalidState('auth.invalid_state'),
  tokenExpired('auth.token_expired'),
  invalidToken('auth.invalid_token'),
  invalidCode('auth.invalid_code'),
  invalidIssuer('auth.invalid_issuer'),
  invalidAudience('auth.invalid_audience'),
  invalidNonce('auth.invalid_nonce'),
  permissionDenied('auth.permission_denied');

  @override
  final String value;
  const AuthErrorCode(this.value);

  static AuthErrorCode? _fromName(String name) {
    for (final code in values) {
      if (code.value.substring(code.value.indexOf('.') + 1) == name) {
        return code;
      }
    }
    return null;
  }
}

enum StorageErrorCode implements VaneStackErrorCode {
  storageNotConfigured('storage.storage_not_configured'),
  multipartDataRequired('storage.multipart_data_required'),
  fileRequired('storage.file_required'),
  bucketNotFound('storage.bucket_not_found'),
  bucketNameRequired('storage.bucket_name_required'),
  invalidBucketName('storage.invalid_bucket_name'),
  fileNotFound('storage.file_not_found'),
  invalidPath('storage.invalid_path'),
  fileTypeNotAllowed('storage.file_type_not_allowed'),
  fileSizeExceeded('storage.file_size_exceeded'),
  invalidMimeType('storage.invalid_mime_type'),
  settingsNotFound('storage.settings_not_found');

  @override
  final String value;
  const StorageErrorCode(this.value);

  static StorageErrorCode? _fromName(String name) {
    for (final code in values) {
      if (code.value.substring(code.value.indexOf('.') + 1) == name) {
        return code;
      }
    }
    return null;
  }
}

enum UsersErrorCode implements VaneStackErrorCode {
  userNotFound('users.user_not_found'),
  invalidEmail('users.invalid_email'),
  invalidUserId('users.invalid_user_id'),
  emailAlreadyExists('users.email_already_exists'),
  weakPassword('users.weak_password');

  @override
  final String value;
  const UsersErrorCode(this.value);

  static UsersErrorCode? _fromName(String name) {
    for (final code in values) {
      if (code.value.substring(code.value.indexOf('.') + 1) == name) {
        return code;
      }
    }
    return null;
  }
}

enum CollectionsErrorCode implements VaneStackErrorCode {
  collectionNotFound('collections.collection_not_found'),
  collectionNameRequired('collections.collection_name_required'),
  invalidCollectionName('collections.invalid_collection_name'),
  collectionAlreadyExists('collections.collection_already_exists'),
  viewIsReadOnly('collections.view_is_read_only'),
  systemColumnOverride('collections.system_column_override'),
  viewQueryRequired('collections.view_query_required'),
  viewQueryMissingId('collections.view_query_missing_id'),
  viewCreationFailed('collections.view_creation_failed'),
  dependentViewsExist('collections.dependent_views_exist'),
  notBaseCollection('collections.not_base_collection'),
  notViewCollection('collections.not_view_collection'),
  exportFailed('collections.export_failed'),
  importFailed('collections.import_failed'),
  validationFailed('collections.validation_failed'),
  indexesNotSupported('collections.indexes_not_supported');

  @override
  final String value;
  const CollectionsErrorCode(this.value);

  static CollectionsErrorCode? _fromName(String name) {
    for (final code in values) {
      if (code.value.substring(code.value.indexOf('.') + 1) == name) {
        return code;
      }
    }
    return null;
  }
}

enum DocumentsErrorCode implements VaneStackErrorCode {
  collectionNotFound('documents.collection_not_found'),
  documentNotFound('documents.document_not_found'),
  validationFailed('documents.validation_failed'),
  viewIsReadOnly('documents.view_is_read_only');

  @override
  final String value;
  const DocumentsErrorCode(this.value);

  static DocumentsErrorCode? _fromName(String name) {
    for (final code in values) {
      if (code.value.substring(code.value.indexOf('.') + 1) == name) {
        return code;
      }
    }
    return null;
  }
}

enum SettingsErrorCode implements VaneStackErrorCode {
  updateFailed('settings.update_failed'),
  s3NotConfigured('settings.s3_not_configured'),
  s3ConnectionFailed('settings.s3_connection_failed'),
  mailerNotConfigured('settings.mailer_not_configured'),
  appleSecretGenerationFailed('settings.apple_secret_generation_failed');

  @override
  final String value;
  const SettingsErrorCode(this.value);

  static SettingsErrorCode? _fromName(String name) {
    for (final code in values) {
      if (code.value.substring(code.value.indexOf('.') + 1) == name) {
        return code;
      }
    }
    return null;
  }
}

enum ClientErrorCode implements VaneStackErrorCode {
  emptyResponseBody('client.empty_response_body'),
  unknownError('client.unknown_error');

  @override
  final String value;
  const ClientErrorCode(this.value);

  static ClientErrorCode? _fromName(String name) {
    for (final code in values) {
      if (code.value.substring(code.value.indexOf('.') + 1) == name) {
        return code;
      }
    }
    return null;
  }
}

enum ServerErrorCode implements VaneStackErrorCode {
  unknownError('server.unknown_error'),
  hookCancelled('server.hook_cancelled');

  @override
  final String value;
  const ServerErrorCode(this.value);

  static ServerErrorCode? _fromName(String name) {
    for (final code in values) {
      if (code.value.substring(code.value.indexOf('.') + 1) == name) {
        return code;
      }
    }
    return null;
  }
}

class VaneStackException implements Exception {
  final String message;
  final int status;
  final VaneStackErrorCode code;

  VaneStackException(this.message, {this.status = 500, required this.code});

  Map<String, Object> toJson() {
    return {
      'error': {
        'message': message,
        if (code case VaneStackErrorCode code) 'code': code.value,
      },
    };
  }

  static VaneStackException fromJson(int status, String? json) {
    if (json == null || json.isEmpty) {
      return VaneStackException(
        'Unknown error',
        status: status,
        code: ClientErrorCode.unknownError,
      );
    }

    final data = jsonDecode(json);
    if (data case {'error': Map<String, Object?> error}) {
      return VaneStackException(
        error['message'] as String? ?? 'Unknown error',
        status: status,
        code:
            _parseCode(error['code'] as String?) ??
            ClientErrorCode.unknownError,
      );
    }

    return VaneStackException(
      'Unknown error',
      status: status,
      code: ClientErrorCode.unknownError,
    );
  }

  static VaneStackErrorCode? _parseCode(String? raw) {
    if (raw == null) return null;
    final dot = raw.indexOf('.');
    if (dot == -1) return null;
    final prefix = raw.substring(0, dot);
    final name = raw.substring(dot + 1);
    return switch (prefix) {
      'auth' => AuthErrorCode._fromName(name),
      'storage' => StorageErrorCode._fromName(name),
      'users' => UsersErrorCode._fromName(name),
      'collections' => CollectionsErrorCode._fromName(name),
      'documents' => DocumentsErrorCode._fromName(name),
      'settings' => SettingsErrorCode._fromName(name),
      'client' => ClientErrorCode._fromName(name),
      'server' => ServerErrorCode._fromName(name),
      _ => null,
    };
  }

  @override
  String toString() {
    final codeStr = ', code: ${code.value}';
    return 'VaneStackException: $message (status: $status$codeStr)';
  }
}
