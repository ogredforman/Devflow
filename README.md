# Devflow

A Claude Code plugin for building software with AI coding agents the same way every time:

**discuss an idea → BRIEF → SPEC → PLAN → build one task at a time (plan → build → verify → review).**

I built it because agents left on their own drift: they skip tests, widen scope, and forget
decisions made three sessions ago. Devflow keeps every project's intent in a few plain documents
the agent must follow, and puts a human approval and an independent review on every task.

I've used it to build [Waypoint](https://github.com/ogredforman/waypoint),
[MediaMan](https://github.com/ogredforman/MediaMan) and [ServerDog](https://servers.dog).

## How it works

1. **Kickoff** turns an idea discussion into four documents, one step at a time with review in
   between:
   - `docs/BRIEF.md`: the idea, the problem and the decisions already made.
   - `docs/SPEC.md`: what the system is and why, with product principles and an interface plus a
     test fake for every external dependency.
   - `docs/PLAN.md`: stages (foundations → prototype on fakes → MVP → refinement → packaging) broken
     into tasks small enough for one session, each citing the SPEC sections it implements.
   - `AGENTS.md` / `CLAUDE.md`: commands, hard rules and path rules for the agents.
2. **Next task** picks the next unchecked PLAN task, restates it, proposes a plan and **waits for
   approval**. Then it builds with tests, runs the project's checks, has the reviewer agent check
   the diff, and ticks the task.
3. **The reviewer** is a read-only agent that checks a diff against the project's own hard rules,
   product principles, stage scope and test quality. It reports; it never edits.

The documents follow a written contract ([`plugins/devflow/CONTRACT.md`](plugins/devflow/CONTRACT.md)),
and `check-contract` verifies a repo against it, so any repo shaped this way works with the skills.

## Commands

| Command | What it does |
|---|---|
| `/devflow:kickoff` | Runs the next missing kickoff step (brief → spec → plan → agents), then stops for review |
| `/devflow:next-task` | Next unchecked PLAN task: plan, wait for approval, build with tests, verify, review, tick |
| `/devflow:next-task 1.5` | Same, for a specific task |
| `/devflow:park <idea>` | Saves an idea to PLAN.md's Parked section without acting on it |
| `/devflow:progress` | Where things stand and what's next |
| `/devflow:check-contract` | Lists every missing or malformed doc item with the exact fix |
| `devflow:reviewer` agent | Read-only review of a task's diff |

## What's in here

```
.claude-plugin/marketplace.json   makes this repo installable as a plugin marketplace
plugins/devflow/
  CONTRACT.md                     the doc shapes the skills rely on
  skills/                         kickoff (+ its four steps), next-task, park, progress, check-contract
  agents/reviewer.md
  hooks/                          titles the session after the task /devflow:next-task picks
  templates/                      BRIEF, SPEC, PLAN, AGENTS, CLAUDE, CODEMAP, ADR skeletons
  presets/go/                     Go hooks program (+tests), settings, rules, gitignore
docs/SPEC.md, docs/PLAN.md        Devflow's own spec and plan; it's built with itself
```

## Install

```sh
claude plugin marketplace add ogredforman/Devflow
claude plugin install devflow@devflow
```

Restart your Claude Code session, then run `/devflow:kickoff` in an empty folder to start a
project, or `/devflow:check-contract` in an existing one.

## Using devflow with ponytail

[ponytail](https://github.com/DietrichGebert/ponytail) keeps each change as small as it can be.
Devflow owns the process, ponytail owns how big the solution is. Ponytail is optional: without it,
the stage-end sweep uses devflow's reviewer instead of `ponytail-audit`. Its hooks need `node` on your PATH. Install it with
these two commands, sent as two separate prompts:

```sh
/plugin marketplace add DietrichGebert/ponytail
```

```sh
/plugin install ponytail@ponytail
```

- **Keep ponytail out of the reviewer.** Ponytail adds its rules to every subagent. Set
  `PONYTAIL_SUBAGENT_MATCHER` to a regex naming the agents that *should* get them, for example
  everything except devflow's agents. Add the key to the existing `env` block in
  `~/.claude/settings.json`:

  ```json
  { "env": { "PONYTAIL_SUBAGENT_MATCHER": "^(?!devflow:)" } }
  ```

- **Levels.** Use `/ponytail ultra` while you're still discussing an idea before kickoff, and
  `/ponytail full` (the default) during kickoff and `next-task`.
- **Review once per stage, not per task.** Each task gets one `devflow:reviewer` pass, whose Lean,
  security and load checks cover what ponytail's per-task review used to add. When a stage's tasks
  are all done, `next-task` offers a stage-end sweep: one `/ponytail-audit` over the stage's whole
  diff, with its findings turned into tasks for the next stage (or Parked).
- **Tests.** The project's AGENTS.md test rules win over ponytail's "one small test" minimum.
  `next-task` tells the audit this.
- **Exit criteria.** When checking a stage's exit criteria, run `/ponytail-debt` to list the
  `shortcut:` comments, and check that each has a `## Parked` entry.

## Working on the plugin

Clone the repo and add the local folder as the marketplace instead:

```sh
claude plugin validate .
claude plugin marketplace add <absolute-path-to-this-folder>
claude plugin install devflow@devflow
```

The installed plugin then reads files straight from `plugins/devflow/`. Edit a skill, run
`/reload-plugins` (or start a new session), and the change is live everywhere.

When a project reveals a workflow problem (the reviewer keeps missing something, `next-task`
should do one more step), fix it here, not in the project, so every project gets the fix.
