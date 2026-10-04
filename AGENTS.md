# devflow

A personal Claude Code plugin packaging a doc-driven workflow: idea → BRIEF → SPEC → PLAN → build
task by task with plan → build → verify → review. Almost everything is Markdown (skills, agents,
templates); the only code is stack-preset hook programs.

- What and why: `docs/SPEC.md`
- What to do now: `docs/PLAN.md`
- The doc shapes every devflow project follows: `plugins/devflow/CONTRACT.md`

## Before any task

- Read the task in `docs/PLAN.md` and the SPEC sections it references.
- Don't implement anything from a later stage. Park it with `/devflow:park`.
- For new skills, read the existing ones in `plugins/devflow/skills/` first and match their structure and tone.
- For anything touching more than 2 files, propose a plan and wait for approval.

## Commands

- `claude plugin validate ./plugins/devflow`: validate the plugin manifest and all skill/agent frontmatter
- `claude plugin validate .`: validate the marketplace file
- `go -C plugins/devflow/presets/go/hooks test ./...`: tests for the Go preset hook program (the only code); this is the test command
- `go -C plugins/devflow/presets/go/hooks vet ./...`: lint for the Go preset
- `/reload-plugins` (inside a session): load edited plugin files without restarting

## Hard rules

- Plugin files (`plugins/devflow/**`) never mention a specific project. Examples use placeholders.
- Skills and agents refer to bundled files via `${CLAUDE_PLUGIN_ROOT}/...`, never absolute paths.
- Skills never drop or rename sections that `CONTRACT.md` requires. Changing the contract means
  updating CONTRACT.md, the templates, and every skill that parses it in the same commit.
- Kickoff skills write one artifact, then stop. They never overwrite an existing file without showing
  the change and asking.
- Kickoff skills set `disable-model-invocation: true`. Only `park` may be model-invoked.
- Skill `description` fields stay under ~200 characters; they load into every session.
- Both `claude plugin validate` commands pass before a task is finished.
- Bump `version` in `plugins/devflow/.claude-plugin/plugin.json` when a change alters behavior.

## Style

- Skills are numbered steps with clear stop points, written as direct instructions.
- Prefer one short example over a paragraph of explanation.
- Say what to do when input is missing or malformed.

## Finishing a task

1. Validation passes; Go tests pass if the preset changed.
2. Try the changed skill for real in a scratch project (`/reload-plugins` first).
3. Run the `devflow:reviewer` agent on the diff and fix any Blocking findings.
4. Tick the task `[x]` in `docs/PLAN.md`; update `docs/SPEC.md` if a design decision changed.
5. One task per commit. Message format: `<area>: <what changed> (PLAN <stage>.<task>)`.
