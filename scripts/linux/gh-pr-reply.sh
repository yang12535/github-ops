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

TMP_JSON=$(mktemp)
trap 'rm -f "$TMP_JSON"' EXIT
python3 -c "import json,sys; json.dump({'body': sys.argv[1]}, open(sys.argv[2], 'w'))" "$BODY" "$TMP_JSON"
"$API" -X POST -d "@$TMP_JSON" "repos/$REPO/pulls/$NUM/comments/$CID/replies"
trap - EXIT
