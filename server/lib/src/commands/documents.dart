import 'dart:convert';
import 'dart:io';

import 'package:args/command_runner.dart';
import 'package:vanestack_common/vanestack_common.dart';

import '../database/database.dart';
import '../services/context.dart';
import '../services/documents_service.dart';
import '../utils/env.dart';
import 'stdout.dart';

const _jsonEncoder = JsonEncoder.withIndent('  ');

class DocumentsCommand extends Command {
  @override
  String get description => 'Manage documents.';

  @override
  String get name => 'documents';

  DocumentsCommand(Environment env) {
    addSubcommand(ListDocumentsCommand(env));
    addSubcommand(GetDocumentCommand(env));
    addSubcommand(CreateDocumentCommand(env));
    addSubcommand(DeleteDocumentCommand(env));
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

class ListDocumentsCommand extends Command {
  final Environment env;

  @override
  String get description => 'List documents in a collection.';

  @override
  String get name => 'list';

  ListDocumentsCommand(this.env) {
    argParser
      ..addOption(
        'collection',
        abbr: 'c',
        help: 'The name of the collection.',
        mandatory: true,
      )
      ..addOption(
        'limit',
        abbr: 'l',
        help: 'Maximum number of documents to return.',
        defaultsTo: '20',
      )
      ..addOption(
        'offset',
        abbr: 'o',
        help: 'Number of documents to skip.',
        defaultsTo: '0',
      )
      ..addOption('filter', abbr: 'f', help: 'Filter expression.')
      ..addOption('order-by', help: 'Order by expression.')
      ..addFlag('json', abbr: 'j', help: 'Output as JSON.', defaultsTo: false);
  }

  @override
  Future<void> run() async {
    final collectionName = argResults?['collection'] as String;
    final limitStr = argResults?['limit'] as String;
    final offsetStr = argResults?['offset'] as String;
    final filter = argResults?['filter'] as String?;
    final orderBy = argResults?['order-by'] as String?;
    final asJson = argResults?['json'] as bool;

    final limit = int.tryParse(limitStr) ?? 20;
    final offset = int.tryParse(offsetStr) ?? 0;

    final service = DocumentsService(_createContext(env));

    try {
      final result = await service.list(
        collectionName: collectionName,
        filter: filter,
        orderBy: orderBy,
        limit: limit,
        offset: offset,
      );

      if (asJson) {
        print(_jsonEncoder.convert(result.toJson()));
      } else {
        print('Documents in "$collectionName" (${result.count} total):');
        for (final doc in result.documents) {
          print('  - ${doc.id}: ${jsonEncode(doc.data)}');
        }
        if (result.documents.isEmpty) {
          print(yellow('  No documents found.'));
        }
      }
      exit(0);
    } on VaneStackException catch (e) {
      print(red(e.message));
      exit(1);
    }
  }
}

class GetDocumentCommand extends Command {
  final Environment env;

  @override
  String get description => 'Get a document by ID.';

  @override
  String get name => 'get';

  GetDocumentCommand(this.env) {
    argParser
      ..addOption(
        'collection',
        abbr: 'c',
        help: 'The name of the collection.',
        mandatory: true,
      )
      ..addOption('id', abbr: 'i', help: 'The document ID.', mandatory: true);
  }

  @override
  Future<void> run() async {
    final collectionName = argResults?['collection'] as String;
    final id = argResults?['id'] as String;

    final service = DocumentsService(_createContext(env));

    try {
      final doc = await service.get(
        collectionName: collectionName,
        documentId: id,
      );

      if (doc == null) {
        print(red('Document "$id" not found in collection "$collectionName".'));
        exit(1);
      }

      print(_jsonEncoder.convert(doc.toJson()));
      exit(0);
    } on VaneStackException catch (e) {
      print(red(e.message));
      exit(1);
    }
  }
}

class CreateDocumentCommand extends Command {
  final Environment env;

  @override
  String get description => 'Create a new document.';

  @override
  String get name => 'create';

  CreateDocumentCommand(this.env) {
    argParser
      ..addOption(
        'collection',
        abbr: 'c',
        help: 'The name of the collection.',
        mandatory: true,
      )
      ..addOption(
        'data',
        abbr: 'd',
        help: 'JSON object with document data.',
        mandatory: true,
      )
      ..addOption('id', abbr: 'i', help: 'Optional document ID.');
  }

  @override
  Future<void> run() async {
    final collectionName = argResults?['collection'] as String;
    final dataJson = argResults?['data'] as String;
    final id = argResults?['id'] as String?;

    Map<String, dynamic> data;
    try {
      data = jsonDecode(dataJson) as Map<String, dynamic>;
    } catch (e) {
      print(red('Invalid JSON data: $e'));
      exit(1);
    }

    // If ID is provided, add it to the data map
    if (id != null) {
      data['id'] = id;
    }

    final service = DocumentsService(_createContext(env));

    try {
      final doc = await service.create(
        collectionName: collectionName,
        data: data,
      );
      print(green('Document created with ID: ${doc.id}'));
      print(_jsonEncoder.convert(doc.toJson()));
      exit(0);
    } on VaneStackException catch (e) {
      print(red(e.message));
      exit(1);
    }
  }
}

class DeleteDocumentCommand extends Command {
  final Environment env;

  @override
  String get description => 'Delete a document.';

  @override
  String get name => 'delete';

  DeleteDocumentCommand(this.env) {
    argParser
      ..addOption(
        'collection',
        abbr: 'c',
        help: 'The name of the collection.',
        mandatory: true,
      )
      ..addOption('id', abbr: 'i', help: 'The document ID.', mandatory: true)
      ..addFlag(
        'force',
        abbr: 'f',
        help: 'Skip confirmation prompt.',
        defaultsTo: false,
      );
  }

  @override
  Future<void> run() async {
    final collectionName = argResults?['collection'] as String;
    final id = argResults?['id'] as String;
    final force = argResults?['force'] as bool;

    final service = DocumentsService(_createContext(env));

    try {
      // Check if document exists
      final doc = await service.get(
        collectionName: collectionName,
        documentId: id,
      );
      if (doc == null) {
        print(red('Document "$id" not found in collection "$collectionName".'));
        exit(1);
      }

      if (!force) {
        stdout.write('Are you sure you want to delete document "$id"? [y/N] ');
        final response = stdin.readLineSync()?.toLowerCase();
        if (response != 'y' && response != 'yes') {
          print('Aborted.');
          exit(0);
        }
      }

      await service.delete(collectionName: collectionName, documentId: id);
      print(green('Document "$id" deleted successfully.'));
      exit(0);
    } on VaneStackException catch (e) {
      print(red(e.message));
      exit(1);
    }
  }
}
