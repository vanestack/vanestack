import 'dart:convert';
import 'dart:io';

import 'package:args/command_runner.dart';
import 'package:http/http.dart' as http;

import 'stdout.dart';

class DeployCommand extends Command {
  @override
  String get name => 'deploy';

  @override
  String get description => 'Deploy this project to VaneStack cloud.';

  DeployCommand() {
    argParser
      ..addOption('host', help: 'Cloud API URL.')
      ..addOption('project', abbr: 'p', help: 'Project slug.')
      ..addOption('os', help: 'Target OS.', defaultsTo: 'linux',
          allowed: ['linux', 'macos', 'windows'])
      ..addOption('arch', help: 'Target architecture.', defaultsTo: 'x64',
          allowed: ['x64', 'arm64']);
  }

  static const _configFile = '.vanestack';

  @override
  Future<void> run() async {
    // 1. Read credentials
    final credFile = File(
      '${Platform.environment['HOME']}/.vanestack/credentials.json',
    );

    if (!await credFile.exists()) {
      print(red('Not logged in. Run `vanestack login` first.'));
      return;
    }

    final creds =
        jsonDecode(await credFile.readAsString()) as Map<String, dynamic>;
    final host = argResults!['host'] as String? ?? creds['host'] as String;
    final token = creds['token'] as String;

    // 2. Resolve project slug
    var slug = argResults!['project'] as String?;

    // Check .vanestack config file (stores projectId which survives renames)
    if (slug == null) {
      final config = File(_configFile);
      if (await config.exists()) {
        final data =
            jsonDecode(await config.readAsString()) as Map<String, dynamic>;
        final savedProjectId = data['projectId'] as String?;
        if (savedProjectId != null) {
          slug = await _resolveSlugByProjectId(host, token, savedProjectId);
          if (slug != null) {
            print('Using project ${green(slug)} from $_configFile');
          } else {
            print(yellow(
                'Saved project no longer exists. Please select again.'));
            await config.delete();
          }
        }
      }
    }

    // If still no slug, fetch projects and let user pick
    if (slug == null) {
      slug = await _selectProject(host, token);
      if (slug == null) return;
    }

    // 3. Cross-compile
    final targetOs = argResults!['os'] as String;
    final targetArch = argResults!['arch'] as String;
    print(yellow('Compiling for $targetOs/$targetArch...'));
    final outputDir = Directory('.dart_tool/deploy');
    await outputDir.create(recursive: true);
    final outputPath = '${outputDir.path}/vanestack';

    final compileResult = await Process.run('dart', [
      'compile',
      'exe',
      'bin/vanestack.dart',
      '-o',
      outputPath,
      '--target-os=$targetOs',
      '--target-arch=$targetArch',
    ]);

    if (compileResult.exitCode != 0) {
      print(red('Compilation failed:'));
      print(compileResult.stderr);
      return;
    }

    // 4. Read binary
    final binaryFile = File(outputPath);
    final bytes = await binaryFile.readAsBytes();
    final sizeMb = (bytes.length / 1024 / 1024).toStringAsFixed(1);
    print(green('Binary compiled: $sizeMb MB'));

    // 5. Upload
    print(yellow('Deploying to $slug...'));
    final url = Uri.parse('$host/v1/projects/$slug/deploy');

    final response = await http.post(
      url,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/octet-stream',
      },
      body: bytes,
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      final body = jsonDecode(response.body) as Map<String, dynamic>;
      print(green('Deployed version ${body['version']} successfully!'));
    } else {
      print(red('Deploy failed (${response.statusCode}):'));
      print(response.body);
    }

    // 6. Cleanup
    try {
      await binaryFile.delete();
    } catch (_) {}
  }

  /// Resolves the current slug for a projectId by fetching the project list.
  Future<String?> _resolveSlugByProjectId(
      String host, String token, String projectId) async {
    final response = await http.get(
      Uri.parse('$host/v1/projects'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode != 200) return null;

    final projects =
        (jsonDecode(response.body) as List).cast<Map<String, dynamic>>();
    for (final p in projects) {
      if (p['project_id'] == projectId) return p['slug'] as String;
    }
    return null;
  }

  /// Fetches user's projects and presents an interactive selection.
  /// Saves the choice to [_configFile]. Returns the selected slug or null.
  Future<String?> _selectProject(String host, String token) async {
    print(yellow('Fetching your projects...'));

    final response = await http.get(
      Uri.parse('$host/v1/projects'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode != 200) {
      print(red('Failed to fetch projects (${response.statusCode}).'));
      return null;
    }

    final projects = (jsonDecode(response.body) as List)
        .cast<Map<String, dynamic>>();

    if (projects.isEmpty) {
      print(red('No projects found. Create one at $host first.'));
      return null;
    }

    final selected = _interactiveSelect(projects);
    if (selected == null) return null;
    final slug = selected['slug'] as String;
    final projectId = selected['project_id'] as String;

    // Save projectId to .vanestack config (survives project renames)
    await File(_configFile).writeAsString(
      const JsonEncoder.withIndent('  ').convert({'projectId': projectId}),
    );
    print('Saved project ${green(slug)} to $_configFile');
    print('');

    return slug;
  }

  /// Arrow-key interactive project selector.
  /// Clears and reprints the full list on every change — simple and reliable.
  Map<String, dynamic>? _interactiveSelect(
      List<Map<String, dynamic>> projects) {
    var cursor = 0;
    // Total lines we print each render (header + hint + blank + items)
    final totalLines = projects.length + 3;

    void render({bool first = false}) {
      // Move up and clear previous render (skip on first draw)
      if (!first) {
        stdout.write('\x1B[${totalLines}A');
      }
      stdout.writeln('\x1B[2KSelect a project to deploy to:');
      stdout.writeln(
          '\x1B[2K${yellow('Use \u2191\u2193 arrows, enter to confirm, q to cancel')}');
      stdout.writeln('\x1B[2K');
      for (var i = 0; i < projects.length; i++) {
        final p = projects[i];
        final name = p['name'] ?? p['slug'];
        final slug = p['slug'];
        final status = p['status'] ?? '';
        final statusLabel =
            status == 'active' ? green('active') : yellow(status.toString());

        if (i == cursor) {
          stdout.writeln(
              '\x1B[2K ${green('\u276f')} \x1B[1m$name\x1B[0m ${yellow('($slug)')} [$statusLabel]');
        } else {
          stdout.writeln(
              '\x1B[2K   $name ${yellow('($slug)')} [$statusLabel]');
        }
      }
    }

    stdin.echoMode = false;
    stdin.lineMode = false;

    try {
      render(first: true);

      while (true) {
        final byte = stdin.readByteSync();

        if (byte == 113 || byte == 3) {
          // q or Ctrl-C
          print(red('\nCancelled.'));
          return null;
        }

        if (byte == 10 || byte == 13) {
          // Enter
          print('');
          return projects[cursor];
        }

        if (byte == 27) {
          final next = stdin.readByteSync();
          if (next == 91) {
            final arrow = stdin.readByteSync();
            if (arrow == 65 && cursor > 0) {
              cursor--;
              render();
            } else if (arrow == 66 && cursor < projects.length - 1) {
              cursor++;
              render();
            }
          }
        }
      }
    } finally {
      stdin.echoMode = true;
      stdin.lineMode = true;
    }
  }
}
