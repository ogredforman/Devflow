---
name: kickoff-brief
description: Distill an idea discussion (this conversation, pasted notes, or a file) into docs/BRIEF.md from the devflow template. Asks at most 5 questions, writes one file, then stops.
argument-hint: "[notes file path or pasted notes]"
disable-model-invocation: true
---

# Kickoff: brief

Turn a free-form idea discussion into `docs/BRIEF.md`: conclusions and decisions with their reasons,
not a transcript. This is the first kickoff step. Write one file, then stop for review.

## 1. Gather the input

- If `$ARGUMENTS` is a path to an existing file, read it. If it looks like a path but the file
  doesn't exist, say so and stop.
- Otherwise, if `$ARGUMENTS` has text, treat it as pasted notes. Also use the current conversation
  if it discusses the same idea.
- If `$ARGUMENTS` is empty, use the current conversation.
- If there is no idea discussion to work from, ask for one in one short line ("Paste your notes, give a
  file path, or describe the idea") and stop.

## 2. Check the target

- Read `${CLAUDE_PLUGIN_ROOT}/templates/BRIEF.md`. It is the shape of the output.
- Check whether `docs/BRIEF.md` exists (`ls`). If it does, say so in one line and ask whether to
  continue (step 4 will show the changes before replacing it). If the user declines, stop.

## 3. Ask about the gaps

- Map the input onto the template's sections. List what is missing or unclear **and matters**: the
  stack, a key decision with no reason, the MVP test (scope guardrail), external dependencies.
- Ask at most 5 questions, all in one message, most important first. Each one gets a default taken
  from the input where possible:
  ```
  1. Stack? Default: Go CLI, single binary (you wanted no runtime dependencies).
  2. Minimum useful version? Default: imports one CSV and prints the monthly total.
  ```
  End with: "Reply with answers, or 'defaults' to accept them all."
- Wait for the answers. Anything still unresolved goes under "Open questions" with what it blocks.
  Don't invent decisions, reasons, or requirements the input doesn't support.
- If nothing important is missing, skip the questions and say so in one line.

## 4. Write docs/BRIEF.md

- Fill the template:
  - Use today's date.
  - Take the project name from the input; if there isn't one, use a short descriptive placeholder and add it to Open questions.
  - Every key decision gets its reason. Include rejected alternatives when the input gives them.
  - Remove the template's `<!-- -->` comments.
- Keep every section and heading in template order. If a section has no content, write "None yet."
  rather than dropping it.
- Record conclusions, not the conversation. Keep it to 1–2 pages.
- If `docs/BRIEF.md` already exists: read it, show a short per-section summary of what would change,
  and ask before replacing it. If the user declines, stop without writing.
- Create `docs/` if needed, then write the file.

## 5. Stop

Reply briefly:
- The file written, and what to review: the key decisions and their reasons, the scope guardrail,
  and the open questions (answer or accept them by editing the file).
- Next step: `/devflow:kickoff-spec` once the brief looks right.

Don't start the SPEC or any other kickoff step.
