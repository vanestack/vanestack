// GENERATED CODE - DO NOT MODIFY BY HAND

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:shelf/shelf.dart' as _i1;
import 'dart:convert' as _i2;
import 'dart:async' as _i3;
import 'dart:io' as _i4;
import 'package:vanestack/src/endpoints/health.dart' as _i5;
import 'package:vanestack/src/endpoints/auth/send_password_reset_email.dart'
    as _i6;
import 'package:vanestack_common/vanestack_common.dart' as _i7;
import 'package:vanestack/src/endpoints/auth/logout.dart' as _i8;
import 'package:vanestack/src/endpoints/auth/refresh.dart' as _i9;
import 'package:vanestack/src/endpoints/auth/reset_password.dart' as _i10;
import 'package:vanestack/src/endpoints/auth/sign_in_with_email_and_password.dart'
    as _i11;
import 'package:vanestack/src/endpoints/auth/sign_in_with_id_token.dart'
    as _i12;
import 'package:vanestack/src/endpoints/auth/sign_in_with_otp.dart' as _i13;
import 'package:vanestack/src/endpoints/auth/user.dart' as _i14;
import 'package:vanestack/src/endpoints/auth/verify_otp.dart' as _i15;
import 'package:vanestack/src/endpoints/storage/buckets/list.dart' as _i16;
import 'package:vanestack/src/endpoints/collections/create.dart' as _i17;
import 'package:vanestack/src/endpoints/collections/list.dart' as _i18;
import 'package:vanestack/src/endpoints/collections/export.dart' as _i19;
import 'package:vanestack/src/endpoints/collections/import.dart' as _i20;
import 'package:vanestack/src/endpoints/logs/list.dart' as _i21;
import 'package:uuid/uuid.dart' as _i22;
import 'package:vanestack/src/endpoints/realtime.dart' as _i23;
import 'package:vanestack/src/handlers/sse.dart' as _i24;
import 'package:vanestack/src/endpoints/settings/get.dart' as _i25;
import 'package:vanestack/src/endpoints/settings/update.dart' as _i26;
import 'package:vanestack/src/endpoints/settings/generate_apple_client_secret.dart'
    as _i27;
import 'package:vanestack/src/endpoints/settings/test_s3.dart' as _i28;
import 'package:vanestack/src/endpoints/stats/stats.dart' as _i29;
import 'package:vanestack/src/endpoints/users/list.dart' as _i30;
import 'package:vanestack/src/endpoints/users/create.dart' as _i31;
import 'package:vanestack/src/endpoints/auth/oauth2.dart' as _i32;
import 'package:vanestack/src/endpoints/auth/oauth2_callback.dart' as _i33;
import 'package:vanestack/src/endpoints/storage/buckets/create.dart' as _i34;
import 'package:vanestack/src/endpoints/storage/buckets/delete.dart' as _i35;
import 'package:vanestack/src/endpoints/storage/buckets/get.dart' as _i36;
import 'package:vanestack/src/endpoints/storage/buckets/update.dart' as _i37;
import 'package:vanestack/src/endpoints/collections/get.dart' as _i38;
import 'package:vanestack/src/endpoints/collections/delete.dart' as _i39;
import 'package:vanestack/src/endpoints/collections/update.dart' as _i40;
import 'package:vanestack/src/endpoints/collections/generate.dart' as _i41;
import 'package:vanestack/src/endpoints/documents/list.dart' as _i42;
import 'package:vanestack/src/endpoints/documents/create.dart' as _i43;
import 'package:vanestack/src/endpoints/documents/get.dart' as _i44;
import 'package:vanestack/src/endpoints/documents/delete.dart' as _i45;
import 'package:vanestack/src/endpoints/documents/update.dart' as _i46;
import 'package:vanestack/src/endpoints/storage/files/list.dart' as _i47;
import 'package:vanestack/src/endpoints/storage/files/delete.dart' as _i48;
import 'package:vanestack/src/endpoints/storage/files/move.dart' as _i49;
import 'package:vanestack/src/endpoints/storage/files/download.dart' as _i50;
import 'package:vanestack/src/endpoints/storage/files/get_download_url.dart'
    as _i51;
import 'package:vanestack/src/endpoints/storage/files/upload.dart' as _i52;
import 'package:vanestack/src/endpoints/users/delete.dart' as _i53;
import 'package:vanestack/src/endpoints/users/get.dart' as _i54;
import 'package:vanestack/src/endpoints/users/update.dart' as _i55;
import 'package:shelf_router/shelf_router.dart' as _i56;
import 'package:vanestack_common/vanestack_common.dart';

extension RequestUtils on _i1.Request {
  Future<Map<String, Object?>> toMap() async {
    final contentType = headers['content-type'] ?? '';
    final body = await readAsString();

    if (body.isEmpty) {
      return {};
    }

    if (contentType.contains('application/json')) {
      final decoded = _i2.jsonDecode(body);
      if (decoded is Map) {
        return Map<String, Object?>.from(decoded);
      } else {
        throw FormatException('JSON body is not an object');
      }
    }

    if (contentType.contains('application/x-www-form-urlencoded')) {
      final formData = Uri.splitQueryString(body);
      return Map<String, Object?>.from(formData);
    }

    // Fallback
    return {};
  }
}

String cleanParam(String pathSegment) {
  // Split by '?' and take the first part
  var parts = pathSegment.split('?');
  var value = parts.first.trim();

  parts = value.split('%3F'); // URL-encoded '?'
  value = parts.first.trim();

  return value;
}

Object? stringToDartType(String value) {
  return switch (value) {
    'null' => null,
    'true' => true,
    'false' => false,
    _ when int.tryParse(value) != null => int.parse(value),
    _ when double.tryParse(value) != null => double.parse(value),
    _ when DateTime.tryParse(value) != null => DateTime.parse(value),
    _ => value,
  };
}

_i3.Future<_i1.Response> catchError(
  Future<_i1.Response> Function() wrapper,
) async {
  try {
    return await wrapper();
  } on VaneStackException catch (e) {
    return _i1.Response(
      e.status,
      body: _i2.jsonEncode(e),
      encoding: _i2.Encoding.getByName('utf-8'),
      headers: {_i4.HttpHeaders.contentTypeHeader: 'application/json'},
    );
  } on _i1.HijackException {
    rethrow;
  } catch (e) {
    return _i1.Response(
      _i4.HttpStatus.internalServerError,
      body: _i2.jsonEncode({
        'error': {'message': e.toString()},
      }),
      encoding: _i2.Encoding.getByName('utf-8'),
      headers: {_i4.HttpHeaders.contentTypeHeader: 'application/json'},
    );
  }
}

