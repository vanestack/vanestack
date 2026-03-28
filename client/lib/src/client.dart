// GENERATED CODE - DO NOT MODIFY BY HAND

import 'dart:async';
import 'dart:convert';
import 'dart:math' as math;
import 'dart:typed_data';
import 'package:http/http.dart';
import 'package:http/retry.dart';
import 'package:sse_channel/sse_channel.dart';
import 'package:vanestack_common/vanestack_common.dart';
import 'auth_storage.dart';
import 'realtime_channels.dart';
import 'replay_last_stream.dart';

class VaneStackClient extends BaseClient {
  final String baseUrl;
  final AuthStorage authStorage;
  final Map<String, String> headers = {'Content-Type': 'application/json'};

  final String _accessTokenKey = 'vanestack_access_token';
  final String _refreshTokenKey = 'vanestack_refresh_token';
  final String _userKey = 'vanestack_user';
  final Client _inner;

  late final Client _client;

  final _userController = ReplayLastStream<User?>();

  Stream<User?> get onUserChanges => _userController.stream;

  User? _currentUser;
  String? _accessToken;

  User? get currentUser => _currentUser;

  /// Returns the current access token, or null if not authenticated.
  String? get accessToken => _accessToken;

  VaneStackClient({
    required this.baseUrl,
    required this.authStorage,
    Client? client,
  }) : _inner = client ?? Client() {
    _client = RetryClient(
      this,
      when: (res) => res.statusCode == 503 || res.statusCode == 401,
      onRetry: (req, res, retryCount) async {
        if (res?.statusCode == 401) {
          headers.remove('Authorization');
          await authStorage.delete(_accessTokenKey);

          final refreshResponse = await auth.refresh();

          headers['Authorization'] = 'Bearer ${refreshResponse.accessToken}';
          await authStorage.save(_accessTokenKey, refreshResponse.accessToken);
          await authStorage.save(
            _refreshTokenKey,
            refreshResponse.refreshToken,
          );
        }
      },
      delay: (retryCount) => retryCount == 0
          ? Duration(milliseconds: 100)
          : const Duration(milliseconds: 500) * math.pow(1.5, retryCount),
    );
  }

  Future<void> initialize() async {
    final accessToken = await authStorage.read(_accessTokenKey);
    final user = await authStorage.read(_userKey);
    if (accessToken != null && user != null) {
      headers['Authorization'] = 'Bearer $accessToken';
      _accessToken = accessToken;

      final parsedUser = UserMapper.fromJsonString(user);
      _currentUser = parsedUser;
      _userController.add(parsedUser);
    } else {
      _accessToken = null;
      _currentUser = null;
      _userController.add(null);
    }
  }

  Future<void> _saveAuthResponse(AuthResponse response) async {
    headers['Authorization'] = 'Bearer ${response.accessToken}';
    _accessToken = response.accessToken;

    await Future.wait([
      authStorage.save(_accessTokenKey, response.accessToken),
      authStorage.save(_refreshTokenKey, response.refreshToken),
      authStorage.save(_userKey, response.user.toJsonString()),
    ]);

    _currentUser = response.user;
    _userController.add(response.user);
  }

  Future<void> _clearAuthData() async {
    await Future.wait([
      authStorage.delete(_accessTokenKey),
      authStorage.delete(_refreshTokenKey),
      authStorage.delete(_userKey),
    ]);

    headers.remove('Authorization');
    _accessToken = null;
    _currentUser = null;
    _userController.add(null);
  }

  @override
  Future<StreamedResponse> send(
    BaseRequest request, {
    Map<String, String>? headers,
  }) {
    request.headers.addAll(this.headers);
    if (headers != null) {
      request.headers.addAll(headers);
    }
    return _inner.send(request);
  }

  Future<void> dispose() async {
    await _userController.close();
    _inner.close();
    _client.close();
    close();
  }

  late final auth = _AuthRoutes(this);
  late final buckets = _BucketsRoutes(this);
  late final collections = _CollectionsRoutes(this);
  late final logs = _LogsRoutes(this);
  late final realtime = _RealtimeRoutes(this);
  late final settings = _SettingsRoutes(this);
  late final stats = _StatsRoutes(this);
  late final users = _UsersRoutes(this);
  late final documents = _DocumentsRoutes(this);
  late final files = _FilesRoutes(this);
}

class _RealtimeRoutes {
  final VaneStackClient _vanestack;
  _RealtimeRoutes(this._vanestack);

  final Set<String> _subscribedChannels = {};
  SseChannel? _sseChannel;
  StreamController<RealtimeEvent>? _controller;

  /// Subscribes to a channel and returns a filtered stream for that channel.
  Future<(Stream<RealtimeEvent>, void Function())> subscribe({
    required Channel channel,
  }) async {
    final channelString = channel.build();
    _subscribedChannels.add(channelString);
    await _recreateConnection();

    // Filter the shared event stream for just this channel
    final stream = _controller!.stream.where(
      (e) => e.channels.contains(channelString),
    );

    void unsubscribe() {
      _subscribedChannels.remove(channelString);
      _recreateConnection(); // Rebuild SSE connection with remaining channels
    }

    return (stream, unsubscribe);
  }

