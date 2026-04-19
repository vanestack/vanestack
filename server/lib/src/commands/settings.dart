import 'dart:convert';
import 'dart:io';

import 'package:args/command_runner.dart';
import 'package:vanestack_common/vanestack_common.dart' hide File;

import '../database/database.dart';
import '../services/context.dart';
import '../services/settings_service.dart';
import '../utils/env.dart';
import 'stdout.dart';

const _jsonEncoder = JsonEncoder.withIndent('  ');

class SettingsCommand extends Command {
  @override
  String get description => 'Manage application settings.';

  @override
  String get name => 'settings';

  SettingsCommand(Environment env) {
    addSubcommand(GetSettingsCommand(env));
    addSubcommand(UpdateSettingsCommand(env));
    addSubcommand(TestS3Command(env));
    addSubcommand(GenerateAppleSecretCommand(env));
  }
}

ServiceContext _createContext(Environment env) {
  return (
    database: AppDatabase.fromEnv(env),
    env: env,
    realtime: null,
    hooks: null,
    collectionsCache: null,
  );
}

int _countOAuthProviders(OAuthProviderList providers) {
  var count = 0;
  if (providers.google != null) count++;
  if (providers.apple != null) count++;
  if (providers.facebook != null) count++;
  if (providers.github != null) count++;
  if (providers.linkedin != null) count++;
  if (providers.slack != null) count++;
  if (providers.spotify != null) count++;
  if (providers.reddit != null) count++;
  if (providers.twitch != null) count++;
  if (providers.discord != null) count++;
  return count;
}

class GetSettingsCommand extends Command {
  final Environment env;

  @override
  String get description => 'Get current application settings.';

  @override
  String get name => 'get';

  GetSettingsCommand(this.env) {
    argParser.addFlag(
      'json',
      abbr: 'j',
      help: 'Output as JSON.',
      defaultsTo: false,
    );
  }

  @override
  Future<void> run() async {
    final asJson = argResults?['json'] as bool;
    final service = SettingsService(_createContext(env));

    try {
      final settings = await service.get();

      if (asJson) {
        print(_jsonEncoder.convert(settings.toJson()));
      } else {
        print('Application Settings:');
        print('  App Name: ${settings.appName}');
        print('  Site URL: ${settings.siteUrl.isEmpty ? '(not set)' : settings.siteUrl}');
        print('  Redirect URLs: ${settings.redirectUrls.isEmpty ? '(not set)' : settings.redirectUrls.join(', ')}');
        print('  S3 Storage: ${settings.s3 != null ? 'Configured' : 'Not configured'}');
        print('  Mail: ${settings.mail != null ? 'Configured' : 'Not configured'}');
        print('  OAuth Providers: ${_countOAuthProviders(settings.oauthProviders)} configured');
        print('  Created: ${settings.createdAt}');
        print('  Updated: ${settings.updatedAt}');
      }
      exit(0);
    } on VaneStackException catch (e) {
      print(red(e.message));
      exit(1);
    }
  }
}

class UpdateSettingsCommand extends Command {
  final Environment env;

  @override
  String get description => 'Update application settings.';

  @override
  String get name => 'update';

  UpdateSettingsCommand(this.env) {
    argParser
      ..addOption('app-name', abbr: 'n', help: 'Application name.')
      ..addOption('site-url', abbr: 'u', help: 'Site URL.')
      ..addMultiOption(
        'redirect-urls',
        abbr: 'r',
        help: 'Redirect URLs (can be specified multiple times).',
      )
      ..addOption(
        's3',
        help: 'S3 settings as JSON (e.g., \'{"bucket":"my-bucket","region":"us-east-1",...}\').',
      )
      ..addOption(
        'mail',
        help: 'Mail settings as JSON.',
      );
  }

