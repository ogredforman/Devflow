# <Project> — Implementation Plan

> Companion to [`SPEC.md`](./SPEC.md). The spec defines *what* and *why*; this plan defines *order*,
> *scope per stage*, and *exit criteria*. Each stage ends in a runnable, usable state. Don't pull
> later-stage work forward.

**Current stage: Stage 0 — Foundations**

Task IDs are `<stage>.<task>` (e.g. `1.5`). A stage inserted between two others gets a dotted ID
(Stage `1.5`, tasks `1.5.1`, ...), and a task inserted after another gets a letter (`1.5.13b`).
Tick tasks `[x]` as they're finished.
`/devflow:next-task` picks the first unchecked task in the current stage; `/devflow:park` adds ideas
to the Parked section at the bottom.

<!-- devflow doc contract: keep the "Current stage" line, the "- [ ] **n.m**" task format,
     "**Exit criteria:**" per stage, and the final "## Parked" section exactly as shown.

     Task-writing rules:
     - Each task is one session of work (roughly 30 min – 3 hours for an agent + review).
     - Start with a verb. Reference the SPEC sections it implements.
     - Tests are part of the task, not a separate task.
     - Order so each task builds on finished ones; foundations and contracts first. -->

## Background

<!-- 5–10 bullets summarizing the brief: idea, motivation, key decisions, stack, scope, guardrail. -->

---

## Stage 0 — Foundations

**Goal:** an empty but correctly wired app that builds, runs, and tests on every target platform.

- [ ] **0.1** <Initialize the project, repo layout (SPEC §10.2), and the build/test/lint commands AGENTS.md lists.>
- [ ] **0.2** <...>
- [ ] **0.N** <Last Stage 0 task, or part of an earlier one: start `docs/CODEMAP.md` (template in devflow) describing the wiring and packages so far.>

**Exit criteria:** <e.g. "the build command produces a runnable artifact that starts and reports healthy; CI runs tests.">

---

## Stage 1 — Prototype (fakes, no real external dependencies)

**Goal:** the complete core loop working end to end, with every external dependency replaced by a
deterministic fake. Validates the data model, architecture, and UI before real integrations add cost
and unpredictability.

- [ ] **1.1** <...>

**Exit criteria:**
- <The core loop works end to end using only fakes.>
- <All tests pass in CI.>

---

## Stage 2 — MVP (real integrations, actually usable)

**Goal:** swap fakes for real integrations, with just enough polish that the owner uses it for real.

- [ ] **2.1** <...>

**Exit criteria:**
- <The owner has used it for real for <period>, and it did its job.>

---

## Stage 3 — Refinement (driven by real use)

**Goal:** fix what real use revealed. Priorities come from the friction log and Parked items,
not from this list. Candidates:

-

**Exit criteria:** defined at the start of the stage.

---

## Stage 4 — Packaging

**Goal:** easy for someone who isn't the author to install and run.

- [ ] **4.1** <...>

**Exit criteria:** <e.g. "a fresh machine goes from download to first use in under 5 minutes following the README.">

---

## Later / future (not planned yet)

-

---

## Working agreements

- **One stage at a time.** Finish the exit criteria before starting the next stage.
- **One task per session, one task per commit.**
- **Keep docs true.** If implementation changes a decision, update SPEC.md/PLAN.md or add an ADR in the same change.
- **Definition of done:** code, tests, docs updated if needed, reviewer run, task ticked.

---

## Parked

Ideas and tangents captured mid-work (via `/devflow:park`). Not scheduled. Review them at the start of each stage.
