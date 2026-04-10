---
title: "Codex: Role and Capabilities"
created: 2026-04-10
updated: 2026-04-10
status: active
tags:
  - capabilities
  - codex
  - agent-role
---

# Codex: Role and Capabilities

## Role

Apple/iOS and Xcode specialist. Handles all native platform work.

## Ownership

| Domain | Scope |
|---|---|
| iOS application | SwiftUI views, UIKit integration, app lifecycle |
| Xcode project | Build settings, schemes, targets, asset catalogs |
| Apple frameworks | CoreData, CloudKit, MapKit, StoreKit, etc. |
| Native integrations | Push notifications, widgets, App Clips, extensions |
| Platform-specific testing | XCTest, UI testing, device-specific behavior |

## Environment

- Xcode is available on an external SSD
- Codex runs on Mac alongside Claude Code
- Codex works primarily on Xcode project files and Swift source code

## Strengths

- Xcode-aware code generation
- Apple framework knowledge and best practices
- Swift language expertise
- iOS build system and signing configuration

## Boundaries

- Does **not** own the documentation vault or its structure
- Does **not** make project-wide architectural decisions unilaterally
- Does **not** modify root `CLAUDE.md` or vault `CLAUDE.md`
- Should **receive** cross-cutting work via handoff files in `04-execution/`

## Coordination with Claude Code

Codex receives work from Claude Code via handoff files. When Codex needs
something from Claude Code (API endpoints, data models, shared interfaces),
it creates a handoff file requesting that work.

See [[02-operating-model/agent-coordination]] for the full protocol.

## Instruction Files

Codex may need its own instruction file format. Potential locations:

- `CODEX.md` at repo root (if Codex supports a similar convention)
- Inline comments in Xcode project files
- A dedicated `03-capabilities/codex-instructions.md` note that Codex reads

This will be determined once Codex's instruction-file behavior is confirmed.

## Related

- [[claude-code]] — Claude Code's complementary role
- [[02-operating-model/agent-coordination]] — How coordination works
- [[01-decisions/ADR-001-dual-agent-architecture]] — Why two agents
