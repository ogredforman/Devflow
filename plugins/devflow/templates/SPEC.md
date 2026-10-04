# <Project> — System Specification

> **Audience:** the project owner and AI coding agents. Source of truth for *what* the system is
> and *why*. For *how and in what order* to build it, see [`PLAN.md`](./PLAN.md).
>
> **Status:** <Pre-prototype | Prototype | MVP | ...>

<!-- Follow the devflow doc contract (CONTRACT.md): the "Product principles" heading is required.
     Tag requirements [P] prototype, [M] MVP, [L] later so agents know what's in scope. -->

## 1. Summary

<!-- 1–2 paragraphs: what it is, who it's for, the core idea. -->

## 2. Problem statement

-

## 3. Goals

1.

## 4. Non-goals (for now)

-

<!-- Note anything the design must not *preclude* even though it's out of scope (e.g. auth later). -->

## 5. Product principles

<!-- Requirements, not suggestions. Agents and the reviewer treat violations as bugs.
     Each: a bold short name, then one or two sentences. -->

- **<Principle>.** <What it means in practice.>

## 6. Domain model

### 6.1 Entities

| Entity | Purpose | Key fields |
|---|---|---|
| | | |

### 6.2 Relationships

```
A 1─* B
```

## 7. Core flows

<!-- Numbered steps for each important flow. Include failure handling. -->

### 7.1 <Flow name>

1.

## 8. Functional requirements

<!-- Grouped by area, each tagged [P]/[M]/[L]. -->

**<Area>**
- [P]

## 9. Non-functional requirements

<!-- Portability, performance, privacy, resilience, data portability. Make them checkable. -->

-

## 10. Architecture

<!-- Diagram, technology choices table, repository layout, key interfaces.
     Every external dependency sits behind an interface with a fake implementation for the prototype. -->

### 10.1 Technology choices

| Concern | Choice | Notes |
|---|---|---|
| | | |

### 10.2 Repository layout

```
```

### 10.3 Key interfaces

```
```

### 10.4 Fakes

<!-- For each external dependency: how the fake behaves, and how it's made deterministic for tests. -->

## 11. UI surfaces

<!-- If there's a UI: each screen, its purpose, and UX rules. -->

## 12. Quality and testing

-

## 13. Open questions

-

## 14. Guidance for AI agents

Agent instructions live in [`AGENTS.md`](../AGENTS.md) (imported by `CLAUDE.md`), with area-specific
rules in `.claude/rules/`. If a rule there contradicts this spec, the spec wins and the rule should be fixed.

## 15. Glossary

-
