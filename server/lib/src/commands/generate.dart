import 'dart:io';

import 'package:args/command_runner.dart';
import 'package:shelf/shelf.dart';

import '../routes_info.dart';
import '../utils/http_method.dart';

class GenerateClientCommand extends Command {
  @override
  final String name = 'generate';

  @override
  final String description = 'Generate the client SDK package.';

  final Map<(HttpMethod, String), Handler> _customRoutes;
  final Set<(HttpMethod, String)> _ignoredForClient;

  GenerateClientCommand(this._customRoutes, this._ignoredForClient) {
    argParser.addOption(
      'output',
      abbr: 'o',
      help: 'Output directory for the generated client package.',
      defaultsTo: '../client',
    );
  }

  @override
  Future<void> run() async {
    final outputDir = argResults!['output'] as String;

    // Collect routes from routes_info.dart (excluding ignoreForClient)
    final allRoutes = routesInfo
        .where((r) => r['ignoreForClient'] != true)
        .toList();

    // Add custom routes (excluding ignored ones)
    for (final entry in _customRoutes.entries) {
      final key = entry.key;
      if (_ignoredForClient.contains(key)) continue;

      final method = key.$1;
      final path = key.$2;

      final pathParams = RegExp(
        r'<(\w+)>',
      ).allMatches(path).map((m) => m.group(1)!).toList();

      allRoutes.add({
        'functionName': _methodNameFromPath(method, path),
        'method': method.name,
        'path': path,
        'pathParams': pathParams,
        'bodyParams': <Map<String, Object?>>[],
        'returnTypeName': 'String',
        'returnTypeFlags': <String, Object?>{
          'isStream': false,
          'isList': false,
          'isBool': false,
          'isString': true,
          'isNum': false,
          'isMap': false,
          'isVoid': false,
          'isFileResponse': false,
          'listItemTypeName': null,
          'innerTypeName': 'String',
        },
        'ignoreForClient': false,
        'requiresAuth': false,
        'requiresSuperUserAuth': false,
      });
    }

    // Generate the package
    await _generatePackage(outputDir, allRoutes);

    print('Client SDK generated at $outputDir');
  }

  /// Converts a hyphen/underscore-separated string to camelCase.
  /// e.g. 'test-group' -> 'testGroup', 'auth' -> 'auth'
  String _toCamelCase(String input) {
    final words = input
        .split(RegExp(r'[-_]'))
        .where((w) => w.isNotEmpty)
        .toList();
    if (words.isEmpty) return input;
    final first = words.first;
    final rest = words.skip(1).map((s) => s[0].toUpperCase() + s.substring(1));
    return '$first${rest.join()}';
  }

  String _methodNameFromPath(HttpMethod method, String path) {
    final allSegments = path.split('/').where((s) => s.isNotEmpty).toList();

    // Remove 'v1' prefix if present
    if (allSegments.isNotEmpty && allSegments.first == 'v1') {
      allSegments.removeAt(0);
    }
    // Remove group segment (first non-param segment — already used as class name)
    if (allSegments.isNotEmpty && !allSegments.first.startsWith('<')) {
      allSegments.removeAt(0);
    }

    // Build method name from remaining non-param segments
    final parts = <String>[];
    for (final segment in allSegments.where((s) => !s.startsWith('<'))) {
      final words = segment.split(RegExp(r'[-_]'));
      parts.addAll(words.where((w) => w.isNotEmpty));
    }

    if (parts.isEmpty) return method.name;
    final first = parts.first;
    final rest = parts.skip(1).map((s) => s[0].toUpperCase() + s.substring(1));
    return '$first${rest.join()}';
  }

