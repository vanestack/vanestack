import 'package:vanestack/vanestack.dart';

void main(List<String> args) async {
  final server = VaneStack();
  await server.run(args);
}