  @override
  Future<void> run() async {
    final appName = argResults?['app-name'] as String?;
    final siteUrl = argResults?['site-url'] as String?;
    final redirectUrls = argResults?['redirect-urls'] as List<String>;
    final s3Json = argResults?['s3'] as String?;
    final mailJson = argResults?['mail'] as String?;

    S3Settings? s3;
    if (s3Json != null) {
      try {
        s3 = S3SettingsMapper.fromJson(jsonDecode(s3Json) as Map<String, dynamic>);
      } catch (e) {
        print(red('Invalid S3 settings JSON: $e'));
        exit(1);
      }
    }

    MailSettings? mail;
    if (mailJson != null) {
      try {
        mail = MailSettingsMapper.fromJson(jsonDecode(mailJson) as Map<String, dynamic>);
      } catch (e) {
        print(red('Invalid mail settings JSON: $e'));
        exit(1);
      }
    }

    final service = SettingsService(_createContext(env));

    try {
      final settings = await service.update(
        appName: appName,
        siteUrl: siteUrl,
        redirectUrls: redirectUrls.isEmpty ? null : redirectUrls,
        s3: s3,
        mail: mail,
      );
      print(green('Settings updated successfully.'));
      print('  App Name: ${settings.appName}');
      print('  Site URL: ${settings.siteUrl.isEmpty ? '(not set)' : settings.siteUrl}');
      exit(0);
    } on VaneStackException catch (e) {
      print(red(e.message));
      exit(1);
    }
  }
}

class TestS3Command extends Command {
  final Environment env;

  @override
  String get description => 'Test S3 connection.';

  @override
  String get name => 'test-s3';

  TestS3Command(this.env);

  @override
  Future<void> run() async {
    final service = SettingsService(_createContext(env));

    try {
      print('Testing S3 connection...');
      await service.testS3Connection();
      print(green('S3 connection successful!'));
      exit(0);
    } on VaneStackException catch (e) {
      print(red(e.message));
      exit(1);
    }
  }
}

class GenerateAppleSecretCommand extends Command {
  final Environment env;

  @override
  String get description => 'Generate Apple client secret JWT for Sign in with Apple.';

  @override
  String get name => 'generate-apple-secret';

  GenerateAppleSecretCommand(this.env) {
    argParser
      ..addOption(
        'client-id',
        abbr: 'c',
        help: 'Apple Services ID (client ID).',
        mandatory: true,
      )
      ..addOption(
        'team-id',
        abbr: 't',
        help: 'Apple Developer Team ID.',
        mandatory: true,
      )
      ..addOption(
        'key-id',
        abbr: 'k',
        help: 'Apple Key ID.',
        mandatory: true,
      )
      ..addOption(
        'private-key',
        abbr: 'p',
        help: 'Path to the .p8 private key file.',
        mandatory: true,
      )
      ..addOption(
        'duration',
        abbr: 'd',
        help: 'Token validity duration in seconds (max 15777000 = 6 months).',
        defaultsTo: '15777000',
      );
  }

  @override
  Future<void> run() async {
    final clientId = argResults?['client-id'] as String;
    final teamId = argResults?['team-id'] as String;
    final keyId = argResults?['key-id'] as String;
    final privateKeyPath = argResults?['private-key'] as String;
    final durationStr = argResults?['duration'] as String;

    final duration = int.tryParse(durationStr);
    if (duration == null || duration <= 0) {
      print(red('Invalid duration: $durationStr. Must be a positive integer.'));
      exit(1);
    }

    // Read private key from file
    final keyFile = File(privateKeyPath);
    if (!keyFile.existsSync()) {
      print(red('Private key file not found: $privateKeyPath'));
      exit(1);
    }

    String privateKey;
    try {
      privateKey = await keyFile.readAsString();
    } catch (e) {
      print(red('Failed to read private key file: $e'));
      exit(1);
    }

    final service = SettingsService(_createContext(env));

    try {
      final secret = service.generateAppleClientSecret(
        clientId: clientId,
        teamId: teamId,
        keyId: keyId,
        privateKey: privateKey,
        duration: duration,
      );

      print(green('Apple client secret generated successfully!'));
      print('');
      print('Client Secret:');
      print(secret);
      print('');
      print(yellow('Note: This secret expires in ${duration ~/ 86400} days.'));
      exit(0);
    } on VaneStackException catch (e) {
      print(red(e.message));
      exit(1);
    }
  }
}
