---
name: kickoff-agents
description: Turn docs/SPEC.md and docs/PLAN.md into AGENTS.md, CLAUDE.md, path rules, docs/adr/, and an optional stack preset. Checks the contract, offers git init, then stops.
argument-hint: "[preset name | none]"
disable-model-invocation: true
---

# Kickoff: agents

Turn the reviewed spec and plan into the files every agent session loads: `AGENTS.md`, `CLAUDE.md`,
`.claude/rules/`, `docs/adr/`, and the chosen stack preset. This is the fourth and last kickoff
step. Write the set, check it, offer the first commit, then stop.

## 1. Read the inputs

- Use `docs/SPEC.md`, else `SPEC.md`. If neither exists, say "No spec found. Run
  `/devflow:kickoff-spec` first." and stop.
- Use `docs/PLAN.md`, else `PLAN.md`. If neither exists, say "No plan found. Run
  `/devflow:kickoff-plan` first." and stop.
- Read the SPEC by section, not whole. Start with `grep -nE '^#{2,3} ' <SPEC>`, then read:
  - 1. Summary (the AGENTS.md intro paragraph)
  - 5. Product principles (hard rules)
  - 9. Non-functional (portability, security, privacy rules)
  - 10. Architecture, especially 10.1 technology, 10.2 layout, 10.3 interfaces, 10.4 fakes
  - 12. Quality and testing, 14. Guidance for AI agents
- From the PLAN read only task `0.1` (`grep -n -A4 '\*\*0\.1\*\*' <PLAN>`). It names the build,
  test, and lint commands. If it names no test or lint command, say so; it becomes the first
  question in step 4.

## 2. Check the target

- Read `${CLAUDE_PLUGIN_ROOT}/templates/AGENTS.md` and `${CLAUDE_PLUGIN_ROOT}/templates/CLAUDE.md`.
  They are the shape of the output.
- Read the `## AGENTS.md` section of `${CLAUDE_PLUGIN_ROOT}/CONTRACT.md` (only that section).
- `ls` for the outputs: `AGENTS.md`, `CLAUDE.md`, `.claude/`, `docs/adr/`, `.gitignore`,
  `.gitattributes`, `tools/hooks/`. Note which exist; step 5 shows the change before replacing any
  of them.

## 3. Choose a preset

- If `$ARGUMENTS` names a preset (or `none`), use it.
- Otherwise list the folders in `${CLAUDE_PLUGIN_ROOT}/presets/` plus `none`, recommend the one
  matching SPEC §10.1 (or `none` if no preset fits the stack), and ask in step 4.
- If the named preset doesn't exist, say so, list the available ones, and stop.
- For the chosen preset, read its `README.md`. Its table says which file is copied where and which
  hook flags to adjust. The README itself is not copied.

## 4. Draft, then ask about the gaps

- **Hard rules.** Derive each from a SPEC section and keep the source next to it while drafting.
  Each rule is concrete and checkable in a diff:
  ```
  - All bank access goes through `internal/bank.Feed`; tests use the fake (SPEC §10.3, §10.4).
  - Never log transaction amounts or payee names (SPEC §5.2).
  ```
  Typical sources: one rule per interface in 10.3 ("goes through X"), the fakes rule from 10.4,
  boundaries in 10.2, portability and security limits in §9, and any principle in §5 that a diff
  can break. Skip principles a reviewer can't check from code.
- **Commands.** Exactly the commands task `0.1` names, as `` `command`: what it does ``.
- **Path rules.** One `.claude/rules/<area>.md` for each major area in SPEC §10.2 that has rules of
  its own (e.g. `db`, `web`, `integrations`). Skip areas with nothing area-specific to say; the
  preset's language rules cover the language itself.
- **Hook flags** (if the preset has them): set them from the SPEC, e.g. `--protect` for append-only
  folders such as applied migrations, `--no-cgo` if the SPEC requires a pure-Go build, `--web-dir`
  for the frontend folder. Remove a flag the SPEC gives no reason for.
