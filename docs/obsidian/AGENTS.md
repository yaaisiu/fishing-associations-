# AGENTS.md — Vault Instructions (Codex)

> Vault-level instructions for Codex when working inside `docs/obsidian/`.
> Claude Code reads `docs/obsidian/CLAUDE.md` instead.

## Vault Structure

```
00-overview/       What this project is
01-decisions/      Architecture Decision Records (ADRs)
02-operating-model/ How work flows
03-capabilities/   Agent roles and ownership
04-execution/      Tasks, handoffs, work logs
05-reference/      Schemas, conventions, glossary
_templates/        Note skeletons
```

## When You Create or Edit Notes

You may need to create or update vault notes (e.g., updating a handoff status,
adding a capabilities note for an iOS component). Follow these rules:

### Naming

- Lowercase kebab-case: `push-notification-setup.md`
- ADRs: `ADR-NNN-short-title.md`
- Tasks: `TASK-NNN-short-title.md`
- Handoffs: `HANDOFF-NNN-short-title.md`

### Frontmatter

Every note (except `index.md`) needs YAML frontmatter:

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

### Links

Use Obsidian wiki-links: `[[note-name]]` or `[[folder/note-name|Display Text]]`

### After Creating a Note

Update that folder's `index.md` to include a link to the new note.

## What You Should and Should Not Do in the Vault

| Action | OK? |
|---|---|
| Update your own handoff files in `04-execution/` | Yes |
| Add iOS capability notes to `03-capabilities/` | Yes |
| Update `codex.md` with new ownership info | Yes |
| Modify vault folder structure or numbering | No — create a handoff requesting it |
| Edit `CLAUDE.md` files | No — those belong to Claude Code |
| Create notes without frontmatter | No |
| Create notes without updating the index | No |
