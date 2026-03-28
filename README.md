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

## Repository Structure

| Package | Description |
|---------|-------------|
| [`server/`](server/) | Backend framework — authentication, dynamic collections, real-time (SSE), file storage, and an embedded admin dashboard |
| [`common/`](common/) | Shared models and types used across server, client, and dashboard |
| [`client/`](client/) | Auto-generated typed HTTP client SDK |
| [`annotation/`](annotation/) | `@Route` annotation and `HttpMethod` enum |
| [`generator/`](generator/) | Build runner code generator for route handlers |
| [`dashboard/`](dashboard/) | Jaspr admin UI (embedded in the server binary) |

## Getting Started

```bash
# Install dependencies
cd server && dart pub get

# Run the server (serves dashboard from embedded build)
dart run bin/vanestack.dart start

# Run in dev mode (proxies dashboard from localhost:8079)
dart run bin/vanestack.dart start --dev

# Create an admin user
dart run bin/vanestack.dart users create -e admin@example.com -p mypassword -s
```

## Development

```bash
# Code generation (after changing endpoints or models)
cd server
dart run build_runner build
dart run bin/vanestack.dart generate   # regenerate client SDK

# Dashboard development (run alongside server in --dev mode)
cd dashboard
jaspr serve --port 8079

# Dashboard production build
cd dashboard
jaspr build
```
