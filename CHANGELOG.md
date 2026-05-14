# Changelog

All notable changes to this project will be documented in this file.

## [Unreleased]

### Added
- **Windows PowerShell port** (`scripts/windows/`):
  - `gh-api.ps1` — pure PowerShell API wrapper using `Invoke-RestMethod`, no Python required
  - `gh-user.ps1` / `gh-repo.ps1` / `gh-issue.ps1` / `gh-pr.ps1` — PowerShell equivalents of core Bash scripts
  - Auth fallback chain: `gh auth token` → `GITHUB_TOKEN`/`GH_TOKEN` env → `~/.github_token` file → `~/.config/github-ops/token` → `~/github_token.txt`
- Token file fallback in `scripts/gh-api.py` for lab/revert environments (`~/.github_token`, `~/.config/github-ops/token`, etc.)
- Platform split: `scripts/linux/` (Bash+Python) and `scripts/windows/` (PowerShell)

### Changed
- README updated with platform-specific quick start examples

### Fixed
- `gh-pr-review.sh`: handle `null` `pull_request_review_id` and `user` fields from GitHub API
- `gh-pr-reviews.sh`: handle `null` `user` field from GitHub API

## [1.0.0] - 2026-05-13

### Added
- Core API wrapper `scripts/gh-api.py` (Python/urllib, no heavy SDK required)
- Bash quick scripts for common GitHub workflows:
  - `gh-user.sh` — user profile lookup
  - `gh-repo.sh` — repository info, issues, PRs, commits, releases, contents
  - `gh-issue.sh` — issue list/view/create/close/reopen/comment
  - `gh-pr.sh` — PR list/view/create/comments/merge/comment
  - `gh-comment.sh` / `gh-comment.py` — quick comment on issues/PRs
  - `gh-activity.sh` / `gh-activity.py` — user activity feed
  - `gh-notify.sh` — notifications list/read
  - `gh-push.sh` / `gh-pull.sh` — git sync helpers
  - `gh-api-call.sh` — generic API endpoint access
  - `gh-push-check.py` — pre-push remote status check
- PR review helpers:
  - `gh-pr-review.sh` — view PR review comments grouped by review round
  - `gh-pr-reviews.sh` — summary of all review rounds
  - `gh-pr-reply.sh` — reply to specific review comments
- Full command reference in `SKILL.md`

### Changed
- `gh-issue.sh` and `gh-pr.sh` `create` commands support `--body` and `--body-file` flags
- `gh-comment.sh` supports `--body` and `--body-file` flags
