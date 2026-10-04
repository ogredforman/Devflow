# <Project>

<!-- One paragraph: what the project is, the core idea, and the stack.
     Keep this whole file under ~150 lines. It loads into every agent session. -->

- Product and architecture: `docs/SPEC.md` (source of truth for *what* and *why*)
- Build order and task list: `docs/PLAN.md` (source of truth for *what to do now*)
- Decisions: `docs/adr/`
- Where the code lives, key signatures, test fixtures: `docs/CODEMAP.md` (from Stage 0 onward)

## Before any task

- Read the task in `docs/PLAN.md` and only the SPEC sections it touches. Don't read the whole SPEC by default.
- Orient with `docs/CODEMAP.md`, then read only the functions and files you'll change or call
  (signatures, `grep -n`, line ranges), not whole packages. Everything read stays in context for every later turn.
- The current stage is the one named at the top of `docs/PLAN.md`. Do not implement anything tagged
  for a later stage. Add it to the "Parked" section of PLAN.md instead.
- If a task is ambiguous or conflicts with the SPEC, stop and ask. Don't guess on data model or API shape.
- For anything touching more than 2 files, propose a plan and wait for approval before writing code.

## Commands

<!-- devflow contract: the skills run the test and lint commands listed here.
     Format: `command`: what it does. Mark ones that don't exist yet. -->

These are created in Stage 0 task 0.1. Until then, they don't exist.

- `<dev command>`: <run locally with reload>
- `<test command>`: all tests. Must pass before a task is finished.
- `<lint command>`: static checks
- `<build command>`: production build

## Hard rules

<!-- devflow contract: the reviewer checks every rule here. Each rule is concrete and checkable.
     Derive them from the SPEC's architecture boundaries and product principles. Typical sources:
     - "All X goes through module Y" boundaries
     - Data that must never be mutated or logged
     - Portability constraints (e.g. no CGO, no native deps)
     - Security/privacy defaults (bind to localhost, no secrets in logs)
     - "Every external dependency sits behind its interface; tests never call the real thing" -->

- 
- Product principles in SPEC §5 are requirements, not style.
- New dependencies need a one-line reason in the commit message. Significant ones get an ADR.

## Style

- <Language/idiom preferences that apply everywhere. Area-specific rules go in `.claude/rules/`.>

## Finishing a task

1. Tests added or updated; the test and lint commands pass.
2. Run the `devflow:reviewer` agent on the diff and fix any Blocking findings.
3. Tick the task `[x]` in `docs/PLAN.md`.
4. If a design decision changed, update `docs/SPEC.md` or add `docs/adr/NNNN-title.md` in the same commit.
   If a package, public entry point, or test fixture was added or moved, update `docs/CODEMAP.md`.
5. One task per commit. Message format: `<area>: <what changed> (PLAN <stage>.<task>)`.
