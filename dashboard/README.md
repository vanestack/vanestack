<p align="center">
  <a href="https://vanestack.dev">
    <img src="https://vanestack.dev/images/vanestack_logo.png" alt="VaneStack Logo" width="80" />
  </a>
</p>

<h1 align="center">vanestack_dashboard</h1>

<p align="center">
  The embedded admin dashboard for VaneStack.
</p>

<p align="center">
  <a href="https://vanestack.dev">Website</a> · <a href="https://vanestack.dev/docs">Documentation</a>
</p>

---

Built with [Jaspr](https://jaspr.dev) in client mode (compiles to a JavaScript SPA).

## Stack

- **Jaspr 0.22** - Dart web UI framework
- **Jaspr Router** - Client-side routing
- **Jaspr Riverpod** - State management
- **Tailwind CSS + Basecoat** - Styling (shadcn-style components)
- **vanestack_client** - Backend communication

## Features

- **Collections** - Create/edit database schemas, browse documents in data tables
- **Users** - User management with pagination, sorting, and CRUD
- **Storage** - S3-compatible bucket and file management (upload, download, move, delete)
- **Settings** - App config, auth providers, email/SMTP, S3 storage
- **Logs** - Request log viewer with statistics
- **Auth** - Superuser-only access with JWT, magic URL (OTP), and password reset

## Structure

```
lib/
├── main.client.dart       # Entry point
├── app.dart               # Root component with routing & auth gate
├── pages/                 # Page components (collections, users, storage, settings, logs, login)
├── components/            # Reusable UI (layout, data tables, sheets, dialogs, forms)
├── forms/
│   ├── reactive/          # Custom reactive form system (Form, FormControl, FormGroup, FormArray)
│   └── *.dart             # Domain forms (user, collection, document, bucket, etc.)
├── providers/             # Riverpod providers (collections, users, documents, buckets, logs, settings)
└── utils/                 # Auth storage, extensions, helpers
```

## Development

The dashboard runs separately in dev and is proxied by the main server:

```bash
jaspr serve --port 8079
```

## Production Build

Output is embedded in the server binary:

```bash
jaspr build  # output: build/jaspr/
```

## Related Packages

| Package | Description |
|---------|-------------|
| [vanestack](https://pub.dev/packages/vanestack) | Server framework |
| [vanestack_common](https://pub.dev/packages/vanestack_common) | Shared models and types |
| [vanestack_client](https://pub.dev/packages/vanestack_client) | Generated HTTP client SDK |
