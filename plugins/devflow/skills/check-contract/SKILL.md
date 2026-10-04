---
name: check-contract
description: Check a repo's docs against the devflow doc contract and list every missing or malformed item with the exact fix. Reports only; never edits.
argument-hint: "[repo path]"
disable-model-invocation: true
---

# Check contract

Check that a repo's docs follow `${CLAUDE_PLUGIN_ROOT}/CONTRACT.md`, so the devflow skills can parse
them. Report problems with exact fixes. Never edit files.

Other skills (e.g. the kickoff steps) may follow these steps to check their own output. In that
case, use the report to fix what that skill just wrote, then continue with its steps.

Use `grep -n` and `ls` throughout. Don't read whole files; the checks below only need matching lines.

## 1. Find the files

- The repo is the path in `$ARGUMENTS`, or the current directory if empty. If the path doesn't
  exist, say so and stop.
- Look for: `AGENTS.md` and `CLAUDE.md` at the root; `SPEC.md` and `PLAN.md` in `docs/`, else the
  root; optional `docs/CODEMAP.md`, `docs/adr/`, `.claude/rules/`.
- Each missing required file is one problem. Fix: "create it from
  `${CLAUDE_PLUGIN_ROOT}/templates/<file>`". Skip that file's checks below.

## 2. PLAN.md

Get the structure in one pass:
`grep -nE '^## |^\*\*Current stage|^\*\*Exit criteria|^\s*- \[.\]' <PLAN>`

IDs: a stage ID is `N` or dotted `N.N...` (`1.5`). A task ID is `<stage>.<n>` with an optional
lowercase letter (`1.5.13b`). Tasks may sit under `###` subheadings inside a stage; stages
with only plain bullets (no checkboxes) are allowed and skip the task and exit-criteria checks.

| Check | Rule |
|---|---|
| Current stage line | Exactly one line matching `^\*\*Current stage: Stage [0-9]+(\.[0-9]+)* — .+\*\*$`, and it names a stage that has a heading. |
| Stage headings | Any `## Stage` heading matches `^## Stage [0-9]+(\.[0-9]+)* — .+`. Other `##` headings (Background, Working agreements, ...) are fine. |
| Task lines | Every `- [ ]` / `- [x]` line inside a stage matches `^- \[[ x]\] \*\*[0-9]+(\.[0-9]+)+[a-z]?\*\* .+`. Flag near-misses: ID not bold, `[X]`, missing space, indented. |
| Task stage | Dropping the last `.<n>[letter]` from a task ID gives the stage it sits under (`1.5.13b` belongs under Stage 1.5). |
| Unique IDs | No task ID appears twice. |
| Exit criteria | Each stage with checkbox tasks has an `**Exit criteria:**` line after its last task. |
| Parked | `## Parked` exists and is the last `##` heading. Its checkbox items match `^- \[ \] .+ \(parked [0-9]{4}-[0-9]{2}-[0-9]{2}; suggested stage: .+\)$`, or start `- [x] *(Scheduled as` when ticked. |

## 3. AGENTS.md, CLAUDE.md

`grep -nE '^## |^- ' AGENTS.md` and `wc -l AGENTS.md`.

- `## Commands` exists, with bullets shaped `` - `<command>`: <what it does> ``. At least one is
  described as the test command, or the section says when it will be created (e.g. "created in task 0.1").
- `## Hard rules` exists, with at least one bullet.
- Over ~150 lines: suggestion only (move detail to path rules, SPEC, CODEMAP, or ADRs).
- `CLAUDE.md` contains `@AGENTS.md`.

## 4. SPEC.md

`grep -nE '^#{2,3} |\[(P|M|L)\]' <SPEC>`

- A `##` or `###` heading contains `Product principles`.
- `##` / `###` headings are numbered (`## 7. Core flows`, `### 7.1 ...`). The title `#` is exempt.
- No `[P]`/`[M]`/`[L]` tags: suggestion only.

## 5. Optional files

Check only what exists:
- `docs/adr/*.md` names match `NNNN-title.md` (`0000-template.md` and `README.md` are fine).
- Each `.claude/rules/*.md` has `paths:` in its frontmatter.

## 6. Report

Problems break the contract, and the skills will misread or miss something. Suggestions are
recommended items only and don't affect the result. Give each problem a location, the cause, and the
exact fix, with the corrected line where there is one:

```
Contract check: 3 problems, 1 suggestion

docs/PLAN.md
- :6 current stage line isn't closed → `**Current stage: Stage 2 — MVP**`
- :48 task ID not bold → `- [ ] **2.1** Write the parser (SPEC §7.1)`
AGENTS.md
- no `## Hard rules` section → add it with one bullet per rule whose violation is a bug

Suggestions
- docs/SPEC.md: no [P]/[M]/[L] tags on requirements
```

If there are no problems, the first line is `Contract check: PASS` (plus any suggestions). Stop there;
don't offer to fix anything unless the user asks.
