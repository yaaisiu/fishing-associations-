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

# Count content notes using the same criteria as validate-vault.sh:
# mindepth 2, exclude index, .obsidian, templates, vault-root instruction files.
# Use null-delimited read loop (safe for filenames with spaces/newlines).
NOTE_COUNT=0
while IFS= read -r -d '' _file; do
    NOTE_COUNT=$((NOTE_COUNT + 1))
done < <(find "$VAULT_PATH" -mindepth 2 -name '*.md' \
    ! -name 'index.md' \
    ! -path '*/.obsidian/*' \
    ! -path '*/_templates/*' \
    ! -path "$VAULT_PATH/CLAUDE.md" \
    ! -path "$VAULT_PATH/AGENTS.md" \
    -print0)

if [[ "$NOTE_COUNT" -ge "$THRESHOLD" ]]; then
    echo "Vault has $NOTE_COUNT notes (>= $THRESHOLD threshold). Running strict validation..."
    "$REPO_ROOT/scripts/validate-vault.sh" --strict
    exit $?
else
    echo "Vault has $NOTE_COUNT notes (< $THRESHOLD threshold). Running informational validation..."
    "$REPO_ROOT/scripts/validate-vault.sh" || true
    exit 0
fi
