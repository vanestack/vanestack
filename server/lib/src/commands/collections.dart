import 'dart:convert';
import 'dart:io';

import 'package:args/command_runner.dart';
import 'package:vanestack_common/vanestack_common.dart' hide File;

import '../database/database.dart';
import '../services/collections_service.dart';
import '../services/context.dart';
import '../utils/env.dart';
import 'stdout.dart';

const _jsonEncoder = JsonEncoder.withIndent('  ');

class CollectionsCommand extends Command {
  @override
  String get description => 'Manage collections.';

  @override
  String get name => 'collections';

  CollectionsCommand(Environment env) {
    addSubcommand(ListCollectionsCommand(env));
    addSubcommand(CreateCollectionCommand(env));
    addSubcommand(CreateViewCommand(env));
    addSubcommand(DeleteCollectionCommand(env));
    addSubcommand(GenerateCommand(env));
    addSubcommand(ExportCommand(env));
    addSubcommand(ImportCommand(env));
  }
}

ServiceContext _createContext(Environment env) {
  return (
    database: AppDatabase.fromEnv(env),
    env: env,
    realtime: null,
    hooks: null,
  );
}

class ListCollectionsCommand extends Command {
  final Environment env;

  @override
  String get description => 'List all collections.';

  @override
  String get name => 'list';

  ListCollectionsCommand(this.env) {
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
    final service = CollectionsService(_createContext(env));

    try {
      final collections = await service.list();

      if (asJson) {
        print(
          _jsonEncoder.convert(collections.map((c) => c.toJson()).toList()),
        );
      } else {
        if (collections.isEmpty) {
          print(yellow('No collections found.'));
        } else {
          print('Collections (${collections.length}):');
          for (final collection in collections) {
            final type = collection is ViewCollection ? 'view' : 'base';
            final attrCount = collection.attributes.length;
            print('  - ${collection.name} ($type, $attrCount attributes)');
          }
        }
      }
      exit(0);
    } on VaneStackException catch (e) {
      print(red(e.message));
      exit(1);
    }
  }
}

class CreateCollectionCommand extends Command {
  final Environment env;

  @override
  String get description => 'Create a new base collection.';

  @override
  String get name => 'create';

  CreateCollectionCommand(this.env) {
    argParser
      ..addOption(
        'name',
        abbr: 'n',
        help: 'The name of the collection.',
        mandatory: true,
      )
      ..addOption('attributes', abbr: 'a', help: 'JSON array of attributes.')
      ..addOption('indexes', abbr: 'i', help: 'JSON array of indexes.')
      ..addOption('list-rule', help: 'Rule for listing documents.')
      ..addOption('view-rule', help: 'Rule for viewing documents.')
      ..addOption('create-rule', help: 'Rule for creating documents.')
      ..addOption('update-rule', help: 'Rule for updating documents.')
      ..addOption('delete-rule', help: 'Rule for deleting documents.');
  }

  @override
  Future<void> run() async {
    final name = argResults?['name'] as String;
    final attributesJson = argResults?['attributes'] as String?;
    final indexesJson = argResults?['indexes'] as String?;
    final listRule = argResults?['list-rule'] as String?;
    final viewRule = argResults?['view-rule'] as String?;
    final createRule = argResults?['create-rule'] as String?;
    final updateRule = argResults?['update-rule'] as String?;
    final deleteRule = argResults?['delete-rule'] as String?;

    List<Attribute> attributes = [];
    List<Index> indexes = [];

    if (attributesJson != null) {
      try {
        final parsed = jsonDecode(attributesJson) as List;
        attributes = parsed
            .map((a) => AttributeMapper.fromJson(a as Map<String, dynamic>))
            .toList();
      } catch (e) {
        print(red('Invalid attributes JSON: $e'));
        exit(1);
      }
    }

    if (indexesJson != null) {
      try {
        final parsed = jsonDecode(indexesJson) as List;
        indexes = parsed
            .map((i) => IndexMapper.fromJson(i as Map<String, dynamic>))
            .toList();
      } catch (e) {
        print(red('Invalid indexes JSON: $e'));
        exit(1);
      }
    }

    final service = CollectionsService(_createContext(env));

    try {
      final collection = await service.createBase(
        name: name,
        attributes: attributes,
        indexes: indexes,
        listRule: listRule,
        viewRule: viewRule,
        createRule: createRule,
        updateRule: updateRule,
        deleteRule: deleteRule,
      );
      print(green('Collection "${collection.name}" created successfully.'));
      exit(0);
    } on VaneStackException catch (e) {
      print(red(e.message));
      exit(1);
    }
  }
}

class CreateViewCommand extends Command {
  final Environment env;

  @override
  String get description => 'Create a new view collection.';

  @override
  String get name => 'create-view';

  CreateViewCommand(this.env) {
    argParser
      ..addOption(
        'name',
        abbr: 'n',
        help: 'The name of the view collection.',
        mandatory: true,
      )
      ..addOption(
        'query',
        abbr: 'q',
        help: 'The SQL query for the view.',
        mandatory: true,
      )
      ..addOption('list-rule', help: 'Rule for listing documents.')
      ..addOption('view-rule', help: 'Rule for viewing documents.');
  }

