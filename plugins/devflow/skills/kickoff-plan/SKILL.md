---
name: kickoff-plan
description: Turn docs/SPEC.md into docs/PLAN.md from the devflow template, with standard stages and one-session tasks that cite SPEC sections. Writes one file, then stops.
argument-hint: "[spec file path]"
disable-model-invocation: true
---

# Kickoff: plan

Turn the reviewed spec into `docs/PLAN.md`: the build order, stage by stage, in tasks that
`/devflow:next-task` can pick up one session at a time. This is the third kickoff step. Write one
file, then stop for review.

## 1. Read the spec

- If `$ARGUMENTS` is a path to an existing file, use it as the spec. If it looks like a path but the
  file doesn't exist, say so and stop.
- Otherwise use `docs/SPEC.md`, else `SPEC.md` at the root. If neither exists, say "No spec found.
  Run `/devflow:kickoff-spec` first." and stop.
- Read it by section, not whole. Start with `grep -nE '^#{2,3} |\[(P|M|L)\]' <SPEC>`, then read
  the sections the plan is cut from (e.g. `awk '/^## 8\./,/^## 9\./' <SPEC>`):
  - 1–5, summary through principles (for Background)
  - 7. Core flows and 8. Functional requirements (the tasks)
  - 9. Non-functional (platforms, install, distribution)
  - 10. Architecture, especially 10.1 technology, 10.2 layout, 10.3 interfaces, 10.4 fakes
  - 13. Open questions
- If the requirements carry no `[P]`/`[M]`/`[L]` tags, say so: the stage split will be a guess. Ask
  for the split in step 3 rather than inventing one.
- Note any open questions that block the build order (the stack, what the prototype proves, a
  dependency's role). They go first in step 3's questions.

## 2. Check the target

- Read `${CLAUDE_PLUGIN_ROOT}/templates/PLAN.md`. It is the shape of the output.
- Read the `## PLAN.md` section of `${CLAUDE_PLUGIN_ROOT}/CONTRACT.md` (only that section). Those
  rules must hold for the output.
- Check whether `docs/PLAN.md` exists (`ls`). If it does, say so in one line and ask whether to
  continue (step 4 will show the changes before replacing it). If the user declines, stop.

## 3. Map, then ask about the gaps

- Map the spec onto the stages:

  | SPEC | PLAN |
  |---|---|
  | 1–5, 10.1 | Background bullets |
  | 10.1 technology, 10.2 layout, 10.3 interfaces, 12. Quality and testing | Stage 0 — Foundations |
  | `[P]` requirements, the flows they serve, 10.4 fakes | Stage 1 — Prototype |
  | `[M]` requirements, swapping each fake for the real dependency | Stage 2 — MVP |
  | Nothing yet | Stage 3 — Refinement (plain candidate bullets) |
  | 9. Non-functional (install, distribution) | Stage 4 — Packaging |
  | `[L]` requirements | Later / future |

- List what is missing **and matters** for the order or the exit criteria: target platforms and CI,
  what "used for real" means for the MVP, whether packaging is needed at all.
- Ask at most 5 questions, all in one message, blocking spec questions first, then most important.
  Each gets a default derived from the spec:
  ```
  1. MVP exit criterion? Default: you've used it for two weeks of real budgeting without falling back to the spreadsheet.
  2. CI in Stage 0? Default: yes, tests on Linux and Windows (the spec lists both).
  ```
  End with: "Reply with answers, or 'defaults' to accept them all."
- Wait for the answers. If nothing important is missing, skip the questions and say so in one line.

## 4. Write docs/PLAN.md

- Fill the template, keeping its stages, headings, intro, Working agreements, and final
  `## Parked` section. Set the Current stage line to Stage 0 and remove the template's `<!-- -->`
  comments.
- **Background:** 5–10 bullets: the idea, why, key decisions, stack, scope, and the MVP guardrail.
- **Stage 0:**
  - Task `0.1` initializes the project and repo layout (SPEC §10.2) and creates the build, test, and
    lint commands. Name the commands; AGENTS.md will list exactly these.
  - The last Stage 0 task (or part of an earlier one) starts `docs/CODEMAP.md` from the devflow
    template.
  - Other tasks wire whatever else must exist before features: CI, the domain types, and the
    interfaces from 10.3 (declarations only; their fakes are Stage 1).
- **Stage 1:** the first task builds the fakes from 10.4; every external dependency is its fake. No
  task touches a real API, account, or device. Cover every `[P]` requirement.
- **Stage 2:** one task per real integration replacing its fake, plus the remaining `[M]`
  requirements.
- **Stage 4:** tasks from SPEC §9's install and distribution needs. If packaging isn't needed yet,
  keep the stage with a plain bullet "Not planned yet." and exit criteria "defined at the start of
  the stage".
- **Every task:**
  - Uses the contract format: `- [ ] **<stage>.<n>** <task text>`.
  - Starts with a verb and cites the SPEC sections it implements:
    `- [ ] **1.3** Add the CSV importer using the fake bank feed (SPEC §7.1, §10.4).`
  - Replaces the template's `<...>` placeholder text entirely.
  - Includes its own tests; tests are never a separate task.
  - Fits one session (roughly 30 min – 3 hours for an agent plus review). If it needs many
    endpoints, screens, or files, split it.
  - Builds only on earlier tasks: foundations and interfaces first, then features in the order of
    the core flows.
- **Exit criteria:** each stage gets concrete, checkable criteria (what runs, what a user can do).
  Stage 3's are "defined at the start of the stage".
- If `docs/PLAN.md` already exists: read it, show a short per-stage summary of what would change,
  and ask before replacing it. If the user declines, stop without writing.
- Create `docs/` if needed, then write the file.

## 5. Check the output

- Follow step 2 (PLAN.md) and step 4 (SPEC.md) of `${CLAUDE_PLUGIN_ROOT}/skills/check-contract/SKILL.md`
  against the written files. Skip its AGENTS.md and CLAUDE.md checks; those files come from the next
  kickoff step.
- Check coverage: go through each `[P]` and `[M]` bullet in SPEC §8 and name the Stage 1 or Stage 2
  task that implements it. Add a task, or extend one, for any requirement with no task.
- Check no template placeholders remain: `grep -nE '<([A-Z.]|e\.g\.)[^>]*>' docs/PLAN.md` finds nothing.
- Check that `0.1` names the build, test, and lint commands and that Stage 0 mentions `CODEMAP.md`.

Fix any failure before replying.

## 6. Stop

Reply briefly:
- The file written, and what to review: the stage split, task sizes (anything too big for one
  session), the commands in `0.1`, and each stage's exit criteria.
- Any requirement you couldn't place, or any assumption you made, in one line each.
- Next step: `/devflow:kickoff-agents` once the plan looks right.

Don't start AGENTS.md or any other kickoff step.
