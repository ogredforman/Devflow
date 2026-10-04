# Moving Waypoint onto the devflow plugin

A one-time change that swaps Waypoint's local copies of the workflow skills and reviewer for the
plugin's shared versions. Waypoint's code, docs, rules, hooks, and PLAN progress stay exactly as they are.

*Checked against Waypoint on 2026-10-03 (Stage 1.5, `main`, PLAN at 1.5.13b next).*

## What's already been carried over

During Stage 1, Waypoint's `next-task` skill and reviewer were improved. The generic parts of those
improvements are now in devflow 0.2.0, so deleting the local copies loses nothing:

| Waypoint's local change | Where it lives now |
|---|---|
| "Context is a budget" guidance, batching, reading by signature / line range | Plugin `next-task` and reviewer |
| Read `docs/CODEMAP.md` first; keep it current | Plugin `next-task` and reviewer (when the file exists); Waypoint's AGENTS.md already says it |
| SPEC read by heading with `awk` | Plugin `next-task` and reviewer |
| Split large tasks (e.g. `1.5.13` / `1.5.13b`) | Plugin `next-task`; dotted stages and lettered IDs are now in the contract |
| Structured brief from `next-task` to the reviewer; reviewer trusts reported test results | Plugin `next-task` and reviewer |
| Reviewer on Sonnet | Plugin reviewer (`model: sonnet`) |
| `go doc` / `grep -n '^func'` orientation, test one package with `tail` | Waypoint's `.claude/rules/go.md` (added in Step 3) |
| Exact trimmed `make test` / `make lint` commands | Waypoint's AGENTS.md `## Commands` (added in Step 3) |
| Reviewer's inline copy of the hard rules | Not needed: the plugin reviewer reads AGENTS.md `## Hard rules` directly |

`/park` and `/progress` were never changed locally.

**Command names after the move:**

| Before | After |
|---|---|
| `/next-task` | `/devflow:next-task` |
| `/park` | `/devflow:park` |
| `/progress` | `/devflow:progress` |
| `reviewer` agent | `devflow:reviewer` agent |

Do this **between tasks**, on `main`, with everything committed and no open worktrees.

---

## Step 1: Install the plugin (once per computer)

In PowerShell (or any terminal):

```
cd F:\dev\Devflow
git init
git add -A
git commit -m "devflow: workflow plugin v0.2.0"

claude plugin validate .
claude plugin marketplace add F:\dev\Devflow
claude plugin install devflow@devflow
claude plugin list
```

`claude plugin validate .` checks the marketplace file and the plugin it lists, so one validate is
enough. (To validate the plugin folder by itself, use forward slashes or a full path:
`claude plugin validate ./plugins/devflow`.)

`claude plugin list` should show `devflow@devflow`, version 0.2.0, enabled, at user scope (every
project on this computer). Leave `F:\dev\Devflow` where it is: the plugin is read from there.

Fully quit and reopen T3 Code so new sessions pick it up.

---

## Step 2: Check nothing changed since this guide was written

The table above was checked against Waypoint as of 2026-10-03. If you or Claude changed the local
skills or reviewer after that, look at it before deleting:

```
cd F:\dev\Waypoint
git log --oneline --since=2026-10-03 -- .claude/skills .claude/agents
```

No output means nothing changed; go on. If there are commits, `git show <commit> -- .claude` shows
what. A Waypoint-specific rule goes into AGENTS.md or a `.claude/rules/` file; a general workflow
improvement goes into the plugin in `F:\dev\Devflow`.

---

## Step 3: Update Waypoint

Start a **new** thread in the Waypoint project and paste this prompt. It makes the edits and checks
its own work. (Every change is listed, so you can also do them by hand.)

````
We're moving this repo's workflow skills and reviewer to the installed `devflow` plugin.
Make exactly these changes and nothing else:

1. Delete these with git rm:
   - .claude/skills/next-task/
   - .claude/skills/park/
   - .claude/skills/progress/
   - .claude/agents/reviewer.md
   Remove .claude/skills/ and .claude/agents/ if they are then empty.
   Do NOT touch .claude/rules/ (except step 6), .claude/settings.json, or tools/hooks/.

