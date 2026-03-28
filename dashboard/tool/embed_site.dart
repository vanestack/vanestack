import 'dart:convert';
import 'dart:io';

import 'package:path/path.dart';

void main() async {
  final inputDir = Directory('build/jaspr'); // your website folder
  final output = StringBuffer();

  output.writeln('// GENERATED FILE — DO NOT EDIT');
  output.writeln("import 'dart:typed_data';");
  output.writeln("import 'dart:convert';");
  output.writeln("");

  output.writeln("class EmbeddedSite {");
  output.writeln("  static final Map<String, Uint8List> files = {");

  for (final file in inputDir.listSync(recursive: true)) {
    if (file is File) {
      final relativePath = file.path.replaceFirst('web_static/', '');
      final bytes = await file.readAsBytes();
      final b64 = base64Encode(bytes);

      output.writeln("    r'$relativePath': base64Decode('$b64'),");
    }
  }

  output.writeln("  };");
  output.writeln("}");
  output.writeln("");

  final file = await File('build/embedded_site.dart').writeAsString(output.toString());

  print('Embedded website generated → build/embedded_site.dart');

  await file.copy(
    join(
      Directory.current.parent.path,
      'server',
      'lib',
      'src',
      'embedded_site.dart',
    ),
  );
}
