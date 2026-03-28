<p align="center">
  <a href="https://vanestack.dev">
    <img src="https://vanestack.dev/images/vanestack_logo.png" alt="VaneStack Logo" width="80" />
  </a>
</p>

<h1 align="center">VaneStack</h1>

<p align="center">
  A powerful, easy-to-use Dart backend framework inspired by PocketBase.
</p>

<p align="center">
  <a href="https://vanestack.dev">Website</a> · <a href="https://vanestack.dev/docs">Documentation</a>
</p>

---

## Features

- **Authentication**: JWT-based auth with login, logout, refresh tokens, password reset
- **Dynamic Collections**: Create collections with custom attributes, rules, and indexes
- **Real-time**: Server-Sent Events (SSE) for watching collections and users
- **Admin Dashboard**: Web UI for managing your data
- **SQLite Database**: Built-in Drift ORM with SQLite
- **REST API**: Full REST API for all resources
- **Middleware**: CORS, logging, JWT decoding, rate limiting, request injection
- **Code Generation**: Automatic route generation and client SDK

## Quick Start

### Option 1: Standalone Server (No Custom Code)

If you just need the server as-is without custom routes or endpoints, install the CLI globally and run it:

```bash
dart pub global activate vanestack
vanestack start
```

That's it. The server will start on `http://localhost:8080` with all built-in endpoints ready to go.

### Option 2: Custom Routes & Endpoints

If you want to add custom routes, middleware, or extend the server, add VaneStack as a dependency in your project:

1. Add `vanestack` to your `pubspec.yaml`:
```yaml
dependencies:
  vanestack: ^1.0.0
```

2. Create `bin/main.dart`:
```dart
import 'package:vanestack/vanestack.dart';

void main(List<String> args) async {
  final server = VaneStack();
  await server.run(args);
}
```

3. Run the server:
```bash
dart run bin/main.dart start
```

From here you can add custom routes with `addRoute` and extend the server however you like. See the [Adding Custom Routes](#adding-custom-routes) section below.

### Admin Setup

Create your first admin user:

```bash
vanestack users create -e admin@example.com -p yourpassword -s
# or, if running from a project:
dart run bin/main.dart users create -e admin@example.com -p yourpassword -s
```

## Adding Custom Routes

Use the `addRoute` method to register custom endpoints:

```dart
import 'package:vanestack/vanestack.dart';
import 'package:shelf/shelf.dart';

void main(List<String> args) async {
  final vanestack = VaneStack();

  vanestack.addRoute(HttpMethod.get, '/hello', (request) => Response.ok('Hello!'));
  vanestack.addRoute(HttpMethod.get, '/users/<userId>', (request) async {
    // ...
  });

  await vanestack.run(args);
}
```

Routes added with `addRoute` are automatically included in the generated client SDK. Pass `ignoreForClient: true` to exclude a route from the client.

## Architecture

VaneStack is built with:

- **Server**: Shelf web framework
- **Database**: Drift ORM with SQLite
- **Auth**: JWT tokens with refresh tokens
- **Real-time**: Server-Sent Events
- **Dashboard**: Jaspr web app
- **Client**: Generated Dart client SDK

## Development

### Code Generation

```bash
dart run bin/main.dart generate   # regenerate client SDK
```

### Testing

```bash
dart test
```

## Packages

| Package | Description |
|---------|-------------|
| [vanestack_annotation](https://pub.dev/packages/vanestack_annotation) | `@Route` annotation and `HttpMethod` enum |
| [vanestack_common](https://pub.dev/packages/vanestack_common) | Shared models and types |
| [vanestack_client](https://pub.dev/packages/vanestack_client) | Generated HTTP client SDK |
| [vanestack_generator](https://pub.dev/packages/vanestack_generator) | Build runner code generator |

## License

This project is licensed under the [BSD 3-Clause License](LICENSE).