  /// Recreates the SSE connection to reflect all current subscribed channels.
  Future<void> _recreateConnection() async {
    // Close old connection and controller if they exist
    _sseChannel?.close();
    await _controller?.close();

    if (_subscribedChannels.isEmpty) {
      _sseChannel = null;
      _controller = null;
      return;
    }

    _controller = StreamController<RealtimeEvent>.broadcast();

    final channelsParam = _subscribedChannels.join(',');
    final url = Uri.parse(
      '${_vanestack.baseUrl}/v1/realtime?channels=$channelsParam',
    );

    final sseChannel = SseChannel.connect(
      url.toString(),
      client: _vanestack._client as BaseClient,
    );
    _sseChannel = sseChannel;

    await sseChannel.ready;

    sseChannel.stream.listen(
      (event) {
        if (event.data == null) return;

        try {
          final decoded = jsonDecode(event.data!);
          if (decoded is Map<String, Object?>) {
            final rtEvent = RealtimeEventMapper.fromJson(decoded);
            _controller?.add(rtEvent);
          }
        } catch (e, st) {
          _controller?.addError(e, st);
        }
      },
      onError: (err, stack) {
        _controller?.addError(err, stack);
      },
      onDone: () {
        _controller?.close();
      },
    );
  }
}

class _AuthRoutes {
  final VaneStackClient _vanestack;
  _AuthRoutes(this._vanestack);

  /// Sets the session using a refresh token from an OAuth callback.
  ///
  /// Saves the refresh token and calls the server's refresh endpoint
  /// to get a valid access token and user data.
  Future<AuthResponse> setSession({required String refreshToken}) async {
    await _vanestack.authStorage.save(
      _vanestack._refreshTokenKey,
      refreshToken,
    );
    return refresh();
  }

  Future<void> sendPasswordResetEmail({
    required String email,
    String? redirectTo,
  }) async {
    final url = Uri.parse('${_vanestack.baseUrl}/v1/auth/forgot-password');
    final body = {'email': email, 'redirectTo': redirectTo};
    final response = await _vanestack._client.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(body),
    );
    final result = response.body.isNotEmpty ? response.body : null;
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw VaneStackException.fromJson(response.statusCode, result);
    }
  }

  Future<void> logout() async {
    final url = Uri.parse('${_vanestack.baseUrl}/v1/auth/logout');
    final response = await _vanestack._client.delete(url);
    final result = response.body.isNotEmpty ? response.body : null;
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw VaneStackException.fromJson(response.statusCode, result);
    }
    await _vanestack._clearAuthData();
  }

  Future<AuthResponse> refresh() async {
    final url = Uri.parse('${_vanestack.baseUrl}/v1/auth/refresh');
    final refreshToken = await _vanestack.authStorage.read(
      _vanestack._refreshTokenKey,
    );
    if (refreshToken == null) throw Exception('No refresh token stored');
    final response = await _vanestack._inner.get(
      url,
      headers: {'Authorization': 'Bearer $refreshToken'},
    );
    final result = response.body.isNotEmpty ? response.body : null;
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw VaneStackException.fromJson(response.statusCode, result);
    }
    if (result == null) {
      throw VaneStackException('Empty response body', status: 400);
    }
    final parsed = AuthResponseMapper.fromJsonString(result);
    await _vanestack._saveAuthResponse(parsed);
    return parsed;
  }

  Future<void> resetPassword({
    required String token,
    required String newPassword,
  }) async {
    final url = Uri.parse('${_vanestack.baseUrl}/v1/auth/reset-password');
    final body = {'token': token, 'newPassword': newPassword};
    final response = await _vanestack._client.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(body),
    );
    final result = response.body.isNotEmpty ? response.body : null;
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw VaneStackException.fromJson(response.statusCode, result);
    }
  }

  Future<AuthResponse> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    final url = Uri.parse(
      '${_vanestack.baseUrl}/v1/auth/sign-in-email-password',
    );
    final body = {'email': email, 'password': password};
    final response = await _vanestack._client.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(body),
    );
    final result = response.body.isNotEmpty ? response.body : null;
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw VaneStackException.fromJson(response.statusCode, result);
    }
    if (result == null) {
      throw VaneStackException('Empty response body', status: 400);
    }
    final parsed = AuthResponseMapper.fromJsonString(result);
    await _vanestack._saveAuthResponse(parsed);
    return parsed;
  }

  Future<AuthResponse> signInWithIdToken({
    required IdTokenAuthProvider provider,
    required String idToken,
    String? nonce,
  }) async {
    final url = Uri.parse(
      '${_vanestack.baseUrl}/v1/auth/sign-in-with-id-token',
    );
    final body = {
      'provider': provider.name,
      'idToken': idToken,
      'nonce': nonce,
    };
    final response = await _vanestack._client.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(body),
    );
    final result = response.body.isNotEmpty ? response.body : null;
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw VaneStackException.fromJson(response.statusCode, result);
    }
    if (result == null) {
      throw VaneStackException('Empty response body', status: 400);
    }
    final parsed = AuthResponseMapper.fromJsonString(result);
    await _vanestack._saveAuthResponse(parsed);
    return parsed;
  }

  Future<void> signInWithOtp({required String email}) async {
    final url = Uri.parse('${_vanestack.baseUrl}/v1/auth/sign-in-with-otp');
    final body = {'email': email};
    final response = await _vanestack._client.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(body),
    );
    final result = response.body.isNotEmpty ? response.body : null;
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw VaneStackException.fromJson(response.statusCode, result);
    }
  }

  Future<User> user() async {
    final url = Uri.parse('${_vanestack.baseUrl}/v1/auth/user');
    final response = await _vanestack._client.get(url);
    final result = response.body.isNotEmpty ? response.body : null;
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw VaneStackException.fromJson(response.statusCode, result);
    }
    if (result == null) {
      throw VaneStackException('Empty response body', status: 400);
    }
    final parsed = UserMapper.fromJsonString(result);
    return parsed;
  }

  Future<AuthResponse> verifyOtp({
    required String email,
    required String otp,
  }) async {
    final url = Uri.parse('${_vanestack.baseUrl}/v1/auth/verify-otp');
    final body = {'email': email, 'otp': otp};
    final response = await _vanestack._client.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(body),
    );
    final result = response.body.isNotEmpty ? response.body : null;
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw VaneStackException.fromJson(response.statusCode, result);
    }
    if (result == null) {
      throw VaneStackException('Empty response body', status: 400);
    }
    final parsed = AuthResponseMapper.fromJsonString(result);
    await _vanestack._saveAuthResponse(parsed);
    return parsed;
  }

  Future<String> oauth2({required String provider, String? redirectUrl}) async {
    final endpointPath = '/v1/auth/oauth2/<provider>'.replaceAllMapped(
      RegExp(r'<([^>]+)>'),
      (match) {
        final key = match.group(1)!;
        if (key == 'provider') {
          return Uri.encodeComponent(provider);
        }
        return key;
      },
    );
    final url = Uri.parse('${_vanestack.baseUrl}$endpointPath');
    final body = {'redirectUrl': redirectUrl};
    final response = await _vanestack._client.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(body),
    );
    final result = response.body.isNotEmpty ? response.body : null;
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw VaneStackException.fromJson(response.statusCode, result);
    }
    if (result == null) {
      throw VaneStackException('Empty response body', status: 400);
    }
    final parsed = result;
    return parsed;
  }
}

