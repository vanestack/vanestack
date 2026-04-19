# Change Log

All notable changes to this project will be documented in this file.
See [Conventional Commits](https://conventionalcommits.org) for commit guidelines.

## 2026-04-19

### Changes

---

Packages with breaking changes:

 - There are no breaking changes in this release.

Packages with other changes:

 - [`vanestack` - `v0.1.3`](#vanestack---v013)

---

#### `vanestack` - `v0.1.3`

 - **REFACTOR**(collections): batch generate documents.
 - **FIX**(services): optimize database queries by fetching related data in parallel.
 - **FIX**: Fix jaspr broken input for files.
 - **FIX**(collections): cache collection metadata in-memory.
 - **FIX**: Postgres variable types and filters compatibility.
 - **FEAT**(database): implement concurrent Postgres database support.
 - **FEAT**(stats): optimize stats endpoint with dialect-specific SQL.
 - **FEAT**: add support for PostgreSQL backend.


## 2026-04-02

### Changes

---

Packages with breaking changes:

 - There are no breaking changes in this release.

Packages with other changes:

 - [`vanestack` - `v0.1.2`](#vanestack---v012)
 - [`vanestack_client` - `v0.1.2`](#vanestack_client---v012)
 - [`vanestack_common` - `v0.1.2`](#vanestack_common---v012)
 - [`vanestack_generator` - `v0.1.1+2`](#vanestack_generator---v0112)

---

#### `vanestack` - `v0.1.2`

 - **FIX**(server): reduce OTP expiry from 1 hour to 10 minutes.
 - **FIX**(server): downgrade drift to 2.31.0 and sqlite3 to 2.x to preserve dart compile exe support.
 - **FIX**(server): fix broken dartdoc references in hooks.dart.
 - **FIX**(server): export Environment type from public API.
 - **FIX**(server): reduce OTP expiry from 1 hour to 10 minutes.
 - **FIX**(server): evict stale IPs from rate limiter to prevent memory leak.
 - **FIX**(server): exclude test/, Dockerfile, IDE and template files from pub publish.
 - **FIX**(server): use single quotes for SQL string literals in tests.
 - **FIX**(server): correct version in README install instructions.
 - **FIX**(server): add .pubignore to exclude .vanestack.
 - **FEAT**: Improve error codes.
 - **FEAT**: enhance error handling in user retrieval and token refresh processes.
 - **FEAT**(server): add security headers middleware.
 - **DOCS**: remove hardcoded versions from README install instructions.

#### `vanestack_client` - `v0.1.2`

 - **FEAT**: Improve error codes.
 - **FEAT**: enhance error handling in user retrieval and token refresh processes.

#### `vanestack_common` - `v0.1.2`

 - **FEAT**: Improve error codes.
 - **FEAT**: enhance error handling in user retrieval and token refresh processes.

#### `vanestack_generator` - `v0.1.1+2`

 - **DOCS**: remove hardcoded versions from README install instructions.


## 2026-03-30

### Changes

---

Packages with breaking changes:

 - There are no breaking changes in this release.

Packages with other changes:

 - [`vanestack` - `v0.1.1+2`](#vanestack---v0112)
 - [`vanestack_annotation` - `v0.1.1+1`](#vanestack_annotation---v0111)
 - [`vanestack_client` - `v0.1.1+1`](#vanestack_client---v0111)
 - [`vanestack_generator` - `v0.1.1+1`](#vanestack_generator---v0111)

---

#### `vanestack` - `v0.1.1+2`

 - **FIX**(server): Added more docs.
 - **FIX**(server): Don't export Route annotation.
 - **FIX**(dependencies): update analyzer, dart_style, drift, sqlite3, and mailer versions.
 - **FIX**(server): Add example.

#### `vanestack_annotation` - `v0.1.1+1`

 - **FIX**(annotation): Add dart docs.

#### `vanestack_client` - `v0.1.1+1`

 - **FIX**(client): Add example.

#### `vanestack_generator` - `v0.1.1+1`

 - **FIX**(generator): Add dart docs.
 - **FIX**(generator): update build, code_builder, and source_gen versions.
 - **FIX**(dependencies): update analyzer, dart_style, drift, sqlite3, and mailer versions.


## 2026-03-28

### Changes

---

Packages with breaking changes:

 - There are no breaking changes in this release.

Packages with other changes:

 - [`vanestack` - `v0.1.1+1`](#vanestack---v0111)

---

#### `vanestack` - `v0.1.1+1`

 - **FIX**: commit generated database file.


## 2026-03-28

### Changes

---

Packages with breaking changes:

 - There are no breaking changes in this release.

Packages with other changes:

 - [`vanestack` - `v0.1.1`](#vanestack---v011)
 - [`vanestack_annotation` - `v0.1.1`](#vanestack_annotation---v011)
 - [`vanestack_client` - `v0.1.1`](#vanestack_client---v011)
 - [`vanestack_common` - `v0.1.1`](#vanestack_common---v011)
 - [`vanestack_generator` - `v0.1.1`](#vanestack_generator---v011)

---

#### `vanestack` - `v0.1.1`

 - **FEAT**: initial release.

#### `vanestack_annotation` - `v0.1.1`

 - **FEAT**: initial release.

#### `vanestack_client` - `v0.1.1`

 - **FEAT**: initial release.

#### `vanestack_common` - `v0.1.1`

 - **FEAT**: initial release.

#### `vanestack_generator` - `v0.1.1`

 - **FEAT**: initial release.

