import 'dart:convert';
import 'dart:io';

import 'package:vanestack/src/utils/logger.dart';
import 'package:vanestack_common/vanestack_common.dart';

/// Suppresses all log output during tests.
void silenceTestLogs() {
  configureLogger(logLevel: LogLevel.none);
}

/// Find a free TCP port by binding to port 0 then closing.
Future<int> findFreePort() async {
  final socket = await ServerSocket.bind(InternetAddress.loopbackIPv4, 0);
  final p = socket.port;
  await socket.close();
  return p;
}

class JsonHttpClient {
  final HttpClient _client = HttpClient();
  final Uri _base;
  final Map<String, String> defaultHeaders;

  JsonHttpClient(String host, int port, {this.defaultHeaders = const {}})
    : _base = Uri(scheme: 'http', host: host, port: port);

  Future<({int status, Map<String, dynamic>? json, String body})> get(
    String path, {
    String? bearer,
    Map<String, String>? query,
  }) async {
    final uri = _base.replace(
      path: path.startsWith('/') ? path : '/$path',
      queryParameters: query,
    );
    final req = await _client.getUrl(uri);
    if (bearer != null) {
      req.headers.set(HttpHeaders.authorizationHeader, 'Bearer $bearer');
    }

    defaultHeaders.forEach((key, value) => req.headers.set(key, value));

    final res = await req.close();
    final body = await utf8.decoder.bind(res).join();
    Map<String, dynamic>? json;
    try {
      json = body.isNotEmpty ? jsonDecode(body) as Map<String, dynamic> : null;
    } catch (_) {}

    return (status: res.statusCode, json: json, body: body);
  }

  Future<({int status, Map<String, dynamic>? json, String body})> post(
    String path, {
    Object? body,
    String? bearer,
    Map<String, String>? query,
  }) async {
    final uri = _base.replace(
      path: path.startsWith('/') ? path : '/$path',
      queryParameters: query,
    );
    final req = await _client.postUrl(uri);
    req.headers.set(HttpHeaders.contentTypeHeader, 'application/json');
    if (bearer != null) {
      req.headers.set(HttpHeaders.authorizationHeader, 'Bearer $bearer');
    }

    defaultHeaders.forEach((key, value) => req.headers.set(key, value));

    if (body != null) {
      req.add(utf8.encode(jsonEncode(body)));
    }
    final res = await req.close();
    final resBody = await utf8.decoder.bind(res).join();
    Map<String, dynamic>? json;
    try {
      json = resBody.isNotEmpty
          ? jsonDecode(resBody) as Map<String, dynamic>
          : null;
    } catch (_) {}
    return (status: res.statusCode, json: json, body: resBody);
  }

  Future<({int status, Map<String, dynamic>? json, String body})> patch(
    String path, {
    Object? body,
    String? bearer,
    Map<String, String>? query,
  }) async {
    final uri = _base.replace(
      path: path.startsWith('/') ? path : '/$path',
      queryParameters: query,
    );
    final req = await _client.patchUrl(uri);
    req.headers.set(HttpHeaders.contentTypeHeader, 'application/json');
    if (bearer != null) {
      req.headers.set(HttpHeaders.authorizationHeader, 'Bearer $bearer');
    }

    defaultHeaders.forEach((key, value) => req.headers.set(key, value));

    if (body != null) {
      req.add(utf8.encode(jsonEncode(body)));
    }
    final res = await req.close();
    final resBody = await utf8.decoder.bind(res).join();
    Map<String, dynamic>? json;
    try {
      json = resBody.isNotEmpty
          ? jsonDecode(resBody) as Map<String, dynamic>
          : null;
    } catch (_) {}
    return (status: res.statusCode, json: json, body: resBody);
  }

  Future<({int status, Map<String, dynamic>? json, String body})> del(
    String path, {
    Object? body,
    String? bearer,
    Map<String, String>? query,
  }) async {
    final uri = _base.replace(
      path: path.startsWith('/') ? path : '/$path',
      queryParameters: query,
    );
    final req = await _client.deleteUrl(uri);
    req.headers.set(HttpHeaders.contentTypeHeader, 'application/json');
    if (bearer != null) {
      req.headers.set(HttpHeaders.authorizationHeader, 'Bearer $bearer');
    }

    defaultHeaders.forEach((key, value) => req.headers.set(key, value));

    if (body != null) {
      req.add(utf8.encode(jsonEncode(body)));
    }
    final res = await req.close();
    final resBody = await utf8.decoder.bind(res).join();
    Map<String, dynamic>? json;
    try {
      json = resBody.isNotEmpty
          ? jsonDecode(resBody) as Map<String, dynamic>
          : null;
    } catch (_) {}
    return (status: res.statusCode, json: json, body: resBody);
  }

  Future<({int status, Map<String, dynamic>? json, String body})> uploadFile(
    String path, {
    required String filePath,
    required String fileName,
    required List<int> fileContent,
    String mimeType = 'application/octet-stream',
    String? bearer,
  }) async {
    final uri = _base.replace(path: path.startsWith('/') ? path : '/$path');
    final req = await _client.postUrl(uri);

    final boundary = '----DartFormBoundary${DateTime.now().millisecondsSinceEpoch}';
    req.headers.set(
      HttpHeaders.contentTypeHeader,
      'multipart/form-data; boundary=$boundary',
    );

    if (bearer != null) {
      req.headers.set(HttpHeaders.authorizationHeader, 'Bearer $bearer');
    }
    defaultHeaders.forEach((key, value) => req.headers.set(key, value));

    // Build multipart body
    final bodyParts = <int>[];

    // Add path field
    bodyParts.addAll(utf8.encode('--$boundary\r\n'));
    bodyParts.addAll(utf8.encode('Content-Disposition: form-data; name="path"\r\n\r\n'));
    bodyParts.addAll(utf8.encode('$filePath\r\n'));

    // Add file field
    bodyParts.addAll(utf8.encode('--$boundary\r\n'));
    bodyParts.addAll(utf8.encode(
      'Content-Disposition: form-data; name="file"; filename="$fileName"\r\n',
    ));
    bodyParts.addAll(utf8.encode('Content-Type: $mimeType\r\n\r\n'));
    bodyParts.addAll(fileContent);
    bodyParts.addAll(utf8.encode('\r\n'));

    // End boundary
    bodyParts.addAll(utf8.encode('--$boundary--\r\n'));

    req.contentLength = bodyParts.length;
    req.add(bodyParts);

    final res = await req.close();
    final resBody = await utf8.decoder.bind(res).join();
    Map<String, dynamic>? json;
    try {
      json = resBody.isNotEmpty ? jsonDecode(resBody) as Map<String, dynamic> : null;
    } catch (_) {}
    return (status: res.statusCode, json: json, body: resBody);
  }

  void close() => _client.close(force: true);
}
