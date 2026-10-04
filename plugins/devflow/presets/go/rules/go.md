---
paths:
  - "**/*.go"
---

# Go rules

- To orient in Go code, prefer `go doc ./internal/<pkg>` and `go doc ./internal/<pkg> <Symbol>` or
  `grep -n '^func\|^type' <file>` over reading whole files. Read bodies by line range.
- While iterating, test only the package you changed: `go test ./internal/<pkg>/ 2>&1 | tail -30`.
- Wrap errors with context: `fmt.Errorf("load config %s: %w", path, err)`. Never `panic` in request or worker paths.
- `context.Context` is the first parameter of every function that does I/O, and is passed through, not stored.
- Logging is `log/slog` only, with structured fields. No `fmt.Println` or `log.Printf` outside `main`.
- No package-level mutable state. Dependencies are constructed and wired in `cmd/<app>/main.go`.
- HTTP handlers (if any) stay thin: decode and validate, call a service, encode. Logic lives in services.
- Accept interfaces at package boundaries, return concrete types. Define interfaces where they are consumed.
- Never hold a database transaction open across a network call.
- Tests:
  - Table-driven, next to the code (`foo_test.go`).
  - Prefer real lightweight dependencies (e.g. a temp SQLite DB via `t.TempDir()`) over mocks.
  - External services are replaced by the project's fakes; no test calls a real external API.
  - Use `t.Helper()` in helpers and `t.Cleanup()` for teardown.
- Goroutines must have an owner that can stop them (context cancellation) and must not leak in tests.
