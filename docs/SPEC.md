# devflow — System Specification

> **Audience:** the owner and AI coding agents working on this repo. Source of truth for *what*
> devflow is and *why*. For build order, see [`PLAN.md`](./PLAN.md).
>
> **Status:** Layer 1 (workflow) done; v0.2.0 adds what Waypoint's Stage 1 taught. Layer 2 (kickoff pipeline) not started.

## 1. Summary

devflow is a personal Claude Code plugin that packages a doc-driven development workflow:
**discuss an idea → generate project docs → build task by task with plan → build → verify → review.**

It has two layers:

- **Layer 1, the workflow** (done): `/devflow:next-task`, `/devflow:park`, `/devflow:progress`, and the
  `devflow:reviewer` subagent. They contain nothing project-specific; they work in any repo that
  follows the doc contract (`plugins/devflow/CONTRACT.md`).
- **Layer 2, the kickoff pipeline** (to build): skills that turn an idea discussion into a repo that
  follows the contract: BRIEF → SPEC → PLAN → AGENTS/CLAUDE/rules/hooks.

## 2. Problem statement

- Setting up a new project well (spec, staged plan, agent instructions, rules, hooks) takes hours of
  careful work, and quality varies project to project.
- Without that setup, AI-assisted builds drift: scope creep, forgotten rules, no clear next step.
- Ideas are usually worked out in long conversations whose conclusions never get written down.

## 3. Goals

1. From a finished idea discussion to a ready-to-build repo in under an hour, with human review at each step.
2. Every generated repo follows the doc contract, so Layer 1 works in it without changes.
3. Output quality is consistent across projects because every step fills a template.
4. The pipeline is resumable: state lives in files, so any step can be re-run or continued later.

## 4. Non-goals (for now)

- Supporting teams, org policy, or publishing to public marketplaces.
- Generating application code. Kickoff stops at docs, config, and hooks; Stage 0 of the project's
  own PLAN does the scaffolding.
- Presets for every stack. Add a preset when a real project needs it.

## 5. Product principles

- **Stop for review between steps.** Each kickoff step writes one artifact and stops. Downstream
  steps build on reviewed input only; mistakes in the SPEC must not silently flow into the PLAN.
- **Files are the state.** Skills decide what to do from which docs exist and their contents,
  never from conversation memory alone.
- **Ask, don't invent.** When input is missing something that matters (stack, a key decision), ask.
  At most 5 questions per step; offer a sensible default for each.
- **Templates are the source of shape.** Skills fill `${CLAUDE_PLUGIN_ROOT}/templates/*` rather
  than inventing structure, and never drop contract-required sections.
- **Never overwrite silently.** If a target file exists, show what would change and ask before replacing it.
- **Generic by default.** Plugin files never mention a specific project. Project knowledge lives only
  in the generated repo.
- **Context is a budget.** Every file a session reads is paid for on every later turn. Skills read
  docs by section, code by signature or line range, and command output trimmed, and they lean on a
  project's `docs/CODEMAP.md` for orientation. (Learned in Waypoint's Stage 1.)
- **Small and boring.** Skills are Markdown instructions. Code only where Markdown can't do the job
  (e.g. hooks).

## 6. Components

### 6.1 Layer 1 (done)

| Component | Path | Purpose |
|---|---|---|
| Doc contract | `plugins/devflow/CONTRACT.md` | The shapes the skills rely on |
| `next-task` skill | `plugins/devflow/skills/next-task/` | One PLAN task through plan → build → verify → review |
| `park` skill | `plugins/devflow/skills/park/` | Append an idea to PLAN's Parked section |
| `progress` skill | `plugins/devflow/skills/progress/` | Where-you-left-off summary |
| `reviewer` agent | `plugins/devflow/agents/reviewer.md` | Read-only review against the project's own docs |
| Templates | `plugins/devflow/templates/` | BRIEF, SPEC, PLAN, AGENTS, CLAUDE, CODEMAP, ADR |
| Go preset | `plugins/devflow/presets/go/` | Hooks program, settings, Go rules, gitignore |

### 6.2 Layer 2 (to build)

