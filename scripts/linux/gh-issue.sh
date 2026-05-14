#!/bin/bash
# Quick issue operations: gh-issue.sh <owner/repo> [list|view <n>|create <title> [--body <text>|--body-file <path>]|close <n>|reopen <n>|comment <n> <body>]

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
API="$SCRIPT_DIR/gh-api.py"

usage() {
    echo "Usage: gh-issue.sh <owner/repo> [command]"
    echo "Commands:"
    echo "  list                           List open issues"
    echo "  view <number>                  View issue details"
    echo "  create <title> [--body <text>|--body-file <path>]   Create new issue"
    echo "  close <number>                 Close issue"
    echo "  reopen <number>                Reopen issue"
    echo "  comment <number> <body>        Add comment"
    exit 1
}

REPO="${1:-}"
CMD="${2:-list}"
if [ -z "$REPO" ]; then usage; fi

case "$CMD" in
    list)
        "$API" "repos/$REPO/issues" -p
        ;;
    view)
        NUM="${3:-}"
        [ -z "$NUM" ] && { echo "Error: issue number required"; exit 1; }
        "$API" "repos/$REPO/issues/$NUM"
        ;;
    create)
        TITLE="${3:-}"
        [ -z "$TITLE" ] && { echo "Error: title required"; exit 1; }

        shift 3
        BODY=""
        BODY_FILE=""

        # Backward compatibility: single positional arg treated as body
        if [ $# -eq 1 ] && [[ "$1" != --* ]]; then
            BODY="$1"
        else
            while [ $# -gt 0 ]; do
                case "$1" in
                    --body) BODY="$2"; shift 2 ;;
                    --body-file) BODY_FILE="$2"; shift 2 ;;
                    *) echo "Unknown option: $1"; usage ;;
                esac
            done
        fi

        TMP_JSON=$(mktemp)
        trap 'rm -f "$TMP_JSON"' EXIT
        python3 - "$TITLE" "${BODY:-}" "${BODY_FILE:-}" "$TMP_JSON" <<'PYEOF'
import json, sys
title, body, body_file, out_file = sys.argv[1:5]
payload = {"title": title}
if body_file:
    with open(body_file, 'r', encoding='utf-8') as f:
        payload["body"] = f.read()
elif body:
    payload["body"] = body
with open(out_file, 'w') as f:
    json.dump(payload, f)
PYEOF
        "$API" -X POST -d "@$TMP_JSON" "repos/$REPO/issues"
        trap - EXIT
        ;;
    close)
        NUM="${3:-}"
        [ -z "$NUM" ] && { echo "Error: issue number required"; exit 1; }
        "$API" -X PATCH -d '{"state":"closed"}' "repos/$REPO/issues/$NUM"
        ;;
    reopen)
        NUM="${3:-}"
        [ -z "$NUM" ] && { echo "Error: issue number required"; exit 1; }
        "$API" -X PATCH -d '{"state":"open"}' "repos/$REPO/issues/$NUM"
        ;;
    comment)
        NUM="${3:-}"
        BODY="${4:-}"
        [ -z "$NUM" ] && { echo "Error: issue number required"; exit 1; }
        [ -z "$BODY" ] && { echo "Error: comment body required"; exit 1; }
        "$SCRIPT_DIR/gh-comment.py" "$REPO" "$NUM" --body "$BODY"
        ;;
    *)
        echo "Unknown command: $CMD"
        usage
        ;;
esac
