# devflow

A personal Claude Code plugin for building projects with AI agents the same way every time:

**discuss an idea → BRIEF → SPEC → PLAN → build one task at a time (plan → build → verify → review).**

| Command | What it does |
|---|---|
| `/devflow:next-task` | Picks the next unchecked PLAN task, restates it, proposes a plan, **waits for approval**, builds with tests, runs checks and the reviewer, ticks the task |
| `/devflow:next-task 1.5` | Same, for a specific task |
| `/devflow:park <idea>` | Saves an idea to PLAN.md's Parked section without acting on it |
| `/devflow:progress` | Where things stand and what's next |
| `devflow:reviewer` agent | Read-only review of a task's diff against the project's own hard rules and principles |

These work in any repo that follows the doc contract: [`plugins/devflow/CONTRACT.md`](plugins/devflow/CONTRACT.md).

## What's in here

```
.claude-plugin/marketplace.json   makes this folder installable as a local marketplace
plugins/devflow/                  the plugin
  CONTRACT.md                     doc shapes the skills rely on
  skills/                         next-task, park, progress (Layer 2 kickoff skills go here too)
  agents/reviewer.md
  templates/                      BRIEF, SPEC, PLAN, AGENTS, CLAUDE, CODEMAP, ADR skeletons
  presets/go/                     Go hooks program (+tests), settings, rules, gitignore
docs/SPEC.md, docs/PLAN.md        devflow's own spec and plan (Layer 2 is built from these)
AGENTS.md, CLAUDE.md              instructions for agents working on devflow itself
MIGRATE-WAYPOINT.md               one-time guide to move Waypoint onto this plugin
```

## Install

Once per computer, with this folder at a permanent location:

```
git init && git add -A && git commit -m "devflow: layer 1 workflow plugin"
claude plugin validate .
claude plugin marketplace add <absolute-path-to-this-folder>
claude plugin install devflow@devflow
claude plugin list          # devflow@devflow should be enabled
```

Then restart T3 Code / Claude Code sessions. Full walkthrough, plus the Waypoint switch-over,
in [`MIGRATE-WAYPOINT.md`](MIGRATE-WAYPOINT.md).

## Changing the plugin

Because the marketplace is this local folder, the installed plugin reads files straight from
`plugins/devflow/`. Edit a skill, run `/reload-plugins` in an open session (or start a new one),
and the change is live everywhere. Commit changes here like any other project.

When a project reveals a workflow problem (the reviewer keeps missing something, `next-task` should
do one more step), fix it here, not in the project, so every project gets the fix.

## Building Layer 2 (the kickoff pipeline)

Layer 2 adds skills that turn an idea discussion into a ready-to-build repo. It's specified in
[`docs/SPEC.md`](docs/SPEC.md) §6.2 and §7, and broken into tasks in [`docs/PLAN.md`](docs/PLAN.md)
Stage 2. devflow follows its own contract, so you build it with its own workflow:

1. Finish the Waypoint migration, then in this repo tick task 1.7 and set the Current stage to Stage 2.
2. Open this folder as a project in T3 Code.
3. Run `/devflow:progress`, then `/devflow:next-task`. It starts with **2.1** (`check-contract`),
   which the later kickoff skills use to check their own output.
4. After each skill task: `/reload-plugins`, try the new skill in a scratch folder, review, commit.
5. Task **2.7** is a dry run on a toy idea. Task **2.8** is your real second project: bootstrap it
   with `/devflow:kickoff`, then run its task 0.1 with `/devflow:next-task`.

### Until Layer 2 exists: starting a new project by hand

If you want to start your other project before Layer 2 is built:

1. Discuss the idea (here or in claude.ai) until the decisions are settled.
2. Ask Claude to fill `plugins/devflow/templates/BRIEF.md` from the discussion. Review it.
3. Then, one at a time with review in between, ask it to fill `templates/SPEC.md` from the brief,
   `templates/PLAN.md` from the spec, and `templates/AGENTS.md` + `CLAUDE.md` from both, following
   `CONTRACT.md`.
4. Copy a preset if one fits (`presets/go/README.md` says what goes where), `git init`, commit.
5. Run `/devflow:next-task`.

That manual run is also a good way to find out what the kickoff skills need to handle. Park what you learn in this repo's PLAN.

## Later: using it on other computers

Push this repo to GitHub (private is fine). On another machine:
`claude plugin marketplace add <github-user>/devflow`, then `claude plugin install devflow@devflow`.
