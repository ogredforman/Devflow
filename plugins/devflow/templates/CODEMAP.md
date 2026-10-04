# Code map

A short orientation to the code, so a task can start without reading whole packages. Read this
first, then open only the files you'll change or call. Keep it current: when a task adds a
package, a public entry point, or a test fixture, update the matching line here in the same commit.
Signatures here are summaries; <the language's doc tool, e.g. `go doc ./internal/<pkg>`> gives the exact ones.

<!-- Keep this a map, not documentation: one line per thing. If a line needs a paragraph, the
     detail belongs in the code's own doc comments or an ADR. Create this file in Stage 0, once
     the first package exists, and grow it task by task. -->

## Reading the docs cheaply

- SPEC sections by heading: `awk '/^### 7.1/,/^### 7.2/' docs/SPEC.md` (or `/^## 7\./,/^## 8\./` for a whole section).
  <One line listing the section numbers worth knowing, e.g. "§5 principles, §6.1 entities, §7.1 main flow, §10.2 layout".>
- PLAN: `grep -n '\[ \]' docs/PLAN.md | head` for the next tasks; read only the current stage's section.
- ADRs: <one line per ADR: number and topic>.

## Wiring

<How the app starts: entry point → config → dependencies → server/loop. One short paragraph or arrow chain.>

## Packages / modules

- **<name>**: <what it owns>. Key entry points: `<Func>`, `<Type>`.

## Frontend (if any)

- <screens/, components/, api client, state stores: one line each.>

## Tests and fixtures

- <Reusable helpers and fixtures, with where they live and what they set up.>
- <How to run one package's tests quickly.>