class _BucketsRoutes {
  final VaneStackClient _vanestack;
  _BucketsRoutes(this._vanestack);
  Future<List<Bucket>> list() async {
    final url = Uri.parse('${_vanestack.baseUrl}/v1/buckets');
    final response = await _vanestack._client.get(url);
    final result = response.body.isNotEmpty ? response.body : null;
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw VaneStackException.fromJson(response.statusCode, result);
    }
    if (result == null) {
      throw VaneStackException('Empty response body', status: 400);
    }
    final parsed = (jsonDecode(result) as List)
        .map((e) => BucketMapper.fromJson(e as Map<String, Object?>))
        .toList();
    return parsed;
  }

  Future<Bucket> create({
    required String bucket,
    String? listRule,
    String? viewRule,
    String? createRule,
    String? updateRule,
    String? deleteRule,
  }) async {
    final endpointPath = '/v1/buckets/<bucket>'.replaceAllMapped(
      RegExp(r'<([^>]+)>'),
      (match) {
        final key = match.group(1)!;
        if (key == 'bucket') {
          return Uri.encodeComponent(bucket);
        }
        return key;
      },
    );
    final url = Uri.parse('${_vanestack.baseUrl}$endpointPath');
    final body = {
      'listRule': listRule,
      'viewRule': viewRule,
      'createRule': createRule,
      'updateRule': updateRule,
      'deleteRule': deleteRule,
    };
    final response = await _vanestack._client.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(body),
    );
    final result = response.body.isNotEmpty ? response.body : null;
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw VaneStackException.fromJson(response.statusCode, result);
    }
    if (result == null) {
      throw VaneStackException('Empty response body', status: 400);
    }
    final parsed = BucketMapper.fromJsonString(result);
    return parsed;
  }

  Future<void> delete({required String bucket}) async {
    final endpointPath = '/v1/buckets/<bucket>'.replaceAllMapped(
      RegExp(r'<([^>]+)>'),
      (match) {
        final key = match.group(1)!;
        if (key == 'bucket') {
          return Uri.encodeComponent(bucket);
        }
        return key;
      },
    );
    final url = Uri.parse('${_vanestack.baseUrl}$endpointPath');
    final response = await _vanestack._client.delete(url);
    final result = response.body.isNotEmpty ? response.body : null;
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw VaneStackException.fromJson(response.statusCode, result);
    }
  }

  Future<Bucket> get({required String bucket}) async {
    final endpointPath = '/v1/buckets/<bucket>'.replaceAllMapped(
      RegExp(r'<([^>]+)>'),
      (match) {
        final key = match.group(1)!;
        if (key == 'bucket') {
          return Uri.encodeComponent(bucket);
        }
        return key;
      },
    );
    final url = Uri.parse('${_vanestack.baseUrl}$endpointPath');
    final response = await _vanestack._client.get(url);
    final result = response.body.isNotEmpty ? response.body : null;
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw VaneStackException.fromJson(response.statusCode, result);
    }
    if (result == null) {
      throw VaneStackException('Empty response body', status: 400);
    }
    final parsed = BucketMapper.fromJsonString(result);
    return parsed;
  }

  Future<Bucket> update({
    required String bucket,
    String? newBucketName,
    String? listRule,
    String? viewRule,
    String? createRule,
    String? updateRule,
    String? deleteRule,
  }) async {
    final endpointPath = '/v1/buckets/<bucket>'.replaceAllMapped(
      RegExp(r'<([^>]+)>'),
      (match) {
        final key = match.group(1)!;
        if (key == 'bucket') {
          return Uri.encodeComponent(bucket);
        }
        return key;
      },
    );
    final url = Uri.parse('${_vanestack.baseUrl}$endpointPath');
    final body = {
      'newBucketName': newBucketName,
      'listRule': listRule,
      'viewRule': viewRule,
      'createRule': createRule,
      'updateRule': updateRule,
      'deleteRule': deleteRule,
    };
    final response = await _vanestack._client.patch(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(body),
    );
    final result = response.body.isNotEmpty ? response.body : null;
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw VaneStackException.fromJson(response.statusCode, result);
    }
    if (result == null) {
      throw VaneStackException('Empty response body', status: 400);
    }
    final parsed = BucketMapper.fromJsonString(result);
    return parsed;
  }
}