_i3.FutureOr<_i1.Response> health0Route(_i1.Request request) async {
  return await _i5.health(request);
}

_i3.FutureOr<_i1.Response> sendPasswordResetEmail1Route(
  _i1.Request request,
) async {
  final body = await request.toMap();
  final email = (body['email'] as String);
  final redirectTo = (body['redirectTo'] as String?);
  await _i6.sendPasswordResetEmail(request, email, redirectTo);
  return _i1.Response(
    _i4.HttpStatus.ok,
    encoding: _i2.Encoding.getByName('utf-8'),
    headers: {_i4.HttpHeaders.contentTypeHeader: 'application/json'},
  );
}

_i3.FutureOr<_i1.Response> logout2Route(_i1.Request request) async {
  final userType = (request.context['userType'] as _i7.UserType);
  if (userType == _i7.UserType.guest) {
    return _i1.Response(
      _i4.HttpStatus.forbidden,
      body: _i2.jsonEncode({
        'error': {'message': 'Authentication required.'},
      }),
      encoding: _i2.Encoding.getByName('utf-8'),
      headers: {_i4.HttpHeaders.contentTypeHeader: 'application/json'},
    );
  }
  await _i8.logout(request);
  return _i1.Response(
    _i4.HttpStatus.ok,
    encoding: _i2.Encoding.getByName('utf-8'),
    headers: {_i4.HttpHeaders.contentTypeHeader: 'application/json'},
  );
}

_i3.FutureOr<_i1.Response> refresh3Route(_i1.Request request) async {
  final result = await _i9.refresh(request);
  return _i1.Response(
    _i4.HttpStatus.ok,
    body: _i2.jsonEncode(result),
    encoding: _i2.Encoding.getByName('utf-8'),
    headers: {_i4.HttpHeaders.contentTypeHeader: 'application/json'},
  );
}

_i3.FutureOr<_i1.Response> resetPassword4Route(_i1.Request request) async {
  final body = await request.toMap();
  final token = (body['token'] as String);
  final newPassword = (body['newPassword'] as String);
  await _i10.resetPassword(request, token, newPassword);
  return _i1.Response(
    _i4.HttpStatus.ok,
    encoding: _i2.Encoding.getByName('utf-8'),
    headers: {_i4.HttpHeaders.contentTypeHeader: 'application/json'},
  );
}

_i3.FutureOr<_i1.Response> signInWithEmailAndPassword5Route(
  _i1.Request request,
) async {
  final body = await request.toMap();
  final email = (body['email'] as String);
  final password = (body['password'] as String);
  final result = await _i11.signInWithEmailAndPassword(
    request,
    email,
    password,
  );
  return _i1.Response(
    _i4.HttpStatus.ok,
    body: _i2.jsonEncode(result),
    encoding: _i2.Encoding.getByName('utf-8'),
    headers: {_i4.HttpHeaders.contentTypeHeader: 'application/json'},
  );
}

_i3.FutureOr<_i1.Response> signInWithIdToken6Route(_i1.Request request) async {
  final body = await request.toMap();
  final provider = IdTokenAuthProvider.values.byName(
    (body['provider'] as String),
  );
  final idToken = (body['idToken'] as String);
  final nonce = (body['nonce'] as String?);
  final result = await _i12.signInWithIdToken(
    request,
    provider,
    idToken,
    nonce,
  );
  return _i1.Response(
    _i4.HttpStatus.ok,
    body: _i2.jsonEncode(result),
    encoding: _i2.Encoding.getByName('utf-8'),
    headers: {_i4.HttpHeaders.contentTypeHeader: 'application/json'},
  );
}

_i3.FutureOr<_i1.Response> signInWithOtp7Route(_i1.Request request) async {
  final body = await request.toMap();
  final email = (body['email'] as String);
  await _i13.signInWithOtp(request, email);
  return _i1.Response(
    _i4.HttpStatus.ok,
    encoding: _i2.Encoding.getByName('utf-8'),
    headers: {_i4.HttpHeaders.contentTypeHeader: 'application/json'},
  );
}

_i3.FutureOr<_i1.Response> user8Route(_i1.Request request) async {
  final userType = (request.context['userType'] as _i7.UserType);
  if (userType == _i7.UserType.guest) {
    return _i1.Response(
      _i4.HttpStatus.forbidden,
      body: _i2.jsonEncode({
        'error': {'message': 'Authentication required.'},
      }),
      encoding: _i2.Encoding.getByName('utf-8'),
      headers: {_i4.HttpHeaders.contentTypeHeader: 'application/json'},
    );
  }
  final result = await _i14.user(request);
  return _i1.Response(
    _i4.HttpStatus.ok,
    body: _i2.jsonEncode(result),
    encoding: _i2.Encoding.getByName('utf-8'),
    headers: {_i4.HttpHeaders.contentTypeHeader: 'application/json'},
  );
}

_i3.FutureOr<_i1.Response> verifyOtp9Route(_i1.Request request) async {
  final body = await request.toMap();
  final email = (body['email'] as String);
  final otp = (body['otp'] as String);
  final result = await _i15.verifyOtp(request, email, otp);
  return _i1.Response(
    _i4.HttpStatus.ok,
    body: _i2.jsonEncode(result),
    encoding: _i2.Encoding.getByName('utf-8'),
    headers: {_i4.HttpHeaders.contentTypeHeader: 'application/json'},
  );
}

_i3.FutureOr<_i1.Response> list10Route(_i1.Request request) async {
  final userType = (request.context['userType'] as _i7.UserType);
  if (userType != _i7.UserType.admin) {
    return _i1.Response(
      _i4.HttpStatus.forbidden,
      body: _i2.jsonEncode({
        'error': {'message': 'Admin privileges required.'},
      }),
      encoding: _i2.Encoding.getByName('utf-8'),
      headers: {_i4.HttpHeaders.contentTypeHeader: 'application/json'},
    );
  }
  final result = await _i16.list(request);
  return _i1.Response(
    _i4.HttpStatus.ok,
    body: _i2.jsonEncode(result),
    encoding: _i2.Encoding.getByName('utf-8'),
    headers: {_i4.HttpHeaders.contentTypeHeader: 'application/json'},
  );
}

