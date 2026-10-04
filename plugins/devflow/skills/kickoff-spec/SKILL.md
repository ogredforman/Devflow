---
name: kickoff-spec
description: Turn docs/BRIEF.md into docs/SPEC.md from the devflow template, with product principles, [P]/[M]/[L] tags, and an interface + fake per external dependency. Writes one file, then stops.
argument-hint: "[brief file path]"
disable-model-invocation: true
---

# Kickoff: spec

Turn the reviewed brief into `docs/SPEC.md`: what the system is and why, precise enough that a PLAN
can be cut from it. This is the second kickoff step. Write one file, then stop for review.

## 1. Read the brief

- If `$ARGUMENTS` is a path to an existing file, use it as the brief. If it looks like a path but the
  file doesn't exist, say so and stop.
- Otherwise read `docs/BRIEF.md`. If it doesn't exist, say "No brief found. Run
  `/devflow:kickoff-brief` first." and stop.
- Note any of the brief's "Open questions" that block the SPEC (the stack, the MVP test, an
  external dependency's role). They go first in step 3's questions, not in a separate round.

## 2. Check the target

- Read `${CLAUDE_PLUGIN_ROOT}/templates/SPEC.md`. It is the shape of the output.
- Read the `## SPEC.md` section of `${CLAUDE_PLUGIN_ROOT}/CONTRACT.md` (only that section). Those
  rules must hold for the output.
- Check whether `docs/SPEC.md` exists (`ls`). If it does, say so in one line and ask whether to
  continue (step 4 will show the changes before replacing it). If the user declines, stop.

## 3. Map, then ask about the gaps

- Map the brief onto the template:

  | Brief | SPEC |
  |---|---|
  | Problem, Users and use | 1. Summary, 2. Problem statement |
  | Goals, Non-goals | 3. Goals, 4. Non-goals |
  | Principles, Key decisions | 5. Product principles |
  | Stack, External dependencies | 10. Architecture (10.1–10.4) |
  | Scope guardrail | the `[M]` line in 8. Functional requirements |
  | Open questions | 13. Open questions |

  Sections 6, 7, 9, 11 and 12 come from your answers and what the brief implies; 14 stays as the
  template has it; 15. Glossary defines the domain terms the spec uses.

- The brief usually says little about the domain model, core flows, and which requirements belong
  to the prototype. List what is missing **and matters** for those, plus anything the brief leaves
  ambiguous.
- Ask at most 5 questions, all in one message, blocking brief questions first, then most important. Each gets a default derived
  from the brief:
  ```
  1. Prototype scope? Default: [P] = import a CSV with the fake bank feed and print totals; the real feed is [M].
  2. Does a Budget belong to one Account or many? Default: many (you mentioned shared budgets).
  ```
  End with: "Reply with answers, or 'defaults' to accept them all."
- Wait for the answers. If nothing important is missing, skip the questions and say so in one line.

## 4. Write docs/SPEC.md

- Fill the template:
  - **Product principles:** take them from the brief's Principles and the constraints behind its key
    decisions. Each is a bold short name plus one or two sentences saying what it means in practice.
    Don't invent principles the brief doesn't support; if there are fewer than you'd expect, leave
    it and note it under Open questions.
  - **Requirements:** tag every one `[P]` prototype, `[M]` MVP, or `[L]` later. `[M]` is what the
    brief's scope guardrail needs; `[P]` is the smallest slice that proves the core idea, using
    fakes; anything beyond the guardrail is `[L]`.
  - **External dependencies:** for each one (APIs, LLMs, payment, email, OS services, hardware), an
    interface in 10.3 and an entry in 10.4 saying how the fake behaves and how it is made
    deterministic for tests. If there are none, write "No external dependencies." in 10.3 and 10.4.
    Time counts as a dependency when behavior depends on it (expiry, ages, schedules): give it a
    `Clock` interface and a settable fake. A local dependency that tests can use for real and keep
    deterministic, typically the filesystem via a temp dir, may skip the interface; say so in 10.4
    with how tests isolate it (e.g. "Filesystem: not faked; paths are injected and tests use a temp dir").
  - **Assumptions:** anything you had to decide that the brief and answers didn't settle goes under
    13. Open questions, with what it blocks and the assumption used for now.
  - Set Status to `Pre-prototype` and remove the template's `<!-- -->` comments.
- Keep every section and its number in template order. If a section has no content (e.g. no UI),
  write "None yet." or "Not applicable." rather than dropping it.
- Keep it specific and checkable; leave build order to the PLAN.
- If `docs/SPEC.md` already exists: read it, show a short per-section summary of what would change,
  and ask before replacing it. If the user declines, stop without writing.
- Create `docs/` if needed, then write the file.

## 5. Check the output

Re-check the written file with `grep -n '^##' docs/SPEC.md` and `grep -c '\[[PML]\]' docs/SPEC.md`:
- A heading containing "Product principles" exists, with at least one principle under it.
- All `##` and `###` headings are numbered.
- Requirements in section 8 are tagged, and every external dependency appears in 10.4 and, unless
  10.4 says it isn't faked, in 10.3.

Fix any failure before replying. Don't run `check-contract` here; PLAN.md and AGENTS.md don't exist yet.

## 6. Stop

Reply briefly:
- The file written, and what to review: the product principles, the `[P]`/`[M]` split, the
  interfaces and fakes, and the open questions (answer or accept them by editing the file).
- Next step: `/devflow:kickoff-plan` once the spec looks right.

Don't start the PLAN or any other kickoff step.