class _CollectionsRoutes {
  final VaneStackClient _vanestack;
  _CollectionsRoutes(this._vanestack);
  Future<Collection> create({
    required String name,
    String? listRule,
    String? viewRule,
    String? createRule,
    String? updateRule,
    String? deleteRule,
    String? viewQuery,
    String? type,
    List<Attribute>? attributes,
    List<Index>? indexes,
  }) async {
    final url = Uri.parse('${_vanestack.baseUrl}/v1/collections');
    final body = {
      'name': name,
      'listRule': listRule,
      'viewRule': viewRule,
      'createRule': createRule,
      'updateRule': updateRule,
      'deleteRule': deleteRule,
      'viewQuery': viewQuery,
      'type': type,
      'attributes': attributes,
      'indexes': indexes,
    };
    final response = await _vanestack._client.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(body),
    );
    final result = response.body.isNotEmpty ? response.body : null;
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw VaneStackException.fromJson(response.statusCode, result);
    }
    if (result == null) {
      throw VaneStackException('Empty response body', status: 400);
    }
    final parsed = CollectionMapper.fromJsonString(result);
    return parsed;
  }

  Future<List<Collection>> list({int? limit = 10, int? offset = 0}) async {
    final url = Uri.parse('${_vanestack.baseUrl}/v1/collections');
    final body = {'limit': limit, 'offset': offset};
    final query = body.map((k, v) => MapEntry(k, v.toString()));
    final response = await _vanestack._client.get(
      url.replace(queryParameters: query),
    );
    final result = response.body.isNotEmpty ? response.body : null;
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw VaneStackException.fromJson(response.statusCode, result);
    }
    if (result == null) {
      throw VaneStackException('Empty response body', status: 400);
    }
    final parsed = (jsonDecode(result) as List)
        .map((e) => CollectionMapper.fromJson(e as Map<String, Object?>))
        .toList();
    return parsed;
  }

  Future<ExportResponse> export() async {
    final url = Uri.parse('${_vanestack.baseUrl}/v1/collections/export');
    final response = await _vanestack._client.get(url);
    final result = response.body.isNotEmpty ? response.body : null;
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw VaneStackException.fromJson(response.statusCode, result);
    }
    if (result == null) {
      throw VaneStackException('Empty response body', status: 400);
    }
    final parsed = ExportResponseMapper.fromJsonString(result);
    return parsed;
  }

  Future<ImportResponse> import({
    required List<Map<String, dynamic>> collections,
    bool overwrite = false,
  }) async {
    final url = Uri.parse('${_vanestack.baseUrl}/v1/collections/import');
    final body = {'collections': collections, 'overwrite': overwrite};
    final response = await _vanestack._client.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(body),
    );
    final result = response.body.isNotEmpty ? response.body : null;
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw VaneStackException.fromJson(response.statusCode, result);
    }
    if (result == null) {
      throw VaneStackException('Empty response body', status: 400);
    }
    final parsed = ImportResponseMapper.fromJsonString(result);
    return parsed;
  }

  Future<Collection> get({required String collectionName}) async {
    final endpointPath = '/v1/collections/<collectionName>'.replaceAllMapped(
      RegExp(r'<([^>]+)>'),
      (match) {
        final key = match.group(1)!;
        if (key == 'collectionName') {
          return Uri.encodeComponent(collectionName);
        }
        return key;
      },
    );
    final url = Uri.parse('${_vanestack.baseUrl}$endpointPath');
    final response = await _vanestack._client.get(url);
    final result = response.body.isNotEmpty ? response.body : null;
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw VaneStackException.fromJson(response.statusCode, result);
    }
    if (result == null) {
      throw VaneStackException('Empty response body', status: 400);
    }
    final parsed = CollectionMapper.fromJsonString(result);
    return parsed;
  }

  Future<void> delete({required String collectionName}) async {
    final endpointPath = '/v1/collections/<collectionName>'.replaceAllMapped(
      RegExp(r'<([^>]+)>'),
      (match) {
        final key = match.group(1)!;
        if (key == 'collectionName') {
          return Uri.encodeComponent(collectionName);
        }
        return key;
      },
    );
    final url = Uri.parse('${_vanestack.baseUrl}$endpointPath');
    final response = await _vanestack._client.delete(url);
    final result = response.body.isNotEmpty ? response.body : null;
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw VaneStackException.fromJson(response.statusCode, result);
    }
  }

  Future<Collection> update({
    required String collectionName,
    String? newCollectionName,
    List<Attribute>? attributes,
    List<Index>? indexes,
    String? listRule,
    String? viewRule,
    String? createRule,
    String? updateRule,
    String? deleteRule,
    String? viewQuery,
  }) async {
    final endpointPath = '/v1/collections/<collectionName>'.replaceAllMapped(
      RegExp(r'<([^>]+)>'),
      (match) {
        final key = match.group(1)!;
        if (key == 'collectionName') {
          return Uri.encodeComponent(collectionName);
        }
        return key;
      },
    );
    final url = Uri.parse('${_vanestack.baseUrl}$endpointPath');
    final body = {
      'newCollectionName': newCollectionName,
      'attributes': attributes,
      'indexes': indexes,
      'listRule': listRule,
      'viewRule': viewRule,
      'createRule': createRule,
      'updateRule': updateRule,
      'deleteRule': deleteRule,
      'viewQuery': viewQuery,
    };
    final response = await _vanestack._client.patch(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(body),
    );
    final result = response.body.isNotEmpty ? response.body : null;
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw VaneStackException.fromJson(response.statusCode, result);
    }
    if (result == null) {
      throw VaneStackException('Empty response body', status: 400);
    }
    final parsed = CollectionMapper.fromJsonString(result);
    return parsed;
  }

  Future<GenerateResponse> generate({
    required String collectionName,
    required int count,
  }) async {
    final endpointPath = '/v1/collections/<collectionName>/generate'
        .replaceAllMapped(RegExp(r'<([^>]+)>'), (match) {
          final key = match.group(1)!;
          if (key == 'collectionName') {
            return Uri.encodeComponent(collectionName);
          }
          return key;
        });
    final url = Uri.parse('${_vanestack.baseUrl}$endpointPath');
    final body = {'count': count};
    final response = await _vanestack._client.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(body),
    );
    final result = response.body.isNotEmpty ? response.body : null;
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw VaneStackException.fromJson(response.statusCode, result);
    }
    if (result == null) {
      throw VaneStackException('Empty response body', status: 400);
    }
    final parsed = GenerateResponseMapper.fromJsonString(result);
    return parsed;
  }
}

