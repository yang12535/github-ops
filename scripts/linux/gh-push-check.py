#!/usr/bin/env python3
"""Check remote status before push."""

import subprocess
import sys


def run(cmd, check=True):
    result = subprocess.run(cmd, capture_output=True, text=True, check=check)
    return result


def main():
    branch_override = sys.argv[1] if len(sys.argv) > 1 else None

    try:
        run(["git", "rev-parse", "--git-dir"])
    except subprocess.CalledProcessError:
        print("Error: Not a git repository.", file=sys.stderr)
        sys.exit(1)
    
    try:
        remote_url = run(["git", "remote", "get-url", "origin"]).stdout.strip()
    except subprocess.CalledProcessError:
        print("Error: No 'origin' remote configured.", file=sys.stderr)
        sys.exit(1)
    
    if branch_override:
        branch = branch_override
    else:
        branch = run(["git", "branch", "--show-current"]).stdout.strip()
        if not branch:
            print("Error: Not on any branch (detached HEAD?).", file=sys.stderr)
            sys.exit(1)
    
    print(f"Remote: {remote_url}")
    print(f"Branch: {branch}")
    
    # Fetch quietly to get latest remote state
    fetch_result = run(["git", "fetch", "origin", branch], check=False)
    if fetch_result.returncode != 0:
        print(f"Warning: fetch failed: {fetch_result.stderr.strip()}", file=sys.stderr)
    
    try:
        upstream = run(["git", "rev-parse", "--abbrev-ref", f"{branch}@{{upstream}}"]).stdout.strip()
    except subprocess.CalledProcessError:
        upstream = None
    
    if upstream:
        result = run(["git", "rev-list", "--left-right", "--count", f"{branch}...{upstream}"])
        ahead, behind = map(int, result.stdout.strip().split())
        print(f"Upstream: {upstream}")
        print(f"Commits: ahead {ahead}, behind {behind}")
        
        if behind > 0:
            print("WARNING: Remote is ahead. Pull before pushing.")
            sys.exit(2)
        if ahead == 0:
            print("Everything up-to-date.")
        else:
            print(f"Ready to push {ahead} commit(s).")
    else:
        # No upstream configured; check against origin/<branch> if it exists
        remote_check = run(["git", "rev-parse", "--verify", f"origin/{branch}"], check=False)
        if remote_check.returncode == 0:
            result = run(["git", "rev-list", "--left-right", "--count", f"{branch}...origin/{branch}"])
            ahead, behind = map(int, result.stdout.strip().split())
            print(f"Upstream: origin/{branch} (inferred)")
            print(f"Commits: ahead {ahead}, behind {behind}")
            if behind > 0:
                print("WARNING: Remote is ahead. Pull before pushing.")
                sys.exit(2)
            if ahead == 0:
                print("Everything up-to-date.")
            else:
                print(f"Ready to push {ahead} commit(s).")
        else:
            # New branch, no remote counterpart
            if branch_override:
                # Pushing an explicit new branch — allow
                result = run(["git", "rev-list", "--count", branch], check=False)
                ahead = int(result.stdout.strip()) if result.returncode == 0 else 0
                print(f"Branch '{branch}' has no upstream.")
                if ahead > 0:
                    print(f"Ready for first push ({ahead} commit(s)).")
                else:
                    print("Everything up-to-date.")
            else:
                # Current branch has no upstream — block and instruct
                print(f"Branch '{branch}' has no upstream.")
                print(f"Run: git push -u origin {branch}")
                sys.exit(1)


if __name__ == "__main__":
    main()
