# GitHub Operations

A collection of lightweight scripts for interacting with the GitHub REST API.

Now split by platform — because **Windows is not Unix**.

## About

**Author:** [yang12535](https://github.com/yang12535)

This project provides a minimal, dependency-light toolkit for common GitHub workflows:

- **Direct API calls** via Python (`urllib`) or `curl` — no heavy SDK required.
- **Authentication** via `gh auth token` (preferred) or `GITHUB_TOKEN` / `GH_TOKEN` environment variables.
- **Quick scripts** for everyday tasks: viewing repos, issues, PRs, comments, activity feeds, notifications, and git sync helpers.

All scripts are designed to be readable, composable, and easy to extend.

## Platform Split

| Platform | Directory | Runtime | Notes |
|---|---|---|---|
| **Linux / macOS** | `scripts/linux/` | Bash + Python 3 | Original stack, `python3` required |
| **Windows** | `scripts/windows/` | PowerShell 7+ | Thin wrappers → `scripts/gh-api.py`, requires Python 3.8+ |
| **Legacy (generic)** | `scripts/` | Bash + Python 3 | Kept for backward compatibility |

> **Why split?** Windows lab environments often have non-standard Python installs (`D:\python313\python`) and `gh` CLI spits GraphQL deprecation noise. The PowerShell wrappers handle Windows paths natively, then delegate all HTTP/JSON/pagination logic to the shared Python backend (`scripts/gh-api.py`). Python 3.8+ is required on all platforms.

## Quick Start

### Linux / macOS

```bash
# User profile
scripts/linux/gh-user.sh

# Repository info
scripts/linux/gh-repo.sh owner/repo view

# List open issues
scripts/linux/gh-issue.sh owner/repo list
```

### Windows (PowerShell)

```powershell
# User profile
scripts/windows/gh-user.ps1

# Repository info
scripts/windows/gh-repo.ps1 owner/repo view

# List open PRs
scripts/windows/gh-pr.ps1 owner/repo list

# Create PR
scripts/windows/gh-pr.ps1 owner/repo create "title" "head-branch" "main" --body "PR description"
```

See `SKILL.md` for the full command reference and advanced usage patterns.

## License

This work is licensed under the [Creative Commons Attribution 4.0 International License](LICENSE).

You are free to:

- **Share** — copy and redistribute the material in any medium or format
- **Adapt** — remix, transform, and build upon the material for any purpose, even commercially

Under the following terms:

- **Attribution** — You must give appropriate credit, provide a link to the license, and indicate if changes were made.
