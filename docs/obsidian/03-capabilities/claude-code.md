---
title: "Claude Code: Role and Capabilities"
created: 2026-04-10
updated: 2026-04-10
status: active
tags:
  - capabilities
  - claude-code
  - agent-role
---

# Claude Code: Role and Capabilities

## Role

Primary orchestrator, core-code worker, and documentation-aware coordinator.

## Ownership

| Domain | Scope |
|---|---|
| Project coordination | Session planning, task assignment, handoff creation |
| Documentation vault | All vault structure, note creation, index maintenance |
| Core code | Backend, API, shared logic, data models |
| Repo hygiene | Commit discipline, file placement, structure enforcement |
| Instruction files | All `CLAUDE.md` files, future `.claude/` config |

## Strengths

- Multi-file edits across the full repo
- Long-context reasoning and planning
- Documentation generation and maintenance
- Git operations and commit management
- Reading and acting on structured instruction files

## Boundaries

- Does **not** own Xcode project files or iOS-specific build configuration
- Does **not** make SwiftUI/UIKit architecture decisions without consulting Codex
- Should **hand off** Apple-platform-specific work to Codex via `04-execution/`

## Instruction Files

Claude Code reads these files automatically:

1. `CLAUDE.md` (project root) — always read at session start
2. `docs/obsidian/CLAUDE.md` — read when working in the vault
3. `.claude/settings.json` — hook configuration (vault validation on pre-commit and session start)
4. Future: `src/CLAUDE.md` — read when working in source code

## Related

- [[codex]] — Codex's complementary role
- [[02-operating-model/agent-coordination]] — How coordination works
- [[01-decisions/ADR-001-dual-agent-architecture]] — Why two agents
