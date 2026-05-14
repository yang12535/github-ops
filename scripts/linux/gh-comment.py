#!/usr/bin/env python3
"""Comment on GitHub issue or PR."""

import argparse
import json
import os
import stat
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


def comment(repo, number, body):
    token = get_token()
    url = f"https://api.github.com/repos/{repo}/issues/{number}/comments"
    data = json.dumps({"body": body}).encode("utf-8")
    req = urllib.request.Request(url, data=data, method="POST", headers={
        "Authorization": f"token {token}",
        "Accept": "application/vnd.github.v3+json",
        "Content-Type": "application/json",
        "User-Agent": "github-ops-skill"
    })
    try:
        with urllib.request.urlopen(req) as resp:
            result = json.loads(resp.read().decode("utf-8"))
            print(json.dumps(result, indent=2, ensure_ascii=False))
    except urllib.error.HTTPError as e:
        body = e.read().decode("utf-8")
        print(f"HTTP {e.code}: {body}", file=sys.stderr)
        sys.exit(1)


def main():
    parser = argparse.ArgumentParser(description="Comment on GitHub issue or PR")
    parser.add_argument("repo", help="owner/repo")
    parser.add_argument("number", help="issue or PR number")
    group = parser.add_mutually_exclusive_group(required=True)
    group.add_argument("--body", help="comment body text")
    group.add_argument("--body-file", help="path to file containing comment body")
    args = parser.parse_args()

    if args.body_file:
        with open(args.body_file, "r", encoding="utf-8") as f:
            body = f.read()
    else:
        body = args.body

    comment(args.repo, args.number, body)


if __name__ == "__main__":
    main()
