# GitHub Operations

A collection of lightweight Bash and Python scripts for interacting with the GitHub REST API.

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

See `SKILL.md` for the full command reference and advanced usage patterns.

## License

This work is licensed under the [Creative Commons Attribution 4.0 International License](LICENSE).

You are free to:

- **Share** — copy and redistribute the material in any medium or format
- **Adapt** — remix, transform, and build upon the material for any purpose, even commercially

Under the following terms:

- **Attribution** — You must give appropriate credit, provide a link to the license, and indicate if changes were made.
