---
name: github-ops
description: "GitHub repository and workflow operations via authenticated REST API (curl/urllib) with gh CLI as auth fallback. Use when the user needs to: (1) view or browse repositories, (2) clone/pull/push code, (3) create or manage pull requests, (4) comment on issues or PRs, (5) view user activity feeds or notifications, (6) access GitHub user/org profiles, (7) check repo settings, releases, or actions runs. Trigger on any GitHub-related task especially when gh CLI is unreliable or the user prefers direct API calls."
---

# GitHub Operations

**Primary method**: Direct GitHub REST API calls via `scripts/gh-api.py` (Python/urllib) or raw `curl`. On Windows, pure PowerShell via `Invoke-RestMethod`.
**Quick scripts**: `scripts/linux/gh-*.sh` (Linux/macOS), `scripts/windows/gh-*.ps1` (Windows), and legacy `scripts/gh-*.sh`.
**Auth source**: `gh auth token` (preferred) → `GITHUB_TOKEN` / `GH_TOKEN` env → `~/.github_token` / `~/.config/github-ops/token` / `~/github_token.txt`. Re-authenticate with `gh auth login` only when token is missing.

## Quick Start

### Linux / macOS

```bash
# Current user profile
scripts/linux/gh-user.sh

# View a repository
scripts/linux/gh-repo.sh owner/repo view

# List open issues
scripts/linux/gh-issue.sh owner/repo list

# Comment on an issue or PR
scripts/linux/gh-comment.sh owner/repo 1 "LGTM"

# View recent activity
scripts/linux/gh-activity.sh username 20
```

### Windows (PowerShell)

```powershell
# Current user profile
scripts/windows/gh-user.ps1

# View a repository
scripts/windows/gh-repo.ps1 owner/repo view

# List open issues
scripts/windows/gh-issue.ps1 owner/repo list

# Create PR
scripts/windows/gh-pr.ps1 owner/repo create "title" "head-branch" "main" --body "PR description"
```

## Authentication

All scripts auto-resolve the token. If `gh` is completely broken, use a token file or export the token manually:

```bash
# Linux / macOS
export GITHUB_TOKEN="ghp_xxxxxxxx"
echo "ghp_xxxxxxxx" > ~/.github_token
chmod 600 ~/.github_token

# Windows PowerShell
$env:GITHUB_TOKEN="ghp_xxxxxxxx"
"ghp_xxxxxxxx" | Out-File -Encoding utf8 $env:USERPROFILE\.github_token
```

Verify token works:
```bash
scripts/linux/gh-user.sh
# or
scripts/windows/gh-user.ps1
```

## Linux / macOS Quick Scripts

### gh-user.sh — User Profile

```bash
scripts/gh-user.sh              # Current authenticated user
scripts/gh-user.sh <username>   # Specific user profile
```

### gh-repo.sh — Repository

```bash
scripts/gh-repo.sh <owner/repo> view           # Repo details
scripts/gh-repo.sh <owner/repo> issues         # List open issues
scripts/gh-repo.sh <owner/repo> prs            # List open PRs
scripts/gh-repo.sh <owner/repo> commits        # Recent commits
scripts/gh-repo.sh <owner/repo> releases       # Releases
scripts/gh-repo.sh <owner/repo> contents <path> # File/directory contents
scripts/gh-repo.sh <owner/repo> url            # Print HTML URL
```

Clone a repository:
```bash
git clone https://github.com/<owner>/<repo>.git
```

### gh-issue.sh — Issues

```bash
scripts/gh-issue.sh <owner/repo> list                              # List open issues
scripts/gh-issue.sh <owner/repo> view <number>                     # View issue
scripts/gh-issue.sh <owner/repo> create <title> [--body <text>|--body-file <path>]   # Create issue
scripts/gh-issue.sh <owner/repo> close <number>                    # Close issue
scripts/gh-issue.sh <owner/repo> reopen <number>                   # Reopen issue
scripts/gh-issue.sh <owner/repo> comment <number> <body>           # Add comment
```

> **Tip**: Use `--body-file` when the issue body contains backticks, quotes, or `$` variables to avoid shell parsing errors. Positional body argument is supported for backward compatibility.

### gh-pr.sh — Pull Requests