  Future<void> _generatePackage(
    String outputDir,
    List<Map<String, Object?>> allRoutes,
  ) async {
    final dir = Directory(outputDir);
    if (!dir.existsSync()) {
      dir.createSync(recursive: true);
    }

    final libDir = Directory('$outputDir/lib');
    if (!libDir.existsSync()) libDir.createSync(recursive: true);

    final srcDir = Directory('$outputDir/lib/src');
    if (!srcDir.existsSync()) srcDir.createSync(recursive: true);

    // Write all files
    await Future.wait([
      File(
        '$outputDir/pubspec.yaml',
      ).writeAsString(_genPubspec()),
      File(
        '$outputDir/lib/vanestack_client.dart',
      ).writeAsString(_genBarrelExport()),
      File(
        '$outputDir/lib/src/auth_storage.dart',
      ).writeAsString(_genAuthStorage()),
      File('$outputDir/lib/src/filters.dart').writeAsString(_genFilters()),
      File(
        '$outputDir/lib/src/realtime_channels.dart',
      ).writeAsString(_genRealtimeChannels()),
      File(
        '$outputDir/lib/src/replay_last_stream.dart',
      ).writeAsString(_genReplayLastStream()),
      File('$outputDir/lib/src/nonce.dart').writeAsString(_genNonce()),
      File(
        '$outputDir/lib/src/client.dart',
      ).writeAsString(_genClient(allRoutes)),
      File('$outputDir/README.md').writeAsString(_genReadme(allRoutes)),
    ]);

    // Format the generated Dart files
    final result = await Process.run('dart', ['format', '$outputDir/lib']);
    if (result.exitCode != 0) {
      print('Warning: dart format failed: ${result.stderr}');
    }
  }

  String _genPubspec() =>
      '''
name: vanestack_client
environment:
  sdk: ^3.9.2
dependencies:
  crypto: ^3.0.6
  http: ^1.5.0
  vanestack_common: ^0.1.0
  sse_channel: ^0.2.2
  http_parser: ^4.1.2
dev_dependencies:
  test: ^1.25.6
''';

  String _genBarrelExport() => '''
export 'src/auth_storage.dart';
export 'src/client.dart';
export 'src/filters.dart';
export 'src/nonce.dart';
export 'src/realtime_channels.dart';
export 'package:vanestack_common/vanestack_common.dart';
export 'package:http/http.dart' show MultipartFile;
export 'package:http_parser/http_parser.dart' show MediaType;
''';

  String _genAuthStorage() => '''
abstract class AuthStorage {
  Future<void> save(String key, String value);
  Future<String?> read(String key);
  Future<void> delete(String key);
}

class MemoryAuthStorage extends AuthStorage {
  final Map<String, String> _storage = {};

  @override
  Future<void> delete(String key) async {
    _storage.remove(key);
  }

  @override
  Future<String?> read(String key) async {
    return _storage[key];
  }

  @override
  Future<void> save(String key, String value) async {
    _storage[key] = value;
  }
}
''';