2. CLAUDE.md: replace the "## Claude Code" section with:

   ## Claude Code

   - Use plan mode for any task that touches the schema, `internal/changeset`, or the extraction pipeline.
   - Workflows (devflow plugin): `/devflow:next-task` (do the next PLAN task), `/devflow:park <idea>`
     (capture an idea without doing it), `/devflow:progress` (where things stand).
   - The `devflow:reviewer` subagent checks diffs against the hard rules above. Use it before finishing any task.
   - Hooks in `.claude/settings.json` auto-format Go, protect committed migrations, and run
     `go build` + `go vet` when you stop. If a hook blocks you, fix the cause; don't work around it.

   If that section has lines not in the text above, keep them and tell me.

3. AGENTS.md, "## Finishing a task": change "Run the `reviewer` agent" to
   "Run the `devflow:reviewer` agent".

4. AGENTS.md, "## Commands": add this bullet at the end of the list:
   - Trimmed for agents: `make test 2>&1 | grep -v '^ok\|no test files' | tail -30` and
     `make lint 2>&1 | tail -15`. Use these forms when checking a task.

5. docs/PLAN.md: in the paragraph under the "Current stage" line, change `/next-task` to
   `/devflow:next-task` and `/park` to `/devflow:park`. Change nothing else in PLAN.md.

6. .claude/rules/go.md: add these two bullets at the top of the list:
   - To orient, prefer `go doc ./internal/<pkg>` and `go doc ./internal/<pkg> <Symbol>` or
     `grep -n '^func\|^type' <file>` over reading whole files. Read bodies by line range.
   - While iterating, test only the package you changed: `go test ./internal/<pkg>/ 2>&1 | tail -30`.

7. README.md, workflow table: `/next-task` → `/devflow:next-task`, `/next-task 1.5` →
   `/devflow:next-task 1.5`, `/park` → `/devflow:park`, `/progress` → `/devflow:progress`.

8. .gitignore: under the Claude Code section (next to `.claude/settings.local.json`), add
   `.claude/worktrees/` so agent worktrees never show up as untracked files.

9. Verify: search the repo (excluding .git, node_modules, and docs/adr) for "/next-task", "/park",
   "/progress", and "`reviewer`", and show me any remaining reference not prefixed with "devflow:".
   Then show `git status --short` and `git diff --stat`. Don't commit.
````

Review the diff, then commit:

```
git add -A
git commit -m "chore: use devflow plugin for workflow skills and reviewer"
```

---

## Step 4: Confirm it works

In a **new** Waypoint thread:

1. Ask: *"Which skills and agents do you have available?"* You should see `devflow:next-task`,
   `devflow:park`, `devflow:progress`, and `devflow:reviewer`, and **no** unprefixed `next-task`
   or `reviewer` (that would mean a local copy survived).
2. Run `/devflow:progress`. It should report Stage 1.5 and the same next task as before (1.5.13b).
3. Continue with `/devflow:next-task`. In its first steps it should read `docs/CODEMAP.md` and only
   the Stage 1.5 section of PLAN.md, the same as your local version did.

If T3 Code doesn't show the plugin's commands, check `claude plugin list` in a terminal. If it's listed
there but not in T3 Code, fully quit and reopen T3 Code. As a fallback, saying "Run the devflow
next-task skill" works too.

Branches or worktrees created **before** the migration commit still contain the old local skills.
Finish and merge them first, or start new ones after the migration.

---

## Undo

The migration is one commit: `git revert <commit>` brings the local skills and reviewer back.
`claude plugin disable devflow@devflow` turns the plugin off without uninstalling it.

## Afterwards

In `F:\dev\Devflow`, tick task **1.7** in `docs/PLAN.md`, change the Current stage line to
`**Current stage: Stage 2 — Kickoff pipeline**`, and commit. That's the start of Layer 2.
