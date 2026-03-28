import 'dart:convert';
import 'dart:io';

import 'package:args/command_runner.dart';
import 'package:vanestack_common/vanestack_common.dart';

import '../database/database.dart';
import '../services/auth_service.dart';
import '../services/context.dart';
import '../services/users_service.dart';
import '../utils/env.dart';
import 'stdout.dart';

const _jsonEncoder = JsonEncoder.withIndent('  ');

class UsersCommand extends Command {
  @override
  String get description => 'Manage users.';

  @override
  String get name => 'users';

  UsersCommand(Environment env) {
    addSubcommand(ListUsersCommand(env));
    addSubcommand(GetUserCommand(env));
    addSubcommand(CreateUserCommand(env));
    addSubcommand(UpdateUserCommand(env));
    addSubcommand(DeleteUserCommand(env));
    addSubcommand(GenerateOtpCommand(env));
  }
}

ServiceContext _createContext(Environment env) {
  return (
    database: AppDatabase(null, env.databasePath),
    env: env,
    realtime: null,
    hooks: null,
  );
}

class ListUsersCommand extends Command {
  final Environment env;

  @override
  String get description => 'List all users.';

  @override
  String get name => 'list';

  ListUsersCommand(this.env) {
    argParser
      ..addOption(
        'limit',
        abbr: 'l',
        help: 'Maximum number of users to return.',
        defaultsTo: '20',
      )
      ..addOption(
        'offset',
        abbr: 'o',
        help: 'Number of users to skip.',
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

    final service = UsersService(_createContext(env));

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
        print('Users (${result.count} total):');
        for (final user in result.users) {
          final name = user.name != null ? ' - ${user.name}' : '';
          print('  - ${user.email} (${user.id})$name');
        }
        if (result.users.isEmpty) {
          print(yellow('  No users found.'));
        }
      }
      exit(0);
    } on VaneStackException catch (e) {
      print(red(e.message));
      exit(1);
    }
  }
}

class GetUserCommand extends Command {
  final Environment env;

  @override
  String get description => 'Get a user by ID or email.';

  @override
  String get name => 'get';

  GetUserCommand(this.env) {
    argParser
      ..addOption('id', abbr: 'i', help: 'The user ID.')
      ..addOption('email', abbr: 'e', help: 'The user email.');
  }

  @override
  Future<void> run() async {
    final id = argResults?['id'] as String?;
    final email = argResults?['email'] as String?;

    if (id == null && email == null) {
      print(red('You must provide either --id or --email.'));
      exit(1);
    }

    final service = UsersService(_createContext(env));

    try {
      final user = id != null
          ? await service.getById(id)
          : await service.getByEmail(email!);

      if (user == null) {
        print(red('User not found.'));
        exit(1);
      }

      print(_jsonEncoder.convert(user.toJson()));
      exit(0);
    } on VaneStackException catch (e) {
      print(red(e.message));
      exit(1);
    }
  }
}

class CreateUserCommand extends Command {
  final Environment env;

  @override
  String get description => 'Create a new user.';

  @override
  String get name => 'create';

  CreateUserCommand(this.env) {
    argParser
      ..addOption(
        'email',
        abbr: 'e',
        help: 'The email address.',
        mandatory: true,
      )
      ..addOption('password', abbr: 'p', help: 'The password.')
      ..addOption('id', abbr: 'i', help: 'The user ID (UUID).')
      ..addOption('name', abbr: 'n', help: 'The display name.')
      ..addFlag(
        'superuser',
        abbr: 's',
        help: 'Make this user a superuser.',
        defaultsTo: false,
      );
  }

