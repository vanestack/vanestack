## 0.1.2

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

## 0.1.1+2

 - **FIX**(server): Added more docs.
 - **FIX**(server): Don't export Route annotation.
 - **FIX**(dependencies): update analyzer, dart_style, drift, sqlite3, and mailer versions.
 - **FIX**(server): Add example.

## 0.1.1+1

 - **FIX**: commit generated database file.

## 0.1.1

 - **FEAT**: initial release.

## 0.1.0

- Initial release.