_i3.FutureOr<_i1.Response> create11Route(_i1.Request request) async {
  final userType = (request.context['userType'] as _i7.UserType);
  if (userType != _i7.UserType.admin) {
    return _i1.Response(
      _i4.HttpStatus.forbidden,
      body: _i2.jsonEncode({
        'error': {'message': 'Admin privileges required.'},
      }),
      encoding: _i2.Encoding.getByName('utf-8'),
      headers: {_i4.HttpHeaders.contentTypeHeader: 'application/json'},
    );
  }
  final body = await request.toMap();
  final name = (body['name'] as String);
  final listRule = (body['listRule'] as String?);
  final viewRule = (body['viewRule'] as String?);
  final createRule = (body['createRule'] as String?);
  final updateRule = (body['updateRule'] as String?);
  final deleteRule = (body['deleteRule'] as String?);
  final viewQuery = (body['viewQuery'] as String?);
  final type = (body['type'] as String?);
  final attributes = (body['attributes'] as List?) == null
      ? null
      : List<Attribute>.from(
          (body['attributes'] as List).map((e) => AttributeMapper.fromJson(e)),
        );
  final indexes = (body['indexes'] as List?) == null
      ? null
      : List<Index>.from(
          (body['indexes'] as List).map((e) => IndexMapper.fromJson(e)),
        );
  final result = await _i17.create(
    request,
    name,
    listRule,
    viewRule,
    createRule,
    updateRule,
    deleteRule,
    viewQuery,
    type,
    attributes,
    indexes,
  );
  return _i1.Response(
    _i4.HttpStatus.ok,
    body: _i2.jsonEncode(result),
    encoding: _i2.Encoding.getByName('utf-8'),
    headers: {_i4.HttpHeaders.contentTypeHeader: 'application/json'},
  );
}

_i3.FutureOr<_i1.Response> list12Route(_i1.Request request) async {
  final userType = (request.context['userType'] as _i7.UserType);
  if (userType != _i7.UserType.admin) {
    return _i1.Response(
      _i4.HttpStatus.forbidden,
      body: _i2.jsonEncode({
        'error': {'message': 'Admin privileges required.'},
      }),
      encoding: _i2.Encoding.getByName('utf-8'),
      headers: {_i4.HttpHeaders.contentTypeHeader: 'application/json'},
    );
  }
  final body = request.url.queryParameters.map(
    (k, v) => MapEntry(k, stringToDartType(v)),
  );

  final limit = (body['limit'] as int?);
  final offset = (body['offset'] as int?);
  final result = await _i18.list(request, limit, offset);
  return _i1.Response(
    _i4.HttpStatus.ok,
    body: _i2.jsonEncode(result),
    encoding: _i2.Encoding.getByName('utf-8'),
    headers: {_i4.HttpHeaders.contentTypeHeader: 'application/json'},
  );
}

_i3.FutureOr<_i1.Response> export13Route(_i1.Request request) async {
  final userType = (request.context['userType'] as _i7.UserType);
  if (userType != _i7.UserType.admin) {
    return _i1.Response(
      _i4.HttpStatus.forbidden,
      body: _i2.jsonEncode({
        'error': {'message': 'Admin privileges required.'},
      }),
      encoding: _i2.Encoding.getByName('utf-8'),
      headers: {_i4.HttpHeaders.contentTypeHeader: 'application/json'},
    );
  }
  final result = await _i19.export(request);
  return _i1.Response(
    _i4.HttpStatus.ok,
    body: _i2.jsonEncode(result),
    encoding: _i2.Encoding.getByName('utf-8'),
    headers: {_i4.HttpHeaders.contentTypeHeader: 'application/json'},
  );
}

_i3.FutureOr<_i1.Response> import14Route(_i1.Request request) async {
  final userType = (request.context['userType'] as _i7.UserType);
  if (userType != _i7.UserType.admin) {
    return _i1.Response(
      _i4.HttpStatus.forbidden,
      body: _i2.jsonEncode({
        'error': {'message': 'Admin privileges required.'},
      }),
      encoding: _i2.Encoding.getByName('utf-8'),
      headers: {_i4.HttpHeaders.contentTypeHeader: 'application/json'},
    );
  }
  final body = await request.toMap();
  final collections = List<Map<String, dynamic>>.from(
    (body['collections'] as List),
  );
  final overwrite = (body['overwrite'] as bool);
  final result = await _i20.import(request, collections, overwrite);
  return _i1.Response(
    _i4.HttpStatus.ok,
    body: _i2.jsonEncode(result),
    encoding: _i2.Encoding.getByName('utf-8'),
    headers: {_i4.HttpHeaders.contentTypeHeader: 'application/json'},
  );
}

_i3.FutureOr<_i1.Response> list15Route(_i1.Request request) async {
  final userType = (request.context['userType'] as _i7.UserType);
  if (userType != _i7.UserType.admin) {
    return _i1.Response(
      _i4.HttpStatus.forbidden,
      body: _i2.jsonEncode({
        'error': {'message': 'Admin privileges required.'},
      }),
      encoding: _i2.Encoding.getByName('utf-8'),
      headers: {_i4.HttpHeaders.contentTypeHeader: 'application/json'},
    );
  }
  final body = request.url.queryParameters.map(
    (k, v) => MapEntry(k, stringToDartType(v)),
  );

  final orderBy = (body['orderBy'] as String?);
  final filter = (body['filter'] as String?);
  final limit = (body['limit'] as int?);
  final offset = (body['offset'] as int?);
  final result = await _i21.list(request, orderBy, filter, limit, offset);
  return _i1.Response(
    _i4.HttpStatus.ok,
    body: _i2.jsonEncode(result),
    encoding: _i2.Encoding.getByName('utf-8'),
    headers: {_i4.HttpHeaders.contentTypeHeader: 'application/json'},
  );
}

_i3.FutureOr<_i1.Response> subscribe16Route(_i1.Request request) async {
  final body = request.url.queryParameters.map(
    (k, v) => MapEntry(k, stringToDartType(v)),
  );

  final channels = (body['channels'] as String);
  final sessionId = const _i22.Uuid().v7();
  final result = _i23.subscribe(request, sessionId, channels);
  return _i24.sseHandler(request, sessionId, result);
}

_i3.FutureOr<_i1.Response> get17Route(_i1.Request request) async {
  final userType = (request.context['userType'] as _i7.UserType);
  if (userType != _i7.UserType.admin) {
    return _i1.Response(
      _i4.HttpStatus.forbidden,
      body: _i2.jsonEncode({
        'error': {'message': 'Admin privileges required.'},
      }),
      encoding: _i2.Encoding.getByName('utf-8'),
      headers: {_i4.HttpHeaders.contentTypeHeader: 'application/json'},
    );
  }
  final result = await _i25.get(request);
  return _i1.Response(
    _i4.HttpStatus.ok,
    body: _i2.jsonEncode(result),
    encoding: _i2.Encoding.getByName('utf-8'),
    headers: {_i4.HttpHeaders.contentTypeHeader: 'application/json'},
  );
}

