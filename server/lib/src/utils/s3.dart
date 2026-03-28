import 'dart:convert';
import 'dart:typed_data';

import 'package:vanestack_common/vanestack_common.dart';
import 'package:http/http.dart' as http;
import 'package:hashlib/hashlib.dart' as hashlib;

import 'logger.dart';

/// A client for S3-compatible object storage using AWS Signature V4.
class S3Client {
  final S3Settings settings;
  final http.Client _httpClient;

  /// Creates a new S3 client.
  S3Client(this.settings, {http.Client? httpClient})
    : _httpClient = httpClient ?? http.Client();

  /// Uploads an object to the S3 bucket from a stream.
  ///
  /// Uses `UNSIGNED-PAYLOAD` for the content hash so the body can be streamed
  /// directly to S3 without reading it into memory first.
  Future<bool> putObject(
    String objectKey,
    Stream<List<int>> body,
    int contentLength, {
    String? contentType,
  }) async {
    if (!settings.enabled) return false;

    final uri = _buildUri(objectKey);
    final request = http.StreamedRequest('PUT', uri);

    final headers = _signHeaders(
      method: 'PUT',
      uri: uri,
      payloadHash: 'UNSIGNED-PAYLOAD',
      contentType: contentType,
    );
    request.headers.addAll(headers);
    request.contentLength = contentLength;

    // Pipe the body stream into the request without buffering.
    body.listen(
      request.sink.add,
      onError: request.sink.addError,
      onDone: request.sink.close,
    );

    final response = await _httpClient.send(request);

    // Drain the response body to free the connection.
    await response.stream.drain<void>();

    return response.statusCode == 200;
  }

  Future<bool> _copyObject(String sourceKey, String destinationKey) async {
    final copySource = '/${settings.bucket}/${_normalizePath(sourceKey)}';

    final request = await _createSignedRequest(
      method: 'PUT',
      objectKey: destinationKey,
    );

    request.headers['x-amz-copy-source'] = copySource;

    final response = await _httpClient.send(request);
    return response.statusCode == 200;
  }

  /// Moves an object within the same bucket.
  Future<bool> moveObject(String sourceKey, String destinationKey) async {
    if (!settings.enabled) return false;

    // 1. Copy
    final copied = await _copyObject(sourceKey, destinationKey);
    if (!copied) return false;

    // 2. Delete original
    final deleted = await deleteObject(sourceKey);
    return deleted;
  }

  /// Returns the object size in bytes, or null if it doesn't exist.
  Future<int?> getObjectSize(String objectKey) async {
    if (!settings.enabled) return null;

    final request = await _createSignedRequest(
      method: 'HEAD',
      objectKey: objectKey,
    );

    final response = await _httpClient.send(request);

    if (response.statusCode == 200) {
      final lengthHeader = response.headers['content-length'];
      if (lengthHeader != null) {
        return int.tryParse(lengthHeader);
      }
    }

    return null;
  }

  /// Retrieves an object's data from the S3 bucket.
  Future<Uint8List?> getObject(String objectKey) async {
    if (!settings.enabled) return null;

    final request = await _createSignedRequest(
      method: 'GET',
      objectKey: objectKey,
    );
    final response = await _httpClient.send(request);

    if (response.statusCode == 200) {
      return response.stream.toBytes();
    }
    return null;
  }

  /// Deletes an object from the S3 bucket.
  Future<bool> deleteObject(String objectKey) async {
    if (!settings.enabled) return false;

    final request = await _createSignedRequest(
      method: 'DELETE',
      objectKey: objectKey,
    );
    final response = await _httpClient.send(request);

    // 204 No Content is the typical success response for DELETE
    return response.statusCode == 204;
  }

  /// Checks if an object exists using a HEAD request.
  Future<bool> objectExists(String objectKey) async {
    if (!settings.enabled) return false;

    final request = await _createSignedRequest(
      method: 'HEAD',
      objectKey: objectKey,
    );
    final response = await _httpClient.send(request);

    // 200 OK means it exists
    return response.statusCode == 200;
  }

  /// Checks if the connection to the S3 bucket is valid (credentials, endpoint, bucket name).
  /// This performs a ListObjectsV2 request with max-keys=0.
  Future<bool> testConnection() async {
    if (!settings.enabled) return false;

    try {
      final request = await _createSignedRequest(
        method: 'GET',
        objectKey: '', // Empty key targets the bucket itself
        queryParams: {'list-type': '2', 'max-keys': '0'},
      );
      final response = await _httpClient.send(request);

      // 200 OK means success
      return response.statusCode == 200;
    } catch (e) {
      // Catch network errors, DNS errors, etc.
      return false;
    }
  }