class _LogsRoutes {
  final VaneStackClient _vanestack;
  _LogsRoutes(this._vanestack);
  Future<ListAppLogsResult> list({
    String? orderBy,
    String? filter,
    int? limit = 10,
    int? offset = 0,
  }) async {
    final url = Uri.parse('${_vanestack.baseUrl}/v1/logs');
    final body = {
      'orderBy': orderBy,
      'filter': filter,
      'limit': limit,
      'offset': offset,
    };
    final query = body.map((k, v) => MapEntry(k, v.toString()));
    final response = await _vanestack._client.get(
      url.replace(queryParameters: query),
    );
    final result = response.body.isNotEmpty ? response.body : null;
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw VaneStackException.fromJson(response.statusCode, result);
    }
    if (result == null) {
      throw VaneStackException('Empty response body', status: 400);
    }
    final parsed = ListAppLogsResultMapper.fromJsonString(result);
    return parsed;
  }
}

class _SettingsRoutes {
  final VaneStackClient _vanestack;
  _SettingsRoutes(this._vanestack);
  Future<Settings> get() async {
    final url = Uri.parse('${_vanestack.baseUrl}/v1/settings');
    final response = await _vanestack._client.get(url);
    final result = response.body.isNotEmpty ? response.body : null;
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw VaneStackException.fromJson(response.statusCode, result);
    }
    if (result == null) {
      throw VaneStackException('Empty response body', status: 400);
    }
    final parsed = SettingsMapper.fromJsonString(result);
    return parsed;
  }

  Future<Settings> update({
    String? appName,
    String? siteUrl,
    List<String>? redirectUrls,
    S3Settings? s3,
    MailSettings? mail,
    OAuthProviderList? oauthProviders,
  }) async {
    final url = Uri.parse('${_vanestack.baseUrl}/v1/settings');
    final body = {
      'appName': appName,
      'siteUrl': siteUrl,
      'redirectUrls': redirectUrls,
      's3': s3,
      'mail': mail,
      'oauthProviders': oauthProviders,
    };
    final response = await _vanestack._client.patch(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(body),
    );
    final result = response.body.isNotEmpty ? response.body : null;
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw VaneStackException.fromJson(response.statusCode, result);
    }
    if (result == null) {
      throw VaneStackException('Empty response body', status: 400);
    }
    final parsed = SettingsMapper.fromJsonString(result);
    return parsed;
  }

  Future<String> generateAppleClientSecret({
    required String clientId,
    required String teamId,
    required String keyId,
    required String privateKey,
    required int duration,
  }) async {
    final url = Uri.parse(
      '${_vanestack.baseUrl}/v1/settings/generate-apple-client-secret',
    );
    final body = {
      'clientId': clientId,
      'teamId': teamId,
      'keyId': keyId,
      'privateKey': privateKey,
      'duration': duration,
    };
    final response = await _vanestack._client.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(body),
    );
    final result = response.body.isNotEmpty ? response.body : null;
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw VaneStackException.fromJson(response.statusCode, result);
    }
    if (result == null) {
      throw VaneStackException('Empty response body', status: 400);
    }
    final parsed = result;
    return parsed;
  }

  Future<void> testS3Connection() async {
    final url = Uri.parse('${_vanestack.baseUrl}/v1/settings/s3');
    final response = await _vanestack._client.get(url);
    final result = response.body.isNotEmpty ? response.body : null;
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw VaneStackException.fromJson(response.statusCode, result);
    }
  }
}