  String _genFilters() => r"""
enum SortDirection { asc, desc }

class OrderBy {
  final List<String> _fields;

  OrderBy(String fieldName, {SortDirection direction = SortDirection.asc})
    : _fields = [
        direction == SortDirection.asc ? '+$fieldName' : '-$fieldName',
      ];

  OrderBy addField(
    String fieldName, {
    SortDirection direction = SortDirection.asc,
  }) {
    final prefix = direction == SortDirection.asc ? '+' : '-';
    _fields.add('$prefix$fieldName');
    return this;
  }

  factory OrderBy.desc(String fieldName) =>
      OrderBy(fieldName, direction: SortDirection.desc);

  factory OrderBy.asc(String fieldName) =>
      OrderBy(fieldName, direction: SortDirection.asc);

  String build() {
    return _fields.join(',');
  }

  @override
  String toString() {
    return _fields.join(',');
  }
}

class Filter {
  final String? _expression;
  final List<Filter>? _children;
  final String? _operator; // AND / OR

  Filter._({String? expression, List<Filter>? children, String? operator})
    : _expression = expression,
      _children = children,
      _operator = operator;

  /// Creates a simple comparison filter like:
  /// Filter.where('age', isGreaterThan: 20)
  static Filter where(
    String field, {
    Object? isEqualTo,
    Object? isNotEqualTo,
    Object? isGreaterThan,
    Object? isLessThan,
    Object? isGreaterThanOrEqualTo,
    Object? isLessThanOrEqualTo,
    Object? like,
    Object? notLike,
  }) {
    String? expr;
    if (isEqualTo != null) {
      expr = _expr(field, '=', isEqualTo);
    } else if (isNotEqualTo != null) {
      expr = _expr(field, '!=', isNotEqualTo);
    } else if (isGreaterThan != null) {
      expr = _expr(field, '>', isGreaterThan);
    } else if (isLessThan != null) {
      expr = _expr(field, '<', isLessThan);
    } else if (isGreaterThanOrEqualTo != null) {
      expr = _expr(field, '>=', isGreaterThanOrEqualTo);
    } else if (isLessThanOrEqualTo != null) {
      expr = _expr(field, '<=', isLessThanOrEqualTo);
    } else if (like != null) {
      expr = _expr(field, 'LIKE', like);
    } else if (notLike != null) {
      expr = _expr(field, 'NOT LIKE', notLike);
    }

    if (expr == null) {
      throw ArgumentError('No valid operator provided for $field');
    }
    return Filter._(expression: expr);
  }

  /// Combines filters with AND
  static Filter and(List<Filter> filters) =>
      Filter._(children: filters, operator: 'AND');

  /// Combines filters with OR
  static Filter or(List<Filter> filters) =>
      Filter._(children: filters, operator: 'OR');

  /// Build SQL expression string recursively
  String build() {
    if (_expression != null) return _expression;
    if (_children == null || _children.isEmpty) return '';

    final built = _children
        .map((f) => f.build())
        .where((s) => s.isNotEmpty)
        .map((s) => '($s)')
        .join(' $_operator ');

    return built.isNotEmpty ? built : '';
  }

  /// Utility to produce value-safe expression
  static String _expr(String field, String op, Object value) {
    final val = _escapeValue(value);
    return '$field $op $val';
  }

  /// Escape string literals for SQL (simple approach)
  static String _escapeValue(Object value) {
    if (value is num || value is bool) return value.toString();
    return "'${value.toString().replaceAll("'", "''")}'";
  }
}
""";

  String _genRealtimeChannels() {
    final b = StringBuffer();
    b.writeln(r"""abstract class Channel {
  static CollectionChannel collection(
    String collection, {
    DocumentEventType type = DocumentEventType.all,
  }) => CollectionChannel(collection, type: type);

  static DocumentChannel document(
    String collection,
    String documentId, {
    DocumentEventType type = DocumentEventType.all,
  }) => DocumentChannel(
    collection: collection,
    documentId: documentId,
    type: type,
  );

  static BucketChannel bucket(
    String bucket, {
    FileEventType type = FileEventType.all,
  }) => BucketChannel(bucket, type: type);

  static FileChannel file(
    String bucket,
    String fileId, {
    FileEventType type = FileEventType.all,
  }) => FileChannel(
    bucket: bucket,
    fileId: fileId,
    type: type,
  );

  static CustomChannel custom(String name) => CustomChannel(name);

  String build();
}

class CustomChannel extends Channel {
  final String name;

  CustomChannel(this.name);

  @override
  String build() => name;
}

enum DocumentEventType {
  all(null),
  create('created'),
  update('updated'),
  delete('deleted');

  final String? value;

  const DocumentEventType(this.value);
}

class CollectionChannel extends Channel {
  final String name;
  final DocumentEventType type;

  CollectionChannel(this.name, {this.type = DocumentEventType.all});

  @override
  String build() {""");
    b.writeln(
      r"    return '$name.*${type.value != null ? '.${type.value}' : ''}';",
    );
    b.writeln(r"""  }
}

enum FileEventType {
  all(null),
  uploaded('uploaded'),
  moved('moved'),
  deleted('deleted');

  final String? value;

  const FileEventType(this.value);
}

class BucketChannel extends Channel {
  final String name;
  final FileEventType type;

  BucketChannel(this.name, {this.type = FileEventType.all});

  @override
  String build() {""");
    b.writeln(
      r"    return '$name.*${type.value != null ? '.${type.value}' : ''}';",
    );
    b.writeln(r"""  }
}

class FileChannel extends Channel {
  final String bucket;
  final String fileId;
  final FileEventType type;

  FileChannel({
    required this.bucket,
    required this.fileId,
    this.type = FileEventType.all,
  });

  @override
  String build() {""");
    b.writeln(
      r"    return '$bucket.$fileId${type.value != null ? '.${type.value}' : ''}';",
    );
    b.writeln(r"""  }
}

class DocumentChannel extends Channel {
  final String collection;
  final String documentId;
  final DocumentEventType type;

  DocumentChannel({
    required this.collection,
    required this.documentId,
    this.type = DocumentEventType.all,
  });

  @override
  String build() {""");
    b.writeln(
      r"    return '$collection.$documentId${type.value != null ? '.${type.value}' : ''}';",
    );
    b.writeln(r"""  }
}""");
    return b.toString();
  }

