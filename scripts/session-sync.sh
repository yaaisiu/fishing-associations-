#!/usr/bin/env bash
# scripts/session-sync.sh
#
# Session-start sync check. Fetches from origin and reports:
# - Whether the current branch is behind origin (other agent pushed)
# - Whether main has new commits since this branch diverged
# - Recent commits by other agents on any branch
#
# Usage: called by .claude/settings.json SessionStart hook
# Never blocks — informational only.

set -euo pipefail

REPO_ROOT="$(git rev-parse --show-toplevel 2>/dev/null || pwd)"
cd "$REPO_ROOT"

CURRENT_BRANCH="$(git branch --show-current 2>/dev/null || echo "detached")"

echo "== Session Sync =="
echo "Branch: $CURRENT_BRANCH"
echo ""

# Fetch from origin (with timeout, never block on network failure)
echo "Fetching from origin..."
if timeout 10 git fetch origin --quiet 2>/dev/null; then
    echo "  Fetch complete."
else
    echo "  WARNING: Fetch failed or timed out. Working with local state only."
    echo ""
    exit 0
fi
echo ""

# Check if current branch is behind its upstream
if git rev-parse --verify "origin/$CURRENT_BRANCH" >/dev/null 2>&1; then
    LOCAL="$(git rev-parse HEAD)"
    REMOTE="$(git rev-parse "origin/$CURRENT_BRANCH")"
    BASE="$(git merge-base HEAD "origin/$CURRENT_BRANCH" 2>/dev/null || echo "")"

    if [[ "$LOCAL" == "$REMOTE" ]]; then
        echo "Current branch is up to date with origin."
    elif [[ "$LOCAL" == "$BASE" ]]; then
        BEHIND=$(git rev-list --count HEAD.."origin/$CURRENT_BRANCH")
        echo "  NOTICE: Current branch is $BEHIND commit(s) BEHIND origin/$CURRENT_BRANCH."
        echo "  Run: git pull origin $CURRENT_BRANCH"
    elif [[ "$REMOTE" == "$BASE" ]]; then
        AHEAD=$(git rev-list --count "origin/$CURRENT_BRANCH"..HEAD)
        echo "  Current branch is $AHEAD commit(s) ahead of origin (unpushed local work)."
    else
        AHEAD=$(git rev-list --count "origin/$CURRENT_BRANCH"..HEAD)
        BEHIND=$(git rev-list --count HEAD.."origin/$CURRENT_BRANCH")
        echo "  NOTICE: Branch has diverged — $AHEAD ahead, $BEHIND behind origin."
        echo "  Manual reconciliation needed."
    fi
else
    echo "  No upstream tracking for $CURRENT_BRANCH (local-only branch)."
fi
echo ""

# Check if main has moved since this branch diverged
if [[ "$CURRENT_BRANCH" != "main" ]] && git rev-parse --verify origin/main >/dev/null 2>&1; then
    MAIN_AHEAD=$(git rev-list --count HEAD..origin/main 2>/dev/null || echo "0")
    if [[ "$MAIN_AHEAD" -gt 0 ]]; then
        echo "  NOTICE: main has $MAIN_AHEAD new commit(s) since this branch diverged."
        echo "  Consider rebasing or merging main into your branch."
    else
        echo "  main has no new commits since this branch diverged."
    fi
    echo ""
fi

# Show recent commits across all remote branches (last 24h or last 5, whichever is less)
echo "== Recent Remote Activity (last 5 commits across all branches) =="
git log --all --remotes --oneline --since="24 hours ago" -5 --format="  %h %s (%an, %ar)" 2>/dev/null || echo "  No recent activity."
echo ""

echo "---"
exit 0
