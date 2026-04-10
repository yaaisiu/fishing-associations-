# CLAUDE.md — Project-Wide Instructions

## Project Identity

This is a dual-agent software project for fishing association management.
Claude Code is the primary orchestrator. Codex is the Apple/iOS specialist.
Both agents coordinate through repository artifacts, not ad hoc chat.

## Agent Roles

| Agent | Scope | Strengths |
|---|---|---|
| **Claude Code** | Core logic, backend, documentation, coordination, repo hygiene | Full-stack reasoning, multi-file edits, long-context planning |
| **Codex** | iOS/Apple platform, Xcode projects, SwiftUI, native integrations | Xcode-aware code generation, Apple framework knowledge |

Claude Code is the documentation-aware coordinator. When in doubt about
project state, read the Obsidian vault before acting.

## Repository Layout

```
CLAUDE.md                    # You are here — project-wide instructions (Claude Code)
AGENTS.md                    # Project-wide instructions (Codex)
.claude/settings.json        # Claude Code hooks and tool config
.codex/config.toml           # Codex project configuration
docs/obsidian/               # Obsidian vault — project memory and coordination layer
  CLAUDE.md                  # Vault-specific instructions (Claude Code)
  AGENTS.md                  # Vault-specific instructions (Codex)
  00-overview/               # What this project is
  01-decisions/              # Why key choices were made (ADRs)
  02-operating-model/        # How work flows between agents and humans
  03-capabilities/           # Who does what — agent roles, skills, ownership
  04-execution/              # Tasks, handoffs, validations, work traces
  05-reference/              # Schemas, conventions, stable reference material
  _templates/                # Reusable note skeletons
src/                         # Source code (created when development begins)
scripts/                     # Shared tooling and automation
```

## Coordination Model

Agents coordinate through files, not memory:

1. **Decisions** are recorded as ADRs in `01-decisions/`
2. **Task handoffs** between agents go in `04-execution/`
3. **Capability boundaries** are documented in `03-capabilities/`
4. **Agent-specific instructions** live in `CLAUDE.md` (Claude Code) and `AGENTS.md` (Codex)

When starting a session:
- Read this file for project context
- Check `04-execution/index.md` for pending tasks or handoffs
- Check `01-decisions/index.md` for recent decisions that affect your work
- Check git log for recent changes by the other agent
- Prefer updating existing notes over creating new ones

## File Conventions

- All documentation lives in `docs/obsidian/` and must follow vault rules (see `docs/obsidian/CLAUDE.md`)
- Source code goes in `src/` with language-appropriate structure
- Scripts go in `scripts/` with executable permissions and usage comments
- No loose files in the repo root except `CLAUDE.md`, `AGENTS.md`, `.gitignore`, `LICENSE`, and config files

## Rules for All Agents

1. **Do not create duplicate notes.** Search the vault before creating a new document.
2. **Do not create temporary junk files.** If something is temporary, say so in frontmatter with `status: draft`.
3. **Do not flatten structure.** Respect the numbered folder hierarchy.
4. **Update canonical notes** rather than creating parallel versions.
5. **Keep commits atomic and descriptive.** One logical change per commit.
6. **Never commit secrets, credentials, or API keys.**
7. **When unsure where something belongs, check the vault index files first.**

## Instruction File Hierarchy

Instructions cascade. More specific files override more general ones:

1. `CLAUDE.md` (this file) — project-wide rules
2. `docs/obsidian/CLAUDE.md` — vault-specific rules
3. `.claude/settings.json` — Claude Code hooks (vault validation)
4. Future: `src/CLAUDE.md` — source code conventions

Codex reads a parallel chain: `AGENTS.md` → `docs/obsidian/AGENTS.md` → `.codex/config.toml`.
See `docs/obsidian/01-decisions/ADR-002-codex-instruction-files.md` for details.