_i3.FutureOr<_i1.Response> update18Route(_i1.Request request) async {
  final userType = (request.context['userType'] as _i7.UserType);
  if (userType != _i7.UserType.admin) {
    return _i1.Response(
      _i4.HttpStatus.forbidden,
      body: _i2.jsonEncode({
        'error': {'message': 'Admin privileges required.'},
      }),
      encoding: _i2.Encoding.getByName('utf-8'),
      headers: {_i4.HttpHeaders.contentTypeHeader: 'application/json'},
    );
  }
  final body = await request.toMap();
  final appName = (body['appName'] as String?);
  final siteUrl = (body['siteUrl'] as String?);
  final redirectUrls = (body['redirectUrls'] as List?) == null
      ? null
      : List<String>.from((body['redirectUrls'] as List));
  final s3 = (body['s3'] as Map<String, dynamic>?) == null
      ? null
      : S3SettingsMapper.fromJson((body['s3'] as Map<String, dynamic>));
  final mail = (body['mail'] as Map<String, dynamic>?) == null
      ? null
      : MailSettingsMapper.fromJson((body['mail'] as Map<String, dynamic>));
  final oauthProviders =
      (body['oauthProviders'] as Map<String, dynamic>?) == null
      ? null
      : OAuthProviderListMapper.fromJson(
          (body['oauthProviders'] as Map<String, dynamic>),
        );
  final result = await _i26.update(
    request,
    appName,
    siteUrl,
    redirectUrls,
    s3,
    mail,
    oauthProviders,
  );
  return _i1.Response(
    _i4.HttpStatus.ok,
    body: _i2.jsonEncode(result),
    encoding: _i2.Encoding.getByName('utf-8'),
    headers: {_i4.HttpHeaders.contentTypeHeader: 'application/json'},
  );
}

_i3.FutureOr<_i1.Response> generateAppleClientSecret19Route(
  _i1.Request request,
) async {
  final userType = (request.context['userType'] as _i7.UserType);
  if (userType != _i7.UserType.admin) {
    return _i1.Response(
      _i4.HttpStatus.forbidden,
      body: _i2.jsonEncode({
        'error': {'message': 'Admin privileges required.'},
      }),
      encoding: _i2.Encoding.getByName('utf-8'),
      headers: {_i4.HttpHeaders.contentTypeHeader: 'application/json'},
    );
  }
  final body = await request.toMap();
  final clientId = (body['clientId'] as String);
  final teamId = (body['teamId'] as String);
  final keyId = (body['keyId'] as String);
  final privateKey = (body['privateKey'] as String);
  final duration = (body['duration'] as int);
  final result = await _i27.generateAppleClientSecret(
    request,
    clientId,
    teamId,
    keyId,
    privateKey,
    duration,
  );
  return _i1.Response(
    _i4.HttpStatus.ok,
    body: result,
    encoding: _i2.Encoding.getByName('utf-8'),
    headers: {_i4.HttpHeaders.contentTypeHeader: 'application/json'},
  );
}

_i3.FutureOr<_i1.Response> testS3Connection20Route(_i1.Request request) async {
  final userType = (request.context['userType'] as _i7.UserType);
  if (userType != _i7.UserType.admin) {
    return _i1.Response(
      _i4.HttpStatus.forbidden,
      body: _i2.jsonEncode({
        'error': {'message': 'Admin privileges required.'},
      }),
      encoding: _i2.Encoding.getByName('utf-8'),
      headers: {_i4.HttpHeaders.contentTypeHeader: 'application/json'},
    );
  }
  await _i28.testS3Connection(request);
  return _i1.Response(
    _i4.HttpStatus.ok,
    encoding: _i2.Encoding.getByName('utf-8'),
    headers: {_i4.HttpHeaders.contentTypeHeader: 'application/json'},
  );
}

_i3.FutureOr<_i1.Response> stats21Route(_i1.Request request) async {
  final userType = (request.context['userType'] as _i7.UserType);
  if (userType != _i7.UserType.admin) {
    return _i1.Response(
      _i4.HttpStatus.forbidden,
      body: _i2.jsonEncode({
        'error': {'message': 'Admin privileges required.'},
      }),
      encoding: _i2.Encoding.getByName('utf-8'),
      headers: {_i4.HttpHeaders.contentTypeHeader: 'application/json'},
    );
  }
  final result = await _i29.stats(request);
  return _i1.Response(
    _i4.HttpStatus.ok,
    body: _i2.jsonEncode(result),
    encoding: _i2.Encoding.getByName('utf-8'),
    headers: {_i4.HttpHeaders.contentTypeHeader: 'application/json'},
  );
}

_i3.FutureOr<_i1.Response> list22Route(_i1.Request request) async {
  final userType = (request.context['userType'] as _i7.UserType);
  if (userType != _i7.UserType.admin) {
    return _i1.Response(
      _i4.HttpStatus.forbidden,
      body: _i2.jsonEncode({
        'error': {'message': 'Admin privileges required.'},
      }),
      encoding: _i2.Encoding.getByName('utf-8'),
      headers: {_i4.HttpHeaders.contentTypeHeader: 'application/json'},
    );
  }
  final body = request.url.queryParameters.map(
    (k, v) => MapEntry(k, stringToDartType(v)),
  );

  final orderBy = (body['orderBy'] as String?);
  final filter = (body['filter'] as String?);
  final limit = (body['limit'] as int?);
  final offset = (body['offset'] as int?);
  final result = await _i30.list(request, orderBy, filter, limit, offset);
  return _i1.Response(
    _i4.HttpStatus.ok,
    body: _i2.jsonEncode(result),
    encoding: _i2.Encoding.getByName('utf-8'),
    headers: {_i4.HttpHeaders.contentTypeHeader: 'application/json'},
  );
}

