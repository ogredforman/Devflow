---
name: next-task
description: Pick up and complete the next task from the project's PLAN.md (or a specific one, e.g. /devflow:next-task 1.5) using the plan, build, verify, review loop.
argument-hint: "[task id, e.g. 1.5 or 1.5.13b]"
disable-model-invocation: true
---

# Next task

Complete exactly one task from the project's plan, then stop.

This skill relies on the devflow doc contract: `docs/PLAN.md` (or `PLAN.md`) with a
`**Current stage: ...**` line and `- [ ] **<task id>**` task lines; `docs/SPEC.md` (or `SPEC.md`);
and `AGENTS.md` with `## Commands` and `## Hard rules` sections. If PLAN.md or AGENTS.md is missing
or doesn't follow that shape, say what's missing and stop rather than improvising.
The full contract is in `${CLAUDE_PLUGIN_ROOT}/CONTRACT.md`.

Every turn re-reads the whole conversation, so context you load early gets paid for again on
every later turn. Keep the session lean: read only what the task needs, and do the work in
few, well-batched steps. This matters as much as getting it right the first time.

## 1. Pick the task

- If an ID was given (`$ARGUMENTS`), use that task.
- Otherwise use the first unchecked `[ ]` task in the current stage.
  Find it with `grep -n` rather than reading the whole file; read only the current stage's section.
- Check that earlier tasks it depends on are done. If one isn't, say which, and stop.
- If the current stage has no unchecked tasks, check its exit criteria. If they're met, say so and
  suggest updating the "Current stage" line; don't start the next stage yourself.
- Run `git status --short` and note any files that are already uncommitted (step 7 needs this).
- Name the thread after the task, e.g. `1.5 Add export endpoint` (id plus 3–6 words). In Claude Code
  the plugin's hook already set the session title. If the host gives you a tool that renames the
  current thread (it may need loading first), call it. Otherwise skip this.

## 2. Understand it

- If `docs/CODEMAP.md` exists, read it first. It says where things live, the key signatures, and
  which test fixtures to reuse.
- Read only the SPEC sections the task touches, by heading
  (e.g. `awk '/^### 7.1/,/^### 7.2/' docs/SPEC.md`), not the whole SPEC.
- Look at the existing code the task interacts with, cheaply:
  - Signatures and structure: the language's doc tool (e.g. `go doc ./internal/<pkg>`) or
    `grep -n` for function and type declarations.
  - Bodies: read the specific functions or line ranges you need, not whole files.
  - Read a whole file only if you'll edit much of it. Don't open files you won't change or call.
  - Don't re-read a file you already have in context, or one you just edited.
- Restate, briefly:
  - **Task:** one sentence.
  - **Done when:** 2–5 concrete, checkable acceptance criteria.
  - **Out of scope:** anything nearby that belongs to a later task.
  - **Questions:** real ambiguities only. If none, say "none".

## 3. Plan, then stop

- Propose an implementation plan: files to create or change, key types and functions, and the tests you'll write.
  End it with the commit it will make: `When done: commits "<message>" (say "no commit" to skip).`
  If AGENTS.md opts out (see step 7), say it will suggest the message instead.
- If the task is large (e.g. many endpoints or screens, or more than ~8 files), propose splitting it
  into smaller PLAN tasks (e.g. `1.5.13` and `1.5.13b`) and doing only the first now. Long sessions
  cost far more per step than short ones.
- **Stop and wait for the user's approval.** Do not write code yet. If the user changes the plan,
  update it and continue. Approving the plan also approves committing the finished task (step 7).

## 4. Build

- Implement the approved plan with tests alongside the code.
- Batch the work to keep turns few:
  - Write new files whole, in one step each.
  - Make related edits to a file together, not one line per turn.
  - Don't stop to compile or test after every small change. Finish a coherent piece, then check it.
- While iterating, test only the affected package or module, with trimmed output
  (e.g. `... 2>&1 | tail -30`). Keep all command output short (`tail`, `grep`, `head`).
- Stay in scope. If something worth doing isn't part of this task, append it to PLAN.md's
  `## Parked` section (same format as `/devflow:park`) and move on.
- A deliberate shortcut with a known limit gets a `shortcut: <limit>, <when to upgrade>` comment
  and a Parked entry for the upgrade, written when you take the shortcut.

## 5. Verify

- Run the test and lint commands listed in AGENTS.md `## Commands` once the work is done, with
  output trimmed to failures. Fix failures.
- For UI work, tell the user exactly what to click through to confirm it works. Don't drive browser
  preview tools unless the user asks; their snapshots are large.

## 6. Review

- Invoke the `devflow:reviewer` subagent with a brief, so it doesn't redo your orientation:
  ```
  Review PLAN <id>: <task title>
  SPEC sections: <e.g. §7.1, §10.5>
  Changed files: <list, noting which are new>
  Tests / lint: passed   (or: the failures, trimmed)
  Notes: <anything non-obvious: deliberate trade-offs, things parked>
  ```
- If the `ponytail:ponytail-review` skill is available, also spawn a general-purpose subagent in
  the same message as the reviewer call (so they run in parallel), so its report stays out of this context. Prompt: "Run the
  `ponytail:ponytail-review` skill on the uncommitted changes", the same brief, and "The project's
  AGENTS.md test rules override your missing-test checks." Map its groups onto the reviewer's:
  Must fix → Blocking, Should fix → Should fix, Nice to have → Nitpick; merge findings both raise.
  If the skill isn't available, skip this silently.
- Fix every Blocking finding. Fix Should-fix findings unless there's a good reason not to; if you
  skip one, say why.
- If you made significant fixes, run the review(s) once more, naming only the files you changed since
  (for ponytail, put those files in place of "the uncommitted changes").

## 7. Wrap up

- Tick the task `[x]` in PLAN.md.
- Check that every `shortcut:` comment the diff adds (`git diff | grep '^+.*shortcut:'`, plus
  `grep -n 'shortcut:'` in untracked new files) has a matching entry in PLAN.md's `## Parked`
  section; add any that are missing.
- Update the SPEC or add an ADR in `docs/adr/` if a design decision changed.
- If `docs/CODEMAP.md` exists and you added or moved a package, public entry point, or test fixture,
  update it. Keep it a map: one line per thing.
- Commit the task with a message in the format AGENTS.md specifies (default
  `<area>: <what changed> (PLAN <id>)`). Stage only the files this task changed (`git add <paths>`,
  never `-A`). Never push. If the commit fails (e.g. a hook), fix the cause and retry; never skip
  hooks.
- Don't commit, and instead give the suggested message and say why, if any of these hold:
  - the user said not to commit;
  - AGENTS.md has a line `- Auto-commit: off` (`grep -nE '^\s*- Auto-commit: off' AGENTS.md`);
  - a file the task changed already had uncommitted edits at step 1;
  - a Blocking finding or a test/lint failure is still open;
  - the project isn't a git repository.
- Give the user a short summary: what was built, anything skipped or parked, and the commit (hash
  and message) or the suggested message. Don't start the next task.
