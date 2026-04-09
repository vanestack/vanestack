# CLAUDE.md

VaneStack is a Dart backend framework (PocketBase-inspired) monorepo: `server/`, `common/`, `client/`, `dashboard/`.

## Key Commands

```bash
# Server
cd server && dart pub get
dart run bin/vanestack.dart start          # prod (embedded dashboard)
dart run bin/vanestack.dart start --dev    # dev (proxies dashboard :8079)
dart run bin/vanestack.dart users create -e test@test.com -p mypassword -s
dart run build_runner build                # regenerate routes (REQUIRED after endpoint changes)
dart run bin/vanestack.dart generate       # regenerate client SDK
dart test

# Dashboard
cd dashboard && jaspr serve --port 8079
jaspr build  # output: build/jaspr/
```

## Endpoints

Annotate top-level functions in `lib/src/endpoints/` — routes are auto-discovered:

```dart
@Route(
  path: '/v1/myfeature/<id>',  // <name> for path params
  method: HttpMethod.get,       // get, post, put, patch, delete, head, all
  requireAuth: false,           // optional
  requireSuperUserAuth: false,  // optional
)
FutureOr<Post> myHandler(Request request, String id, String? optionalParam) async {
  final db = request.database;
}
```

- GET/DELETE: non-path params from query string; POST/PUT/PATCH: from JSON body
- Nullable params are optional in the client
- Return types: `FutureOr<T>` (JSON), `FutureOr<void>` (200), `FutureOr<Response>` (raw), `Stream<T>` (SSE)
- Client grouping: `/v1/auth/sign-in` → `client.auth.signIn(...)`
- **Never edit `routes.dart` or `routes_info.dart`** (auto-generated)

## Services Layer

Business logic in `lib/src/services/`. Services take a `ServiceContext` record:

```dart
typedef ServiceContext = ({AppDatabase database, Environment env, RealtimeEventBus? realtime, HookExecutor? hooks});
```

Available: `AuthService`, `UsersService`, `CollectionsService`, `DocumentsService`, `StorageService`, `SettingsService`, `LogsService`

To add: create file → export from `services.dart` → inject `ServiceContext`.

## Database

Drift ORM + SQLite. Tables in `lib/database/tables/`. Schema changes require `build_runner build`. File: `./data/database.sqlite`.

## Dashboard (Jaspr)

Jaspr 0.22 client-mode SPA. Riverpod state, Tailwind + Basecoat UI.

```dart
div(classes: 'flex gap-2', [button(classes: 'btn', [Component.text('Click')])])
```

Reactive forms in `lib/forms/reactive/` — `Form`, `FormControl<T>`, `FormGroup`, `FormArray<T>`. Path syntax: `'email'`, `'address.street'`, `'items.[0].name'`.

## Request Flow

`inject (db/env/realtime/hooks) → cors → prettyLogger → rateLimit → decodeJwt → Router → Handler`