_i3.FutureOr<_i1.Response> create23Route(_i1.Request request) async {
  final userType = (request.context['userType'] as _i7.UserType);
  if (userType != _i7.UserType.admin) {
    return _i1.Response(
      _i4.HttpStatus.forbidden,
      body: _i2.jsonEncode({
        'error': {'message': 'Admin privileges required.'},
      }),
      encoding: _i2.Encoding.getByName('utf-8'),
      headers: {_i4.HttpHeaders.contentTypeHeader: 'application/json'},
    );
  }
  final body = await request.toMap();
  final id = (body['id'] as String?);
  final password = (body['password'] as String?);
  final name = (body['name'] as String?);
  final email = (body['email'] as String);
  final superUser = (body['superUser'] as bool);
  final result = await _i31.create(
    request,
    id,
    password,
    name,
    email,
    superUser,
  );
  return _i1.Response(
    _i4.HttpStatus.ok,
    body: _i2.jsonEncode(result),
    encoding: _i2.Encoding.getByName('utf-8'),
    headers: {_i4.HttpHeaders.contentTypeHeader: 'application/json'},
  );
}

_i3.FutureOr<_i1.Response> oauth224Route(
  _i1.Request request,
  String provider,
) async {
  final body = await request.toMap();
  final redirectUrl = (body['redirectUrl'] as String?);
  final result = await _i32.oauth2(request, cleanParam(provider), redirectUrl);
  return _i1.Response(
    _i4.HttpStatus.ok,
    body: result,
    encoding: _i2.Encoding.getByName('utf-8'),
    headers: {_i4.HttpHeaders.contentTypeHeader: 'application/json'},
  );
}

_i3.FutureOr<_i1.Response> oauth2Callback25Route(
  _i1.Request request,
  String provider,
) async {
  return await _i33.oauth2Callback(request, cleanParam(provider));
}

_i3.FutureOr<_i1.Response> oauth2CallbackPost26Route(
  _i1.Request request,
  String provider,
) async {
  return await _i33.oauth2CallbackPost(request, cleanParam(provider));
}

_i3.FutureOr<_i1.Response> create27Route(
  _i1.Request request,
  String bucket,
) async {
  final userType = (request.context['userType'] as _i7.UserType);
  if (userType != _i7.UserType.admin) {
    return _i1.Response(
      _i4.HttpStatus.forbidden,
      body: _i2.jsonEncode({
        'error': {'message': 'Admin privileges required.'},
      }),
      encoding: _i2.Encoding.getByName('utf-8'),
      headers: {_i4.HttpHeaders.contentTypeHeader: 'application/json'},
    );
  }
  final body = await request.toMap();
  final listRule = (body['listRule'] as String?);
  final viewRule = (body['viewRule'] as String?);
  final createRule = (body['createRule'] as String?);
  final updateRule = (body['updateRule'] as String?);
  final deleteRule = (body['deleteRule'] as String?);
  final result = await _i34.create(
    request,
    cleanParam(bucket),
    listRule,
    viewRule,
    createRule,
    updateRule,
    deleteRule,
  );
  return _i1.Response(
    _i4.HttpStatus.ok,
    body: _i2.jsonEncode(result),
    encoding: _i2.Encoding.getByName('utf-8'),
    headers: {_i4.HttpHeaders.contentTypeHeader: 'application/json'},
  );
}

_i3.FutureOr<_i1.Response> delete28Route(
  _i1.Request request,
  String bucket,
) async {
  final userType = (request.context['userType'] as _i7.UserType);
  if (userType != _i7.UserType.admin) {
    return _i1.Response(
      _i4.HttpStatus.forbidden,
      body: _i2.jsonEncode({
        'error': {'message': 'Admin privileges required.'},
      }),
      encoding: _i2.Encoding.getByName('utf-8'),
      headers: {_i4.HttpHeaders.contentTypeHeader: 'application/json'},
    );
  }
  await _i35.delete(request, cleanParam(bucket));
  return _i1.Response(
    _i4.HttpStatus.ok,
    encoding: _i2.Encoding.getByName('utf-8'),
    headers: {_i4.HttpHeaders.contentTypeHeader: 'application/json'},
  );
}

_i3.FutureOr<_i1.Response> get29Route(
  _i1.Request request,
  String bucket,
) async {
  final userType = (request.context['userType'] as _i7.UserType);
  if (userType != _i7.UserType.admin) {
    return _i1.Response(
      _i4.HttpStatus.forbidden,
      body: _i2.jsonEncode({
        'error': {'message': 'Admin privileges required.'},
      }),
      encoding: _i2.Encoding.getByName('utf-8'),
      headers: {_i4.HttpHeaders.contentTypeHeader: 'application/json'},
    );
  }
  final result = await _i36.get(request, cleanParam(bucket));
  return _i1.Response(
    _i4.HttpStatus.ok,
    body: _i2.jsonEncode(result),
    encoding: _i2.Encoding.getByName('utf-8'),
    headers: {_i4.HttpHeaders.contentTypeHeader: 'application/json'},
  );
}

_i3.FutureOr<_i1.Response> update30Route(
  _i1.Request request,
  String bucket,
) async {
  final userType = (request.context['userType'] as _i7.UserType);
  if (userType != _i7.UserType.admin) {
    return _i1.Response(
      _i4.HttpStatus.forbidden,
      body: _i2.jsonEncode({
        'error': {'message': 'Admin privileges required.'},
      }),
      encoding: _i2.Encoding.getByName('utf-8'),
      headers: {_i4.HttpHeaders.contentTypeHeader: 'application/json'},
    );
  }
  final body = await request.toMap();
  final newBucketName = (body['newBucketName'] as String?);
  final listRule = (body['listRule'] as String?);
  final viewRule = (body['viewRule'] as String?);
  final createRule = (body['createRule'] as String?);
  final updateRule = (body['updateRule'] as String?);
  final deleteRule = (body['deleteRule'] as String?);
  final result = await _i37.update(
    request,
    cleanParam(bucket),
    newBucketName,
    listRule,
    viewRule,
    createRule,
    updateRule,
    deleteRule,
  );
  return _i1.Response(
    _i4.HttpStatus.ok,
    body: _i2.jsonEncode(result),
    encoding: _i2.Encoding.getByName('utf-8'),
    headers: {_i4.HttpHeaders.contentTypeHeader: 'application/json'},
  );
}

_i3.FutureOr<_i1.Response> get31Route(
  _i1.Request request,
  String collectionName,
) async {
  final userType = (request.context['userType'] as _i7.UserType);
  if (userType != _i7.UserType.admin) {
    return _i1.Response(
      _i4.HttpStatus.forbidden,
      body: _i2.jsonEncode({
        'error': {'message': 'Admin privileges required.'},
      }),
      encoding: _i2.Encoding.getByName('utf-8'),
      headers: {_i4.HttpHeaders.contentTypeHeader: 'application/json'},
    );
  }
  final result = await _i38.get(request, cleanParam(collectionName));
  return _i1.Response(
    _i4.HttpStatus.ok,
    body: _i2.jsonEncode(result),
    encoding: _i2.Encoding.getByName('utf-8'),
    headers: {_i4.HttpHeaders.contentTypeHeader: 'application/json'},
  );
}

