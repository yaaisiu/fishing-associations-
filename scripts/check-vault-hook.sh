#!/usr/bin/env bash
# scripts/check-vault-hook.sh
#
# Pre-commit gate for vault validation.
# - Always runs validation and shows output
# - Only enforces strict mode (blocks commit) when vault has 15+ notes
# - Below 15 notes, warnings are informational only
#
# Usage: called by .claude/settings.json PreCommit hook

set -euo pipefail

REPO_ROOT="$(git rev-parse --show-toplevel 2>/dev/null || pwd)"
VAULT_PATH="$REPO_ROOT/docs/obsidian"
THRESHOLD=15

if [[ ! -d "$VAULT_PATH" ]]; then
    exit 0
fi

# Count content notes (excluding index, templates, instruction files)
NOTE_COUNT=$(find "$VAULT_PATH" -name '*.md' \
    ! -name 'index.md' \
    ! -name 'CLAUDE.md' \
    ! -name 'AGENTS.md' \
    ! -path '*/_templates/*' \
    -print | wc -l)

if [[ "$NOTE_COUNT" -ge "$THRESHOLD" ]]; then
    echo "Vault has $NOTE_COUNT notes (>= $THRESHOLD threshold). Running strict validation..."
    exec "$REPO_ROOT/scripts/validate-vault.sh" --strict
else
    echo "Vault has $NOTE_COUNT notes (< $THRESHOLD threshold). Running informational validation..."
    "$REPO_ROOT/scripts/validate-vault.sh" || true
    exit 0
fi
