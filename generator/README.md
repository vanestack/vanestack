<p align="center">
  <a href="https://vanestack.dev">
    <img src="https://vanestack.dev/images/vanestack_logo.png" alt="VaneStack Logo" width="80" />
  </a>
</p>

<h1 align="center">vanestack_generator</h1>

<p align="center">
  Code generator for the <a href="https://pub.dev/packages/vanestack">VaneStack</a> Dart backend framework.
</p>

<p align="center">
  <a href="https://vanestack.dev">Website</a> · <a href="https://vanestack.dev/docs">Documentation</a>
</p>

---

This package is a [build_runner](https://pub.dev/packages/build_runner) builder that reads `@Route` annotations from your VaneStack server and generates:

- **`routes.dart`** — Type-safe route handlers with request parsing, auth checks, and error handling
- **`routes_info.dart`** — Route metadata used by the `generate` command to produce the client SDK

## Setup

Add as a **dev dependency** alongside `build_runner`:

```yaml
dev_dependencies:
  build_runner: ^2.10.2
  vanestack_generator: # see pub.dev for latest version
```

## Usage

```bash
dart run build_runner build
```

The generator automatically runs on the root package (via `auto_apply: root_package`). No `build.yaml` configuration is needed in your project.

## How It Works

1. Scans all `.dart` files for functions annotated with `@Route`
2. Generates wrapper handlers that parse path/body/query parameters, check auth, and handle errors
3. Produces a `registerRoutes()` function that wires all handlers into a Shelf router
4. Outputs route metadata for client SDK generation

## Related Packages

| Package | Description |
|---------|-------------|
| [vanestack](https://pub.dev/packages/vanestack) | Server framework |
| [vanestack_annotation](https://pub.dev/packages/vanestack_annotation) | `@Route` annotation and `HttpMethod` enum |
| [vanestack_common](https://pub.dev/packages/vanestack_common) | Shared models and types |
| [vanestack_client](https://pub.dev/packages/vanestack_client) | Generated HTTP client SDK |
