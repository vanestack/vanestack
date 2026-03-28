import 'dart:io';

import 'package:vanestack/src/database/database.dart';
import 'package:vanestack/src/middleware/decode_jwt.dart';
import 'package:vanestack/src/middleware/inject.dart';
import 'package:vanestack/src/utils/auth.dart';

import 'package:vanestack/src/utils/env.dart';

import 'package:drift/native.dart';
import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart' as shelf_io;

import 'package:test/test.dart';

import 'test_utils.dart';

void main() {
  late Environment env;
  late AppDatabase database;
  late JsonHttpClient client;
  late HttpServer server;

  setUp(() async {
    final port = await findFreePort();
    env = Environment(port: port);
    database = AppDatabase(NativeDatabase.memory(setup: AppDatabase.setup));
    client = JsonHttpClient('127.0.0.1', port);
  });

  tearDown(() async {
    client.close();
    database.close();
    await server.close();
  });

  group('middleware', () {
    test('jwt gets decoded and stored into context properties', () async {
      String? userId;

      final handler = Pipeline()
          .addMiddleware(inject({'database': database, 'env': env}))
          .addMiddleware(decodeJwt())
          .addHandler((final request) async {
            userId = request.context['userId'] as String?;
            return Response.ok(null);
          });

      final jwt = AuthUtils.generateJwt(
        userId: 'test_user',
        jwtSecret: env.jwtSecret,
      );

      server = await shelf_io.serve(handler, InternetAddress.anyIPv4, env.port);

      await client.get('/test', bearer: jwt);

      expect(userId, 'test_user');
    });
  });
}
