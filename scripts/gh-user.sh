#!/bin/bash
# Quick user profile: gh-user.sh [username]

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
API="$SCRIPT_DIR/gh-api.py"

usage() {
    echo "Usage: gh-user.sh [username]"
    echo "  gh-user.sh         # Current authenticated user"
    echo "  gh-user.sh <name>  # Specific user profile"
    exit 1
}

USERNAME="${1:-}"

if [ -n "$USERNAME" ]; then
    "$API" "users/$USERNAME"
else
    "$API" "user"
fi