_i3.FutureOr<_i1.Response> delete32Route(
  _i1.Request request,
  String collectionName,
) async {
  final userType = (request.context['userType'] as _i7.UserType);
  if (userType != _i7.UserType.admin) {
    return _i1.Response(
      _i4.HttpStatus.forbidden,
      body: _i2.jsonEncode({
        'error': {'message': 'Admin privileges required.'},
      }),
      encoding: _i2.Encoding.getByName('utf-8'),
      headers: {_i4.HttpHeaders.contentTypeHeader: 'application/json'},
    );
  }
  await _i39.delete(request, cleanParam(collectionName));
  return _i1.Response(
    _i4.HttpStatus.ok,
    encoding: _i2.Encoding.getByName('utf-8'),
    headers: {_i4.HttpHeaders.contentTypeHeader: 'application/json'},
  );
}

_i3.FutureOr<_i1.Response> update33Route(
  _i1.Request request,
  String collectionName,
) async {
  final userType = (request.context['userType'] as _i7.UserType);
  if (userType != _i7.UserType.admin) {
    return _i1.Response(
      _i4.HttpStatus.forbidden,
      body: _i2.jsonEncode({
        'error': {'message': 'Admin privileges required.'},
      }),
      encoding: _i2.Encoding.getByName('utf-8'),
      headers: {_i4.HttpHeaders.contentTypeHeader: 'application/json'},
    );
  }
  final body = await request.toMap();
  final newCollectionName = (body['newCollectionName'] as String?);
  final attributes = (body['attributes'] as List?) == null
      ? null
      : List<Attribute>.from(
          (body['attributes'] as List).map((e) => AttributeMapper.fromJson(e)),
        );
  final indexes = (body['indexes'] as List?) == null
      ? null
      : List<Index>.from(
          (body['indexes'] as List).map((e) => IndexMapper.fromJson(e)),
        );
  final listRule = (body['listRule'] as String?);
  final viewRule = (body['viewRule'] as String?);
  final createRule = (body['createRule'] as String?);
  final updateRule = (body['updateRule'] as String?);
  final deleteRule = (body['deleteRule'] as String?);
  final viewQuery = (body['viewQuery'] as String?);
  final result = await _i40.update(
    request,
    cleanParam(collectionName),
    newCollectionName,
    attributes,
    indexes,
    listRule,
    viewRule,
    createRule,
    updateRule,
    deleteRule,
    viewQuery,
  );
  return _i1.Response(
    _i4.HttpStatus.ok,
    body: _i2.jsonEncode(result),
    encoding: _i2.Encoding.getByName('utf-8'),
    headers: {_i4.HttpHeaders.contentTypeHeader: 'application/json'},
  );
}

_i3.FutureOr<_i1.Response> generate34Route(
  _i1.Request request,
  String collectionName,
) async {
  final userType = (request.context['userType'] as _i7.UserType);
  if (userType != _i7.UserType.admin) {
    return _i1.Response(
      _i4.HttpStatus.forbidden,
      body: _i2.jsonEncode({
        'error': {'message': 'Admin privileges required.'},
      }),
      encoding: _i2.Encoding.getByName('utf-8'),
      headers: {_i4.HttpHeaders.contentTypeHeader: 'application/json'},
    );
  }
  final body = await request.toMap();
  final count = (body['count'] as int);
  final result = await _i41.generate(
    request,
    cleanParam(collectionName),
    count,
  );
  return _i1.Response(
    _i4.HttpStatus.ok,
    body: _i2.jsonEncode(result),
    encoding: _i2.Encoding.getByName('utf-8'),
    headers: {_i4.HttpHeaders.contentTypeHeader: 'application/json'},
  );
}

_i3.FutureOr<_i1.Response> list35Route(
  _i1.Request request,
  String collectionName,
) async {
  final body = request.url.queryParameters.map(
    (k, v) => MapEntry(k, stringToDartType(v)),
  );

  final orderBy = (body['orderBy'] as String?);
  final filter = (body['filter'] as String?);
  final limit = (body['limit'] as int?);
  final offset = (body['offset'] as int?);
  final result = await _i42.list(
    request,
    cleanParam(collectionName),
    orderBy,
    filter,
    limit,
    offset,
  );
  return _i1.Response(
    _i4.HttpStatus.ok,
    body: _i2.jsonEncode(result),
    encoding: _i2.Encoding.getByName('utf-8'),
    headers: {_i4.HttpHeaders.contentTypeHeader: 'application/json'},
  );
}

_i3.FutureOr<_i1.Response> create36Route(
  _i1.Request request,
  String collectionName,
) async {
  final body = await request.toMap();
  final data = (body['data'] as Map<String, Object?>);
  final result = await _i43.create(request, cleanParam(collectionName), data);
  return _i1.Response(
    _i4.HttpStatus.ok,
    body: _i2.jsonEncode(result),
    encoding: _i2.Encoding.getByName('utf-8'),
    headers: {_i4.HttpHeaders.contentTypeHeader: 'application/json'},
  );
}

_i3.FutureOr<_i1.Response> get37Route(
  _i1.Request request,
  String collectionName,
  String documentId,
) async {
  final result = await _i44.get(
    request,
    cleanParam(collectionName),
    cleanParam(documentId),
  );
  return _i1.Response(
    _i4.HttpStatus.ok,
    body: _i2.jsonEncode(result),
    encoding: _i2.Encoding.getByName('utf-8'),
    headers: {_i4.HttpHeaders.contentTypeHeader: 'application/json'},
  );
}

_i3.FutureOr<_i1.Response> delete38Route(
  _i1.Request request,
  String collectionName,
  String documentId,
) async {
  await _i45.delete(
    request,
    cleanParam(collectionName),
    cleanParam(documentId),
  );
  return _i1.Response(
    _i4.HttpStatus.ok,
    encoding: _i2.Encoding.getByName('utf-8'),
    headers: {_i4.HttpHeaders.contentTypeHeader: 'application/json'},
  );
}

_i3.FutureOr<_i1.Response> update39Route(
  _i1.Request request,
  String collectionName,
  String documentId,
) async {
  final body = await request.toMap();
  final data = (body['data'] as Map<String, Object?>);
  final result = await _i46.update(
    request,
    cleanParam(collectionName),
    cleanParam(documentId),
    data,
  );
  return _i1.Response(
    _i4.HttpStatus.ok,
    body: _i2.jsonEncode(result),
    encoding: _i2.Encoding.getByName('utf-8'),
    headers: {_i4.HttpHeaders.contentTypeHeader: 'application/json'},
  );
}

