#!/bin/bash
# Quick comment on issue or PR: gh-comment.sh <owner/repo> <number> [--body <text>|--body-file <path>]

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

usage() {
    echo "Usage: gh-comment.sh <owner/repo> <issue-or-pr-number> [--body <text>|--body-file <path>]"
    echo "  gh-comment.sh owner/repo 8 --body-file /tmp/comment.md"
    exit 1
}

REPO="${1:-}"
NUM="${2:-}"
[ -z "$REPO" ] || [ -z "$NUM" ] && usage
shift 2

# Backward compatibility: third positional arg treated as body
if [ $# -eq 1 ] && [[ "$1" != --* ]]; then
    BODY="$1"
    "$SCRIPT_DIR/gh-comment.py" "$REPO" "$NUM" --body "$BODY"
    exit 0
fi

BODY=""
BODY_FILE=""

while [ $# -gt 0 ]; do
    case "$1" in
        --body) BODY="$2"; shift 2 ;;
        --body-file) BODY_FILE="$2"; shift 2 ;;
        *) echo "Unknown option: $1"; usage ;;
    esac
done

if [ -n "$BODY_FILE" ]; then
    "$SCRIPT_DIR/gh-comment.py" "$REPO" "$NUM" --body-file "$BODY_FILE"
elif [ -n "$BODY" ]; then
    "$SCRIPT_DIR/gh-comment.py" "$REPO" "$NUM" --body "$BODY"
else
    usage
fi
