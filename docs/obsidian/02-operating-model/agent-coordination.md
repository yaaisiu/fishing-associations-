---
title: Agent Coordination Model
created: 2026-04-10
updated: 2026-04-10
status: active
tags:
  - operating-model
  - coordination
  - agents
---

# Agent Coordination Model

## Principle

Agents coordinate through repository artifacts, not shared memory or ad hoc
chat. Every piece of project state that matters must be findable in the repo.

## Coordination Artifacts

| Artifact | Location | Purpose |
|---|---|---|
| Project instructions | Root `CLAUDE.md` | Project-wide agent behavior |
| Vault instructions | `docs/obsidian/CLAUDE.md` | Documentation rules |
| Decision records | `01-decisions/ADR-*.md` | Why choices were made |
| Task files | `04-execution/TASK-*.md` | Work to be done |
| Handoff files | `04-execution/HANDOFF-*.md` | Cross-agent work transfers |
| Capability docs | `03-capabilities/*.md` | What each agent owns |

## Handoff Protocol

When one agent needs the other to do work:

1. The requesting agent creates a `HANDOFF-NNN-short-title.md` in `04-execution/`
2. The handoff file includes:
   - What needs to be done
   - Why it's needed
   - What files are relevant
   - What the receiving agent should produce
   - Acceptance criteria
3. The requesting agent updates `04-execution/index.md` with the new handoff
4. The receiving agent reads the handoff, does the work, and updates the handoff
   file with results
5. The requesting agent reviews and marks the handoff as completed

## Session Start Checklist

When an agent starts a new session:

1. Read root `CLAUDE.md` for project context
2. Read `04-execution/index.md` for pending tasks and handoffs
3. Read `01-decisions/index.md` for recent decisions
4. Check git log for recent changes by the other agent
5. Proceed with the highest-priority pending work

## Branch and PR Workflow

Agents never push directly to `main`. Each agent works on its own feature
branch and merges to `main` via pull request with human approval.

```
codex/feature-branch ──PR──┐
                            ├──► main (human approves)
claude/feature-branch ──PR──┘
```

### Branch conventions

- Claude Code branches: `claude/<description>`
- Codex branches: `codex/<description>`
- Never force-push to `main`

### Sync mechanism

- **Session start:** Claude Code's `session-sync.sh` hook fetches from origin
  and reports whether the branch is behind, ahead, or diverged. It also shows
  recent commits across all remote branches so each agent sees the other's work.
- **CI:** A GitHub Actions workflow (`.github/workflows/validate-vault.yml`)
  runs vault validation in strict mode on every PR to `main` and on pushes
  that touch `docs/obsidian/`.
- **Local:** Agents should `git pull` if the sync hook reports they are behind.

### PR etiquette

- Keep PRs focused — one logical change or feature per PR
- Both agents may have PRs open simultaneously; if they touch overlapping files,
  coordinate via handoff before merging
- The human reviews and merges; agents do not merge their own PRs

## Conflict Resolution

- If both agents modified the same file, the human resolves the conflict
- If a decision affects both agents' domains, create an ADR before proceeding
- If a handoff is ambiguous, the receiving agent asks for clarification via a
  comment in the handoff file rather than guessing

## Related

- [[01-decisions/ADR-001-dual-agent-architecture]] — Why this model exists
- [[03-capabilities/claude-code]] — Claude Code's responsibilities
- [[03-capabilities/codex]] — Codex's responsibilities