  /// Lists objects in the S3 bucket (using ListObjectsV2).
  ///
  /// Note: This is a basic implementation that only returns the first 1000 keys
  /// and uses simple regex parsing for the XML response, as external XML parsers
  /// cannot be imported in this environment. It does not handle pagination.
  Future<List<String>> listObjects({String? prefix, String? delimiter}) async {
    if (!settings.enabled) return [];

    final queryParams = <String, String>{
      'list-type': '2', // Use ListObjectsV2
    };

    if (prefix != null && prefix.isNotEmpty) {
      queryParams['prefix'] = prefix;
    }
    if (delimiter != null && delimiter.isNotEmpty) {
      queryParams['delimiter'] = delimiter;
    }

    final request = await _createSignedRequest(
      method: 'GET',
      objectKey: '', // Targets the bucket root
      queryParams: queryParams,
    );

    try {
      final streamedResponse = await _httpClient.send(request);
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        // Simple and fragile XML parsing using regex without external dependencies.
        // We look for all <Key>...</Key> tags in the response body.
        // The regex pattern is designed to capture the content between the tags.
        const keyRegex = '<Key>(.*?)<\\/Key>';
        final keys = <String>[];
        final matches = RegExp(keyRegex).allMatches(response.body);

        for (final match in matches) {
          // match.group(1) is the captured content (the key)
          if (match.groupCount >= 1) {
            keys.add(match.group(1)!);
          }
        }
        return keys;
      } else {
        storageLogger.warn('Failed to list objects: Status ${response.statusCode}');
        return [];
      }
    } catch (e) {
      storageLogger.error('Error during listObjects', error: e);
      return [];
    }
  }

  // --- AWS Signature V4 Implementation ---

  /// Builds the target URI for an S3 object key, preserving any base path
  /// from the endpoint (e.g., `/storage` for cloud proxy).
  Uri _buildUri(String objectKey, {Map<String, String>? queryParams}) {
    final endpointUri = Uri.parse(settings.endpoint);
    final objectPath = objectKey.isEmpty ? '' : _normalizePath(objectKey);
    final basePath = endpointUri.path.endsWith('/')
        ? endpointUri.path.substring(0, endpointUri.path.length - 1)
        : endpointUri.path;
    final path = '$basePath/${settings.bucket}/$objectPath';
    return Uri(
      scheme: endpointUri.scheme,
      host: endpointUri.host,
      port: endpointUri.port,
      path: path,
      queryParameters: queryParams?.isEmpty ?? true ? null : queryParams,
    );
  }

  /// Creates signed headers for an S3 request.
  ///
  /// [payloadHash] can be a real SHA-256 hex digest or `'UNSIGNED-PAYLOAD'`
  /// for streamed uploads where the body isn't available upfront.
  Map<String, String> _signHeaders({
    required String method,
    required Uri uri,
    required String payloadHash,
    String? contentType,
  }) {
    const service = 's3';
    final now = DateTime.now().toUtc();
    final amzDate = _formatAmzDate(now);
    final dateStamp = _formatDateStamp(now);
    final host = Uri.parse(settings.endpoint).host;

    final headers = <String, String>{
      'host': host,
      'x-amz-date': amzDate,
      'x-amz-content-sha256': payloadHash,
    };
    if (contentType != null) {
      headers['content-type'] = contentType;
    }

    final canonicalRequest = _getCanonicalRequest(
      method,
      uri,
      headers,
      payloadHash,
    );
    final canonicalRequestHash = _sha256Hash(utf8.encode(canonicalRequest));

    final credentialScope =
        '$dateStamp/${settings.region}/$service/aws4_request';
    final stringToSign = _getStringToSign(
      amzDate,
      credentialScope,
      canonicalRequestHash,
    );

    final signingKey = _getSignatureKey(
      settings.secretKey,
      dateStamp,
      settings.region,
      service,
    );
    final signature = _hmacSha256(signingKey, utf8.encode(stringToSign));
    final signatureHex = _hexEncode(signature);

    final signedHeaderKeys = headers.keys.map((k) => k.toLowerCase()).toList()
      ..sort();
    headers['authorization'] =
        'AWS4-HMAC-SHA256 Credential=${settings.accessKey}/$credentialScope, SignedHeaders=${signedHeaderKeys.join(';')}, Signature=$signatureHex';

    return headers;
  }

  /// Creates a fully signed [http.Request] object.
  Future<http.Request> _createSignedRequest({
    required String method,
    required String objectKey,
    Uint8List? payload,
    String? contentType,
    Map<String, String>? queryParams,
  }) async {
    payload ??= Uint8List(0);

    final uri = _buildUri(objectKey, queryParams: queryParams);
    final request = http.Request(method, uri)..bodyBytes = payload;

    final payloadHash = _sha256Hash(payload);
    final headers = _signHeaders(
      method: method,
      uri: uri,
      payloadHash: payloadHash,
      contentType: contentType,
    );

    request.headers.addAll(headers);
    return request;
  }

  /// Task 1: Create a canonical request
  String _getCanonicalRequest(
    String method,
    Uri uri,
    Map<String, String> headers,
    String payloadHash,
  ) {
    // Sort headers by key (lowercase)
    final sortedHeaderKeys = headers.keys.toList()..sort();
    final canonicalHeaders = sortedHeaderKeys
        .map((key) => '${key.toLowerCase()}:${headers[key]!.trim()}')
        .join('\n');
    final signedHeaders = sortedHeaderKeys
        .map((key) => key.toLowerCase())
        .join(';');

    // Sort query parameters by key
    final sortedQueryKeys = uri.queryParameters.keys.toList()..sort();
    final canonicalQuery = sortedQueryKeys
        .map(
          (key) =>
              '${_uriEncode(key)}=${_uriEncode(uri.queryParameters[key]!)}',
        )
        .join('&');

    return [
      method,
      uri.path,
      canonicalQuery,
      '$canonicalHeaders\n', // Extra newline is important
      signedHeaders,
      payloadHash,
    ].join('\n');
  }

  /// Task 2: Create a string to sign
  String _getStringToSign(
    String amzDate,
    String credentialScope,
    String canonicalRequestHash,
  ) {
    return [
      'AWS4-HMAC-SHA256',
      amzDate,
      credentialScope,
      canonicalRequestHash,
    ].join('\n');
  }

  /// Task 3: Calculate the signing key
  Uint8List _getSignatureKey(
    String secretKey,
    String dateStamp,
    String region,
    String service,
  ) {
    final kDate = _hmacSha256(
      utf8.encode('AWS4$secretKey'),
      utf8.encode(dateStamp),
    );
    final kRegion = _hmacSha256(kDate, utf8.encode(region));
    final kService = _hmacSha256(kRegion, utf8.encode(service));
    final kSigning = _hmacSha256(kService, utf8.encode('aws4_request'));
    return kSigning;
  }

  // --- Crypto Helpers ---

  /// HMAC-SHA256 digest calculation.
  Uint8List _hmacSha256(Uint8List key, Uint8List data) {
    final digest = hashlib.hmac_sha256.by(key).convert(data);
    return Uint8List.fromList(digest.bytes);
  }

  /// SHA-256 hash calculation, returned as a hex string.
  String _sha256Hash(Uint8List data) {
    final digest = hashlib.sha256.convert(data);
    return _hexEncode(Uint8List.fromList(digest.bytes));
  }

  /// Converts a byte list to a lowercase hex string.
  String _hexEncode(Uint8List bytes) {
    return bytes.map((b) => b.toRadixString(16).padLeft(2, '0')).join('');
  }

  // --- Formatting Helpers ---

  /// Formats date as "YYYYMMDD'T'HHMMSS'Z'" (e.g., "20251030T162900Z")
  String _formatAmzDate(DateTime dt) {
    // Use core Dart methods instead of intl
    final utcDt = dt.toUtc();
    return [
      utcDt.year.toString().padLeft(4, '0'),
      utcDt.month.toString().padLeft(2, '0'),
      utcDt.day.toString().padLeft(2, '0'),
      'T',
      utcDt.hour.toString().padLeft(2, '0'),
      utcDt.minute.toString().padLeft(2, '0'),
      utcDt.second.toString().padLeft(2, '0'),
      'Z',
    ].join('');
  }

  /// Formats date as "YYYYMMDD" (e.g., "20251030")
  String _formatDateStamp(DateTime dt) {
    // Use core Dart methods instead of intl
    final utcDt = dt.toUtc();
    return [
      utcDt.year.toString().padLeft(4, '0'),
      utcDt.month.toString().padLeft(2, '0'),
      utcDt.day.toString().padLeft(2, '0'),
    ].join('');
  }

  /// Normalizes a path to not start with a '/' and ensure single slashes.
  String _normalizePath(String path) {
    return path.split('/').where((s) => s.isNotEmpty).join('/');
  }

  /// AWS-compliant URI encoding
  String _uriEncode(String s) {
    final encoded = Uri.encodeComponent(s);
    // AWS SigV4 requires slashes in the path to NOT be encoded,
    // but query parameter slashes ARE encoded. This helper is generic,
    // so we default to standard component encoding (which encodes '/').
    // The canonical request path builder handles path slashes correctly.
    // For query params, this is correct.
    // A more robust implementation would differentiate.
    // For now, this is standard.
    return encoded;
  }
}
