# devflow — Implementation Plan

> Companion to [`SPEC.md`](./SPEC.md). Build Layer 2 one task at a time with `/devflow:next-task`,
> the same way any other devflow project is built.

**Current stage: Stage 2 — Kickoff pipeline**

Task IDs are `<stage>.<task>`. Tick tasks `[x]` as they're finished. `/devflow:next-task` picks the
first unchecked task in the current stage; `/devflow:park` adds ideas to the Parked section.

## Background

- devflow started as Waypoint's `.claude/` setup, then was generalized into a plugin so every project
  gets the same plan → build → verify → review loop.
- Layer 1 (workflow skills, reviewer, contract, templates, Go preset) is extracted and working.
- Layer 2 turns an idea discussion into a repo that follows the contract. It's built here, then
  proven on a real second project.
- Every piece is Markdown except preset hooks. Plugin files never mention a specific project.

---

## Stage 1 — Layer 1: workflow plugin

**Goal:** the workflow runs from an installed plugin in any contract-following repo.

- [x] **1.1** Doc contract (`plugins/devflow/CONTRACT.md`).
- [x] **1.2** Generic `next-task`, `park`, `progress` skills.
- [x] **1.3** Generic `reviewer` agent that reads the project's own docs and path rules.
- [x] **1.4** Templates: BRIEF, SPEC, PLAN, AGENTS, CLAUDE, ADR.
- [x] **1.5** Go preset: hooks program with flags and tests, settings, rules, gitignore.
- [x] **1.6** Fold Waypoint's Stage 1 workflow improvements into the plugin (v0.2.0): lean-context
  rules in `next-task` and the reviewer, a structured brief from `next-task` to the reviewer, the
  reviewer on Sonnet and trusting reported test results, optional `docs/CODEMAP.md` in the contract
  and templates, dotted stage IDs (`1.5`) and lettered task IDs (`1.5.13b`) in the contract.
- [x] **1.7** Install the plugin and migrate Waypoint to it (`MIGRATE-WAYPOINT.md`). Confirm
  `/devflow:progress` and `/devflow:next-task` work there, including from T3 Code. This task is done
  by hand in the Waypoint repo; afterwards tick it here and change the Current stage line to Stage 2.

**Exit criteria:** a Waypoint task has been completed end to end with the plugin's skills and
reviewer, and Waypoint no longer has its own copies.

---

## Stage 2 — Kickoff pipeline

**Goal:** from an idea discussion to a ready-to-build, contract-following repo, one reviewed step at a time (SPEC §6.2, §7).

- [x] **2.1** `check-contract` skill: inspect a repo against `${CLAUDE_PLUGIN_ROOT}/CONTRACT.md` and
  report each missing or malformed item with the exact fix. It must accept dotted stage IDs and
  lettered task IDs. Test it on Waypoint (should pass) and on
  a folder with a deliberately broken PLAN.md (should list the problems). Built first because the
  other kickoff steps use it to check their own output.
- [x] **2.2** `kickoff-brief` skill (SPEC §6.2): input from the conversation, pasted text, or a file
  path in `$ARGUMENTS`; output `docs/BRIEF.md` from the template; at most 5 questions, each with a
  default; stops and says what to review. Never overwrites an existing BRIEF without asking.
- [x] **2.3** `kickoff-spec` skill: BRIEF → `docs/SPEC.md` from the template. Must produce the
  "Product principles" section, [P]/[M]/[L] tags, and an interface + fake for every external
  dependency. Lists anything it had to assume under "Open questions".
- [x] **2.4** `kickoff-plan` skill: SPEC → `docs/PLAN.md` from the template. Standard stages;
  tasks start with a verb, reference SPEC sections, and fit one session; Stage 0's first task
  creates the commands AGENTS.md will list, and Stage 0 starts `docs/CODEMAP.md`; Stage 1 uses fakes
  only. Runs `check-contract` on the result.
- [x] **2.5** `kickoff-agents` skill: SPEC + PLAN → AGENTS.md (hard rules derived from SPEC
  boundaries and principles; `## Commands` matching Stage 0's plan), CLAUDE.md, path rules for each
  major area, ADR folder. Asks which preset to use (list `${CLAUDE_PLUGIN_ROOT}/presets/`, or "none")
  and copies it, adjusting hook flags to the SPEC. Runs `check-contract`. Offers `git init` + first commit.
- [x] **2.6** `kickoff` orchestrator skill: detect which kickoff outputs exist and run the next
  missing step only, then stop and name the following command. Safe to run repeatedly.
- [ ] **2.7** Dry run: in a scratch folder, run the full pipeline on a small toy idea. Log every
  friction point with `/devflow:park`; fix the ones that produced wrong or missing output.
- [ ] **2.8** Real run: bootstrap the second real project with the pipeline and complete its
  task 0.1 with `/devflow:next-task`. Fix what breaks.

**Exit criteria:**
- A new project went from idea discussion to a committed, contract-passing repo using only the kickoff skills.
- Its first PLAN task was completed with `/devflow:next-task` and the reviewer, with no manual doc fixes needed.

---

## Stage 3 — Refinement (driven by use)

**Goal:** fix what real use revealed. Priorities come from Parked items. Candidates:

- A TypeScript/Node preset, and others only when a real project needs them.
- `adopt` skill: bring an existing repo onto the contract (generate missing docs from the code + a short interview).
- `workflow-note` skill: capture workflow friction from inside any project into this repo's Parked list.
- Plugin evals with `claude plugin eval` for `next-task` and the reviewer.
- Pushing this repo to GitHub and installing from there, for use on other machines.

**Exit criteria:** defined at the start of the stage.

---

## Working agreements

- One task per session, one task per commit.
- After editing plugin files, run `/reload-plugins` in the session and `claude plugin validate ./plugins/devflow`.
- Keep plugin files generic. If you catch yourself writing a project name, it belongs in that project.

---

## Parked

Ideas and tangents captured mid-work (via `/devflow:park`). Not scheduled. Review them at the start of each stage.
