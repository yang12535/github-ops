#!/bin/bash
# Quick PR operations: gh-pr.sh <owner/repo> [list|view <n>|create <title> <head> <base> [--body <text>|--body-file <path>]|comments <n>|merge <n> [method]|comment <n> <body>]

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
API="$SCRIPT_DIR/gh-api.py"

usage() {
    echo "Usage: gh-pr.sh <owner/repo> [command]"
    echo "Commands:"
    echo "  list                                              List open PRs"
    echo "  view <number>                                     View PR details"
    echo "  create <title> <head> <base> [--body <text>|--body-file <path>]  Create PR"
    echo "  comments <number>                                 List PR comments"
    echo "  merge <number> [merge|squash|rebase]              Merge PR"
    echo "  comment <number> <body>                           Add comment"
    exit 1
}

REPO="${1:-}"
CMD="${2:-list}"
if [ -z "$REPO" ]; then usage; fi

case "$CMD" in
    list)
        "$API" "repos/$REPO/pulls" -p
        ;;
    view)
        NUM="${3:-}"
        [ -z "$NUM" ] && { echo "Error: PR number required"; exit 1; }
        "$API" "repos/$REPO/pulls/$NUM"
        ;;
    create)
        TITLE="${3:-}"
        HEAD="${4:-}"
        BASE="${5:-}"
        [ -z "$TITLE" ] && { echo "Error: title required"; exit 1; }
        [ -z "$HEAD" ] && { echo "Error: head branch required"; exit 1; }
        [ -z "$BASE" ] && { echo "Error: base branch required"; exit 1; }

        shift 5
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

        if [ -n "$BODY_FILE" ]; then
            TMP_JSON=$(mktemp)
            python3 - "$TITLE" "$HEAD" "$BASE" "$BODY_FILE" "$TMP_JSON" <<'PYEOF'
import json, sys
title, head, base, body_file, out_file = sys.argv[1:6]
with open(body_file, 'r', encoding='utf-8') as f:
    body = f.read()
with open(out_file, 'w') as f:
    json.dump({"title": title, "head": head, "base": base, "body": body}, f)
PYEOF
            "$API" -X POST -d "@$TMP_JSON" "repos/$REPO/pulls"
            rm -f "$TMP_JSON"
        elif [ -n "$BODY" ]; then
            "$API" -X POST -d "{\"title\":\"$TITLE\",\"head\":\"$HEAD\",\"base\":\"$BASE\",\"body\":\"$BODY\"}" "repos/$REPO/pulls"
        else
            "$API" -X POST -d "{\"title\":\"$TITLE\",\"head\":\"$HEAD\",\"base\":\"$BASE\"}" "repos/$REPO/pulls"
        fi
        ;;
    comments)
        NUM="${3:-}"
        [ -z "$NUM" ] && { echo "Error: PR number required"; exit 1; }
        "$API" "repos/$REPO/issues/$NUM/comments" -p
        ;;
    merge)
        NUM="${3:-}"
        METHOD="${4:-merge}"
        [ -z "$NUM" ] && { echo "Error: PR number required"; exit 1; }
        "$API" -X PUT -d "{\"merge_method\":\"$METHOD\"}" "repos/$REPO/pulls/$NUM/merge"
        ;;
    comment)
        NUM="${3:-}"
        BODY="${4:-}"
        [ -z "$NUM" ] && { echo "Error: PR number required"; exit 1; }
        [ -z "$BODY" ] && { echo "Error: comment body required"; exit 1; }
        "$SCRIPT_DIR/gh-comment.py" "$REPO" "$NUM" "$BODY"
        ;;
    *)
        echo "Unknown command: $CMD"
        usage
        ;;
esac