  String _genReplayLastStream() => '''
import 'dart:async';

class ReplayLastStream<T> {
  final _controller = StreamController<T>.broadcast();
  Value<T?>? _lastValue;

  void add(T value) {
    _lastValue = Value(value);

    _controller.add(value);
  }

  Stream<T?> get stream async* {
    if (_lastValue != null) yield _lastValue!.value;
    yield* _controller.stream;
  }

  Future<void> close() => _controller.close();
}

class Value<T> {
  T? value;
  Value(this.value);
}
''';

  String _genNonce() => r"""
import 'dart:convert';
import 'dart:math';

import 'package:crypto/crypto.dart';

/// Generates a cryptographically random nonce and its SHA-256 hash.
///
/// Returns a record with:
/// - `raw`: the raw nonce string (sent to the server for verification)
/// - `hashed`: the SHA-256 hex digest (passed to the identity provider)
({String raw, String hashed}) generateNonce([int length = 32]) {
  final random = Random.secure();
  final raw = List.generate(length, (_) => random.nextInt(256))
      .map((b) => b.toRadixString(16).padLeft(2, '0'))
      .join();
  final hashed = sha256.convert(utf8.encode(raw)).toString();
  return (raw: raw, hashed: hashed);
}
""";

  // ===== README generation =====

