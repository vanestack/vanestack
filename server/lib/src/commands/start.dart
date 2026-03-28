import 'dart:async';
import 'dart:io';

import 'package:args/command_runner.dart';

import '../server.dart';

class StartCommand extends Command {
  @override
  final String name = 'start';

  @override
  final String description = 'Starts the VaneStack server.';

  final VaneStackServer server;

  StartCommand(this.server) {
    argParser.addFlag(
      'dev',
      defaultsTo: false,
      help:
          'Starts the server in development mode serving the dashboard from localhost:8079.',
    );
  }

  @override
  Future<void> run() async {
    StreamSubscription<ProcessSignal>? sigint;
    StreamSubscription<ProcessSignal>? sigterm;

    sigint = ProcessSignal.sigint.watch().take(1).listen((_) async {
      sigterm?.cancel();
      await server.stop();
      exit(0);
    });

    sigterm = ProcessSignal.sigterm.watch().take(1).listen((_) async {
      sigint?.cancel();
      await server.stop();
      exit(0);
    });

    await server.start(devMode: argResults?['dev'] ?? false);
  }
}
