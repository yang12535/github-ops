---
name: github-ops
description: "通过已认证的 REST API（curl/urllib）进行 GitHub 仓库与工作流操作，以 gh CLI 作为认证回退。适用于以下场景：(1) 查看或浏览仓库，(2) 克隆/拉取/推送代码，(3) 创建或管理 Pull Request，(4) 在议题或 PR 下评论，(5) 查看用户活动流或通知，(6) 访问 GitHub 用户/组织资料，(7) 检查仓库设置、发行版或 Actions 运行记录。遇到任何 GitHub 相关任务时均可触发，尤其在 gh CLI 不可靠或用户倾向于直接调用 API 时。"
---

# GitHub 运维工具集

**主要方式**：通过 `scripts/gh-api.py`（Python/urllib）或直接 `curl` 调用 GitHub REST API。
**快捷脚本**：`scripts/gh-*.sh` 为常见任务提供便利封装。
**认证来源**：`gh auth token`（优先）→ `GITHUB_TOKEN` / `GH_TOKEN` 环境变量回退。仅在 token 缺失时才需要执行 `gh auth login` 重新认证。

## 快速开始

```bash
# 当前认证用户资料
scripts/gh-user.sh

# 查看仓库
scripts/gh-repo.sh owner/repo view

# 列出开放议题
scripts/gh-issue.sh owner/repo list

# 在议题或 PR 下评论
scripts/gh-comment.sh owner/repo 1 "LGTM"

# 查看近期活动
scripts/gh-activity.sh username 20
```

## 认证

所有脚本会自动解析 token。如果 `gh` 完全不可用，请手动导出 token：
```bash
export GITHUB_TOKEN="ghp_xxxxxxxx"
```

验证 token 是否生效：
```bash
scripts/gh-user.sh
```

## Bash 快捷脚本

### gh-user.sh — 用户资料

```bash
scripts/gh-user.sh              # 当前认证用户
scripts/gh-user.sh <用户名>      # 指定用户资料
```

### gh-repo.sh — 仓库

```bash
scripts/gh-repo.sh <owner/repo> view           # 仓库详情
scripts/gh-repo.sh <owner/repo> issues         # 列出开放议题
scripts/gh-repo.sh <owner/repo> prs            # 列出开放 PR
scripts/gh-repo.sh <owner/repo> commits        # 近期提交
scripts/gh-repo.sh <owner/repo> releases       # 发行版
scripts/gh-repo.sh <owner/repo> contents <路径> # 文件/目录内容
scripts/gh-repo.sh <owner/repo> url            # 输出 HTML 链接
```

克隆仓库：
```bash
git clone https://github.com/<owner>/<repo>.git
```

### gh-issue.sh — 议题

```bash
scripts/gh-issue.sh <owner/repo> list                              # 列出开放议题
scripts/gh-issue.sh <owner/repo> view <编号>                        # 查看议题
scripts/gh-issue.sh <owner/repo> create <标题> [--body <文本>|--body-file <路径>]   # 创建议题
scripts/gh-issue.sh <owner/repo> close <编号>                       # 关闭议题
scripts/gh-issue.sh <owner/repo> reopen <编号>                      # 重开议题
scripts/gh-issue.sh <owner/repo> comment <编号> <正文>               # 添加评论
```

> **提示**：当议题正文包含反引号、引号或 `$` 变量时，请使用 `--body-file` 以避免 shell 解析错误。为兼容旧版，仍支持位置参数传递正文。

### gh-pr.sh — Pull Request

```bash
scripts/gh-pr.sh <owner/repo> list                              # 列出开放 PR
scripts/gh-pr.sh <owner/repo> view <编号>                        # 查看 PR
scripts/gh-pr.sh <owner/repo> create <标题> <head> <base> [--body <文本>|--body-file <路径>]  # 创建 PR
scripts/gh-pr.sh <owner/repo> comments <编号>                    # 列出 PR 评论
scripts/gh-pr.sh <owner/repo> merge <编号> [merge|squash|rebase]  # 合并 PR
scripts/gh-pr.sh <owner/repo> comment <编号> <正文>               # 添加评论
```

> **提示**：当 PR 描述包含反引号、引号或 `$` 变量时，请使用 `--body-file` 以避免 shell 解析错误。为兼容旧版，仍支持位置参数传递正文。

> **注意**：`comments` 列出的是常规议题/PR 评论（非 review 评论）。如需查看 review 评论，请使用 `gh-pr-review.sh`。

### gh-pr-review.sh — PR Review 评论

按 review 轮次分组查看 review 评论：
```bash
scripts/gh-pr-review.sh <owner/repo> <编号>                # 所有 review 评论（截断显示）
scripts/gh-pr-review.sh <owner/repo> <编号> --latest       # 仅最新一轮
scripts/gh-pr-review.sh <owner/repo> <编号> --full         # 显示完整评论正文
scripts/gh-pr-review.sh <owner/repo> <编号> --user Copilot # 按 reviewer 过滤
```

### gh-pr-reviews.sh — PR Reviews 摘要

快速查看所有 review 轮次的摘要（状态 + 评论数）：
```bash
scripts/gh-pr-reviews.sh <owner/repo> <编号>
```

### gh-pr-reply.sh — 回复 Review 评论

```bash
scripts/gh-pr-reply.sh <owner/repo> <pr-编号> <评论id> "已在 commit abc 中修复"
```

### gh-comment.sh — 快速评论

