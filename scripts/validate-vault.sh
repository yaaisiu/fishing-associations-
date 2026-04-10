#!/usr/bin/env bash
# scripts/validate-vault.sh
#
# Validates Obsidian vault integrity:
# - Every non-index .md file must be linked from its folder's index.md
# - Every folder containing .md files must have an index.md
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

# Count all content notes in the vault.
# Content notes are .md files inside subfolders (mindepth 2), excluding index
# files, instruction files, templates, and Obsidian config.
while IFS= read -r -d '' file; do
    NOTE_COUNT=$((NOTE_COUNT + 1))
done < <(find "$VAULT_PATH" -mindepth 2 -name '*.md' \
    ! -name 'index.md' \
    ! -path '*/.obsidian/*' \
    ! -path '*/_templates/*' \
    ! -path "$VAULT_PATH/CLAUDE.md" \
    ! -path "$VAULT_PATH/AGENTS.md" \
    -print0)

echo "Notes in vault: $NOTE_COUNT"
echo ""

# Check 1: Every vault folder containing .md files must have an index.md.
# Covers top-level numbered folders, _templates, and any nested subdirectories.
echo "== Checking folder indexes =="
while IFS= read -r -d '' dir; do
    # Skip the vault root itself
    if [[ "$dir" == "$VAULT_PATH" ]]; then
        continue
    fi

    # Only check directories that contain at least one non-index .md file
    has_md=false
    while IFS= read -r -d '' _md_file; do
        has_md=true
        break
    done < <(find "$dir" -maxdepth 1 -name '*.md' ! -name 'index.md' -print0 2>/dev/null)
    if [[ "$has_md" == false ]]; then
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

# Check 2: Every non-index .md file must be referenced in its folder's index.md.
# Uses wiki-link matching: [[filename]] or [[filename|...]] or the bare filename
# as a fixed string (not regex).
echo "== Checking index links =="
LINK_WARNINGS=0
while IFS= read -r -d '' file; do
    file_name="${file##*/}"          # basename
    file_stem="${file_name%.md}"     # strip .md
    file_dir="${file%/*}"            # dirname
    dir_name="${file_dir##*/}"       # parent folder name
    index_file="$file_dir/index.md"

    if [[ ! -f "$index_file" ]]; then
        # Missing index already reported in Check 1
        continue
    fi

    # Match the Obsidian wiki-link pattern [[file_stem]] or [[file_stem|...]]
    # or a bare reference to file_stem. Use fixed-string grep to avoid regex
    # interpretation of filenames containing special characters.
    if ! grep -qF "$file_stem" "$index_file" 2>/dev/null; then
        echo "  WARNING: $dir_name/$file_name is not linked from $dir_name/index.md"
        LINK_WARNINGS=$((LINK_WARNINGS + 1))
        WARNINGS=$((WARNINGS + 1))
    fi
done < <(find "$VAULT_PATH" -mindepth 2 -name '*.md' \
    ! -name 'index.md' \
    ! -path '*/.obsidian/*' \
    ! -path "$VAULT_PATH/CLAUDE.md" \
    ! -path "$VAULT_PATH/AGENTS.md" \
    -print0)
if [[ $LINK_WARNINGS -eq 0 ]]; then
    echo "  All notes are linked from their index files."
fi
echo ""

# Check 3: Frontmatter check on content files.
# Every .md file except index files, templates, vault-root instruction files,
# and Obsidian config must start with '---'.
echo "== Checking frontmatter =="
FM_MISSING=0
while IFS= read -r -d '' file; do
    file_name="${file##*/}"
    file_dir="${file%/*}"
    dir_name="${file_dir##*/}"

    # Skip index files and template files
    if [[ "$file_name" == "index.md" ]] || [[ "$dir_name" == "_templates" ]]; then
        continue
    fi
    # Skip vault-root instruction files
    if [[ "$file_dir" == "$VAULT_PATH" ]]; then
        continue
    fi

    # Check if file starts with --- (strip BOM and CR for Windows-edited files)
    if ! head -1 "$file" | tr -d '\r\xEF\xBB\xBF' | grep -q '^---$'; then
        echo "  WARNING: $dir_name/$file_name is missing YAML frontmatter"
        FM_MISSING=$((FM_MISSING + 1))
        WARNINGS=$((WARNINGS + 1))
    fi
done < <(find "$VAULT_PATH" -mindepth 2 -name '*.md' \
    ! -path '*/.obsidian/*' \
    -print0)
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
