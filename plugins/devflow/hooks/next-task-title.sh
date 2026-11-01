#!/usr/bin/env bash
# UserPromptSubmit hook: on /devflow:next-task, title the session "<task id> <short task name>".
# Prints nothing (and changes nothing) for any other prompt or when no task is found.
input=$(cat)
printf '%s' "$input" | grep -q '"prompt"[[:space:]]*:[[:space:]]*"/devflow:next-task\([ "]\|\\n\)' || exit 0
id=$(printf '%s' "$input" | sed -n 's/.*"prompt"[[:space:]]*:[[:space:]]*"\/devflow:next-task[[:space:]]*\([^[:space:]"\\]*\).*/\1/p')

plan=docs/PLAN.md
[ -f "$plan" ] || plan=PLAN.md
[ -f "$plan" ] || exit 0

title=$(awk -v id="$id" '
  { sub(/\r$/, "") }
  /^\*\*Current stage: Stage / { stage = $4 }
  /^- \[.\] \*\*[^*]+\*\* / {
    match($0, /\*\*[^*]+\*\*/); tid = substr($0, RSTART + 2, RLENGTH - 4)
    # Given id: match it. No id: first unchecked task in the current stage.
    if (id != "" ? tid != id : ($0 !~ /^- \[ \]/ || index(tid, stage ".") != 1)) next
    text = substr($0, RSTART + RLENGTH + 1); gsub(/[`*]/, "", text)
    if (match(text, /(: |\. | \(| — )/)) text = substr(text, 1, RSTART - 1)
    sub(/\.$/, "", text)
    if (length(text) > 50) text = substr(text, 1, 47) "..."
    print tid " " text; exit
  }' "$plan")
[ -n "$title" ] || exit 0
title=$(printf '%s' "$title" | sed 's/\\/\\\\/g; s/"/\\"/g')
printf '{"hookSpecificOutput":{"hookEventName":"UserPromptSubmit","sessionTitle":"%s"}}\n' "$title"