```bash
scripts/gh-pr.sh <owner/repo> list                              # List open PRs
scripts/gh-pr.sh <owner/repo> view <number>                     # View PR
scripts/gh-pr.sh <owner/repo> create <title> <head> <base> [--body <text>|--body-file <path>]  # Create PR
scripts/gh-pr.sh <owner/repo> comments <number>                 # List PR comments
scripts/gh-pr.sh <owner/repo> merge <number> [merge|squash|rebase] # Merge PR
scripts/gh-pr.sh <owner/repo> comment <number> <body>           # Add comment
```

> **Tip**: Use `--body-file` when the PR description contains backticks, quotes, or `$` variables to avoid shell parsing errors. Positional body argument is supported for backward compatibility.

> **Note**: `comments` lists regular issue/PR comments (not review comments). For review comments, use `gh-pr-review.sh`.

### gh-pr-review.sh — PR Review Comments

View review comments grouped by review round:
```bash
scripts/gh-pr-review.sh <owner/repo> <number>                # All review comments (truncated)
scripts/gh-pr-review.sh <owner/repo> <number> --latest       # Latest round only
scripts/gh-pr-review.sh <owner/repo> <number> --full         # Show full comment bodies
scripts/gh-pr-review.sh <owner/repo> <number> --user Copilot # Filter by reviewer
```

### gh-pr-reviews.sh — PR Reviews Summary

Quick summary of all review rounds (state + comment count):
```bash
scripts/gh-pr-reviews.sh <owner/repo> <number>
```

### gh-pr-reply.sh — Reply to Review Comment

```bash
scripts/gh-pr-reply.sh <owner/repo> <pr-number> <comment-id> "Fixed in commit abc"
```

### gh-comment.sh — Quick Comment

Works for both issues and PRs:
```bash
scripts/gh-comment.sh <owner/repo> <number> <body>                  # Positional (legacy)
scripts/gh-comment.sh <owner/repo> <number> --body-file comment.md  # From file (recommended)
scripts/gh-comment.sh <owner/repo> <number> --body "LGTM"           # Explicit flag
```

> **Tip**: Use `--body-file` when the comment contains backticks, quotes, or `$` variables to avoid shell parsing errors.

### gh-push.sh / gh-pull.sh — Git Sync

```bash
scripts/gh-pull.sh              # git pull
scripts/gh-pull.sh origin main  # git pull origin main

scripts/gh-push.sh              # Check remote status, then push
scripts/gh-push.sh feature-x    # Push specific branch
```

### gh-activity.sh — Activity Feed

```bash
scripts/gh-activity.sh                    # Current user activity
scripts/gh-activity.sh <username> 20      # Last 20 events
scripts/gh-activity.sh <username> 30 PushEvent  # Filter by event type
```

Common event types: `PushEvent`, `PullRequestEvent`, `IssuesEvent`, `CreateEvent`, `DeleteEvent`, `WatchEvent`.

### gh-notify.sh — Notifications

```bash
scripts/gh-notify.sh list               # List notifications
scripts/gh-notify.sh read <thread-id>   # Mark as read
```

### gh-api-call.sh — Generic API Call

Direct endpoint access with optional method and body:
```bash
scripts/gh-api-call.sh user
scripts/gh-api-call.sh repos/owner/repo/issues -p
scripts/gh-api-call.sh repos/owner/repo/issues -X POST -d '{"title":"bug"}'
```

## Advanced: Direct API Patterns

When the Python wrapper is unavailable, use raw `curl`:
```bash
TOKEN=$(gh auth token)
curl -s -H "Authorization: token $TOKEN" \
  -H "Accept: application/vnd.github.v3+json" \
  https://api.github.com/<endpoint>
```

POST with `curl`:
```bash
curl -s -X POST -H "Authorization: token $TOKEN" \
  -H "Accept: application/vnd.github.v3+json" \
  -H "Content-Type: application/json" \
  -d '{"body":"..."}' \
  https://api.github.com/repos/<owner>/<repo>/issues/<number>/comments
```

## gh-api.py Flags Reference

The underlying Python wrapper supports these flags:

| Flag | Purpose |
|------|---------|
| `-X METHOD` | HTTP method (GET, POST, PATCH, PUT, DELETE) |
| `-d '{...}'` | JSON request body; prefix with `@` to load from file |
| `-p` | Auto-paginate list endpoints |
| `-c` | Compact JSON output (one line) |
| `-f field` | Extract nested field, e.g. `-f owner.login` |
| `-q` | Quiet mode (no output, exit code only) |

