#!/bin/bash
# Quick repo operations: gh-repo.sh <owner/repo> [view|issues|prs|commits|releases|contents <path>]

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
API="$SCRIPT_DIR/gh-api.py"

usage() {
    echo "Usage: gh-repo.sh <owner/repo> [command]"
    echo "Commands:"
    echo "  view                 Show repo details"
    echo "  issues               List open issues"
    echo "  prs                  List open pull requests"
    echo "  commits              List recent commits"
    echo "  releases             List releases"
    echo "  contents <path>      Show file/directory contents"
    echo "  url                  Print repo HTML URL"
    exit 1
}

REPO="${1:-}"
CMD="${2:-view}"
if [ -z "$REPO" ]; then usage; fi

case "$CMD" in
    view)
        "$API" "repos/$REPO"
        ;;
    issues)
        "$API" "repos/$REPO/issues" -p
        ;;
    prs)
        "$API" "repos/$REPO/pulls" -p
        ;;
    commits)
        "$API" "repos/$REPO/commits" -p
        ;;
    releases)
        "$API" "repos/$REPO/releases" -p
        ;;
    contents)
        PATH_ARG="${3:-}"
        if [ -z "$PATH_ARG" ]; then echo "Error: path required"; exit 1; fi
        "$API" "repos/$REPO/contents/$PATH_ARG"
        ;;
    url)
        "$API" "repos/$REPO" -f html_url
        ;;
    *)
        echo "Unknown command: $CMD"
        usage
        ;;
esac