class _StatsRoutes {
  final VaneStackClient _vanestack;
  _StatsRoutes(this._vanestack);
  Future<DashboardStats> stats() async {
    final url = Uri.parse('${_vanestack.baseUrl}/v1/stats');
    final response = await _vanestack._client.get(url);
    final result = response.body.isNotEmpty ? response.body : null;
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw VaneStackException.fromJson(response.statusCode, result);
    }
    if (result == null) {
      throw VaneStackException('Empty response body', status: 400);
    }
    final parsed = DashboardStatsMapper.fromJsonString(result);
    return parsed;
  }
}

class _UsersRoutes {
  final VaneStackClient _vanestack;
  _UsersRoutes(this._vanestack);
  Future<ListUsersResult> list({
    String? orderBy,
    String? filter,
    int? limit = 10,
    int? offset = 0,
  }) async {
    final url = Uri.parse('${_vanestack.baseUrl}/v1/users');
    final body = {
      'orderBy': orderBy,
      'filter': filter,
      'limit': limit,
      'offset': offset,
    };
    final query = body.map((k, v) => MapEntry(k, v.toString()));
    final response = await _vanestack._client.get(
      url.replace(queryParameters: query),
    );
    final result = response.body.isNotEmpty ? response.body : null;
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw VaneStackException.fromJson(response.statusCode, result);
    }
    if (result == null) {
      throw VaneStackException('Empty response body', status: 400);
    }
    final parsed = ListUsersResultMapper.fromJsonString(result);
    return parsed;
  }

  Future<User> create({
    String? id,
    String? password,
    String? name,
    required String email,
    bool superUser = false,
  }) async {
    final url = Uri.parse('${_vanestack.baseUrl}/v1/users');
    final body = {
      'id': id,
      'password': password,
      'name': name,
      'email': email,
      'superUser': superUser,
    };
    final response = await _vanestack._client.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(body),
    );
    final result = response.body.isNotEmpty ? response.body : null;
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw VaneStackException.fromJson(response.statusCode, result);
    }
    if (result == null) {
      throw VaneStackException('Empty response body', status: 400);
    }
    final parsed = UserMapper.fromJsonString(result);
    return parsed;
  }

  Future<void> delete({required String userId}) async {
    final endpointPath = '/v1/users/<userId>'.replaceAllMapped(
      RegExp(r'<([^>]+)>'),
      (match) {
        final key = match.group(1)!;
        if (key == 'userId') {
          return Uri.encodeComponent(userId);
        }
        return key;
      },
    );
    final url = Uri.parse('${_vanestack.baseUrl}$endpointPath');
    final response = await _vanestack._client.delete(url);
    final result = response.body.isNotEmpty ? response.body : null;
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw VaneStackException.fromJson(response.statusCode, result);
    }
  }

  Future<User> get({required String userId}) async {
    final endpointPath = '/v1/users/<userId>'.replaceAllMapped(
      RegExp(r'<([^>]+)>'),
      (match) {
        final key = match.group(1)!;
        if (key == 'userId') {
          return Uri.encodeComponent(userId);
        }
        return key;
      },
    );
    final url = Uri.parse('${_vanestack.baseUrl}$endpointPath');
    final response = await _vanestack._client.get(url);
    final result = response.body.isNotEmpty ? response.body : null;
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw VaneStackException.fromJson(response.statusCode, result);
    }
    if (result == null) {
      throw VaneStackException('Empty response body', status: 400);
    }
    final parsed = UserMapper.fromJsonString(result);
    return parsed;
  }

  Future<User> update({
    required String userId,
    String? email,
    String? password,
    String? name,
    bool? superUser,
  }) async {
    final endpointPath = '/v1/users/<userId>'.replaceAllMapped(
      RegExp(r'<([^>]+)>'),
      (match) {
        final key = match.group(1)!;
        if (key == 'userId') {
          return Uri.encodeComponent(userId);
        }
        return key;
      },
    );
    final url = Uri.parse('${_vanestack.baseUrl}$endpointPath');
    final body = {
      'email': email,
      'password': password,
      'name': name,
      'superUser': superUser,
    };
    final response = await _vanestack._client.patch(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(body),
    );
    final result = response.body.isNotEmpty ? response.body : null;
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw VaneStackException.fromJson(response.statusCode, result);
    }
    if (result == null) {
      throw VaneStackException('Empty response body', status: 400);
    }
    final parsed = UserMapper.fromJsonString(result);
    return parsed;
  }
}