_i3.FutureOr<_i1.Response> list40Route(
  _i1.Request request,
  String bucket,
) async {
  final body = request.url.queryParameters.map(
    (k, v) => MapEntry(k, stringToDartType(v)),
  );

  final path = (body['path'] as String?);
  final orderBy = (body['orderBy'] as String?);
  final filter = (body['filter'] as String?);
  final limit = (body['limit'] as int?);
  final offset = (body['offset'] as int?);
  final result = await _i47.list(
    request,
    cleanParam(bucket),
    path,
    orderBy,
    filter,
    limit,
    offset,
  );
  return _i1.Response(
    _i4.HttpStatus.ok,
    body: _i2.jsonEncode(result),
    encoding: _i2.Encoding.getByName('utf-8'),
    headers: {_i4.HttpHeaders.contentTypeHeader: 'application/json'},
  );
}

_i3.FutureOr<_i1.Response> delete41Route(
  _i1.Request request,
  String bucket,
) async {
  final body = request.url.queryParameters.map(
    (k, v) => MapEntry(k, stringToDartType(v)),
  );

  final path = (body['path'] as String);
  await _i48.delete(request, cleanParam(bucket), path);
  return _i1.Response(
    _i4.HttpStatus.ok,
    encoding: _i2.Encoding.getByName('utf-8'),
    headers: {_i4.HttpHeaders.contentTypeHeader: 'application/json'},
  );
}

_i3.FutureOr<_i1.Response> move42Route(
  _i1.Request request,
  String bucket,
  String fileId,
) async {
  final body = await request.toMap();
  final destination = (body['destination'] as String);
  final result = await _i49.move(
    request,
    cleanParam(bucket),
    cleanParam(fileId),
    destination,
  );
  return _i1.Response(
    _i4.HttpStatus.ok,
    body: _i2.jsonEncode(result),
    encoding: _i2.Encoding.getByName('utf-8'),
    headers: {_i4.HttpHeaders.contentTypeHeader: 'application/json'},
  );
}

_i3.FutureOr<_i1.Response> download43Route(
  _i1.Request request,
  String bucket,
  String fileId,
) async {
  final body = request.url.queryParameters.map(
    (k, v) => MapEntry(k, stringToDartType(v)),
  );

  final token = (body['token'] as String?);
  final result = await _i50.download(
    request,
    cleanParam(bucket),
    cleanParam(fileId),
    token,
  );
  return _i1.Response(
    _i4.HttpStatus.ok,
    body: result.stream,
    headers: {
      _i4.HttpHeaders.contentTypeHeader: result.mimeType,
      _i4.HttpHeaders.contentLengthHeader: result.size.toString(),
      _i4.HttpHeaders.contentDisposition:
          'attachment; filename="${result.fileName}"',
    },
  );
}

_i3.FutureOr<_i1.Response> getDownloadUrl44Route(
  _i1.Request request,
  String bucket,
  String fileId,
) async {
  final result = await _i51.getDownloadUrl(
    request,
    cleanParam(bucket),
    cleanParam(fileId),
  );
  return _i1.Response(
    _i4.HttpStatus.ok,
    body: _i2.jsonEncode(result),
    encoding: _i2.Encoding.getByName('utf-8'),
    headers: {_i4.HttpHeaders.contentTypeHeader: 'application/json'},
  );
}

_i3.FutureOr<_i1.Response> upload45Route(
  _i1.Request request,
  String bucket,
) async {
  final result = await _i52.upload(request, cleanParam(bucket));
  return _i1.Response(
    _i4.HttpStatus.ok,
    body: _i2.jsonEncode(result),
    encoding: _i2.Encoding.getByName('utf-8'),
    headers: {_i4.HttpHeaders.contentTypeHeader: 'application/json'},
  );
}

_i3.FutureOr<_i1.Response> delete46Route(
  _i1.Request request,
  String userId,
) async {
  final userType = (request.context['userType'] as _i7.UserType);
  if (userType != _i7.UserType.admin) {
    return _i1.Response(
      _i4.HttpStatus.forbidden,
      body: _i2.jsonEncode({
        'error': {'message': 'Admin privileges required.'},
      }),
      encoding: _i2.Encoding.getByName('utf-8'),
      headers: {_i4.HttpHeaders.contentTypeHeader: 'application/json'},
    );
  }
  await _i53.delete(request, cleanParam(userId));
  return _i1.Response(
    _i4.HttpStatus.ok,
    encoding: _i2.Encoding.getByName('utf-8'),
    headers: {_i4.HttpHeaders.contentTypeHeader: 'application/json'},
  );
}

_i3.FutureOr<_i1.Response> get47Route(
  _i1.Request request,
  String userId,
) async {
  final result = await _i54.get(request, cleanParam(userId));
  return _i1.Response(
    _i4.HttpStatus.ok,
    body: _i2.jsonEncode(result),
    encoding: _i2.Encoding.getByName('utf-8'),
    headers: {_i4.HttpHeaders.contentTypeHeader: 'application/json'},
  );
}

_i3.FutureOr<_i1.Response> update48Route(
  _i1.Request request,
  String userId,
) async {
  final userType = (request.context['userType'] as _i7.UserType);
  if (userType != _i7.UserType.admin) {
    return _i1.Response(
      _i4.HttpStatus.forbidden,
      body: _i2.jsonEncode({
        'error': {'message': 'Admin privileges required.'},
      }),
      encoding: _i2.Encoding.getByName('utf-8'),
      headers: {_i4.HttpHeaders.contentTypeHeader: 'application/json'},
    );
  }
  final body = await request.toMap();
  final email = (body['email'] as String?);
  final password = (body['password'] as String?);
  final name = (body['name'] as String?);
  final superUser = (body['superUser'] as bool?);
  final result = await _i55.update(
    request,
    cleanParam(userId),
    email,
    password,
    name,
    superUser,
  );
  return _i1.Response(
    _i4.HttpStatus.ok,
    body: _i2.jsonEncode(result),
    encoding: _i2.Encoding.getByName('utf-8'),
    headers: {_i4.HttpHeaders.contentTypeHeader: 'application/json'},
  );
}

