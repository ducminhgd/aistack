# AI Stack

A curated collection of skills, rules, agents, and commands for AI coding assistants (Claude Code, Cursor, Codex, etc.).

## Structure

| Directory | Purpose |
|---|---|
| `agents/` | Sub-agent personas |
| `commands/` | Custom slash commands |
| `rules/` | Modular instruction files loaded into AI context |
| `skills/` | Auto-invoke workflows triggered by keywords or commands |

---

## Installation

Use the `make install` command to copy files into your AI client's config directory.

### Syntax

```sh
make install -- <agent> [-g|--global] [-d|--dir <dirs>] [-f|--force]
```

### Arguments

| Argument | Description |
|---|---|
| `agent` | AI client to install for: `claude`, `codex`, `gemini`, `cursor`, `augment` |
| `-g`, `--global` | Install to your home directory (e.g. `~/.claude`) |
| `-d`, `--dir <dirs>` | Install into `.claude/` inside the given directory. Accepts comma-separated paths or repeated flags. |
| `-f`, `--force` | Overwrite existing files without error |

> **Note:** Use `--` between `make install` and the arguments so Make does not interpret flags like `-g` or `-d` as its own.

### Examples

Install globally (affects all projects):

```sh
make install -- claude --global
```

Install into a specific project:

```sh
make install -- claude --dir /path/to/project
```

Install globally and into multiple projects at once:

```sh
make install -- claude --global --dir /path/to/project1,/path/to/project2
```

Force-overwrite an existing installation:

```sh
make install -- claude --global --force
```

---

## Contents

### Rules

Modular instruction files that can be loaded into your AI client's context to enforce coding standards.

| File | Description |
|---|---|
| `rules/project-layout.md` | Clean Architecture layout for Python, Go, and ReactJS |
| `rules/python-best-practices.md` | Python coding standards, typing, async, testing, and security |
| `rules/go-best-practices.md` | Go coding standards, error handling, concurrency, and testing |
| `rules/restful-api-best-practices.md` | RESTful API design: naming, HTTP methods, status codes, versioning, security |
| `rules/database-design-best-practices.md` | Relational DB design: schema, indexing, migrations, PostgreSQL & MySQL specifics |

### Skills

Auto-invoke workflows that activate based on context or explicit commands.

| Skill | Command | Purpose |
|---|---|---|
| `product-ideation` | `product-ideation` | Brainstorm product ideas, critique concepts, rewrite PRDs and user stories into clearer requirements |
| `project-planning` | `project-planning` | Plan delivery, break work into Features → Epics → Tasks → Sub-tasks, estimate effort, map dependencies |
| `arch-design` | `arch-design` | Design system architecture, evaluate trade-offs, produce architecture decision records |

---

## Supported AI Clients

| Client | Status |
|---|---|
| Claude Code | Supported |
| Cursor | Planned |
| Codex | Planned |
| Gemini | Planned |
| Augment | Planned |