同时适用于议题和 PR：
```bash
scripts/gh-comment.sh <owner/repo> <编号> <正文>                  # 位置参数（旧版）
scripts/gh-comment.sh <owner/repo> <编号> --body-file comment.md  # 从文件读取（推荐）
scripts/gh-comment.sh <owner/repo> <编号> --body "LGTM"           # 显式参数
```

> **提示**：当评论包含反引号、引号或 `$` 变量时，请使用 `--body-file` 以避免 shell 解析错误。

### gh-push.sh / gh-pull.sh — Git 同步

```bash
scripts/gh-pull.sh              # git pull
scripts/gh-pull.sh origin main  # git pull origin main

scripts/gh-push.sh              # 检查远程状态，然后推送
scripts/gh-push.sh feature-x    # 推送指定分支
```

### gh-activity.sh — 活动流

```bash
scripts/gh-activity.sh                    # 当前用户活动
scripts/gh-activity.sh <用户名> 20         # 最近 20 条事件
scripts/gh-activity.sh <用户名> 30 PushEvent  # 按事件类型过滤
```

常见事件类型：`PushEvent`、`PullRequestEvent`、`IssuesEvent`、`CreateEvent`、`DeleteEvent`、`WatchEvent`。

### gh-notify.sh — 通知

```bash
scripts/gh-notify.sh list               # 列出通知
scripts/gh-notify.sh read <thread-id>   # 标为已读
```

### gh-api-call.sh — 通用 API 调用

直接访问端点，可选指定方法与请求体：
```bash
scripts/gh-api-call.sh user
scripts/gh-api-call.sh repos/owner/repo/issues -p
scripts/gh-api-call.sh repos/owner/repo/issues -X POST -d '{"title":"bug"}'
```

## 高级用法：直接调用 API

当 Python 包装层不可用时，使用原生 `curl`：
```bash
TOKEN=$(gh auth token)
curl -s -H "Authorization: token $TOKEN" \
  -H "Accept: application/vnd.github.v3+json" \
  https://api.github.com/<端点>
```

用 `curl` 发送 POST 请求：
```bash
curl -s -X POST -H "Authorization: token $TOKEN" \
  -H "Accept: application/vnd.github.v3+json" \
  -H "Content-Type: application/json" \
  -d '{"body":"..."}' \
  https://api.github.com/repos/<owner>/<repo>/issues/<编号>/comments
```

## gh-api.py 参数参考

底层 Python 包装层支持以下参数：

| 参数 | 用途 |
|------|------|
| `-X METHOD` | HTTP 方法（GET、POST、PATCH、PUT、DELETE） |
| `-d '{...}'` | JSON 请求体；以 `@` 开头表示从文件加载 |
| `-p` | 自动分页（用于列表端点） |
| `-c` | 紧凑 JSON 输出（单行） |
| `-f field` | 提取嵌套字段，例如 `-f owner.login` |
| `-q` | 静默模式（无输出，仅返回退出码） |

示例：
```bash
python3 scripts/gh-api.py user -f login
python3 scripts/gh-api.py repos/owner/repo/issues -p -c
python3 scripts/gh-api.py -X PATCH -d '{"state":"closed"}' repos/owner/repo/issues/1
```

## 常用 API 端点

- `user` — 认证用户资料
- `users/{username}` — 公开用户资料
- `users/{username}/repos` — 用户仓库列表
- `users/{username}/events/public` — 公开活动
- `repos/{owner}/{repo}` — 仓库信息
- `repos/{owner}/{repo}/issues` — 议题列表
- `repos/{owner}/{repo}/pulls` — PR 列表
- `repos/{owner}/{repo}/commits` — 提交记录
- `repos/{owner}/{repo}/contents/{path}` — 文件内容
- `repos/{owner}/{repo}/releases` — 发行版
- `repos/{owner}/{repo}/actions/runs` — 工作流运行记录
- `notifications` — 用户通知

## 工作流：处理自动化 PR Review

当 Copilot 或其他机器人留下多轮 review 评论时：

```bash
# 1. 查看最新一轮评论
scripts/gh-pr-review.sh owner/repo 8 --latest

# 2. 查看所有 review 轮次
scripts/gh-pr-reviews.sh owner/repo 8

# 3. 本地修复代码，提交并推送

# 4. 回复指定 review 评论
scripts/gh-pr-reply.sh owner/repo 8 12345678 "已在 commit abc123 中修复"

# 5. 在 PR 下添加总结评论
scripts/gh-pr-comment.sh owner/repo 8 --body-file /tmp/review-summary.md

# 6. 循环直到 review 状态变为 APPROVED
```

## 使用技巧

- 议题评论与 PR 评论均使用 `repos/{owner}/{repo}/issues/{编号}/comments`。
- PR 是议题的超集；许多 PR 字段也出现在议题端点下。
- 对于可能超过 30 条的列表端点（GitHub 默认分页大小），请使用 `-p`。
- 从 Contents API 获取的文件内容中，`content` 字段为 Base64 编码。
- 如果 `gh auth token` 卡住或失败，请设置 `GITHUB_TOKEN` 环境变量后重试。
- 快捷脚本内部均委托给 `gh-api.py`；如果某个脚本不支持特定参数，请直接调用 `gh-api.py`。
- 编写包含反引号或 `$` 的多行评论时，请始终使用 `--body-file`，而非行内 `--body`，以避免 shell 转义问题。
