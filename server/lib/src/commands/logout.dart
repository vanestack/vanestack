import 'dart:io';

import 'package:args/command_runner.dart';

import 'stdout.dart';

class LogoutCommand extends Command {
  @override
  String get name => 'logout';

  @override
  String get description => 'Log out from VaneStack cloud.';

  @override
  Future<void> run() async {
    final credFile =
        File('${Platform.environment['HOME']}/.vanestack/credentials.json');

    if (await credFile.exists()) {
      await credFile.delete();
      print(green('Logged out successfully.'));
    } else {
      print(yellow('Not currently logged in.'));
    }
  }
}
