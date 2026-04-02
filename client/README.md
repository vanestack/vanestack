<!-- GENERATED CODE - DO NOT MODIFY BY HAND -->

# vanestack_client

Auto-generated typed HTTP client SDK for VaneStack. Provides a complete Dart API for all server endpoints with built-in auth management and realtime subscriptions.

**This package is generated** — do not edit manually. Regenerate with:

```bash
cd server
dart run bin/vanestack.dart generate
```

## Usage

```dart
import 'package:vanestack_client/vanestack_client.dart';

final client = VaneStackClient(
  baseUrl: 'http://localhost:8090',
  authStorage: MemoryAuthStorage(),
);
await client.initialize();
```

## API

### `client.auth`

| Method | Path | Function |
|--------|------|----------|
| `POST` | `/v1/auth/forgot-password` | `auth.sendPasswordResetEmail()` |
| `DELETE` | `/v1/auth/logout` | `auth.logout()` |
| `GET` | `/v1/auth/refresh` | `auth.refresh()` |
| `POST` | `/v1/auth/reset-password` | `auth.resetPassword()` |
| `POST` | `/v1/auth/sign-in-email-password` | `auth.signInWithEmailAndPassword()` |
| `POST` | `/v1/auth/sign-in-with-id-token` | `auth.signInWithIdToken()` |
| `POST` | `/v1/auth/sign-in-with-otp` | `auth.signInWithOtp()` |
| `GET` | `/v1/auth/user` | `auth.user()` |
| `POST` | `/v1/auth/verify-otp` | `auth.verifyOtp()` |
| `POST` | `/v1/auth/oauth2/<provider>` | `auth.oauth2()` |

### `client.buckets`

| Method | Path | Function |
|--------|------|----------|
| `GET` | `/v1/buckets` | `buckets.list()` |
| `POST` | `/v1/buckets/<bucket>` | `buckets.create()` |
| `DELETE` | `/v1/buckets/<bucket>` | `buckets.delete()` |
| `GET` | `/v1/buckets/<bucket>` | `buckets.get()` |
| `PATCH` | `/v1/buckets/<bucket>` | `buckets.update()` |

### `client.collections`

| Method | Path | Function |
|--------|------|----------|
| `POST` | `/v1/collections` | `collections.create()` |
| `GET` | `/v1/collections` | `collections.list()` |
| `GET` | `/v1/collections/export` | `collections.export()` |
| `POST` | `/v1/collections/import` | `collections.import()` |
| `GET` | `/v1/collections/<collectionName>` | `collections.get()` |
| `DELETE` | `/v1/collections/<collectionName>` | `collections.delete()` |
| `PATCH` | `/v1/collections/<collectionName>` | `collections.update()` |
| `POST` | `/v1/collections/<collectionName>/generate` | `collections.generate()` |

### `client.logs`

| Method | Path | Function |
|--------|------|----------|
| `GET` | `/v1/logs` | `logs.list()` |

### `client.realtime`

| Method | Path | Function |
|--------|------|----------|
| `GET` | `/v1/realtime` | `realtime.subscribe()` |

### `client.settings`

| Method | Path | Function |
|--------|------|----------|
| `GET` | `/v1/settings` | `settings.get()` |
| `PATCH` | `/v1/settings` | `settings.update()` |
| `POST` | `/v1/settings/generate-apple-client-secret` | `settings.generateAppleClientSecret()` |
| `GET` | `/v1/settings/s3` | `settings.testS3Connection()` |

### `client.stats`

| Method | Path | Function |
|--------|------|----------|
| `GET` | `/v1/stats` | `stats.stats()` |

### `client.users`

| Method | Path | Function |
|--------|------|----------|
| `GET` | `/v1/users` | `users.list()` |
| `POST` | `/v1/users` | `users.create()` |
| `DELETE` | `/v1/users/<userId>` | `users.delete()` |
| `GET` | `/v1/users/<userId>` | `users.get()` |
| `PATCH` | `/v1/users/<userId>` | `users.update()` |

### `client.documents`

| Method | Path | Function |
|--------|------|----------|
| `GET` | `/v1/documents/<collectionName>` | `documents.list()` |
| `POST` | `/v1/documents/<collectionName>` | `documents.create()` |
| `GET` | `/v1/documents/<collectionName>/<documentId>` | `documents.get()` |
| `DELETE` | `/v1/documents/<collectionName>/<documentId>` | `documents.delete()` |
| `PATCH` | `/v1/documents/<collectionName>/<documentId>` | `documents.update()` |

### `client.files`

| Method | Path | Function |
|--------|------|----------|
| `GET` | `/v1/files/<bucket>` | `files.list()` |
| `DELETE` | `/v1/files/<bucket>` | `files.delete()` |
| `PATCH` | `/v1/files/<bucket>/<fileId>` | `files.move()` |
| `GET` | `/v1/files/<bucket>/<fileId>` | `files.download()` |
| `GET` | `/v1/files/<bucket>/<fileId>/url` | `files.getDownloadUrl()` |
| `POST` | `/v1/files/<bucket>/upload` | `files.upload()` |

### `client.realtime`

```dart
final (stream, unsubscribe) = await client.realtime.subscribe(
  channel: Channel.collection('posts', type: DocumentEventType.create),
);
stream.listen((event) => print(event));
unsubscribe(); // when done
```

## Filtering & Sorting

```dart
final filter = Filter.and([
  Filter.where('status', isEqualTo: 'published'),
  Filter.where('views', isGreaterThan: 100),
]);

final orderBy = OrderBy('createdAt', direction: SortDirection.desc);
```

## Auth Storage

Implement `AuthStorage` for persistent token storage:

```dart
abstract class AuthStorage {
  Future<void> save(String key, String value);
  Future<String?> read(String key);
  Future<void> delete(String key);
}
```

`MemoryAuthStorage` is included for testing/non-persistent use.

## Features

- Automatic token refresh on 401 responses
- Retry with backoff on 503
- SSE-based realtime subscriptions with channel filtering
- User state stream via `client.onUserChanges`
- Multipart file uploads