  @override
  Future<void> run() async {
    final name = argResults?['name'] as String;
    final viewQuery = argResults?['query'] as String;
    final listRule = argResults?['list-rule'] as String?;
    final viewRule = argResults?['view-rule'] as String?;

    final service = CollectionsService(_createContext(env));

    try {
      final collection = await service.createView(
        name: name,
        viewQuery: viewQuery,
        listRule: listRule,
        viewRule: viewRule,
      );
      print(
        green('View collection "${collection.name}" created successfully.'),
      );
      exit(0);
    } on VaneStackException catch (e) {
      print(red(e.message));
      exit(1);
    }
  }
}

class DeleteCollectionCommand extends Command {
  final Environment env;

  @override
  String get description => 'Delete a collection.';

  @override
  String get name => 'delete';

  DeleteCollectionCommand(this.env) {
    argParser
      ..addOption(
        'name',
        abbr: 'n',
        help: 'The name of the collection to delete.',
        mandatory: true,
      )
      ..addFlag(
        'force',
        abbr: 'f',
        help: 'Skip confirmation prompt.',
        defaultsTo: false,
      );
  }

  @override
  Future<void> run() async {
    final name = argResults?['name'] as String;
    final force = argResults?['force'] as bool;

    final service = CollectionsService(_createContext(env));

    try {
      // Check if collection exists
      final collection = await service.getByName(name);
      if (collection == null) {
        print(red('Collection "$name" not found.'));
        exit(1);
      }

      if (!force) {
        stdout.write(
          'Are you sure you want to delete collection "$name"? [y/N] ',
        );
        final response = stdin.readLineSync()?.toLowerCase();
        if (response != 'y' && response != 'yes') {
          print('Aborted.');
          exit(0);
        }
      }

      await service.delete(name);
      print(green('Collection "$name" deleted successfully.'));
      exit(0);
    } on VaneStackException catch (e) {
      print(red(e.message));
      exit(1);
    }
  }
}

class GenerateCommand extends Command {
  final Environment env;

  @override
  String get description => 'Generate fake documents for a collection.';

  @override
  String get name => 'generate';

  GenerateCommand(this.env) {
    argParser
      ..addOption(
        'name',
        abbr: 'n',
        help: 'The name of the collection.',
        mandatory: true,
      )
      ..addOption(
        'count',
        abbr: 'c',
        help: 'Number of documents to generate.',
        defaultsTo: '10',
      );
  }

  @override
  Future<void> run() async {
    final name = argResults?['name'] as String;
    final countStr = argResults?['count'] as String;
    final count = int.tryParse(countStr);

    if (count == null || count <= 0) {
      print(red('Invalid count: $countStr. Must be a positive integer.'));
      exit(1);
    }

    final service = CollectionsService(_createContext(env));

    try {
      final result = await service.generate(collectionName: name, count: count);
      print(
        green('Generated ${result.count} documents in collection "$name".'),
      );
      exit(0);
    } on VaneStackException catch (e) {
      print(red(e.message));
      exit(1);
    }
  }
}

class ExportCommand extends Command {
  final Environment env;

  @override
  String get description => 'Export collections to JSON.';

  @override
  String get name => 'export';

  ExportCommand(this.env) {
    argParser.addOption(
      'output',
      abbr: 'o',
      help: 'Output file path (default: stdout).',
    );
  }

  @override
  Future<void> run() async {
    final outputPath = argResults?['output'] as String?;

    final service = CollectionsService(_createContext(env));

    try {
      final export = await service.export();

      final json = _jsonEncoder.convert(export.toJson());

      if (outputPath != null) {
        final file = File(outputPath);
        await file.writeAsString(json);
        print(
          green(
            'Exported ${export.collections.length} collections to $outputPath',
          ),
        );
      } else {
        print(json);
      }
      exit(0);
    } on VaneStackException catch (e) {
      print(red(e.message));
      exit(1);
    }
  }
}

class ImportCommand extends Command {
  final Environment env;

  @override
  String get description => 'Import collections from JSON file.';

  @override
  String get name => 'import';

  ImportCommand(this.env) {
    argParser
      ..addOption(
        'file',
        abbr: 'f',
        help: 'Path to JSON file containing collections.',
        mandatory: true,
      )
      ..addFlag(
        'overwrite',
        abbr: 'o',
        help: 'Overwrite existing collections.',
        defaultsTo: false,
      );
  }

  @override
  Future<void> run() async {
    final filePath = argResults?['file'] as String;
    final overwrite = argResults?['overwrite'] as bool;

    final file = File(filePath);
    if (!file.existsSync()) {
      print(red('File not found: $filePath'));
      exit(1);
    }

    List<Map<String, dynamic>> collections;
    try {
      final content = await file.readAsString();
      final parsed = jsonDecode(content);
      if (parsed is List) {
        collections = parsed.cast<Map<String, dynamic>>();
      } else {
        print(red('Invalid JSON: expected an array of collections.'));
        exit(1);
      }
    } catch (e) {
      print(red('Failed to parse JSON: $e'));
      exit(1);
    }

    final service = CollectionsService(_createContext(env));

    try {
      final result = await service.import(
        collections: collections,
        overwrite: overwrite,
      );

      print(green('Import complete:'));
      print('  Created: ${result.created}');
      print('  Updated: ${result.updated}');
      print('  Skipped: ${result.skipped}');
      exit(0);
    } on VaneStackException catch (e) {
      print(red(e.message));
      exit(1);
    }
  }
}
