import 'dart:convert';
import 'dart:io';

import 'package:args/command_runner.dart';
import 'package:vanestack_common/vanestack_common.dart';

import '../database/database.dart';
import '../services/context.dart';
import '../services/logs_service.dart';
import '../utils/env.dart';
import 'stdout.dart';

const _jsonEncoder = JsonEncoder.withIndent('  ');

class LogsCommand extends Command {
  @override
  String get description => 'View application logs.';

  @override
  String get name => 'logs';

  LogsCommand(Environment env) {
    addSubcommand(ListLogsCommand(env));
  }
}

ServiceContext _createContext(Environment env) {
  return (database: AppDatabase(null, env.databasePath), env: env, realtime: null, hooks: null);
}

class ListLogsCommand extends Command {
  final Environment env;

  @override
  String get description => 'List application logs.';

  @override
  String get name => 'list';

  ListLogsCommand(this.env) {
    argParser
      ..addOption(
        'limit',
        abbr: 'l',
        help: 'Maximum number of logs to return.',
        defaultsTo: '20',
      )
      ..addOption(
        'offset',
        abbr: 'o',
        help: 'Number of logs to skip.',
        defaultsTo: '0',
      )
      ..addOption('filter', abbr: 'f', help: 'Filter expression.')
      ..addOption('order-by', help: 'Order by expression.')
      ..addFlag('json', abbr: 'j', help: 'Output as JSON.', defaultsTo: false);
  }

  @override
  Future<void> run() async {
    final limitStr = argResults?['limit'] as String;
    final offsetStr = argResults?['offset'] as String;
    final filter = argResults?['filter'] as String?;
    final orderBy = argResults?['order-by'] as String?;
    final asJson = argResults?['json'] as bool;

    final limit = int.tryParse(limitStr) ?? 20;
    final offset = int.tryParse(offsetStr) ?? 0;

    final service = LogsService(_createContext(env));

    try {
      final result = await service.list(
        filter: filter,
        orderBy: orderBy,
        limit: limit,
        offset: offset,
      );

      if (asJson) {
        print(_jsonEncoder.convert(result.toJson()));
      } else {
        print('Logs (${result.count} total):');
        for (final log in result.logs) {
          final levelColor = switch (log.level) {
            LogLevel.debug => (String s) => s,
            LogLevel.info => green,
            LogLevel.warn => yellow,
            LogLevel.error => red,
            LogLevel.none => (String s) => s,
          };
          print(
            '  ${log.createdAt} ${levelColor(log.level.name.toUpperCase().padRight(5))} [${log.source.name}] ${log.message}',
          );
        }
        if (result.logs.isEmpty) {
          print(yellow('  No logs found.'));
        }
      }
      exit(0);
    } on VaneStackException catch (e) {
      print(red(e.message));
      exit(1);
    }
  }
}