- Ask at most 5 questions, all in one message, most important first. Each gets a default derived
  from the spec:
  ```
  1. Preset? Default: go (SPEC §10.1 is Go + SQLite). Others: none.
  2. Protect applied migrations from edits? Default: yes, `internal/db/migrations/` (SPEC §10.2).
  ```
  End with: "Reply with answers, or 'defaults' to accept them all."
- Wait for the answers. If nothing is missing, skip the questions and say so in one line.

## 5. Write the files

- If any output already exists: read it, show a short summary of what would change per file, and
  ask before replacing it. If the user declines a file, skip that file and keep going.
- **AGENTS.md** (repo root), from the template:
  - Replace `<Project>` and the intro comment with one paragraph from SPEC §1 and §10.1.
  - `## Commands`: keep the line saying they're created in task 0.1, then the commands from step 4.
    Drop template bullets that 0.1 doesn't create (e.g. no dev command for a library).
  - `## Hard rules`: the rules from step 4, each citing its SPEC section, then keep the template's
    last two rules.
  - `## Style`: a few repo-wide bullets from SPEC §12 and §14; area-specific ones go to path rules.
  - Keep `## Before any task` and `## Finishing a task` as in the template. Remove every `<!-- -->`
    comment. Stay under ~150 lines.
- **CLAUDE.md**, from the template: name the riskiest areas for plan mode (data model, the
  interfaces in 10.3). Keep the hooks bullet only if a preset with hooks is copied, and describe
  the hooks in one line from the preset README. Otherwise remove it.
- **`.claude/rules/<area>.md`**, one per area from step 4:
  ```
  ---
  paths:
    - "internal/db/**"
  ---

  # Database rules

  - Migrations are append-only: add a new file, never edit an applied one.
  ```
- **`docs/adr/`**: copy `${CLAUDE_PLUGIN_ROOT}/templates/adr/README.md` and `0000-template.md`.
- **Preset** (unless `none`): copy each file to the destination in its README table (e.g.
  `cp -r ${CLAUDE_PLUGIN_ROOT}/presets/<name>/hooks tools/hooks`). Then adjust the copies:
  - Hook flags in `.claude/settings.json` as decided in step 4.
  - Sections of `.gitignore` the project doesn't need (e.g. the frontend section with no frontend).
  - If `.claude/settings.json` already exists, merge the preset's `hooks` into it rather than
    replacing other settings, and show the result before writing.

## 6. Check the output

- Follow steps 2–4 of `${CLAUDE_PLUGIN_ROOT}/skills/check-contract/SKILL.md` against PLAN.md,
  AGENTS.md, CLAUDE.md, and SPEC.md.
- Check no template placeholders or comments remain:
  `grep -nE '<([A-Za-z.]|e\.g\.)[^>]*>|<!--' AGENTS.md CLAUDE.md | grep -v 'PLAN <stage>'` finds
  nothing. (The commit format line in `## Finishing a task` is meant to keep its `<...>`.) A hit
  that is real content, not a leftover placeholder (e.g. a generic type in a rule), can stay.
- Check the `## Commands` list matches the commands task `0.1` names, and every hard rule other
  than the two kept from the template cites a SPEC section.
- If a preset with hooks was copied, check `.claude/settings.json` parses as JSON and its flags
  match step 4.

Fix any failure before replying.

## 7. Offer git

- If there's no `.git`, offer `git init`. Run it only if the user says yes.
- Offer a first commit of everything kickoff wrote (`docs/`, `AGENTS.md`, `CLAUDE.md`, `.claude/`,
  and the preset files), with a message like `docs: kickoff (brief, spec, plan, agent files)`.
  Show `git status --short` first. Commit only if the user says yes; never push.

## 8. Stop

Reply briefly:
- The files written, and what to review: the hard rules, the commands, the path rules, and the hook
  flags.
- Any assumption you made, in one line each.
- Next step: `/devflow:next-task` to start task 0.1.

Kickoff is done. Don't start task 0.1.
