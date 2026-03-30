import 'package:shelf/shelf.dart';
import 'package:vanestack/vanestack.dart';

Future<void> main(List<String> args) async {
  final vanestack = VaneStack(port: 8080, jwtSecret: 'your-secret-key');

  // Add custom routes
  vanestack.addRoute(
    HttpMethod.get,
    '/hello',
    (request) => Response.ok('Hello from VaneStack!'),
  );

  // Register hooks for lifecycle events
  vanestack.hooks.onBeforeDocumentCreate((e) {
    e.data['createdBy'] = 'system';
    return true;
  });

  vanestack.hooks.onAfterDocumentCreate((e) {
    print('Document created: ${e.result.id}');
  });

  await vanestack.run(args);
}
