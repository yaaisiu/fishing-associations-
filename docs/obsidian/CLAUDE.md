# CLAUDE.md — Obsidian Vault Instructions

This file governs how agents interact with the documentation vault at `docs/obsidian/`.
It supplements the root `CLAUDE.md` with vault-specific rules.

## Vault Structure

```
00-overview/       What this project is — scope, identity, goals
01-decisions/      Architecture Decision Records (ADRs) — why choices were made
02-operating-model/ How work flows — processes, coordination, handoffs
03-capabilities/   Who does what — agent roles, skills, instruction-file ownership
04-execution/      What's happening — tasks, handoffs, validations, work logs
05-reference/      Stable lookups — schemas, conventions, glossary
_templates/        Note skeletons for consistent creation
```

Every folder has an `index.md` that explains the folder's purpose and links to
its contents. Always update the index when adding or removing notes.

## Note Naming

- Use lowercase kebab-case: `agent-coordination.md`, not `AgentCoordination.md`
- ADRs use the pattern: `ADR-NNN-short-title.md` (e.g., `ADR-001-dual-agent-architecture.md`)
- Task files use the pattern: `TASK-NNN-short-title.md`
- Handoff files use the pattern: `HANDOFF-NNN-short-title.md`
- Index files are always named `index.md`

## Frontmatter Requirements

Every note (except index files) must include YAML frontmatter:

```yaml
---
title: Human-Readable Title
created: YYYY-MM-DD
updated: YYYY-MM-DD
status: active | draft | superseded | archived
tags:
  - relevant-tag
---
```

**General notes** use these status values:
- `status: active` — current and authoritative
- `status: draft` — work in progress, may be incomplete
- `status: superseded` — replaced by another note (link to replacement)
- `status: archived` — no longer relevant but preserved for history

**ADRs** use a domain-specific status set (see `_templates/decision-record.md`):
- `status: proposed` — under discussion, not yet decided
- `status: accepted` — agreed upon and in effect
- `status: superseded` — replaced by a newer ADR (link to replacement)
- `status: deprecated` — no longer recommended, kept for historical context

## Linking Rules

- Use Obsidian wiki-links: `[[note-name]]` or `[[folder/note-name|Display Text]]`
- Link to notes by filename without extension: `[[project-overview]]`
- Cross-folder links include the relative path: `[[01-decisions/ADR-001-dual-agent-architecture]]`
- Every note should be reachable from its folder's `index.md`
- Orphan notes (unreachable from any index) are a vault hygiene failure

## Content Rules

1. **One concept per note.** If a note covers two distinct topics, split it.
2. **No duplicate notes.** Search before creating. If a note already exists for a concept, update it.
3. **No temporary junk.** Every file must have a clear purpose and proper frontmatter.
4. **Update, don't append forever.** Notes are living documents. Rewrite sections rather than appending "UPDATE:" blocks.
5. **Templates are for structure, not content.** Use `_templates/` skeletons when creating new notes of a known type.
6. **Keep index files current.** When you add a note to a folder, add it to that folder's `index.md`.

## Template Usage

When creating a new note:

1. Check if a template exists in `_templates/` for that note type
2. Copy the template structure into the new file
3. Fill in the frontmatter
4. Place the file in the correct folder
5. Update that folder's `index.md`

Available templates:
- `_templates/note.md` — general-purpose note
- `_templates/decision-record.md` — Architecture Decision Record
- `_templates/task.md` — task definition for `04-execution/`
- `_templates/handoff.md` — cross-agent handoff for `04-execution/`

## What Belongs Here vs. Elsewhere

| Content | Location |
|---|---|
| Project documentation, plans, decisions | This vault (`docs/obsidian/`) |
| Agent instructions (project-wide) | Root `CLAUDE.md` |
| Agent instructions (vault-specific) | This file (`docs/obsidian/CLAUDE.md`) |
| Source code | `src/` |
| Build scripts, automation | `scripts/` |
| Claude Code tool config | `.claude/settings.json` |
| Hook configuration | `.claude/settings.json` |
| Hook scripts | `scripts/` |

## Agent Behavior in the Vault

- Read the relevant `index.md` before working in any folder
- Prefer updating an existing note over creating a new one
- When creating a note, always use the correct template
- After modifying the vault, verify that all new notes are linked from an index
- Do not rearrange the folder numbering without an ADR
