#!/bin/bash
# Quick activity viewer: gh-activity.sh [username] [count] [event-type]

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

usage() {
    echo "Usage: gh-activity.sh [username] [count] [event-type]"
    echo "Examples:"
    echo "  gh-activity.sh                   # Current user activity"
    echo "  gh-activity.sh <username> 20     # Last 20 events"
    echo "  gh-activity.sh <username> 30 PushEvent"
    exit 1
}

USERNAME="${1:-}"
COUNT="${2:-30}"
EVENT_TYPE="${3:-}"

"$SCRIPT_DIR/gh-activity.py" "$USERNAME" "$COUNT" "$EVENT_TYPE"
