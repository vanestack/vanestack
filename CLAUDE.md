# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

VaneStack is a Dart backend framework inspired by PocketBase. This monorepo contains the framework, shared packages, and admin dashboard. The cloud platform ([vanestack/cloud](https://github.com/vanestack/cloud)) is a separate private repo.

## Repository Structure

```
VaneStack/
├── server/                        # Backend framework
│   ├── bin/vanestack.dart         # CLI entry point
│   ├── lib/
│   │   ├── vanestack.dart         # CLI CommandRunner
│   │   └── src/
│   │       ├── server.dart        # HTTP server + middleware pipeline
│   │       ├── routes.dart        # AUTO-GENERATED - never edit
│   │       ├── endpoints/         # HTTP handlers (auto-discovered)
│   │       ├── services/          # Business logic layer
│   │       ├── database/          # Drift ORM (tables in database/tables/)
│   │       ├── middleware/        # Request processing (inject, cors, jwt, logging)
│   │       ├── realtime/          # SSE event bus
│   │       └── utils/             # Helpers (auth, filtering, S3, etc.)
│   └── test/                      # Integration tests
├── common/                        # Shared models (server, client, dashboard)
├── client/                        # Generated HTTP client SDK
└── dashboard/                     # Jaspr admin UI (client-mode SPA)
```

### Package Dependencies

```
server
├── common
└── client
    └── common

dashboard
├── client
│   └── common
└── common
```

---

## Server (`server/`)

### Common Commands

```bash
cd server

# Install dependencies
dart pub get

# Run server (serves dashboard from embedded build)
dart run bin/vanestack.dart start

# Run in dev mode (proxies dashboard from localhost:8079)
dart run bin/vanestack.dart start --dev

# Create admin user
dart run bin/vanestack.dart users create -e test@test.com -p mypassword -s

# Code generation - REQUIRED after changing endpoints
dart run build_runner build       # regenerate routes
dart run build_runner watch       # watch mode for routes
dart run bin/vanestack.dart generate   # regenerate client SDK

# Run tests
dart test
dart test test/auth_flow_test.dart  # single test file
```

### Dashboard Development

```bash
cd dashboard
jaspr serve --port 8079  # main server proxies to this port

# Production build
jaspr build  # output: build/jaspr/
```

### Services Layer

Business logic is in service classes at `lib/src/services/`, decoupled from HTTP.

**Available services:** `AuthService`, `UsersService`, `CollectionsService`, `DocumentsService`, `StorageService`, `SettingsService`, `LogsService`

**ServiceContext:** Services receive dependencies via a record:
```dart
typedef ServiceContext = ({
  AppDatabase database,
  Environment env,
  RealtimeEventBus? realtime,
  HookExecutor? hooks,
});
```

**Usage:**
```dart
final context = (database: db, env: env, realtime: realtime, hooks: hooks);
final authService = AuthService(context);
```

**Adding a new service:**
1. Create `lib/src/services/my_service.dart`
2. Export from `lib/src/services/services.dart`
3. Inject `ServiceContext` in constructor, access db via `context.database`

### Code Generation

| Command | What it generates |
|---|---|
| `dart run build_runner build` | `routes.dart` and `routes_info.dart` |
| `dart run bin/vanestack.dart generate` | `../client/lib/src/client.dart` |

After adding/modifying endpoints, run both. **Never edit generated files manually.**

### Request Flow

```
Request → inject middleware (db, env, realtime, hooks) → cors → prettyLogger
→ rateLimit → decodeJwt → Router → Handler → Response
```


#### The `@Route` Annotation

```dart
import 'package:vanestack/tools/route.dart';
import 'package:vanestack/src/utils/http_method.dart';

@Route(
  path: '/v1/myfeature/<id>',       // path params use <name> syntax
  method: HttpMethod.get,            // get, post, put, patch, delete, head, all
  requireAuth: false,                // optional: reject unauthenticated requests
  requireSuperUserAuth: false,       // optional: require admin privileges
  ignoreForClient: false,            // optional: exclude from generated client SDK
)
```

#### Handler Function Signature

```dart
FutureOr<ReturnType> myHandler(
  Request request,        // always first param
  String id,              // path params come next (as Strings, matched by name)
  String bodyField,       // remaining params are parsed from request body (POST/PATCH/PUT)
  String? optionalField,  // nullable params are optional in the client
) async { ... }
```

- For `GET`/`DELETE`: non-path params are parsed from query string
- For `POST`/`PATCH`/`PUT`: non-path params are parsed from JSON body

**Supported return types:** `FutureOr<T>` (JSON), `FutureOr<void>` (empty 200), `FutureOr<Response>` (raw Shelf), `FutureOr<FileResponse>` (binary), `Stream<T>` (SSE)

**Supported parameter types:** `String`, `int`, `double`, `bool`, `DateTime` (ms since epoch), `List<T>`, `Map<String, Object?>`, enums, Mappable models

#### Example Endpoint

```dart
@Route(path: '/v1/posts/<postId>', method: HttpMethod.get)
FutureOr<Post> getPost(Request request, String postId) async {
  final db = request.database;
  // ... fetch and return post
}

@Route(path: '/v1/posts', method: HttpMethod.post, requireAuth: true)
FutureOr<Post> createPost(Request request, String title, String body) async {
  final db = request.database;
  // ... create and return post
}
```

The client groups endpoints by the first path segment after `/v1/`:
- `/v1/auth/sign-in` → `client.auth.signIn(...)`
- `/v1/posts/<id>` → `client.posts.getPost(postId: '...')`

### Dashboard (Jaspr)

- Built with Jaspr 0.22 in client mode (JavaScript SPA)
- Uses Riverpod for state, Jaspr Router for navigation
- UI: Tailwind CSS + Basecoat components
- In dev: run `jaspr serve --port 8079` in `dashboard/` and start the server with `--dev` flag to proxy to it
- In prod: dashboard is embedded in the server binary (no separate process needed)

#### Jaspr HTML Syntax

```dart
div(classes: 'flex gap-2', [
  h1([Component.text('Title')]),
  button(classes: 'btn btn-primary', [Component.text('Click')]),
])
```

#### Reactive Forms

The dashboard has a reactive forms system in `lib/forms/reactive/` with path-based field access.

**Core classes:** `Form`, `FormControl<T>`, `FormGroup`, `FormArray<T>`
**UI components:** `FormBuilder`, `FormFieldBuilder<T>`

```dart
final form = Form({
  'email': FormControl<String>(initialValue: '', validators: [required(), email()]),
  'password': FormControl<String>(initialValue: '', validators: [required()]),
});
```

**Path syntax:** `'email'`, `'address.street'`, `'items.[0]'`, `'items.[0].name'`

### Database

- Drift ORM with SQLite
- Tables defined in `lib/database/tables/`
- Schema changes require `dart run build_runner build`
- Database file: `./data/database.sqlite`

### Authentication

- JWT-based (access + refresh tokens)
- JWT decoded in middleware, available via request context
- Auth endpoints in `lib/endpoints/auth/`
