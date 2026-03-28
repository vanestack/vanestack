import 'dart:io' as io;

import 'package:vanestack_common/vanestack_common.dart';
import 'package:drift/drift.dart' hide Index;
import 'package:drift/native.dart';

import 'package:sqlite3/sqlite3.dart';
import 'package:uuid/uuid.dart';

import '../utils/random_name.dart';
import 'tables/buckets.dart';
import 'tables/collections.dart';
import 'tables/external_auths.dart';
import 'tables/files.dart';
import 'tables/logs.dart';
import 'tables/oauth_states.dart';
import 'tables/otps.dart';
import 'tables/refresh_tokens.dart';
import 'tables/reset_password_tokens.dart';
import 'tables/settings.dart';
import 'tables/users.dart';

part 'database.g.dart';

@DriftDatabase(
  tables: [
    Users,
    RefreshTokens,
    ResetPasswordTokens,
    Logs,
    Collections,
    AppSettings,
    Otps,
    Files,
    Buckets,
    OauthStates,
    ExternalAuths,
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase([QueryExecutor? executor, String path = './database.sqlite'])
    : super(executor ?? _openConnection(path));

  @override
  int get schemaVersion => 7;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (m) async {
      await m.createAll();
      appSettings.insertOne(
        AppSettingsCompanion.insert(
          appName: generateRandomName(),
          oauthProviders: const OAuthProviderList(),
        ),
      );
    },
    onUpgrade: (m, from, to) async {
      if (from < 2) {
        await m.createTable(oauthStates);
      }

      if (from < 3) {
        await m.addColumn(oauthStates, oauthStates.redirectUrl);
      }

      if (from < 5) {
        await m.addColumn(collections, collections.type);
        await m.addColumn(collections, collections.viewQuery);
      }

      if (from < 6) {
        await m.deleteTable('_logs');
        await m.createTable(logs);
      }

      if (from < 7) {
        await m.createTable(externalAuths);
      }
    },
  );

  static QueryExecutor _openConnection(String path) {
    return NativeDatabase.createInBackground(io.File(path), setup: setup);
  }

  static void setup(Database database) {
    database.execute('pragma journal_mode = WAL;');
    database.execute('pragma synchronous = NORMAL;');
    database.execute('pragma cache_size = -8000;');
    database.execute('pragma busy_timeout = 5000;');
    database.execute('pragma temp_store = memory;');
    database.createFunction(
      functionName: 'random_uuid_v7',
      directOnly: false,
      argumentCount: AllowedArgumentCount(0),
      function: (_) {
        return const Uuid().v7();
      },
    );
  }
}