  String _genReadme(List<Map<String, Object?>> allRoutes) {
    final buffer = StringBuffer();

    buffer.writeln('<!-- GENERATED CODE - DO NOT MODIFY BY HAND -->');
    buffer.writeln('');
    buffer.writeln('# vanestack_client');
    buffer.writeln('');
    buffer.writeln(
      'Auto-generated typed HTTP client SDK for VaneStack. Provides a complete '
      'Dart API for all server endpoints with built-in auth management and '
      'realtime subscriptions.',
    );
    buffer.writeln('');
    buffer.writeln(
      '**This package is generated** — do not edit manually. Regenerate with:',
    );
    buffer.writeln('');
    buffer.writeln('```bash');
    buffer.writeln('cd server');
    buffer.writeln('dart run bin/vanestack.dart generate');
    buffer.writeln('```');
    buffer.writeln('');
    buffer.writeln('## Usage');
    buffer.writeln('');
    buffer.writeln('```dart');
    buffer.writeln("import 'package:vanestack_client/vanestack_client.dart';");
    buffer.writeln('');
    buffer.writeln('final client = VaneStackClient(');
    buffer.writeln("  baseUrl: 'http://localhost:8090',");
    buffer.writeln('  authStorage: MemoryAuthStorage(),');
    buffer.writeln(');');
    buffer.writeln('await client.initialize();');
    buffer.writeln('```');
    buffer.writeln('');
    buffer.writeln('## API');
    buffer.writeln('');

    // Group routes the same way the client does
    final groupedRoutes = <String, List<Map<String, Object?>>>{};
    for (final route in allRoutes) {
      final path = route['path'] as String;
      final segments = path
          .split('/')
          .where((s) => s.isNotEmpty && s != 'v1' && !s.startsWith('<'))
          .toList();
      final group = segments.isNotEmpty ? segments.first : 'root';
      groupedRoutes.putIfAbsent(group, () => []).add(route);
    }

    // Generate a section per route group
    for (final entry in groupedRoutes.entries) {
      final groupName = entry.key;
      final camel = _toCamelCase(groupName);
      final routes = entry.value;

      buffer.writeln('### `client.$camel`');
      buffer.writeln('');
      buffer.writeln('| Method | Path | Function |');
      buffer.writeln('|--------|------|----------|');

      for (final route in routes) {
        final fnName = route['functionName'] as String;
        final method = (route['method'] as String).toUpperCase();
        final path = route['path'] as String;
        buffer.writeln('| `$method` | `$path` | `$camel.$fnName()` |');
      }

      buffer.writeln('');
    }

    // Realtime section
    buffer.writeln('### `client.realtime`');
    buffer.writeln('');
    buffer.writeln('```dart');
    buffer.writeln(
      'final (stream, unsubscribe) = await client.realtime.subscribe(',
    );
    buffer.writeln(
      "  channel: Channel.collection('posts', type: DocumentEventType.create),",
    );
    buffer.writeln(');');
    buffer.writeln('stream.listen((event) => print(event));');
    buffer.writeln('unsubscribe(); // when done');
    buffer.writeln('```');
    buffer.writeln('');

    // Filtering & sorting
    buffer.writeln('## Filtering & Sorting');
    buffer.writeln('');
    buffer.writeln('```dart');
    buffer.writeln('final filter = Filter.and([');
    buffer.writeln("  Filter.where('status', isEqualTo: 'published'),");
    buffer.writeln("  Filter.where('views', isGreaterThan: 100),");
    buffer.writeln(']);');
    buffer.writeln('');
    buffer.writeln(
      "final orderBy = OrderBy('createdAt', direction: SortDirection.desc);",
    );
    buffer.writeln('```');
    buffer.writeln('');

    // Auth storage
    buffer.writeln('## Auth Storage');
    buffer.writeln('');
    buffer.writeln('Implement `AuthStorage` for persistent token storage:');
    buffer.writeln('');
    buffer.writeln('```dart');
    buffer.writeln('abstract class AuthStorage {');
    buffer.writeln('  Future<void> save(String key, String value);');
    buffer.writeln('  Future<String?> read(String key);');
    buffer.writeln('  Future<void> delete(String key);');
    buffer.writeln('}');
    buffer.writeln('```');
    buffer.writeln('');
    buffer.writeln(
      '`MemoryAuthStorage` is included for testing/non-persistent use.',
    );
    buffer.writeln('');

    // Features
    buffer.writeln('## Features');
    buffer.writeln('');
    buffer.writeln('- Automatic token refresh on 401 responses');
    buffer.writeln('- Retry with backoff on 503');
    buffer.writeln('- SSE-based realtime subscriptions with channel filtering');
    buffer.writeln('- User state stream via `client.onUserChanges`');
    buffer.writeln('- Multipart file uploads');

    return buffer.toString();
  }

  // ===== Client generation =====

