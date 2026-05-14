#!/bin/bash
# Quick PR reviews summary: gh-pr-reviews.sh <owner/repo> <number>

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
API="$SCRIPT_DIR/gh-api.py"

usage() {
    echo "Usage: gh-pr-reviews.sh <owner/repo> <number>"
    exit 1
}

REPO="${1:-}"
NUM="${2:-}"
[ -z "$REPO" ] || [ -z "$NUM" ] && usage

TMP=$(mktemp)
trap 'rm -f "$TMP"' EXIT
"$API" "repos/$REPO/pulls/$NUM/reviews" -c > "$TMP"

python3 - "$TMP" << 'PYEOF'
import json, sys
with open(sys.argv[1]) as f:
    reviews = json.load(f)
if not reviews:
    print("No reviews found.")
    sys.exit(0)
for r in reviews:
    rid = r["id"]
    user = (r.get("user") or {}).get("login", "unknown")
    state = r["state"]
    body = (r.get("body") or "").replace("\n", " ")[:100]
    print(f"Review {rid} by {user}: {state}")
    if body:
        print(f"  -> {body}...")
    print()
PYEOF

trap - EXIT
