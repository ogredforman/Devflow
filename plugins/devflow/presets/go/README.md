# Go preset

Stack-specific pieces for a Go project. Copied into a project once (by `/devflow:kickoff-agents`, or by hand), then owned by that
project.

| File | Copy to | Notes |
|---|---|---|
| `hooks/` | `tools/hooks/` | Hook program. Its own Go module, so it's never part of the app build. Run its tests with `go -C tools/hooks test ./...`. |
| `settings.json` | `.claude/settings.json` | Adjust flags: `--protect <dir>/` (repeatable) for append-only folders like applied migrations; `--no-cgo` if the project must be pure Go; `--web-dir` for the frontend folder. Remove `--protect` or `--no-cgo` to disable that guard; with no `--protect` at all, drop the `guard-edit` entry. `--web-dir` defaults to `web` and is harmless without a frontend, so it can just be removed. |
| `rules/go.md` | `.claude/rules/go.md` | Generic Go rules. Adjust any the SPEC contradicts and drop ones for things the project lacks (database, HTTP handlers). Add project-specific rules (db, frontend, integrations) as separate files. |
| `gitignore` | `.gitignore` | Trim the frontend section if there's no frontend. Ignores `.claude/worktrees/`, where Claude Code puts agent worktrees. |
| `gitattributes` | `.gitattributes` | LF line endings everywhere; matters for Windows/macOS/Linux teams of one. |

## What the hooks do

- **format** (after edits): `gofmt -w` on Go files. A syntax error is sent back to Claude to fix.
  Prettier runs on frontend files once `<web-dir>/node_modules` has it installed.
- **guard-edit** (before edits): denies edits to *committed* files under any `--protect` directory.
- **guard-bash** (before shell commands): asks you before `go get`, `npm i <pkg>`, `pnpm add`, etc.
  With `--no-cgo`, denies commands that set `CGO_ENABLED=1`.
- **check** (when Claude stops): `go build ./...` and `go vet ./...` must pass if Go files changed.
  Skipped until the project has a `go.mod`. Never blocks twice in a row, so it can't loop.

Requirements: Go 1.22+ and git on PATH. Works on Windows, macOS, and Linux.

Decisions are returned as Claude Code JSON hook output with exit code 0, because `go run`
reports a child's exit code 2 as 1, which Claude Code would treat as a non-blocking error.
