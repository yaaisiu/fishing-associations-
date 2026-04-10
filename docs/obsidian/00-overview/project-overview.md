---
title: Project Overview
created: 2026-04-10
updated: 2026-04-10
status: active
tags:
  - overview
  - project-identity
---

# Project Overview

## What This Is

A fishing association management system built using a dual-agent development
workflow. The project manages operations, membership, and activities for
fishing associations.

## Development Model

This project uses two AI agents with distinct roles:

- **Claude Code** — primary orchestrator, core-code worker, and documentation coordinator
- **Codex** — Apple/iOS and Xcode specialist for native platform work

Agents coordinate through repository artifacts (documentation, task files,
handoff records) rather than shared chat context. The Obsidian vault at
`docs/obsidian/` serves as the project memory and coordination layer.

## Platform Targets

- iOS/Apple (native, via Xcode on external SSD)
- Backend/API (technology TBD)
- Potential web interface (TBD)

## Key Principles

1. **Documentation-first coordination** — agents read and write structured notes rather than relying on ephemeral context
2. **Clean separation of concerns** — each agent owns its domain; boundaries are explicit
3. **Iterative safety** — the project is structured for long-term work, not quick prototyping
4. **Vault hygiene** — documentation stays organized, linked, and canonical

## Related

- [[01-decisions/ADR-001-dual-agent-architecture]] — Why the dual-agent model
- [[02-operating-model/agent-coordination]] — How agents coordinate
- [[03-capabilities/claude-code]] — Claude Code's role
- [[03-capabilities/codex]] — Codex's role
