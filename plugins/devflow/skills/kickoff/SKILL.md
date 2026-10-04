---
name: kickoff
description: Resume the devflow kickoff. Detects which of BRIEF, SPEC, PLAN, and AGENTS.md exist, runs only the next missing step, then stops. Safe to run repeatedly.
argument-hint: "[arguments for the next step]"
disable-model-invocation: true
---

# Kickoff

Run the next missing kickoff step (brief → spec → plan → agents), and only that one. Each step
writes its files and stops for review; running `/devflow:kickoff` again picks up where it left off.

## 1. Detect what exists

- Check each output with one `ls`, in both places the step skills accept:
  `ls docs/BRIEF.md docs/SPEC.md SPEC.md docs/PLAN.md PLAN.md AGENTS.md CLAUDE.md`
- A file only counts if it's filled in. Every step removes the template's `<!-- -->` comments, so if
  `grep -n '<!--' <file>` shows template guidance (instructions on what to write), treat the file
  as missing; its step will redo it and ask before replacing it. A few comments the user added
  (e.g. `<!-- TODO: confirm pricing -->`) don't make a file unfilled.
- Work back from the last step and take the first match:

  | Found | Step to run |
  |---|---|
  | `AGENTS.md` with `## Commands` and `## Hard rules`, and `CLAUDE.md` | none: kickoff is done |
  | PLAN | `kickoff-agents` |
  | SPEC | `kickoff-plan` |
  | `docs/BRIEF.md` | `kickoff-spec` |
  | nothing | `kickoff-brief` |

  A row applies only if the step's inputs exist: `kickoff-agents` needs SPEC and PLAN,
  `kickoff-plan` needs SPEC. A PLAN with no SPEC therefore falls through to `kickoff-spec` (or
  `kickoff-brief` if there's no BRIEF either). Steps don't need files older than their inputs, so
  a repo that already has a SPEC but no BRIEF goes straight to `kickoff-plan`. An `AGENTS.md`
  without those two sections counts as missing.
- If kickoff is done, say so in one line, suggest `/devflow:check-contract` to verify the repo or
  `/devflow:next-task` to start building, and stop.

## 2. Say which step

One line naming what was found and what runs now, e.g.:
```
Found docs/SPEC.md, no PLAN → running kickoff-plan.
```

## 3. Run that step

- Read `${CLAUDE_PLUGIN_ROOT}/skills/kickoff-<step>/SKILL.md` and follow it from its step 1 to its
  last step, exactly as if the user had run `/devflow:kickoff-<step>`. (The step skills can't be
  invoked as tools; following their file is the way to run them.)
- Where it says `${CLAUDE_PLUGIN_ROOT}`, use this skill's plugin root. Where it says `$ARGUMENTS`,
  use the arguments given to `/devflow:kickoff` (`$ARGUMENTS`), or none.
- If the step stops early (missing input, the user declines an overwrite), stop there too.

## 4. Stop

- Give the step's own closing reply.
- If the step finished, add one line naming the next command:
  `Next: /devflow:kickoff again (runs kickoff-<next step>).` After `kickoff-agents`, the next
  command is `/devflow:next-task` instead.

Run one step per invocation. Don't start the following step, even if the user's input already covers it.
