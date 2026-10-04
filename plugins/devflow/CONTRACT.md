# The devflow doc contract

devflow's skills and reviewer contain nothing project-specific. They work in any repo whose docs
follow this contract. Keep a project's docs in this shape and the whole workflow comes for free.

Templates that already follow it are in `templates/`.

## Files

| File | Location | Purpose |
|---|---|---|
| `AGENTS.md` | repo root | Always-loaded agent instructions. Shared with other agents (Codex, Cursor, ...). |
| `CLAUDE.md` | repo root | `@AGENTS.md` plus Claude-only notes. |
| `SPEC.md` | `docs/SPEC.md` (or repo root) | What the system is and why. Source of truth for behavior. |
| `PLAN.md` | `docs/PLAN.md` (or repo root) | Build order: stages, tasks, exit criteria, parked ideas. |
| `CODEMAP.md` | `docs/CODEMAP.md` | *Optional, recommended once there's code.* A short map of where things live, key entry points and signatures, test fixtures, and how to read the docs cheaply. |
| ADRs | `docs/adr/NNNN-title.md` | Significant decisions, numbered, never deleted. |
| Path rules | `.claude/rules/*.md` with `paths:` frontmatter | Area-specific rules, loaded only when matching files are touched. |

## PLAN.md

Required shapes (the skills parse these):

- **Current stage line**, near the top, exactly one:
  `**Current stage: Stage <stage> — <name>**`
- **Stage headings:** `## Stage <stage> — <name>`, optionally followed by a status such as
  ` — done 2026-10-01`.
- **Stage IDs** are a number, or a dotted number for a stage inserted between two others
  (`1.5` sits between Stage 1 and Stage 2).
- **Tasks:** checkbox lines with a bold task ID, `<stage>.<n>`, optionally with a letter suffix
  for a task inserted after another (`1.5.13b` follows `1.5.13`):
  `- [ ] **<stage>.<n>** <task text, referencing SPEC sections where relevant>`
  Ticked tasks use `- [x]`. Tasks may be grouped under `###` subheadings inside a stage.
- **Exit criteria:** each stage has a `**Exit criteria:**` paragraph or list after its tasks.
- **Parked section:** a final `## Parked` heading. Items are appended as:
  `- [ ] <idea> (parked <YYYY-MM-DD>; suggested stage: <stage or "later">)`
  When a parked item is scheduled, tick it and note where: `- [x] *(Scheduled as 1.5.13.)* <idea> ...`

Stages that are intentionally unplanned (e.g. "refinement, driven by use") may use plain bullets
instead of task lines; `next-task` only picks checkbox tasks.

## AGENTS.md

Required sections (exact heading text):

- `## Commands`: a bullet list of commands as `` `command`: what it does ``. The skills look for
  commands described as test, lint, and build. If a command doesn't exist yet, say so here
  (e.g. "created in task 0.1").
- `## Hard rules`: bullet list of rules whose violation is a bug. The reviewer checks every one.

Recommended sections: a one-paragraph project summary, `## Before any task`, `## Style`,
`## Finishing a task` (including the commit message format; default is
`<area>: <what changed> (PLAN <id>)`).

Keep AGENTS.md under ~150 lines. Detail belongs in path rules, the SPEC, the CODEMAP, or ADRs.

## SPEC.md

Required:

- A section whose heading contains **`Product principles`** (numbered or not). The reviewer treats
  each principle as a requirement.
- Numbered `##` / `###` headings (`## 7. Core flows`, `### 7.1 ...`), so a section can be read on
  its own by heading instead of loading the whole file.

Recommended: requirements tagged by the stage that first needs them (`[P]` prototype, `[M]` MVP,
`[L]` later), so `next-task` can tell what's in scope.

## CODEMAP.md (optional)

When present, `next-task` and the reviewer read it before exploring code, and `next-task` keeps it
current. Keep it a map, not documentation: one line per package, entry point, or fixture; no detail
that the language's own doc tool already gives. Useful sections: how to read the SPEC and PLAN by
heading, how the app is wired at startup, one line per package with its key entry points, and where
the reusable test fixtures are.

## Conventions the skills assume

- One task per session, one task per commit.
- `next-task` stops after proposing a plan and waits for approval.
- Context is a budget: every file read stays in the session for every later turn. Skills read docs
  by section, code by signature or line range, and command output trimmed to what matters.
- Out-of-scope ideas are parked, not built.
- The reviewer is read-only and reports Blocking / Should fix / Nitpick.
