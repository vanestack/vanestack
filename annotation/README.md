<p align="center">
  <a href="https://vanestack.dev">
    <img src="https://vanestack.dev/images/vanestack_logo.png" alt="VaneStack Logo" width="80" />
  </a>
</p>

<h1 align="center">vanestack_annotation</h1>

<p align="center">
  Annotations and metadata types for the <a href="https://pub.dev/packages/vanestack">VaneStack</a> Dart backend framework.
</p>

<p align="center">
  <a href="https://vanestack.dev">Website</a> · <a href="https://vanestack.dev/docs">Documentation</a>
</p>

---

This package provides the `@Route` annotation and `HttpMethod` enum used to define HTTP endpoints in VaneStack. It is a lightweight dependency with zero transitive dependencies.

## Usage

```dart
import 'package:vanestack_annotation/vanestack_annotation.dart';

@Route(path: '/v1/posts', method: HttpMethod.get)
FutureOr<List<Post>> listPosts(Request request) async {
  // ...
}

@Route(
  path: '/v1/posts/<postId>',
  method: HttpMethod.get,
  requireAuth: true,
)
FutureOr<Post> getPost(Request request, String postId) async {
  // ...
}
```

## API

### `@Route`

| Parameter | Type | Default | Description |
|---|---|---|---|
| `path` | `String` | required | URL path, supports `<param>` syntax |
| `method` | `HttpMethod` | required | HTTP method |
| `requireAuth` | `bool` | `false` | Reject unauthenticated requests |
| `requireSuperUserAuth` | `bool` | `false` | Require admin privileges |
| `ignoreForClient` | `bool` | `false` | Exclude from generated client SDK |

### `HttpMethod`

`get`, `post`, `put`, `delete`, `patch`, `head`, `all`

## Related Packages

| Package | Description |
|---------|-------------|
| [vanestack](https://pub.dev/packages/vanestack) | Server framework |
| [vanestack_generator](https://pub.dev/packages/vanestack_generator) | Code generator that reads `@Route` annotations |
| [vanestack_common](https://pub.dev/packages/vanestack_common) | Shared models and types |
| [vanestack_client](https://pub.dev/packages/vanestack_client) | Generated HTTP client SDK |