void registerRoutes(_i56.Router router) {
  router.get(
    '/health',
    (request) => catchError(() async => health0Route(request)),
  );
  router.post(
    '/v1/auth/forgot-password',
    (request) => catchError(() async => sendPasswordResetEmail1Route(request)),
  );
  router.delete(
    '/v1/auth/logout',
    (request) => catchError(() async => logout2Route(request)),
  );
  router.get(
    '/v1/auth/refresh',
    (request) => catchError(() async => refresh3Route(request)),
  );
  router.post(
    '/v1/auth/reset-password',
    (request) => catchError(() async => resetPassword4Route(request)),
  );
  router.post(
    '/v1/auth/sign-in-email-password',
    (request) =>
        catchError(() async => signInWithEmailAndPassword5Route(request)),
  );
  router.post(
    '/v1/auth/sign-in-with-id-token',
    (request) => catchError(() async => signInWithIdToken6Route(request)),
  );
  router.post(
    '/v1/auth/sign-in-with-otp',
    (request) => catchError(() async => signInWithOtp7Route(request)),
  );
  router.get(
    '/v1/auth/user',
    (request) => catchError(() async => user8Route(request)),
  );
  router.post(
    '/v1/auth/verify-otp',
    (request) => catchError(() async => verifyOtp9Route(request)),
  );
  router.get(
    '/v1/buckets',
    (request) => catchError(() async => list10Route(request)),
  );
  router.post(
    '/v1/collections',
    (request) => catchError(() async => create11Route(request)),
  );
  router.get(
    '/v1/collections',
    (request) => catchError(() async => list12Route(request)),
  );
  router.get(
    '/v1/collections/export',
    (request) => catchError(() async => export13Route(request)),
  );
  router.post(
    '/v1/collections/import',
    (request) => catchError(() async => import14Route(request)),
  );
  router.get(
    '/v1/logs',
    (request) => catchError(() async => list15Route(request)),
  );
  router.get(
    '/v1/realtime',
    (request) => catchError(() async => subscribe16Route(request)),
  );
  router.get(
    '/v1/settings',
    (request) => catchError(() async => get17Route(request)),
  );
  router.patch(
    '/v1/settings',
    (request) => catchError(() async => update18Route(request)),
  );
  router.post(
    '/v1/settings/generate-apple-client-secret',
    (request) =>
        catchError(() async => generateAppleClientSecret19Route(request)),
  );
  router.get(
    '/v1/settings/s3',
    (request) => catchError(() async => testS3Connection20Route(request)),
  );
  router.get(
    '/v1/stats',
    (request) => catchError(() async => stats21Route(request)),
  );
  router.get(
    '/v1/users',
    (request) => catchError(() async => list22Route(request)),
  );
  router.post(
    '/v1/users',
    (request) => catchError(() async => create23Route(request)),
  );
  router.post(
    '/v1/auth/oauth2/<provider>',
    (request, provider) =>
        catchError(() async => oauth224Route(request, provider)),
  );
  router.get(
    '/v1/auth/oauth2/<provider>/callback',
    (request, provider) =>
        catchError(() async => oauth2Callback25Route(request, provider)),
  );
  router.post(
    '/v1/auth/oauth2/<provider>/callback',
    (request, provider) =>
        catchError(() async => oauth2CallbackPost26Route(request, provider)),
  );
  router.post(
    '/v1/buckets/<bucket>',
    (request, bucket) => catchError(() async => create27Route(request, bucket)),
  );
  router.delete(
    '/v1/buckets/<bucket>',
    (request, bucket) => catchError(() async => delete28Route(request, bucket)),
  );
  router.get(
    '/v1/buckets/<bucket>',
    (request, bucket) => catchError(() async => get29Route(request, bucket)),
  );
  router.patch(
    '/v1/buckets/<bucket>',
    (request, bucket) => catchError(() async => update30Route(request, bucket)),
  );
  router.get(
    '/v1/collections/<collectionName>',
    (request, collectionName) =>
        catchError(() async => get31Route(request, collectionName)),
  );
  router.delete(
    '/v1/collections/<collectionName>',
    (request, collectionName) =>
        catchError(() async => delete32Route(request, collectionName)),
  );
  router.patch(
    '/v1/collections/<collectionName>',
    (request, collectionName) =>
        catchError(() async => update33Route(request, collectionName)),
  );
  router.post(
    '/v1/collections/<collectionName>/generate',
    (request, collectionName) =>
        catchError(() async => generate34Route(request, collectionName)),
  );
  router.get(
    '/v1/documents/<collectionName>',
    (request, collectionName) =>
        catchError(() async => list35Route(request, collectionName)),
  );
  router.post(
    '/v1/documents/<collectionName>',
    (request, collectionName) =>
        catchError(() async => create36Route(request, collectionName)),
  );
  router.get(
    '/v1/documents/<collectionName>/<documentId>',
    (request, collectionName, documentId) =>
        catchError(() async => get37Route(request, collectionName, documentId)),
  );
  router.delete(
    '/v1/documents/<collectionName>/<documentId>',
    (request, collectionName, documentId) => catchError(
      () async => delete38Route(request, collectionName, documentId),
    ),
  );
  router.patch(
    '/v1/documents/<collectionName>/<documentId>',
    (request, collectionName, documentId) => catchError(
      () async => update39Route(request, collectionName, documentId),
    ),
  );
  router.get(
    '/v1/files/<bucket>',
    (request, bucket) => catchError(() async => list40Route(request, bucket)),
  );
  router.delete(
    '/v1/files/<bucket>',
    (request, bucket) => catchError(() async => delete41Route(request, bucket)),
  );
  router.patch(
    '/v1/files/<bucket>/<fileId>',
    (request, bucket, fileId) =>
        catchError(() async => move42Route(request, bucket, fileId)),
  );
  router.get(
    '/v1/files/<bucket>/<fileId>',
    (request, bucket, fileId) =>
        catchError(() async => download43Route(request, bucket, fileId)),
  );
  router.get(
    '/v1/files/<bucket>/<fileId>/url',
    (request, bucket, fileId) =>
        catchError(() async => getDownloadUrl44Route(request, bucket, fileId)),
  );
  router.post(
    '/v1/files/<bucket>/upload',
    (request, bucket) => catchError(() async => upload45Route(request, bucket)),
  );
  router.delete(
    '/v1/users/<userId>',
    (request, userId) => catchError(() async => delete46Route(request, userId)),
  );
  router.get(
    '/v1/users/<userId>',
    (request, userId) => catchError(() async => get47Route(request, userId)),
  );
  router.patch(
    '/v1/users/<userId>',
    (request, userId) => catchError(() async => update48Route(request, userId)),
  );
}
