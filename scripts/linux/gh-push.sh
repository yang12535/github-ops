#!/bin/bash
# Quick push with safety check: gh-push.sh [branch]

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

usage() {
    echo "Usage: gh-push.sh [branch]"
    echo "  Checks remote status first, then pushes."
    exit 1
}

BRANCH="${1:-}"

# Run push-check first (pass target branch so we check the right branch)
if ! "$SCRIPT_DIR/gh-push-check.py" "$BRANCH"; then
    echo "Push aborted. Resolve the issues above and retry."
    exit 1
fi

if [ -n "$BRANCH" ]; then
    git push origin "$BRANCH"
else
    git push
fi
