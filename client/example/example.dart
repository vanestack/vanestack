import 'package:vanestack_client/vanestack_client.dart';

Future<void> main() async {
  final client = VaneStackClient(
    baseUrl: 'http://localhost:8080',
    authStorage: MemoryAuthStorage(),
  );

  await client.initialize();

  // Authenticate
  final authResponse = await client.auth.signInWithEmailAndPassword(
    email: 'user@example.com',
    password: 'password123',
  );
  print('Signed in as: ${authResponse.user.email}');

  // Create a document
  final doc = await client.documents.create(
    collectionName: 'posts',
    data: {'title': 'Hello World', 'body': 'My first post'},
  );
  print('Created document: ${doc.id}');

  // List documents with filtering
  final result = await client.documents.list(
    collectionName: 'posts',
    filter: Filter.where('title', like: '%Hello%').build(),
    orderBy: OrderBy.desc('created_at').build(),
  );
  print('Found ${result.documents.length} documents');
}
