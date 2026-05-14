# GitHub 运维工具集

一组轻量级的脚本，用于调用 GitHub REST API。

现已按平台拆分 —— 因为 **Windows 不是 Unix**。

## 简介

**作者：** [yang12535](https://github.com/yang12535)

本项目提供了一套依赖极简的工具集，覆盖日常 GitHub 工作流：

- **直接调用 API**：通过 Python（`urllib`）或 `curl`，无需笨重的 SDK。
- **认证方式**：优先使用 `gh auth token`，也可通过 `GITHUB_TOKEN` / `GH_TOKEN` 环境变量回退。
- **快捷脚本**：查看仓库、议题、PR、评论、活动流、通知，以及 Git 同步辅助。

所有脚本力求可读、可组合、易扩展。

## 平台划分

| 平台 | 目录 | 运行环境 | 说明 |
|---|---|---|---|
| **Linux / macOS** | `scripts/linux/` | Bash + Python 3 | 原版技术栈，需要 `python3` |
| **Windows** | `scripts/windows/` | PowerShell 7+ | 薄包装层 → `scripts/gh-api.py`，需要 Python 3.8+ |
| **旧版（通用）** | `scripts/` | Bash + Python 3 | 保留向后兼容 |

> **为什么要拆分？** Windows 实验环境的 Python 安装路径往往不标准（比如 `D:\python313\python`），而且 `gh` CLI 经常输出 GraphQL 弃用警告。PowerShell 包装层原生处理 Windows 路径，然后把所有 HTTP/JSON/分页逻辑委托给共享的 Python 后端（`scripts/gh-api.py`）。所有平台均需要 Python 3.8+。

## 快速开始

### Linux / macOS

```bash
# 用户资料
scripts/linux/gh-user.sh

# 仓库信息
scripts/linux/gh-repo.sh owner/repo view

# 列出开放议题
scripts/linux/gh-issue.sh owner/repo list
```

### Windows（PowerShell）

```powershell
# 用户资料
scripts/windows/gh-user.ps1

# 仓库信息
scripts/windows/gh-repo.ps1 owner/repo view

# 列出开放 PR
scripts/windows/gh-pr.ps1 owner/repo list

# 创建 PR
scripts/windows/gh-pr.ps1 owner/repo create "标题" "head-branch" "main" --body "PR 描述"
```

完整命令参考与高级用法请见 `SKILL.md`。

## 许可证

本作品采用 [Creative Commons Attribution 4.0 International License](LICENSE) 授权。

您可以：

- **共享** — 以任何媒介或格式复制、 redistribute 本材料
- **改编** — 再混音、转换、基于本材料进行创作，包括商业用途

需遵守以下条款：

- **署名** — 您必须给出适当的署名，提供许可证链接，并注明是否做了修改。