| Skill | Input | Output | Notes |
|---|---|---|---|
| `kickoff-brief` | The current conversation, pasted notes, or a file path in `$ARGUMENTS` | `docs/BRIEF.md` | Distills conclusions and decisions *with reasons*. Lists open questions instead of guessing. |
| `kickoff-spec` | `docs/BRIEF.md` | `docs/SPEC.md` | Fills the SPEC template. Principles come from the brief. Every external dependency gets an interface and a fake (§10.4 of the template); time gets a `Clock`. A local dependency tests can use for real (the filesystem via a temp dir) may skip the interface if §10.4 says how tests isolate it. |
| `kickoff-plan` | `docs/SPEC.md` | `docs/PLAN.md` | Standard stage pattern (0 foundations, 1 prototype with fakes, 2 MVP, 3 refinement, 4 packaging). Tasks sized to one session each. Stage 0 includes starting `docs/CODEMAP.md`. |
| `kickoff-agents` | SPEC + PLAN + chosen preset | `AGENTS.md`, `CLAUDE.md`, `.claude/rules/*`, `.claude/settings.json`, `tools/hooks/`, `.gitignore`, `.gitattributes`, `docs/adr/` | Hard rules derived from SPEC boundaries and principles. Copies the stack preset. Offers `git init` + first commit. |
| `kickoff` | Whatever exists | Runs the next missing step | Resumable orchestrator: inspects which docs exist and runs the next step, stopping after each. |
| `check-contract` | An existing repo | A report | Verifies a repo follows CONTRACT.md; lists exactly what to fix. Used at the end of kickoff and when adopting devflow in existing repos. |

## 7. Core flow: kickoff

1. The user discusses the idea (in claude.ai or a Claude Code session), as long as needed.
2. `/devflow:kickoff-brief` → writes `docs/BRIEF.md` → stops. User reviews and edits.
3. `/devflow:kickoff-spec` → writes `docs/SPEC.md` → stops.
4. `/devflow:kickoff-plan` → writes `docs/PLAN.md` → stops.
5. `/devflow:kickoff-agents` → asks which preset (or none), writes agent files and config → runs
   `check-contract` → offers `git init` and the first commit → stops.
6. The user runs `/devflow:next-task` to start Stage 0.

`/devflow:kickoff` does steps 2–5 one at a time: each run performs the next missing step and stops.

## 8. Requirements

- [L2] Every kickoff skill reads its template from `${CLAUDE_PLUGIN_ROOT}/templates/` and its
  contract from `${CLAUDE_PLUGIN_ROOT}/CONTRACT.md`.
- [L2] Every kickoff skill has `disable-model-invocation: true`; the user starts each step.
- [L2] Each skill ends by telling the user what to review and which command runs next.
- [L2] The whole pipeline is tested on at least one toy idea and one real project before Layer 2 is "done".

## 9. Non-functional

- Works on Windows, macOS, and Linux (skills are Markdown; preset hooks are Go).
- `claude plugin validate ./plugins/devflow` and `claude plugin validate .` pass after every change.
- Skill descriptions stay short, since they load into every session's context.

## 10. Repository layout

```
.claude-plugin/marketplace.json   local marketplace listing the devflow plugin
plugins/devflow/                  the plugin (installed from here)
  .claude-plugin/plugin.json
  CONTRACT.md
  skills/<name>/SKILL.md
  agents/reviewer.md
  templates/
  presets/<stack>/
docs/SPEC.md  docs/PLAN.md        this repo's own spec and plan (it follows the contract too)
AGENTS.md  CLAUDE.md              agent instructions for working on devflow itself
```

## 11. Open questions

- Should `kickoff-brief` read a claude.ai conversation export directly, or only pasted text? (Default: pasted text or a file.)
- Should kickoff create the project folder, or always run inside an existing empty folder? (Default: existing folder.)

## 12. Glossary

- **Contract:** the doc shapes in `CONTRACT.md` that Layer 1 depends on.
- **Preset:** stack-specific files (hooks, rules, gitignore) copied into a project once, then owned by it.
- **Kickoff:** the Layer 2 pipeline from idea to ready-to-build repo.
