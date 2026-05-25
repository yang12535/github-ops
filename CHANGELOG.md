# 更新日志

本项目的所有重要变更均记录于此。

## [未发布]

### 新增
- **Windows PowerShell 移植版**（`scripts/windows/`）：
  - `scripts/windows/*.ps1` — 薄 PowerShell 包装层，委托给 `scripts/gh-api.py`（Python 后端）；需要 Python 3.7+
  - `_common.ps1` — 共享辅助函数，负责构建参数并调用 Python 后端
  - `gh-user.ps1` / `gh-repo.ps1` / `gh-issue.ps1` / `gh-pr.ps1` — 核心 Bash 脚本的 PowerShell 等价物
  - 认证回退链：`gh auth token` → `GITHUB_TOKEN`/`GH_TOKEN` 环境变量 → `~/.github_token` 文件 → `~/.config/github-ops/token` → `~/github_token.txt`
- `scripts/gh-api.py` 增加 token 文件回退，用于实验室/回滚环境（`~/.github_token`、`~/.config/github-ops/token` 等）
- 平台拆分：`scripts/linux/`（Bash+Python）和 `scripts/windows/`（PowerShell）

### 变更
- README 已更新，增加各平台快速上手指南
- Windows 文档改为使用 `py -3` / `python`，不再假设存在 `py3` 或 `python3`

### 修复
- Windows Python 探测优先使用 `py -3`，避免 bare `py` 被 `py.ini`/`PY_PYTHON` 配置到 Python 2
- Python API 后端代理处理改用 `urllib.request.getproxies()`，保留小写代理变量覆盖大写变量的标准优先级
- Windows PowerShell 包装器改用 .NET UTF-8 无 BOM 写文件，兼容 Windows PowerShell 5.1
- `gh-pr-review.sh`：处理 GitHub API 返回的 `null` 类型 `pull_request_review_id` 和 `user` 字段
- `gh-pr-reviews.sh`：处理 GitHub API 返回的 `null` 类型 `user` 字段

## [1.0.0] - 2026-05-13

### 新增
- 核心 API 包装层 `scripts/gh-api.py`（Python/urllib，无需重型 SDK）
- Bash 快捷脚本，覆盖常见 GitHub 工作流：
  - `gh-user.sh` — 用户资料查询
  - `gh-repo.sh` — 仓库信息、议题、PR、提交记录、发行版、目录内容
  - `gh-issue.sh` — 议题的列出/查看/创建/关闭/重开/评论
  - `gh-pr.sh` — PR 的列出/查看/创建/评论/合并/评论
  - `gh-comment.sh` / `gh-comment.py` — 在议题/PR 上快速评论
  - `gh-activity.sh` / `gh-activity.py` — 用户活动流
  - `gh-notify.sh` — 通知的列出/标为已读
  - `gh-push.sh` / `gh-pull.sh` — Git 同步辅助
  - `gh-api-call.sh` — 通用 API 端点访问
  - `gh-push-check.py` — 推送前远程状态检查
- PR Review 辅助工具：
  - `gh-pr-review.sh` — 按 review 轮次分组查看 review 评论
  - `gh-pr-reviews.sh` — 所有 review 轮次的摘要
  - `gh-pr-reply.sh` — 回复指定 review 评论
- 完整命令参考见 `SKILL.md`

### 变更
- `gh-issue.sh` 与 `gh-pr.sh` 的 `create` 命令支持 `--body` 和 `--body-file` 参数
- `gh-comment.sh` 支持 `--body` 和 `--body-file` 参数