  @override
  Future<void> run() async {
    final email = argResults?['email'] as String;
    final password = argResults?['password'] as String?;
    final id = argResults?['id'] as String?;
    final name = argResults?['name'] as String?;
    final superuser = argResults?['superuser'] as bool;

    final service = UsersService(_createContext(env));

    try {
      final user = await service.create(
        id: id,
        email: email,
        password: password,
        name: name,
        superUser: superuser,
      );
      print(green('User created successfully.'));
      print('  ID: ${user.id}');
      print('  Email: ${user.email}');
      if (user.name != null) print('  Name: ${user.name}');
      exit(0);
    } on VaneStackException catch (e) {
      print(red(e.message));
      exit(1);
    }
  }
}

class UpdateUserCommand extends Command {
  final Environment env;

  @override
  String get description => 'Update an existing user.';

  @override
  String get name => 'update';

  UpdateUserCommand(this.env) {
    argParser
      ..addOption(
        'id',
        abbr: 'i',
        help: 'The ID of the user to update.',
        mandatory: true,
      )
      ..addOption('email', abbr: 'e', help: 'New email address.')
      ..addOption('password', abbr: 'p', help: 'New password.')
      ..addOption('name', abbr: 'n', help: 'New display name.')
      ..addFlag(
        'superuser',
        abbr: 's',
        help: 'Set superuser status.',
        defaultsTo: null,
      );
  }

  @override
  Future<void> run() async {
    final id = argResults?['id'] as String;
    final email = argResults?['email'] as String?;
    final password = argResults?['password'] as String?;
    final name = argResults?['name'] as String?;
    final superuser = argResults?['superuser'] as bool?;

    final service = UsersService(_createContext(env));

    try {
      final user = await service.update(
        id: id,
        email: email,
        password: password,
        name: name,
        superUser: superuser,
      );
      print(green('User updated successfully.'));
      print('  ID: ${user.id}');
      print('  Email: ${user.email}');
      exit(0);
    } on VaneStackException catch (e) {
      print(red(e.message));
      exit(1);
    }
  }
}

class DeleteUserCommand extends Command {
  final Environment env;

  @override
  String get description => 'Delete a user.';

  @override
  String get name => 'delete';

  DeleteUserCommand(this.env) {
    argParser
      ..addOption('id', abbr: 'i', help: 'The user ID.')
      ..addOption('email', abbr: 'e', help: 'The user email.')
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
    final email = argResults?['email'] as String?;
    final force = argResults?['force'] as bool;

    if (id == null && email == null) {
      print(red('You must provide either --id or --email.'));
      exit(1);
    }

    final service = UsersService(_createContext(env));

    try {
      // Check if user exists first
      final user = id != null
          ? await service.getById(id)
          : await service.getByEmail(email!);

      if (user == null) {
        print(red('User not found.'));
        exit(1);
      }

      if (!force) {
        stdout.write(
          'Are you sure you want to delete user "${user.email}"? [y/N] ',
        );
        final response = stdin.readLineSync()?.toLowerCase();
        if (response != 'y' && response != 'yes') {
          print('Aborted.');
          exit(0);
        }
      }

      if (id != null) {
        await service.delete(id);
      } else {
        await service.deleteByEmail(email!);
      }

      print(green('User "${user.email}" deleted successfully.'));
      exit(0);
    } on VaneStackException catch (e) {
      print(red(e.message));
      exit(1);
    }
  }
}

class GenerateOtpCommand extends Command {
  final Environment env;

  @override
  String get description => 'Generate an OTP for a user.';

  @override
  String get name => 'otp';

  GenerateOtpCommand(this.env) {
    argParser.addOption(
      'email',
      abbr: 'e',
      help: 'The email address of the user.',
      mandatory: true,
    );
  }

  @override
  Future<void> run() async {
    final email = argResults?['email'] as String;

    final service = AuthService(_createContext(env));

    try {
      final otp = await service.createOtp(email: email);
      print(green('OTP generated successfully.'));
      print('  Email: $email');
      print('  OTP: $otp');
      exit(0);
    } on VaneStackException catch (e) {
      print(red(e.message));
      exit(1);
    }
  }
}
