#!/bin/bash
# Generic GitHub API call: gh-api-call.sh <endpoint> [-X METHOD] [-d DATA]
# Uses curl directly as the ultimate fallback when gh-api.py is unavailable.

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
API="$SCRIPT_DIR/gh-api.py"

usage() {
    echo "Usage: gh-api-call.sh <endpoint> [-X METHOD] [-d DATA] [-p] [-c]"
    echo "  endpoint: API path, e.g. repos/owner/repo/issues"
    echo "  -X: HTTP method (default GET)"
    echo "  -d: JSON request body"
    echo "  -p: Paginate list results"
    echo "  -c: Compact output"
    echo ""
    echo "Examples:"
    echo "  gh-api-call.sh user"
    echo "  gh-api-call.sh repos/owner/repo/issues -p"
    echo "  gh-api-call.sh repos/owner/repo/issues -X POST -d '{\"title\":\"bug\"}'"
    exit 1
}

if [ $# -eq 0 ]; then usage; fi

# Prefer gh-api.py if available
if [ -x "$API" ]; then
    "$API" "$@"
else
    # Raw curl fallback
    ENDPOINT="$1"
    shift
    
    METHOD="GET"
    DATA=""
    PAGINATE=""
    COMPACT=""
    
    while [ $# -gt 0 ]; do
        case "$1" in
            -X) METHOD="$2"; shift 2 ;;
            -d) DATA="$2"; shift 2 ;;
            -p) PAGINATE="1"; shift ;;
            -c) COMPACT="1"; shift ;;
            -h|--help) usage ;;
            *) echo "Unknown option: $1"; usage ;;
        esac
    done
    
    TOKEN=$(gh auth token 2>/dev/null || echo "${GITHUB_TOKEN:-${GH_TOKEN}}")
    if [ -z "$TOKEN" ]; then
        echo "Error: No GitHub token found." >&2
        exit 1
    fi
    
    URL="https://api.github.com/${ENDPOINT#/}"
    CURL_OPTS=(-s -H "Authorization: token $TOKEN" -H "Accept: application/vnd.github.v3+json")
    
    if [ -n "$DATA" ]; then
        CURL_OPTS+=(-H "Content-Type: application/json" -X "$METHOD" -d "$DATA")
    elif [ "$METHOD" != "GET" ]; then
        CURL_OPTS+=(-X "$METHOD")
    fi
    
    if [ -n "$PAGINATE" ]; then
        TMP_BODY=$(mktemp)
        TMP_HDR=$(mktemp)
        trap 'rm -f "$TMP_BODY" "$TMP_HDR"' EXIT

        RESULTS=""
        NEXT_URL="$URL"
        PAGES=0
        MAX_PAGES=10

        while [ -n "$NEXT_URL" ] && [ "$PAGES" -lt "$MAX_PAGES" ]; do
            PAGES=$((PAGES + 1))
            curl -s -D "$TMP_HDR" "${CURL_OPTS[@]}" "$NEXT_URL" > "$TMP_BODY"

            if [ -z "$RESULTS" ]; then
                RESULTS=$(cat "$TMP_BODY")
            else
                INNER1=$(printf '%s' "$RESULTS" | sed 's/^\[//;s/\]$//')
                INNER2=$(cat "$TMP_BODY" | sed 's/^\[//;s/\]$//')
                if [ -n "$INNER1" ] && [ -n "$INNER2" ]; then
                    RESULTS="[$INNER1,$INNER2]"
                elif [ -n "$INNER2" ]; then
                    RESULTS=$(cat "$TMP_BODY")
                fi
            fi

            NEXT_URL=$(grep -i '^link:' "$TMP_HDR" 2>/dev/null | tr ',' '\n' | grep 'rel="next"' 2>/dev/null | sed 's/.*<\([^>]*\)>;.*/\1/' | tr -d '\r' || true)
        done

        rm -f "$TMP_BODY" "$TMP_HDR"
        trap - EXIT

        if [ -n "$COMPACT" ]; then
            printf '%s\n' "$RESULTS"
        else
            printf '%s\n' "$RESULTS" | python3 -m json.tool
        fi
    elif [ -n "$COMPACT" ]; then
        curl "${CURL_OPTS[@]}" "$URL"
    else
        curl "${CURL_OPTS[@]}" "$URL" | python3 -m json.tool
    fi
fi