  String _genClient(List<Map<String, Object?>> allRoutes) {
    final buffer = StringBuffer();

    buffer.writeln('// GENERATED CODE - DO NOT MODIFY BY HAND');
    buffer.writeln('');
    buffer.writeln(_clientImports());
    buffer.writeln(_clientClassStart());

    // Group routes by first non-param path segment (after /v1/ if present)
    final groupedRoutes = <String, List<Map<String, Object?>>>{};
    for (final route in allRoutes) {
      final path = route['path'] as String;
      final segments = path
          .split('/')
          .where((s) => s.isNotEmpty && s != 'v1' && !s.startsWith('<'))
          .toList();
      final group = segments.isNotEmpty ? segments.first : 'root';
      groupedRoutes.putIfAbsent(group, () => []).add(route);
    }

    // Write subclient declarations
    for (final entry in groupedRoutes.entries) {
      final camel = _toCamelCase(entry.key);
      final className = '_${camel[0].toUpperCase()}${camel.substring(1)}Routes';
      buffer.writeln('  late final $camel = $className(this);');
    }

    buffer.writeln('}');
    buffer.writeln('');

    // Write _RealtimeRoutes class
    buffer.writeln(_realtimeRoutesClass());

    // Write route group classes
    for (final entry in groupedRoutes.entries) {
      final groupName = entry.key;
      if (groupName == 'realtime') continue;

      final camel = _toCamelCase(groupName);
      final className = '_${camel[0].toUpperCase()}${camel.substring(1)}Routes';
      buffer.writeln('class $className {');
      buffer.writeln('  final VaneStackClient _vanestack;');
      buffer.writeln('  $className(this._vanestack);');

      // Add setSession to auth group
      if (groupName == 'auth') {
        buffer.writeln(_setSessionMethod());
      }

      for (final route in entry.value) {
        buffer.writeln(_genRouteMethod(route));
      }

      buffer.writeln('}');
      buffer.writeln('');
    }

    return buffer.toString();
  }

  String _clientImports() => r"""
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
""";

  String _clientClassStart() => r"""
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
""";

  String _realtimeRoutesClass() => r"""
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
""";

  String _setSessionMethod() => r'''
  /// Sets the session using a refresh token from an OAuth callback.
  ///
  /// Saves the refresh token and calls the server's refresh endpoint
  /// to get a valid access token and user data.
  Future<AuthResponse> setSession({required String refreshToken}) async {
    await _vanestack.authStorage.save(_vanestack._refreshTokenKey, refreshToken);
    return refresh();
  }
''';

  String _genRouteMethod(Map<String, Object?> route) {
    final fnName = route['functionName'] as String;
    final method = route['method'] as String;
    final path = route['path'] as String;
    final pathParams = (route['pathParams'] as List).cast<String>();
    final bodyParams = (route['bodyParams'] as List)
        .cast<Map<String, Object?>>();
    final returnTypeName = route['returnTypeName'] as String;
    final flags = (route['returnTypeFlags'] as Map).cast<String, Object?>();

    final isStream = flags['isStream'] as bool;
    final isList = flags['isList'] as bool;
    final isBool = flags['isBool'] as bool;
    final isString = flags['isString'] as bool;
    final isNum = flags['isNum'] as bool;
    final isMap = flags['isMap'] as bool;
    final isVoid = flags['isVoid'] as bool;
    final isFileResponse = flags['isFileResponse'] as bool;
    final listItemTypeName = flags['listItemTypeName'] as String?;

    final buffer = StringBuffer();

    // Method signature
    if (isStream) {
      buffer.writeln(
        '  Future<(Stream<$returnTypeName>, void Function())> $fnName(',
      );
    } else if (isFileResponse) {
      buffer.writeln('  Future<Uint8List> $fnName(');
    } else {
      buffer.writeln('  Future<$returnTypeName> $fnName(');
    }

    // Parameters
    if (pathParams.isNotEmpty || bodyParams.isNotEmpty || fnName == 'upload') {
      buffer.writeln('  {');
      for (final param in pathParams) {
        buffer.writeln('    required String $param,');
      }
      for (final bp in bodyParams) {
        final typeName = bp['typeName'] as String;
        final isOptional = bp['isOptional'] as bool;
        final isNullable = bp['isNullable'] as bool;
        final defaultValue = bp['defaultValue'] as String?;

        final requiredStr = (isNullable || isOptional) ? '' : 'required ';
        final defaultStr = defaultValue != null ? ' = $defaultValue' : '';
        buffer.writeln('    $requiredStr$typeName ${bp['name']}$defaultStr,');
      }
      if (fnName == 'upload') {
        buffer.writeln('    required MultipartFile file,');
        buffer.writeln('    required String filePath,');
      }
      buffer.writeln('  }');
    }
    buffer.writeln('  ) async {');

    // Build URL
    _buildUrl(buffer, path, pathParams);

    if (isStream) {
      _buildSseBody(
        buffer,
        returnTypeName,
        isList,
        isNum,
        isString,
        isMap,
        listItemTypeName,
      );
    } else {
      _buildHttpBody(
        buffer,
        fnName: fnName,
        method: method,
        path: path,
        pathParams: pathParams,
        bodyParams: bodyParams,
        returnTypeName: returnTypeName,
        isList: isList,
        isBool: isBool,
        isString: isString,
        isVoid: isVoid,
        isFileResponse: isFileResponse,
        listItemTypeName: listItemTypeName,
      );
    }

    buffer.writeln('  }');
    return buffer.toString();
  }

