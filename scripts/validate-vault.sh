#!/usr/bin/env bash
# scripts/validate-vault.sh
#
# Validates Obsidian vault integrity:
# - Every non-index .md file must be linked from its folder's index.md
# - Every folder must have an index.md
# - Frontmatter must exist on non-index, non-template files
#
# Usage: ./scripts/validate-vault.sh [--strict]
#   --strict: exit 1 on any warning (for use in hooks/CI)
#
# Returns: 0 if valid, 1 if issues found (in strict mode)

set -euo pipefail

VAULT_DIR="docs/obsidian"
STRICT=false
ERRORS=0
WARNINGS=0
NOTE_COUNT=0

if [[ "${1:-}" == "--strict" ]]; then
    STRICT=true
fi

# Find the repo root (look for .git)
REPO_ROOT="$(git rev-parse --show-toplevel 2>/dev/null || pwd)"
VAULT_PATH="$REPO_ROOT/$VAULT_DIR"

if [[ ! -d "$VAULT_PATH" ]]; then
    echo "ERROR: Vault directory not found at $VAULT_PATH"
    exit 1
fi

echo "Validating vault: $VAULT_PATH"
echo "---"

# Count all non-index markdown files in the vault (excluding CLAUDE.md, AGENTS.md at vault root)
while IFS= read -r -d '' file; do
    NOTE_COUNT=$((NOTE_COUNT + 1))
done < <(find "$VAULT_PATH" -name '*.md' \
    ! -name 'index.md' \
    ! -name 'CLAUDE.md' \
    ! -name 'AGENTS.md' \
    ! -path '*/_templates/*' \
    -print0)

echo "Notes in vault: $NOTE_COUNT"
echo ""

# Check 1: Every vault folder containing .md files must have an index.md
# This covers top-level numbered folders, _templates, and any nested subdirectories.
echo "== Checking folder indexes =="
while IFS= read -r -d '' dir; do
    # Skip the vault root itself
    if [[ "$dir" == "$VAULT_PATH" ]]; then
        continue
    fi

    # Only check directories that contain at least one .md file
    md_count=$(find "$dir" -maxdepth 1 -name '*.md' ! -name 'index.md' -print -quit 2>/dev/null | wc -l)
    if [[ "$md_count" -eq 0 ]]; then
        continue
    fi

    # Build a relative path for display
    rel_dir="${dir#"$VAULT_PATH/"}"

    if [[ ! -f "$dir/index.md" ]]; then
        echo "  ERROR: Missing index.md in $rel_dir/"
        ERRORS=$((ERRORS + 1))
    else
        echo "  OK: $rel_dir/index.md exists"
    fi
done < <(find "$VAULT_PATH" -type d ! -name '.obsidian' ! -path '*/.obsidian/*' -print0)
echo ""

# Check 2: Every non-index .md file must be referenced in its folder's index.md
echo "== Checking index links =="
LINK_WARNINGS=0
while IFS= read -r -d '' file; do
    # Skip files directly in the vault root (CLAUDE.md, AGENTS.md, etc.)
    if [[ "$(dirname "$file")" == "$VAULT_PATH" ]]; then
        continue
    fi

    filename="$(basename "$file" .md)"
    dir="$(dirname "$file")"
    dirname="$(basename "$dir")"
    index_file="$dir/index.md"

    if [[ ! -f "$index_file" ]]; then
        # Already reported above
        continue
    fi

    # Check if the filename appears in the index (as wiki-link or plain text)
    if ! grep -q "$filename" "$index_file" 2>/dev/null; then
        echo "  WARNING: $dirname/$filename.md is not linked from $dirname/index.md"
        LINK_WARNINGS=$((LINK_WARNINGS + 1))
        WARNINGS=$((WARNINGS + 1))
    fi
done < <(find "$VAULT_PATH" -mindepth 2 -name '*.md' \
    ! -name 'index.md' \
    ! -name 'CLAUDE.md' \
    ! -name 'AGENTS.md' \
    -print0)
if [[ $LINK_WARNINGS -eq 0 ]]; then
    echo "  All notes are linked from their index files."
fi
echo ""

# Check 3: Frontmatter check on content files
echo "== Checking frontmatter =="
FM_MISSING=0
while IFS= read -r -d '' file; do
    filename="$(basename "$file")"
    dir_basename="$(basename "$(dirname "$file")")"

    # Skip index files and template files
    if [[ "$filename" == "index.md" ]] || [[ "$dir_basename" == "_templates" ]]; then
        continue
    fi
    # Skip vault-root instruction files
    if [[ "$(dirname "$file")" == "$VAULT_PATH" ]]; then
        continue
    fi

    # Check if file starts with ---
    if ! head -1 "$file" | grep -q '^---$'; then
        echo "  WARNING: $dir_basename/$filename is missing YAML frontmatter"
        FM_MISSING=$((FM_MISSING + 1))
        WARNINGS=$((WARNINGS + 1))
    fi
done < <(find "$VAULT_PATH" -name '*.md' -print0)
if [[ $FM_MISSING -eq 0 ]]; then
    echo "  All content files have frontmatter."
fi
echo ""

# Summary
echo "---"
echo "Validation complete: $ERRORS errors, $WARNINGS warnings, $NOTE_COUNT notes"

if [[ $ERRORS -gt 0 ]]; then
    exit 1
fi

if [[ "$STRICT" == true ]] && [[ $WARNINGS -gt 0 ]]; then
    exit 1
fi

exit 0
