#!/bin/bash
# Reply to a PR review comment: gh-pr-reply.sh <owner/repo> <pr-number> <comment-id> <body>

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
API="$SCRIPT_DIR/gh-api.py"

usage() {
    echo "Usage: gh-pr-reply.sh <owner/repo> <pr-number> <comment-id> <body>"
    exit 1
}

REPO="${1:-}"
NUM="${2:-}"
CID="${3:-}"
BODY="${4:-}"
[ -z "$REPO" ] || [ -z "$NUM" ] || [ -z "$CID" ] || [ -z "$BODY" ] && usage

"$API" -X POST -d "{\"body\":\"$BODY\"}" "repos/$REPO/pulls/$NUM/comments/$CID/replies"