class _DocumentsRoutes {
  final VaneStackClient _vanestack;
  _DocumentsRoutes(this._vanestack);
  Future<ListDocumentsResult> list({
    required String collectionName,
    String? orderBy,
    String? filter,
    int? limit = 10,
    int? offset = 0,
  }) async {
    final endpointPath = '/v1/documents/<collectionName>'.replaceAllMapped(
      RegExp(r'<([^>]+)>'),
      (match) {
        final key = match.group(1)!;
        if (key == 'collectionName') {
          return Uri.encodeComponent(collectionName);
        }
        return key;
      },
    );
    final url = Uri.parse('${_vanestack.baseUrl}$endpointPath');
    final body = {
      'orderBy': orderBy,
      'filter': filter,
      'limit': limit,
      'offset': offset,
    };
    final query = body.map((k, v) => MapEntry(k, v.toString()));
    final response = await _vanestack._client.get(
      url.replace(queryParameters: query),
    );
    final result = response.body.isNotEmpty ? response.body : null;
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw VaneStackException.fromJson(response.statusCode, result);
    }
    if (result == null) {
      throw VaneStackException('Empty response body', status: 400);
    }
    final parsed = ListDocumentsResultMapper.fromJsonString(result);
    return parsed;
  }

  Future<Document> create({
    required String collectionName,
    required Map<String, Object?> data,
  }) async {
    final endpointPath = '/v1/documents/<collectionName>'.replaceAllMapped(
      RegExp(r'<([^>]+)>'),
      (match) {
        final key = match.group(1)!;
        if (key == 'collectionName') {
          return Uri.encodeComponent(collectionName);
        }
        return key;
      },
    );
    final url = Uri.parse('${_vanestack.baseUrl}$endpointPath');
    final body = {'data': data};
    final response = await _vanestack._client.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(body),
    );
    final result = response.body.isNotEmpty ? response.body : null;
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw VaneStackException.fromJson(response.statusCode, result);
    }
    if (result == null) {
      throw VaneStackException('Empty response body', status: 400);
    }
    final parsed = DocumentMapper.fromJsonString(result);
    return parsed;
  }

  Future<Document> get({
    required String collectionName,
    required String documentId,
  }) async {
    final endpointPath = '/v1/documents/<collectionName>/<documentId>'
        .replaceAllMapped(RegExp(r'<([^>]+)>'), (match) {
          final key = match.group(1)!;
          if (key == 'collectionName') {
            return Uri.encodeComponent(collectionName);
          }
          if (key == 'documentId') {
            return Uri.encodeComponent(documentId);
          }
          return key;
        });
    final url = Uri.parse('${_vanestack.baseUrl}$endpointPath');
    final response = await _vanestack._client.get(url);
    final result = response.body.isNotEmpty ? response.body : null;
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw VaneStackException.fromJson(response.statusCode, result);
    }
    if (result == null) {
      throw VaneStackException('Empty response body', status: 400);
    }
    final parsed = DocumentMapper.fromJsonString(result);
    return parsed;
  }

  Future<void> delete({
    required String collectionName,
    required String documentId,
  }) async {
    final endpointPath = '/v1/documents/<collectionName>/<documentId>'
        .replaceAllMapped(RegExp(r'<([^>]+)>'), (match) {
          final key = match.group(1)!;
          if (key == 'collectionName') {
            return Uri.encodeComponent(collectionName);
          }
          if (key == 'documentId') {
            return Uri.encodeComponent(documentId);
          }
          return key;
        });
    final url = Uri.parse('${_vanestack.baseUrl}$endpointPath');
    final response = await _vanestack._client.delete(url);
    final result = response.body.isNotEmpty ? response.body : null;
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw VaneStackException.fromJson(response.statusCode, result);
    }
  }

  Future<Document> update({
    required String collectionName,
    required String documentId,
    required Map<String, Object?> data,
  }) async {
    final endpointPath = '/v1/documents/<collectionName>/<documentId>'
        .replaceAllMapped(RegExp(r'<([^>]+)>'), (match) {
          final key = match.group(1)!;
          if (key == 'collectionName') {
            return Uri.encodeComponent(collectionName);
          }
          if (key == 'documentId') {
            return Uri.encodeComponent(documentId);
          }
          return key;
        });
    final url = Uri.parse('${_vanestack.baseUrl}$endpointPath');
    final body = {'data': data};
    final response = await _vanestack._client.patch(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(body),
    );
    final result = response.body.isNotEmpty ? response.body : null;
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw VaneStackException.fromJson(response.statusCode, result);
    }
    if (result == null) {
      throw VaneStackException('Empty response body', status: 400);
    }
    final parsed = DocumentMapper.fromJsonString(result);
    return parsed;
  }
}