Examples:
```bash
python3 scripts/gh-api.py user -f login
python3 scripts/gh-api.py repos/owner/repo/issues -p -c
python3 scripts/gh-api.py -X PATCH -d '{"state":"closed"}' repos/owner/repo/issues/1
```

## Common API Endpoints

- `user` — authenticated user profile
- `users/{username}` — public user profile
- `users/{username}/repos` — user repositories
- `users/{username}/events/public` — public activity
- `repos/{owner}/{repo}` — repository info
- `repos/{owner}/{repo}/issues` — issues list
- `repos/{owner}/{repo}/pulls` — PRs list
- `repos/{owner}/{repo}/commits` — commits
- `repos/{owner}/{repo}/contents/{path}` — file contents
- `repos/{owner}/{repo}/releases` — releases
- `repos/{owner}/{repo}/actions/runs` — workflow runs
- `notifications` — user notifications

## Workflow: Handling Automated PR Reviews

When Copilot or other bots leave multiple rounds of review comments:

```bash
# 1. See the latest round of comments
scripts/gh-pr-review.sh owner/repo 8 --latest

# 2. See all review rounds
scripts/gh-pr-reviews.sh owner/repo 8

# 3. Fix code locally, commit and push

# 4. Reply to a specific review comment
scripts/gh-pr-reply.sh owner/repo 8 12345678 "Fixed in commit abc123"

# 5. Add a summary comment to the PR
scripts/gh-pr-comment.sh owner/repo 8 --body-file /tmp/review-summary.md

# 6. Loop until review status is APPROVED
```

## Tips

- Issue and PR comments both use `repos/{owner}/{repo}/issues/{number}/comments`.
- PRs are a superset of issues; many PR fields appear under the issue endpoint.
- Use `-p` for any list endpoint that may exceed 30 items (GitHub default page size).
- For file content from the Contents API, the `content` field is Base64 encoded.
- If `gh auth token` hangs or fails, set `GITHUB_TOKEN` environment variable and retry.
- Quick scripts forward to `gh-api.py` internally; if a script does not support a specific flag, call `gh-api.py` directly.
- When writing multi-line comments with backticks or `$`, always use `--body-file` instead of inline `--body` to avoid shell escaping issues.

## Windows Quick Scripts

### gh-user.ps1 — User Profile

```powershell
scripts/windows/gh-user.ps1              # Current authenticated user
```

### gh-repo.ps1 — Repository

```powershell
scripts/windows/gh-repo.ps1 owner/repo view           # Repo details
scripts/windows/gh-repo.ps1 owner/repo issues         # List open issues
scripts/windows/gh-repo.ps1 owner/repo prs            # List open PRs
scripts/windows/gh-repo.ps1 owner/repo commits        # Recent commits
scripts/windows/gh-repo.ps1 owner/repo releases       # Releases
scripts/windows/gh-repo.ps1 owner/repo contents path  # File/directory contents
scripts/windows/gh-repo.ps1 owner/repo url            # Print HTML URL
```

### gh-issue.ps1 — Issues

```powershell
scripts/windows/gh-issue.ps1 owner/repo list                              # List open issues
scripts/windows/gh-issue.ps1 owner/repo view <number>                     # View issue
scripts/windows/gh-issue.ps1 owner/repo create <title> [--body <text>|--body-file <path>]   # Create issue
scripts/windows/gh-issue.ps1 owner/repo close <number>                    # Close issue
scripts/windows/gh-issue.ps1 owner/repo reopen <number>                   # Reopen issue
scripts/windows/gh-issue.ps1 owner/repo comment <number> <body>           # Add comment
```

### gh-pr.ps1 — Pull Requests

```powershell
scripts/windows/gh-pr.ps1 owner/repo list                              # List open PRs
scripts/windows/gh-pr.ps1 owner/repo view <number>                     # View PR
scripts/windows/gh-pr.ps1 owner/repo create <title> <head> <base> [--body <text>|--body-file <path>]  # Create PR
scripts/windows/gh-pr.ps1 owner/repo comments <number>                 # List PR comments
scripts/windows/gh-pr.ps1 owner/repo merge <number> [merge|squash|rebase] # Merge PR
scripts/windows/gh-pr.ps1 owner/repo comment <number> <body>           # Add comment
```

> **Tip**: Use `--body-file` when the PR description contains backticks, quotes, or `$` variables. Typos in `--body-file` paths or unknown options now fail the command instead of creating an incomplete PR.
