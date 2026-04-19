import 'dart:convert';
import 'dart:io';

import 'package:args/command_runner.dart';
import 'package:vanestack_common/vanestack_common.dart' hide File;
import 'package:path/path.dart' as p;

import '../database/database.dart';
import '../services/context.dart';
import '../services/storage_service.dart';
import '../utils/env.dart';
import '../utils/extensions.dart';
import 'stdout.dart';

const _jsonEncoder = JsonEncoder.withIndent('  ');

class StorageCommand extends Command {
  @override
  String get description => 'Manage storage buckets and files.';

  @override
  String get name => 'storage';

  StorageCommand(Environment env) {
    // Bucket commands
    addSubcommand(ListBucketsCommand(env));
    addSubcommand(GetBucketCommand(env));
    addSubcommand(CreateBucketCommand(env));
    addSubcommand(DeleteBucketCommand(env));
    // File commands
    addSubcommand(ListFilesCommand(env));
    addSubcommand(GetFileCommand(env));
    addSubcommand(DeleteFileCommand(env));
    addSubcommand(MoveFileCommand(env));
    addSubcommand(UploadFileCommand(env));
    addSubcommand(DownloadFileCommand(env));
    addSubcommand(FileUrlCommand(env));
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

class ListBucketsCommand extends Command {
  final Environment env;

  @override
  String get description => 'List all buckets.';

  @override
  String get name => 'list';

  ListBucketsCommand(this.env) {
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
    final service = StorageService(_createContext(env));

    try {
      final buckets = await service.listBuckets();

      if (asJson) {
        print(_jsonEncoder.convert(buckets.map((b) => b.toJson()).toList()));
      } else {
        if (buckets.isEmpty) {
          print(yellow('No buckets found.'));
        } else {
          print('Buckets (${buckets.length}):');
          for (final bucket in buckets) {
            print('  - ${bucket.name}');
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

class GetBucketCommand extends Command {
  final Environment env;

  @override
  String get description => 'Get a bucket by name.';

  @override
  String get name => 'get';

  GetBucketCommand(this.env) {
    argParser.addOption(
      'name',
      abbr: 'n',
      help: 'The bucket name.',
      mandatory: true,
    );
  }

  @override
  Future<void> run() async {
    final name = argResults?['name'] as String;
    final service = StorageService(_createContext(env));

    try {
      final bucket = await service.getBucket(name);

      if (bucket == null) {
        print(red('Bucket "$name" not found.'));
        exit(1);
      }

      print(_jsonEncoder.convert(bucket.toJson()));
      exit(0);
    } on VaneStackException catch (e) {
      print(red(e.message));
      exit(1);
    }
  }
}

class CreateBucketCommand extends Command {
  final Environment env;

  @override
  String get description => 'Create a new bucket.';

  @override
  String get name => 'create';

  CreateBucketCommand(this.env) {
    argParser
      ..addOption('name', abbr: 'n', help: 'The bucket name.', mandatory: true)
      ..addOption('list-rule', help: 'Rule for listing files.')
      ..addOption('view-rule', help: 'Rule for viewing files.')
      ..addOption('create-rule', help: 'Rule for uploading files.')
      ..addOption('update-rule', help: 'Rule for updating files.')
      ..addOption('delete-rule', help: 'Rule for deleting files.');
  }

  @override
  Future<void> run() async {
    final name = argResults?['name'] as String;
    final listRule = argResults?['list-rule'] as String?;
    final viewRule = argResults?['view-rule'] as String?;
    final createRule = argResults?['create-rule'] as String?;
    final updateRule = argResults?['update-rule'] as String?;
    final deleteRule = argResults?['delete-rule'] as String?;

    final service = StorageService(_createContext(env));

    try {
      final bucket = await service.createBucket(
        name: name,
        listRule: listRule,
        viewRule: viewRule,
        createRule: createRule,
        updateRule: updateRule,
        deleteRule: deleteRule,
      );
      print(green('Bucket "${bucket.name}" created successfully.'));
      exit(0);
    } on VaneStackException catch (e) {
      print(red(e.message));
      exit(1);
    }
  }
}

class DeleteBucketCommand extends Command {
  final Environment env;

  @override
  String get description => 'Delete a bucket.';

  @override
  String get name => 'delete';

  DeleteBucketCommand(this.env) {
    argParser
      ..addOption('name', abbr: 'n', help: 'The bucket name.', mandatory: true)
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

    final service = StorageService(_createContext(env));

    try {
      // Check if bucket exists
      final bucket = await service.getBucket(name);
      if (bucket == null) {
        print(red('Bucket "$name" not found.'));
        exit(1);
      }

      if (!force) {
        stdout.write(
          'Are you sure you want to delete bucket "$name" and all its files? [y/N] ',
        );
        final response = stdin.readLineSync()?.toLowerCase();
        if (response != 'y' && response != 'yes') {
          print('Aborted.');
          exit(0);
        }
      }

      await service.deleteBucket(name);
      print(green('Bucket "$name" deleted successfully.'));
      exit(0);
    } on VaneStackException catch (e) {
      print(red(e.message));
      exit(1);
    }
  }
}

// ==================== File Commands ====================

class ListFilesCommand extends Command {
  final Environment env;

  @override
  String get description => 'List files in a bucket.';

  @override
  String get name => 'list-files';

  ListFilesCommand(this.env) {
    argParser
      ..addOption(
        'bucket',
        abbr: 'b',
        help: 'The bucket name.',
        mandatory: true,
      )
      ..addOption('path', abbr: 'p', help: 'Path prefix to filter files.')
      ..addOption(
        'limit',
        abbr: 'l',
        help: 'Maximum number of files to return.',
        defaultsTo: '20',
      )
      ..addOption(
        'offset',
        abbr: 'o',
        help: 'Number of files to skip.',
        defaultsTo: '0',
      )
      ..addOption('filter', abbr: 'f', help: 'Filter expression.')
      ..addOption('order-by', help: 'Order by expression.')
      ..addFlag('json', abbr: 'j', help: 'Output as JSON.', defaultsTo: false);
  }

  @override
  Future<void> run() async {
    final bucket = argResults?['bucket'] as String;
    final path = argResults?['path'] as String?;
    final limitStr = argResults?['limit'] as String;
    final offsetStr = argResults?['offset'] as String;
    final filter = argResults?['filter'] as String?;
    final orderBy = argResults?['order-by'] as String?;
    final asJson = argResults?['json'] as bool;

    final limit = int.tryParse(limitStr) ?? 20;
    final offset = int.tryParse(offsetStr) ?? 0;

    final service = StorageService(_createContext(env));

    try {
      final (dbFiles, folders) = await service.listFiles(
        bucket: bucket,
        path: path,
        filter: filter,
        orderBy: orderBy,
        limit: limit,
        offset: offset,
      );
      final files = dbFiles.map((e) => e.toPublic()).toList();
      final result = ListFilesResult(files: files, folders: folders);

      if (asJson) {
        print(_jsonEncoder.convert(result.toJson()));
      } else {
        print('Files in "$bucket"${path != null ? '/$path' : ''}:');

        if (folders.isNotEmpty) {
          print('  Folders:');
          for (final folder in folders) {
            print('    📁 $folder/');
          }
        }

        if (files.isNotEmpty) {
          print('  Files:');
          for (final file in files) {
            final size = _formatFileSize(file.size);
            print('    📄 ${file.path} ($size)');
          }
        }

        if (files.isEmpty && folders.isEmpty) {
          print(yellow('  No files or folders found.'));
        }
      }
      exit(0);
    } on VaneStackException catch (e) {
      print(red(e.message));
      exit(1);
    }
  }
}

class GetFileCommand extends Command {
  final Environment env;

  @override
  String get description => 'Get file details by ID.';

  @override
  String get name => 'get-file';

  GetFileCommand(this.env) {
    argParser.addOption('id', abbr: 'i', help: 'The file ID.', mandatory: true);
  }

  @override
  Future<void> run() async {
    final id = argResults?['id'] as String;
    final service = StorageService(_createContext(env));

    try {
      final file = await service.getFileById(id);

      if (file == null) {
        print(red('File not found.'));
        exit(1);
      }

      print(_jsonEncoder.convert(file.toPublic().toJson()));
      exit(0);
    } on VaneStackException catch (e) {
      print(red(e.message));
      exit(1);
    }
  }
}

class DeleteFileCommand extends Command {
  final Environment env;

  @override
  String get description => 'Delete a file.';

  @override
  String get name => 'delete-file';

  DeleteFileCommand(this.env) {
    argParser
      ..addOption('id', abbr: 'i', help: 'The file ID.')
      ..addOption(
        'bucket',
        abbr: 'b',
        help: 'The bucket name (used with --path).',
      )
      ..addOption(
        'path',
        abbr: 'p',
        help: 'The file path (used with --bucket).',
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
    final id = argResults?['id'] as String?;
    final bucket = argResults?['bucket'] as String?;
    final path = argResults?['path'] as String?;
    final force = argResults?['force'] as bool;

    if (id == null && (bucket == null || path == null)) {
      print(red('You must provide either --id or both --bucket and --path.'));
      exit(1);
    }

    final service = StorageService(_createContext(env));

    try {
      // Check if file exists (for confirmation message)
      final file = id != null
          ? await service.getFileById(id)
          : await service.getFileByPath(bucket: bucket!, path: path!);

      if (file == null) {
        print(red('File not found.'));
        exit(1);
      }

      if (!force) {
        stdout.write(
          'Are you sure you want to delete file "${file.path}"? [y/N] ',
        );
        final response = stdin.readLineSync()?.toLowerCase();
        if (response != 'y' && response != 'yes') {
          print('Aborted.');
          exit(0);
        }
      }

      // Delete from storage and database
      if (id != null) {
        await service.deleteFile(id);
      } else {
        await service.deleteFileByPath(bucket: bucket!, path: path!);
      }

      print(green('File "${file.path}" deleted successfully.'));
      exit(0);
    } on VaneStackException catch (e) {
      print(red(e.message));
      exit(1);
    }
  }
}

class FileUrlCommand extends Command {
  final Environment env;

  @override
  String get description => 'Get download URL for a file.';

  @override
  String get name => 'file-url';

  FileUrlCommand(this.env) {
    argParser
      ..addOption(
        'bucket',
        abbr: 'b',
        help: 'The bucket name.',
        mandatory: true,
      )
      ..addOption('id', abbr: 'i', help: 'The file ID.', mandatory: true);
  }

  @override
  Future<void> run() async {
    final bucket = argResults?['bucket'] as String;
    final id = argResults?['id'] as String;

    final service = StorageService(_createContext(env));

    try {
      final url = await service.getDownloadUrl(bucketName: bucket, fileId: id);

      print(url);
      exit(0);
    } on VaneStackException catch (e) {
      print(red(e.message));
      exit(1);
    }
  }
}

class MoveFileCommand extends Command {
  final Environment env;

  @override
  String get description => 'Move or rename a file.';

  @override
  String get name => 'move-file';

  MoveFileCommand(this.env) {
    argParser
      ..addOption('id', abbr: 'i', help: 'The file ID.')
      ..addOption(
        'bucket',
        abbr: 'b',
        help: 'The bucket name (used with --path).',
      )
      ..addOption(
        'path',
        abbr: 'p',
        help: 'The current file path (used with --bucket).',
      )
      ..addOption(
        'destination',
        abbr: 'd',
        help: 'The destination path.',
        mandatory: true,
      );
  }

  @override
  Future<void> run() async {
    final id = argResults?['id'] as String?;
    final bucket = argResults?['bucket'] as String?;
    final path = argResults?['path'] as String?;
    final destination = argResults?['destination'] as String;

    if (id == null && (bucket == null || path == null)) {
      print(red('You must provide either --id or both --bucket and --path.'));
      exit(1);
    }

    final service = StorageService(_createContext(env));

    try {
      // Get original path for message
      final file = id != null
          ? await service.getFileById(id)
          : await service.getFileByPath(bucket: bucket!, path: path!);

      if (file == null) {
        print(red('File not found.'));
        exit(1);
      }

      final originalPath = file.path;

      // Move file in storage and database
      if (id != null) {
        await service.moveFile(fileId: id, destination: destination);
      } else {
        await service.moveFileByPath(
          bucket: bucket!,
          path: path!,
          destination: destination,
        );
      }

      print(green('File moved from "$originalPath" to "$destination".'));
      exit(0);
    } on VaneStackException catch (e) {
      print(red(e.message));
      exit(1);
    }
  }
}

class UploadFileCommand extends Command {
  final Environment env;

  @override
  String get description => 'Upload a file to storage.';

  @override
  String get name => 'upload-file';

  UploadFileCommand(this.env) {
    argParser
      ..addOption(
        'bucket',
        abbr: 'b',
        help: 'The bucket name.',
        mandatory: true,
      )
      ..addOption(
        'file',
        abbr: 'f',
        help: 'Path to the local file to upload.',
        mandatory: true,
      )
      ..addOption(
        'path',
        abbr: 'p',
        help: 'Destination path in the bucket. Defaults to the filename.',
      )
      ..addFlag('json', abbr: 'j', help: 'Output as JSON.', defaultsTo: false);
  }

  @override
  Future<void> run() async {
    final bucketName = argResults?['bucket'] as String;
    final filePath = argResults?['file'] as String;
    final destPath = argResults?['path'] as String?;
    final asJson = argResults?['json'] as bool;

    final service = StorageService(_createContext(env));

    try {
      // Check local file exists
      final localFile = File(filePath);
      if (!await localFile.exists()) {
        print(red('File "$filePath" not found.'));
        exit(1);
      }

      // Determine destination path
      final filename = p.basename(filePath);
      var uploadPath = destPath ?? filename;
      uploadPath = p.normalize(uploadPath);

      // Ensure path ends with filename if it looks like a directory
      if (uploadPath.endsWith('/') ||
          destPath == null ||
          !destPath.contains('.')) {
        uploadPath = p.join(uploadPath, filename);
      }
      if (uploadPath.startsWith('./')) {
        uploadPath = uploadPath.substring(2);
      }

      // Detect mime type
      final mimeType = _getMimeType(filename);

      // Upload file
      final dbFile = await service.uploadFile(
        bucket: bucketName,
        path: uploadPath,
        filename: filename,
        data: localFile.openRead(),
        mimeType: mimeType,
      );

      if (asJson) {
        print(_jsonEncoder.convert(dbFile.toPublic().toJson()));
      } else {
        print(green('File uploaded successfully.'));
        print('  ID: ${dbFile.id}');
        print('  Path: ${dbFile.path}');
        print('  Size: ${_formatFileSize(dbFile.size)}');
      }
      exit(0);
    } on VaneStackException catch (e) {
      print(red(e.message));
      exit(1);
    }
  }
}

class DownloadFileCommand extends Command {
  final Environment env;

  @override
  String get description => 'Download a file from storage.';

  @override
  String get name => 'download-file';

  DownloadFileCommand(this.env) {
    argParser
      ..addOption('id', abbr: 'i', help: 'The file ID.')
      ..addOption(
        'bucket',
        abbr: 'b',
        help: 'The bucket name (used with --path).',
      )
      ..addOption(
        'path',
        abbr: 'p',
        help: 'The file path in the bucket (used with --bucket).',
      )
      ..addOption(
        'output',
        abbr: 'o',
        help:
            'Output file path. Defaults to current directory with original filename.',
      );
  }

  @override
  Future<void> run() async {
    final id = argResults?['id'] as String?;
    final bucket = argResults?['bucket'] as String?;
    final path = argResults?['path'] as String?;
    final output = argResults?['output'] as String?;

    if (id == null && (bucket == null || path == null)) {
      print(red('You must provide either --id or both --bucket and --path.'));
      exit(1);
    }

    final service = StorageService(_createContext(env));

    try {
      // Get file metadata
      final file = id != null
          ? await service.getFileById(id)
          : await service.getFileByPath(bucket: bucket!, path: path!);

      if (file == null) {
        print(red('File not found.'));
        exit(1);
      }

      // Get file contents
      final contents = await service.getFileContents(file.id);
      if (contents == null) {
        print(red('Failed to download file contents.'));
        exit(1);
      }

      // Determine output path
      final outputPath = output ?? p.basename(file.path);
      final outputFile = File(outputPath);

      // Write to file
      await outputFile.writeAsBytes(contents);

      print(green('File downloaded successfully.'));
      print('  Saved to: $outputPath');
      print('  Size: ${_formatFileSize(contents.length)}');
      exit(0);
    } on VaneStackException catch (e) {
      print(red(e.message));
      exit(1);
    }
  }
}

String _getMimeType(String filename) {
  final ext = p.extension(filename).toLowerCase();
  return switch (ext) {
    '.jpg' || '.jpeg' => 'image/jpeg',
    '.png' => 'image/png',
    '.gif' => 'image/gif',
    '.webp' => 'image/webp',
    '.svg' => 'image/svg+xml',
    '.pdf' => 'application/pdf',
    '.json' => 'application/json',
    '.xml' => 'application/xml',
    '.txt' => 'text/plain',
    '.html' => 'text/html',
    '.css' => 'text/css',
    '.js' => 'application/javascript',
    '.mp3' => 'audio/mpeg',
    '.mp4' => 'video/mp4',
    '.zip' => 'application/zip',
    '.tar' => 'application/x-tar',
    '.gz' => 'application/gzip',
    _ => 'application/octet-stream',
  };
}

String _formatFileSize(int bytes) {
  if (bytes < 1024) return '$bytes B';
  if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
  if (bytes < 1024 * 1024 * 1024) {
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }
  return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
}
