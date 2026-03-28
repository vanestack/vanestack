<p align="center">
  <a href="https://vanestack.dev">
    <img src="https://vanestack.dev/images/vanestack_logo.png" alt="VaneStack Logo" width="80" />
  </a>
</p>

<h1 align="center">vanestack_client</h1>

<p align="center">
  Typed HTTP client SDK for <a href="https://pub.dev/packages/vanestack">VaneStack</a> servers.
</p>

<p align="center">
  <a href="https://vanestack.dev">Website</a> · <a href="https://vanestack.dev/docs">Documentation</a>
</p>

---

## Getting Started

```dart
import 'package:vanestack_client/vanestack_client.dart';

final client = VaneStackClient(
  baseUrl: 'http://localhost:8080',
  authStorage: MemoryAuthStorage(),
);
await client.initialize();
```

## Authentication

```dart
// Sign in
final auth = await client.auth.signInWithEmailAndPassword(
  email: 'user@example.com',
  password: 'password',
);
print(auth.user.email);

// Listen to auth state changes
client.onUserChanges.listen((user) {
  print('Auth state changed: ${user?.email}');
});

// Sign out
await client.auth.logout();
```

## Documents

```dart
// Create
final doc = await client.documents.create(
  collectionName: 'posts',
  data: {'title': 'Hello World', 'published': true},
);

// Read
final post = await client.documents.get(
  collectionName: 'posts',
  documentId: doc.id,
);

// List with filtering and sorting
final result = await client.documents.list(
  collectionName: 'posts',
  filter: Filter.and([
    Filter.where('published', isEqualTo: true),
    Filter.where('views', isGreaterThan: 100),
  ]),
  orderBy: OrderBy('createdAt', direction: SortDirection.desc),
);

// Update
await client.documents.update(
  collectionName: 'posts',
  documentId: doc.id,
  data: {'title': 'Updated Title'},
);

// Delete
await client.documents.delete(
  collectionName: 'posts',
  documentId: doc.id,
);
```

## File Storage

```dart
// Upload
await client.files.upload(
  bucket: 'images',
  file: MultipartFile.fromPath('photo', '/path/to/image.png'),
);

// Get download URL
final url = await client.files.getDownloadUrl(
  bucket: 'images',
  fileId: 'file-id',
);
```

## Realtime

```dart
final (stream, unsubscribe) = await client.realtime.subscribe(
  channel: Channel.collection('posts', type: DocumentEventType.create),
);

stream.listen((event) {
  print('New post created: ${event.data}');
});

// When done
unsubscribe();
```

## Auth Storage

Implement `AuthStorage` for persistent token storage (e.g. with `shared_preferences`):

```dart
abstract class AuthStorage {
  Future<void> save(String key, String value);
  Future<String?> read(String key);
  Future<void> delete(String key);
}
```

`MemoryAuthStorage` is included for testing and non-persistent use.

## Features

- Automatic token refresh on 401 responses
- Retry with backoff on 503
- SSE-based realtime subscriptions with channel filtering
- User state stream via `client.onUserChanges`
- Multipart file uploads
- Typed filter and sort builders

## Related Packages

| Package | Description |
|---------|-------------|
| [vanestack](https://pub.dev/packages/vanestack) | Server framework |
| [vanestack_common](https://pub.dev/packages/vanestack_common) | Shared models and types |
| [vanestack_annotation](https://pub.dev/packages/vanestack_annotation) | `@Route` annotation and `HttpMethod` enum |
| [vanestack_generator](https://pub.dev/packages/vanestack_generator) | Build runner code generator |
