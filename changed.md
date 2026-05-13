# github-ops Skill Change Log

## Changelog

### 2026-05-12
- **Added** `gh-pr-review.sh` — view PR review comments grouped by review round, with `--latest` and `--user` filters.
- **Added** `gh-pr-reviews.sh` — quick summary of all PR review rounds (state + comment count).
- **Added** `gh-pr-reply.sh` — reply to a specific PR review comment via the replies API.
- **Improved** `gh-comment.py` / `gh-comment.sh` — added `--body` and `--body-file` flags. The shell script now supports backward-compatible positional args while recommending `--body-file` for complex text with backticks/quotes/$.
- **Updated** `SKILL.md` — added new script documentation and a "Workflow: Handling Automated PR Reviews" section.
- **Fixed** ISSUE-001 (partially) — complex comments can now be passed safely via `--body-file` without shell escaping issues.

### 2026-05-11
- **Created** `github-ops` skill with curl-auth-api as primary method.
- Added core wrapper `scripts/gh-api.py` (Python/urllib, no jq dependency).
- Added bash quick scripts for common workflows:
  - `gh-user.sh`, `gh-repo.sh`, `gh-issue.sh`, `gh-pr.sh`
  - `gh-comment.sh`, `gh-activity.sh`, `gh-notify.sh`
  - `gh-push.sh`, `gh-pull.sh`, `gh-api-call.sh`
- Added `scripts/gh-push-check.py` for pre-push remote status check.
- Added `scripts/gh-comment.py` and `scripts/gh-activity.py` for Python-based helpers.
- Updated `SKILL.md` to document both quick scripts and direct API patterns.
- **Fixed** `gh-api.py` paginate bug: missing `urllib.parse` import and `None` Content-Type header.
- **Fixed** `gh-api-call.sh` syntax error in usage example single-quote nesting.

## Todo

- [ ] Add `gh-release.sh` quick script for release create/list/delete.
- [ ] Add `gh-actions.sh` quick script for workflow run list/view logs.
- [ ] Add `gh-file.sh` for read/update/delete repository files via Contents API.
- [ ] Add search support (`search/issues`, `search/repos`).
- [ ] Consider adding `gh fork` helper.

## 2026-05-13

- **Improved** `gh-pr.sh` — `create` command now supports `--body` and `--body-file` flags (backward-compatible positional body still works). Added new `comments` command to list regular PR/issue comments.
- **Improved** `gh-issue.sh` — `create` command now supports `--body` and `--body-file` flags (backward-compatible positional body still works).
- **Improved** `gh-pr-review.sh` — added `--full` option to display complete comment bodies instead of the default 150-char truncation.
- **Updated** `SKILL.md` — documented new flags, `comments` command, and `--full` option.
- **Fixed** ISSUE-001 (fully) — `create` commands in `gh-pr.sh` and `gh-issue.sh` now support `--body-file` for complex text with backticks/quotes/$ without shell escaping issues.

## Issues (Reserved)

- [x] **ISSUE-001**: Quick scripts with `create` commands do not escape double quotes in titles/bodies. Complex strings with `"` will break JSON parsing. **Workaround improved**: use `gh-comment.sh --body-file` for safe multi-line/quoted text. Direct script `create` commands still need `@file` support.
- [ ] **ISSUE-002**: `gh-push-check.py` runs `git fetch` which may be slow on large repos. No timeout is set.
- [ ] **ISSUE-003**: No rate-limit handling in `gh-api.py`. If GitHub returns 403 rate-limit, the error is returned raw without retry or backoff.
- [ ] **ISSUE-004**: `gh-activity.sh` only supports public events for other users; private events for the authenticated user require a different endpoint but are not differentiated in the script help.