  void _buildUrl(StringBuffer buffer, String path, List<String> pathParams) {
    if (pathParams.isEmpty) {
      buffer.writeln(
        "    final url = Uri.parse('\${_vanestack.baseUrl}$path');",
      );
    } else {
      buffer.writeln("    final endpointPath = '$path'.replaceAllMapped(");
      buffer.writeln("      RegExp(r'<([^>]+)>'),");
      buffer.writeln('      (match) {');
      buffer.writeln('        final key = match.group(1)!;');
      for (final param in pathParams) {
        buffer.writeln(
          "        if (key == '$param') { return Uri.encodeComponent($param); }",
        );
      }
      buffer.writeln('        return key;');
      buffer.writeln('      },');
      buffer.writeln('    );');
      buffer.writeln(
        "    final url = Uri.parse('\${_vanestack.baseUrl}\$endpointPath');",
      );
    }
  }

  void _buildSseBody(
    StringBuffer buffer,
    String returnTypeName,
    bool isList,
    bool isNum,
    bool isString,
    bool isMap,
    String? listItemTypeName,
  ) {
    buffer.writeln('''
      final channel = SseChannel.connect(
        url.toString(),
        client: _vanestack._client as BaseClient,
      );

      await channel.ready;
      void unsubscribe() {
        channel.close();
      }

      final stream = channel.stream.where((e) => e.data != null).map((event) {
          final data = event.data;
    ''');

    if (isNum || isString) {
      buffer.writeln('      return data as $returnTypeName;');
    } else if (isList && listItemTypeName != null) {
      buffer.writeln(
        "      return (jsonDecode(data!) as List).map((e) => ${listItemTypeName}Mapper.fromJson(e as Map<String, Object?>)).toList();",
      );
    } else if (isMap) {
      buffer.writeln(
        '      return Map<String, Object?>.from(jsonDecode(data!) as Map);',
      );
    } else {
      buffer.writeln(
        '      final parsed = ${returnTypeName}Mapper.fromJsonString(data!);',
      );
      buffer.writeln('      return parsed;');
    }

    buffer.writeln('    });');
    buffer.writeln('    return (stream, unsubscribe);');
  }

