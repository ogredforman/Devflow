---
name: park
description: Capture an idea, feature, or tangent in the Parked section of the project's PLAN.md without acting on it. Use when the user runs /devflow:park, or when an out-of-scope idea comes up mid-task.
argument-hint: "<idea>"
---

# Park an idea

The point is to get the idea out of the way so current work can continue. Keep it fast.

1. Take the idea from `$ARGUMENTS`. If it's empty, use the out-of-scope idea just discussed; if there
   is none, ask for it in one short line.
2. Append one line to the `## Parked` section at the bottom of `docs/PLAN.md` (or `PLAN.md`).
   Create the section if it doesn't exist.
   `- [ ] <idea, one sentence> (parked <YYYY-MM-DD>; suggested stage: <stage, e.g. 2 or 1.5, or "later">)`
   Pick the suggested stage from the SPEC's stage tags or PLAN's stage descriptions. If unsure, use "later".
3. If it duplicates an existing Parked item or a planned task, don't add it; say which item already covers it.
4. Reply with one line confirming it's parked. Do not discuss, design, or start the idea, and don't
   change the current task.
