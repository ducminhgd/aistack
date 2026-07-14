---
name: specs-define
description:
  Use when the user wants to define a spec for a feature before implementation — requirements, design, or tasks. Trigger
  on "write a spec for", "define requirements for", "spec out this feature", "/specs:define", or when a feature request
  lacks a requirements/design/tasks breakdown. Produces requirements.md, design.md, and tasks.md following spec-driven
  development.
metadata:
  version: 1.0
  effort: medium
  tags:
    - product
    - requirements
    - software-engineering
    - documentation
allowed-tools:
  - Read
  - Grep
  - Glob
  - AskUserQuestion
  - Edit
  - EnterPlanMode
  - ListMcpResourcesTool
  - ReadMcpResourceTool
  - Skill
  - TaskCreate
  - TaskGet
  - TaskList
  - TaskStop
  - TaskUpdate
  - WebSearch
  - WebFetch
  - Write
---

# Specs Define Skill

## Purpose

Turn a feature idea into three artifacts before any code is written: `requirements.md`, `design.md`, `tasks.md`.

## Rule

No implementation starts until requirements.md and design.md exist and are confirmed by the user.

## Output Location

```
specs/<feature-slug>/
├── requirements.md
├── design.md
└── tasks.md
```

`<feature-slug>` = kebab-case, prefixed by domain if relevant (e.g. `billing-invoice-export`, `cli-auth-flow`).

## requirements.md

Structure:

```markdown
# Feature: <Name>

## Overview

<1-3 sentences: what and why>

## User Stories

### US-1

As a <role>, I want <capability>, so that <benefit>.

**Acceptance Criteria (EARS)**

- WHEN <trigger>, THE SYSTEM SHALL <response>.
- IF <condition>, THEN THE SYSTEM SHALL <response>.
- WHILE <state>, THE SYSTEM SHALL <response>.

## Out of Scope

- <explicit exclusions>

## Dependencies

- <existing models, services, libs>
```

Rules:

- Every user story gets EARS-format acceptance criteria — no vague prose criteria.
- Out of Scope section is mandatory, even if short. Prevents scope creep.
- List dependencies on existing code, not just external libs.

## design.md

Structure:

```markdown
# Design: <Name>

## Architecture

<one-paragraph or diagram: how components connect>

## API Contract

<endpoints/functions, request/response shapes, error codes>

## Data Model

<new/changed schema, or "No schema changes. Reuses X, Y.">

## Sequence

<numbered steps of the main flow>

## Components

<new classes/modules to be created, with role>

## Error Handling

<expected error cases and how they surface>
```

Rules:

- Every API contract entry lists error responses, not just happy path.
- Reference existing patterns (e.g. `BaseService` generics) instead of reinventing.
- If no schema change, say so explicitly — don't omit the section.

## tasks.md

Structure:

```markdown
# Tasks: <Name>

- [ ] 1. <task> — design.md#<section>
- [ ] 2. <task> — requirements.md#<US-id> ...
```

Rules:

- Every task references the requirements.md or design.md section it implements.
- Tasks are atomic: one PR-sized unit each.
- Test tasks are explicit line items, not bundled into feature tasks.
- Order tasks by dependency, not by convenience.

## Process

1. Ask clarifying questions only if scope is genuinely ambiguous (max 1-2 questions).
2. Draft requirements.md first. Stop and present it.
3. On confirmation, draft design.md. Stop and present it.
4. On confirmation, draft tasks.md.
5. Do not write implementation code during this skill's execution.

## Anti-patterns to avoid

- Skipping Out of Scope ("obviously not needed" is not a reason to omit it)
- Acceptance criteria without EARS keywords (WHEN/IF/WHILE/THE SYSTEM SHALL)
- Tasks that don't map to any requirement or design section
- Merging design.md and requirements.md into one file