class _FilesRoutes {
  final VaneStackClient _vanestack;
  _FilesRoutes(this._vanestack);
  Future<ListFilesResult> list({
    required String bucket,
    String? path,
    String? orderBy,
    String? filter,
    int? limit = 10,
    int? offset = 0,
  }) async {
    final endpointPath = '/v1/files/<bucket>'.replaceAllMapped(
      RegExp(r'<([^>]+)>'),
      (match) {
        final key = match.group(1)!;
        if (key == 'bucket') {
          return Uri.encodeComponent(bucket);
        }
        return key;
      },
    );
    final url = Uri.parse('${_vanestack.baseUrl}$endpointPath');
    final body = {
      'path': path,
      'orderBy': orderBy,
      'filter': filter,
      'limit': limit,
      'offset': offset,
    };
    final query = body.map((k, v) => MapEntry(k, v.toString()));
    final response = await _vanestack._client.get(
      url.replace(queryParameters: query),
    );
    final result = response.body.isNotEmpty ? response.body : null;
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw VaneStackException.fromJson(response.statusCode, result);
    }
    if (result == null) {
      throw VaneStackException('Empty response body', status: 400);
    }
    final parsed = ListFilesResultMapper.fromJsonString(result);
    return parsed;
  }

  Future<void> delete({required String bucket, required String path}) async {
    final endpointPath = '/v1/files/<bucket>'.replaceAllMapped(
      RegExp(r'<([^>]+)>'),
      (match) {
        final key = match.group(1)!;
        if (key == 'bucket') {
          return Uri.encodeComponent(bucket);
        }
        return key;
      },
    );
    final url = Uri.parse('${_vanestack.baseUrl}$endpointPath');
    final body = {'path': path};
    final query = body.map((k, v) => MapEntry(k, v.toString()));
    final response = await _vanestack._client.delete(
      url.replace(queryParameters: query),
    );
    final result = response.body.isNotEmpty ? response.body : null;
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw VaneStackException.fromJson(response.statusCode, result);
    }
  }

  Future<File> move({
    required String bucket,
    required String fileId,
    required String destination,
  }) async {
    final endpointPath = '/v1/files/<bucket>/<fileId>'.replaceAllMapped(
      RegExp(r'<([^>]+)>'),
      (match) {
        final key = match.group(1)!;
        if (key == 'bucket') {
          return Uri.encodeComponent(bucket);
        }
        if (key == 'fileId') {
          return Uri.encodeComponent(fileId);
        }
        return key;
      },
    );
    final url = Uri.parse('${_vanestack.baseUrl}$endpointPath');
    final body = {'destination': destination};
    final response = await _vanestack._client.patch(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(body),
    );
    final result = response.body.isNotEmpty ? response.body : null;
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw VaneStackException.fromJson(response.statusCode, result);
    }
    if (result == null) {
      throw VaneStackException('Empty response body', status: 400);
    }
    final parsed = FileMapper.fromJsonString(result);
    return parsed;
  }

  Future<Uint8List> download({
    required String bucket,
    required String fileId,
    String? token,
  }) async {
    final endpointPath = '/v1/files/<bucket>/<fileId>'.replaceAllMapped(
      RegExp(r'<([^>]+)>'),
      (match) {
        final key = match.group(1)!;
        if (key == 'bucket') {
          return Uri.encodeComponent(bucket);
        }
        if (key == 'fileId') {
          return Uri.encodeComponent(fileId);
        }
        return key;
      },
    );
    final url = Uri.parse('${_vanestack.baseUrl}$endpointPath');
    final body = {'token': token};
    final query = body.map((k, v) => MapEntry(k, v.toString()));
    final response = await _vanestack._client.get(
      url.replace(queryParameters: query),
    );
    if (response.statusCode < 200 || response.statusCode >= 300) {
      final result = response.body.isNotEmpty ? response.body : null;
      throw VaneStackException.fromJson(response.statusCode, result);
    }
    return response.bodyBytes;
  }

  Future<GetDownloadUrlResult> getDownloadUrl({
    required String bucket,
    required String fileId,
  }) async {
    final endpointPath = '/v1/files/<bucket>/<fileId>/url'.replaceAllMapped(
      RegExp(r'<([^>]+)>'),
      (match) {
        final key = match.group(1)!;
        if (key == 'bucket') {
          return Uri.encodeComponent(bucket);
        }
        if (key == 'fileId') {
          return Uri.encodeComponent(fileId);
        }
        return key;
      },
    );
    final url = Uri.parse('${_vanestack.baseUrl}$endpointPath');
    final response = await _vanestack._client.get(url);
    final result = response.body.isNotEmpty ? response.body : null;
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw VaneStackException.fromJson(response.statusCode, result);
    }
    if (result == null) {
      throw VaneStackException('Empty response body', status: 400);
    }
    final parsed = GetDownloadUrlResultMapper.fromJsonString(result);
    return parsed;
  }

  Future<File> upload({
    required String bucket,
    required MultipartFile file,
    required String filePath,
  }) async {
    final endpointPath = '/v1/files/<bucket>/upload'.replaceAllMapped(
      RegExp(r'<([^>]+)>'),
      (match) {
        final key = match.group(1)!;
        if (key == 'bucket') {
          return Uri.encodeComponent(bucket);
        }
        return key;
      },
    );
    final url = Uri.parse('${_vanestack.baseUrl}$endpointPath');
    final request = MultipartRequest('post', url);
    request.files.add(file);
    request.fields['path'] = filePath;
    final streamedResponse = await _vanestack.send(
      request,
      headers: {'Content-Type': 'multipart/form-data'},
    );
    final response = await Response.fromStream(streamedResponse);
    final result = response.body.isNotEmpty ? response.body : null;
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw VaneStackException.fromJson(response.statusCode, result);
    }
    if (result == null) {
      throw VaneStackException('Empty response body', status: 400);
    }
    final parsed = FileMapper.fromJsonString(result);
    return parsed;
  }
}
