#!/bin/bash
# Quick pull: gh-pull.sh [branch|remote branch]

set -e

usage() {
    echo "Usage: gh-pull.sh [remote] [branch]"
    echo "  gh-pull.sh         # git pull"
    echo "  gh-pull.sh origin main"
    exit 1
}

REMOTE="${1:-}"
BRANCH="${2:-}"

if [ -n "$REMOTE" ] && [ -n "$BRANCH" ]; then
    git pull "$REMOTE" "$BRANCH"
elif [ -n "$REMOTE" ]; then
    git pull "$REMOTE"
else
    git pull
fi
