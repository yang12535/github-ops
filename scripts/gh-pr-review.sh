#!/bin/bash
# Quick PR review comments viewer: gh-pr-review.sh <owner/repo> <number> [--latest|--full|--user <name>]

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
API="$SCRIPT_DIR/gh-api.py"

usage() {
    echo "Usage: gh-pr-review.sh <owner/repo> <number> [options]"
    echo "Options:"
    echo "  --latest              Show only the latest review round"
    echo "  --full                Show full comment bodies (default: 150 chars)"
    echo "  --user <name>         Filter by reviewer username"
    exit 1
}

REPO="${1:-}"
NUM="${2:-}"
[ -z "$REPO" ] || [ -z "$NUM" ] && usage
shift 2

MODE="all"
FILTER_USER=""
FULL=""

while [ $# -gt 0 ]; do
    case "$1" in
        --latest) MODE="latest"; shift ;;
        --full) FULL="1"; shift ;;
        --user) FILTER_USER="$2"; shift 2 ;;
        *) echo "Unknown option: $1"; usage ;;
    esac
done

TMP=$(mktemp)
"$API" "repos/$REPO/pulls/$NUM/comments" -p -c > "$TMP"

python3 - "$MODE" "$FILTER_USER" "$FULL" "$TMP" << 'PYEOF'
import json, sys

mode, filter_user, full, path = sys.argv[1], sys.argv[2], sys.argv[3], sys.argv[4]
with open(path) as f:
    comments = json.load(f)

reviews = {}
for c in comments:
    rid = c.get("pull_request_review_id") or 0
    if rid not in reviews:
        reviews[rid] = []
    reviews[rid].append(c)

if not reviews:
    print("No review comments found.")
    sys.exit(0)

sorted_reviews = sorted(reviews.items())
if mode == "latest" and len(sorted_reviews) > 1:
    sorted_reviews = sorted_reviews[-1:]

for rid, cs in sorted_reviews:
    user = (cs[0].get("user") or {}).get("login", "unknown")
    if filter_user and user != filter_user:
        continue
    print(f"Review {rid} by {user} ({len(cs)} comments):")
    for c in cs:
        path = c["path"]
        line = c.get("line", "?")
        if full:
            body = c["body"]
            print(f"  - {path}:{line} -> {body}")
        else:
            body = c["body"].replace("\n", " ")[:150]
            print(f"  - {path}:{line} -> {body}...")
    print()
PYEOF

rm -f "$TMP"
