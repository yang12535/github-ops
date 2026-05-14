#!/usr/bin/env python3
"""View GitHub user activity/events."""

import json
import os
import subprocess
import sys
import urllib.error
import urllib.request


def get_token():
    try:
        result = subprocess.run(["gh", "auth", "token"], capture_output=True, text=True, check=True, timeout=10)
        token = result.stdout.strip()
        if token:
            return token
    except Exception:
        pass
    token = os.environ.get("GITHUB_TOKEN") or os.environ.get("GH_TOKEN")
    if token:
        return token
    # Fallback token files (lab/revert environments)
    import os, stat
    fallback_paths = [
        os.path.expanduser("~/.github_token"),
        os.path.expanduser("~/.config/github-ops/token"),
        os.path.expanduser("~/github_token.txt"),
    ]
    for path in fallback_paths:
        if os.path.isfile(path):
            try:
                if os.name == "posix":
                    mode = os.stat(path).st_mode
                    if mode & (stat.S_IRWXG | stat.S_IRWXO):
                        print(f"Warning: Token file {path} has overly permissive permissions, skipping.", file=sys.stderr)
                        continue
                with open(path, "r", encoding="utf-8") as f:
                    token = f.read().strip()
                if token:
                    return token
            except OSError:
                continue
    print("Error: No GitHub token found.", file=sys.stderr)
    sys.exit(1)


def get_current_user():
    token = get_token()
    req = urllib.request.Request("https://api.github.com/user", headers={
        "Authorization": f"token {token}",
        "Accept": "application/vnd.github.v3+json",
        "User-Agent": "github-ops-skill"
    })
    with urllib.request.urlopen(req) as resp:
        return json.loads(resp.read().decode("utf-8")).get("login")


def get_activity(username=None, per_page=30, event_type=None):
    token = get_token()
    if not username:
        username = get_current_user()
        url = f"https://api.github.com/users/{username}/events?per_page={per_page}"
    else:
        url = f"https://api.github.com/users/{username}/events/public?per_page={per_page}"
    
    req = urllib.request.Request(url, headers={
        "Authorization": f"token {token}",
        "Accept": "application/vnd.github.v3+json",
        "User-Agent": "github-ops-skill"
    })
    try:
        with urllib.request.urlopen(req) as resp:
            events = json.loads(resp.read().decode("utf-8"))
            if not isinstance(events, list):
                print(json.dumps(events, indent=2))
                return
            
            filtered = events
            if event_type:
                filtered = [e for e in events if e.get("type") == event_type]
            
            if not filtered:
                print("No events found.")
                return
            
            for e in filtered:
                repo_name = e.get("repo", {}).get("name", "N/A")
                print(f"[{e['created_at']}] {e['type']} on {repo_name}")
                payload = e.get("payload", {})
                if e["type"] == "PushEvent":
                    commits = payload.get("commits", [])
                    for c in commits[:3]:
                        print(f"  - {c.get('message', '').split(chr(10))[0]}")
                    if len(commits) > 3:
                        print(f"  ... and {len(commits)-3} more commits")
                elif e["type"] == "PullRequestEvent":
                    pr = payload.get("pull_request", {})
                    action = payload.get("action", "unknown")
                    print(f"  PR #{pr.get('number')}: {pr.get('title')} ({action})")
                elif e["type"] == "IssuesEvent":
                    issue = payload.get("issue", {})
                    action = payload.get("action", "unknown")
                    print(f"  Issue #{issue.get('number')}: {issue.get('title')} ({action})")
                elif e["type"] == "CreateEvent" or e["type"] == "DeleteEvent":
                    ref_type = payload.get("ref_type", "unknown")
                    ref = payload.get("ref", "unknown")
                    print(f"  {ref_type}: {ref}")
                elif e["type"] == "WatchEvent":
                    print(f"  Starred {repo_name}")
    except urllib.error.HTTPError as e:
        body = e.read().decode("utf-8")
        print(f"HTTP {e.code}: {body}", file=sys.stderr)
        sys.exit(1)


if __name__ == "__main__":
    username = sys.argv[1] if len(sys.argv) > 1 else None
    per_page = int(sys.argv[2]) if len(sys.argv) > 2 else 30
    event_type = sys.argv[3] if len(sys.argv) > 3 else None
    get_activity(username, per_page, event_type)