  void _buildHttpBody(
    StringBuffer buffer, {
    required String fnName,
    required String method,
    required String path,
    required List<String> pathParams,
    required List<Map<String, Object?>> bodyParams,
    required String returnTypeName,
    required bool isList,
    required bool isBool,
    required bool isString,
    required bool isVoid,
    required bool isFileResponse,
    String? listItemTypeName,
  }) {
    // Special case: refresh
    if (fnName == 'refresh') {
      buffer.writeln(
        "    final refreshToken = await _vanestack.authStorage.read(_vanestack._refreshTokenKey);",
      );
      buffer.writeln(
        "    if (refreshToken == null) throw Exception('No refresh token stored');",
      );
      buffer.writeln(
        "    final response = await _vanestack._inner.$method(url, headers: {'Authorization': 'Bearer \$refreshToken'},);",
      );
    } else if (fnName == 'upload') {
      buffer.writeln("    final request = MultipartRequest('$method', url);");
      buffer.writeln("    request.files.add(file);");
      buffer.writeln("    request.fields['path'] = filePath;");
      buffer.writeln(
        "    final streamedResponse = await _vanestack.send(request, headers: {'Content-Type': 'multipart/form-data'});",
      );
      buffer.writeln(
        '    final response = await Response.fromStream(streamedResponse);',
      );
    } else {
      // Build body map if there are body params
      if (bodyParams.isNotEmpty) {
        buffer.writeln('    final body = {');
        for (final bp in bodyParams) {
          final name = bp['name'] as String;
          final isDateTime = bp['isDateTime'] as bool? ?? false;
          final isEnum = bp['isEnum'] as bool? ?? false;

          if (isDateTime) {
            buffer.writeln("      '$name': $name.millisecondsSinceEpoch,");
          } else if (isEnum) {
            buffer.writeln("      '$name': $name.name,");
          } else {
            buffer.writeln("      '$name': $name,");
          }
        }
        buffer.writeln('    };');
      }

      if (bodyParams.isNotEmpty) {
        if (method == 'get' || method == 'delete') {
          buffer.writeln(
            "    final query = body.map((k, v) => MapEntry(k, v.toString()));",
          );
          buffer.writeln(
            "    final response = await _vanestack._client.$method(url.replace(queryParameters: query));",
          );
        } else {
          buffer.writeln(
            "    final response = await _vanestack._client.$method(url, headers: {'Content-Type': 'application/json'}, body: jsonEncode(body));",
          );
        }
      } else {
        buffer.writeln(
          "    final response = await _vanestack._client.$method(url);",
        );
      }
    }

    // Handle response
    if (isFileResponse) {
      buffer.writeln(
        "    if (response.statusCode < 200 || response.statusCode >= 300) { "
        "final result = response.body.isNotEmpty ? response.body : null;"
        "throw VaneStackException.fromJson(response.statusCode, result); }",
      );
      buffer.writeln('    return response.bodyBytes;');
    } else {
      buffer.writeln(
        '    final result = response.body.isNotEmpty ? response.body : null;',
      );
      buffer.writeln(
        "    if (response.statusCode < 200 || response.statusCode >= 300) { throw VaneStackException.fromJson(response.statusCode, result); }",
      );

      if (fnName == 'logout') {
        buffer.writeln('    await _vanestack._clearAuthData();');
      }

      if (!isVoid) {
        buffer.writeln(
          "    if (result == null) {throw VaneStackException('Empty response body', status:400);}",
        );
        if (isList && listItemTypeName != null) {
          buffer.writeln(
            "    final parsed = (jsonDecode(result) as List).map((e) => ${listItemTypeName}Mapper.fromJson(e as Map<String, Object?>)).toList();",
          );
        } else if (isBool) {
          buffer.writeln("    final parsed = bool.parse(result);");
        } else if (isString) {
          buffer.writeln("    final parsed = result;");
        } else {
          buffer.writeln(
            "    final parsed = ${returnTypeName}Mapper.fromJsonString(result);",
          );
        }
        if (returnTypeName == 'AuthResponse') {
          buffer.writeln('    await _vanestack._saveAuthResponse(parsed);');
        }
        buffer.writeln('    return parsed;');
      }
    }
  }
}
