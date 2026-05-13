# GitHub Operations

**🚀 Agent-First GitHub Ops Toolkit**  
*Minimal Bash + Python scripts for GitHub REST API — perfect for AI agents and power users*

## Agent-First Design (by Grok)

This toolkit is **explicitly Agent-First**:

> “专为 AI Agent / Copilot / 自动化 Bot 设计的最小化 GitHub 操作工具箱。零依赖、可组合、专治 LLM 转义难题。”

- **Zero external dependencies** — runs anywhere (no PyGithub, no octokit)
- **LLM-safe** — `--body-file`, `--json` outputs, no colorful logs in quiet mode
- **Multi-round PR review loops** — built for Copilot-style bots (see SKILL.md)
- **Composable** — every script is a thin wrapper around `gh-api.py`

**Target users:**
- GitHub Copilot / Devin / Aider / Cursor agents
- Custom LLM agents using `subprocess`
- Power users who prefer `curl` + `jq` over heavy SDKs

---

## About

**Author:** [yang12535](https://github.com/yang12535)

This project provides a minimal, dependency-light toolkit for common GitHub workflows:

- **Direct API calls** via Python (`urllib`) or `curl` — no heavy SDK required.
- **Authentication** via `gh auth token` (preferred) or `GITHUB_TOKEN` / `GH_TOKEN` environment variables.
- **Quick scripts** for everyday tasks: viewing repos, issues, PRs, comments, activity feeds, notifications, and git sync helpers.

All scripts are designed to be readable, composable, and easy to extend.

## Quick Start

```bash
# User profile
scripts/gh-user.sh

# Repository info
scripts/gh-repo.sh owner/repo view

# List open issues
scripts/gh-issue.sh owner/repo list

# Comment on an issue or PR
scripts/gh-comment.sh owner/repo 1 "LGTM"

# View recent activity
scripts/gh-activity.sh <username> 20
```

See `SKILL.md` for the full command reference and advanced usage patterns (including agent-specific workflows).

## License

This work is licensed under the [Creative Commons Attribution 4.0 International License](LICENSE).

You are free to:

- **Share** — copy and redistribute the material in any medium or format
- **Adapt** — remix, transform, and build upon the material for any purpose, even commercially

Under the following terms:

- **Attribution** — You must give appropriate credit, provide a link to the license, and indicate if changes were made.
