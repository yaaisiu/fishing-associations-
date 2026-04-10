---
title: "ADR-001: Dual-Agent Architecture"
created: 2026-04-10
updated: 2026-04-10
status: accepted
tags:
  - adr
  - architecture
  - agents
---

# ADR-001: Dual-Agent Architecture

## Status

Accepted

## Context

This project requires both general software engineering (backend, coordination,
documentation) and specialized Apple/iOS development (Xcode, SwiftUI, native
frameworks). No single AI agent excels at all of these simultaneously.

Claude Code has strong multi-file reasoning, documentation awareness, and
orchestration capabilities. Codex has strong Xcode-aware code generation and
Apple framework knowledge. Using both, with clear boundaries, gives better
results than forcing one agent to cover everything.

The risk is coordination overhead: two agents can create conflicting artifacts,
duplicate work, or lose context across sessions. This must be mitigated by
structure, not by hoping agents will "figure it out."

## Decision

Use a dual-agent model:

1. **Claude Code** is the primary orchestrator, core-code worker, and
   documentation-aware coordinator
2. **Codex** is the Apple/iOS and Xcode specialist
3. Agents coordinate through **repository artifacts** (structured documentation,
   task files, handoff records) stored in an Obsidian-compatible vault
4. The Obsidian vault follows a numbered hierarchy with strict note discipline
5. Root-level and vault-level `CLAUDE.md` files provide instruction layering

## Consequences

### Positive

- Each agent works in its area of strength
- Documentation becomes a first-class coordination mechanism
- Project state is always recoverable from the repo, not from chat history
- Instruction files create predictable behavior across sessions

### Negative

- Higher initial setup cost (this bootstrap work)
- Agents must be disciplined about reading/writing coordination artifacts
- Human must review handoffs when crossing agent boundaries
- More files to maintain in the vault

### Neutral

- The vault structure constrains how documentation is organized (this is intentional)
- Codex may need its own instruction file format if it doesn't read CLAUDE.md

## Related

- [[00-overview/project-overview]] — Project identity
- [[02-operating-model/agent-coordination]] — Coordination details
- [[03-capabilities/claude-code]] — Claude Code role definition
- [[03-capabilities/codex]] — Codex role definition
