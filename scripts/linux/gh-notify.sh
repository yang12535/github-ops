#!/bin/bash
# Quick notifications: gh-notify.sh [list|read <thread-id>]

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
API="$SCRIPT_DIR/gh-api.py"

usage() {
    echo "Usage: gh-notify.sh [command]"
    echo "Commands:"
    echo "  list                 List notifications"
    echo "  read <thread-id>     Mark notification as read"
    exit 1
}

CMD="${1:-list}"

case "$CMD" in
    list)
        "$API" "notifications" -p
        ;;
    read)
        TID="${2:-}"
        [ -z "$TID" ] && { echo "Error: thread-id required"; exit 1; }
        "$API" -X PATCH "notifications/threads/$TID"
        ;;
    *)
        echo "Unknown command: $CMD"
        usage
        ;;
esac
