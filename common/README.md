<p align="center">
  <a href="https://vanestack.dev">
    <img src="https://vanestack.dev/images/vanestack_logo.png" alt="VaneStack Logo" width="80" />
  </a>
</p>

<h1 align="center">vanestack_common</h1>

<p align="center">
  Shared models and types used across VaneStack server, client SDK, and dashboard.
</p>

<p align="center">
  <a href="https://vanestack.dev">Website</a> · <a href="https://vanestack.dev/docs">Documentation</a>
</p>

---

All models use [dart_mappable](https://pub.dev/packages/dart_mappable) for JSON serialization/deserialization with generated `.mapper.dart` files.

## Models

| Model | Description |
|---|---|
| `User`, `ListUsersResult` | User accounts with id, email, name, type, timestamps |
| `AuthResponse` | Access token, refresh token, and user |
| `Collection` (sealed) | `BaseCollection` (with attributes/indexes/rules) and `ViewCollection` (SQL view) |
| `Attribute` (sealed) | Column types: `TextAttribute`, `IntAttribute`, `BoolAttribute`, `DateAttribute`, `DoubleAttribute`, `JsonAttribute` |
| `ForeignKey`, `Index` | Constraints and indexes for collections |
| `Document`, `ListDocumentsResult` | Records within collections (id, data map, timestamps) |
| `Bucket` | S3-compatible storage buckets with access rules |
| `File`, `ListFilesResult` | File metadata (path, mimeType, size) |
| `Settings` | App config (name, URL, S3, mail, OAuth providers) |
| `S3Settings`, `MailSettings` | S3 and SMTP configuration |
| `OAuthProvider`, `OAuthProviderList` | OAuth provider credentials (Google, Apple, GitHub, etc.) |
| `RealtimeEvent` (sealed) | SSE events: `DocumentCreatedEvent`, `DocumentUpdatedEvent`, `DocumentDeletedEvent`, `CustomRealtimeEvent` |
| `Log`, `ListLogsResult`, `LogsStatEntry` | Request logs and statistics |
| `ExportResponse`, `ImportResponse` | Collection import/export results |

## Enums

- `UserType` - admin, user, guest
- `IdTokenAuthProvider` - google, apple, facebook

## Usage

```dart
import 'package:vanestack_common/vanestack_common.dart';

// Deserialize from JSON
final user = UserMapper.fromJson(jsonString);

// Serialize to JSON
final json = user.toJson();
```

## Code Generation

Run after modifying any model:

```bash
dart run build_runner build
```

## Related Packages

| Package | Description |
|---------|-------------|
| [vanestack](https://pub.dev/packages/vanestack) | Server framework |
| [vanestack_annotation](https://pub.dev/packages/vanestack_annotation) | `@Route` annotation and `HttpMethod` enum |
| [vanestack_client](https://pub.dev/packages/vanestack_client) | Generated HTTP client SDK |
| [vanestack_generator](https://pub.dev/packages/vanestack_generator) | Build runner code generator |
