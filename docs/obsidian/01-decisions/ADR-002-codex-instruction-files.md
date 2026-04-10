---
title: "ADR-002: Codex Instruction File Strategy"
created: 2026-04-10
updated: 2026-04-10
status: accepted
tags:
  - adr
  - codex
  - agents-md
  - coordination
---

# ADR-002: Codex Instruction File Strategy

## Status

Accepted

## Context

Claude Code reads `CLAUDE.md` files natively. Codex (OpenAI's CLI agent) reads
`AGENTS.md` files natively. Neither agent reads the other's instruction file by
default.

For the dual-agent model to work, both agents must understand their role,
the project structure, and the coordination protocol. We need to decide how
to deliver instructions to Codex.

Options considered:

1. **Symlink `AGENTS.md` → `CLAUDE.md`** — fragile, single-file can't differentiate roles
2. **Configure Codex fallback to `CLAUDE.md`** — works but CLAUDE.md is written for Claude Code's role, not Codex's
3. **Maintain separate `AGENTS.md` files** — more files, but each agent gets role-appropriate instructions
4. **Single shared file with both names** — copy duplication, drift risk

## Decision

Maintain **separate `AGENTS.md` files** for Codex alongside `CLAUDE.md` files
for Claude Code. Both encode the same project rules but are tailored for each
agent's role:

- `CLAUDE.md` (root) — full project instructions, Claude Code as orchestrator
- `AGENTS.md` (root) — project instructions scoped to Codex's iOS role
- `docs/obsidian/CLAUDE.md` — vault rules for Claude Code
- `docs/obsidian/AGENTS.md` — vault rules for Codex (subset, focused on what Codex may edit)
- `.codex/config.toml` — Codex project config, with `CLAUDE.md` as fallback for subdirectories that lack `AGENTS.md`

The fallback config ensures that if only a `CLAUDE.md` exists in a subdirectory
(e.g., a future `src/CLAUDE.md`), Codex still picks up those instructions
rather than having no guidance.

## Consequences

### Positive

- Each agent reads its native format — no hacks or symlinks
- Instructions are role-appropriate — Codex sees its scope, not Claude Code's
- Fallback config provides coverage in new subdirectories without creating extra files
- AGENTS.md is an open standard (Linux Foundation) — future-proof

### Negative

- Two instruction files to maintain at each level (risk of drift)
- Changes to project rules must be reflected in both CLAUDE.md and AGENTS.md
- Slightly more repo scaffolding

### Neutral

- The vault AGENTS.md is intentionally smaller than vault CLAUDE.md (Codex does less in the vault)
- Codex's 32 KiB doc limit is raised to 64 KiB in project config

## Related

- [[ADR-001-dual-agent-architecture]] — Why two agents
- [[03-capabilities/codex]] — Codex role definition
- [[02-operating-model/agent-coordination]] — Coordination protocol
