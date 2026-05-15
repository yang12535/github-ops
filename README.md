<div align="center">

# 🛠️ GitHub Ops

**轻量级 GitHub 运维工具集 — 零依赖、跨平台、AI 友好**

[![License](https://img.shields.io/badge/License-CC%20BY%204.0-orange.svg)](LICENSE)
[![Platform](https://img.shields.io/badge/Platform-Linux%20%7C%20macOS%20%7C%20Windows-blue.svg)](#-快速开始)
[![Python](https://img.shields.io/badge/Python-3.8%2B-green.svg)](https://www.python.org/)
[![Zero Dependencies](https://img.shields.io/badge/Dependencies-None-brightgreen.svg)](#技术亮点)

</div>

---

## 📖 简介

一组**零第三方依赖**的脚本工具，通过 GitHub REST API 直接操作仓库、Issue、PR、评论等，覆盖日常 GitHub 工作流。

**为什么不用 `gh` CLI？**
- `gh` 在 Windows 上经常输出 GraphQL 弃用警告
- `gh` 依赖复杂，某些环境无法安装
- 你需要**更细粒度的 API 控制**和**可组合的脚本**

> 💡 **注意**：下文推荐用 `gh auth login` 获取 token，但 `gh` CLI 本身是**可选的**。不安装时，可用环境变量或 token 文件完成认证。

**设计哲学**：
- **薄包装层** — Bash/PowerShell 只做参数解析，HTTP/JSON/分页逻辑全部委托给共享 Python 后端
- **失败即指令** — 遇到缺失依赖时，输出清晰的修复指令，不猜测、不静默失败
- **AI 原生** — 完整的 `SKILL.md` 供 AI Agent 直接消费

---

## ✨ 功能特性

### 核心脚本功能矩阵（12 个用户入口）

| 脚本 | 功能 | Linux/macOS | Windows |
|------|------|:-----------:|:-------:|
| `gh-user` | 查看用户资料 | ✅ | ✅ |
| `gh-repo` | 仓库信息 / Issues / PRs / Commits / Releases | ✅ | ✅ |
| `gh-issue` | 创建 / 关闭 / 重开 / 评论 Issue | ✅ | ✅ |
| `gh-pr` | 创建 / 合并 / 评论 PR | ✅ | ✅ |
| `gh-pr-review` | 查看 PR Review 评论（支持多轮过滤） | ✅ | ❌ |
| `gh-pr-reviews` | PR Review 摘要统计 | ✅ | ❌ |
| `gh-pr-reply` | 回复指定 Review 评论 | ✅ | ❌ |
| `gh-comment` | 快速评论（Issue/PR 通用） | ✅ | ❌ |
| `gh-activity` | 用户活动流查询（支持事件过滤） | ✅ | ❌ |
| `gh-notify` | 查看 / 标记已读通知 | ✅ | ❌ |
| `gh-push` / `gh-pull` | Git 同步辅助 | ✅ | ❌ |
| `gh-api-call` | 通用 API 调用（任意端点） | ✅ | ❌ |

### 技术亮点

- **🚀 无 Python 第三方依赖** — 仅用标准库 `urllib`，无需 `requests`、`httpx`（需 Bash/PowerShell + Python 3）
- **📄 自动分页** — 列表接口自动翻页，告别 `Link: rel="next"` 手动处理
- **🎯 字段过滤** — 支持 `owner.login`、`0.name` 等点号路径提取，减少 JSON 噪音
- **🔐 安全认证** — Token 文件权限检查（Linux: `S_IRWXG|S_IRWXO` / Windows: ACL）
- **🔑 多级回退** — `gh auth token` → `GITHUB_TOKEN`/`GH_TOKEN` → `~/.github_token`
- **🐍 统一后端** — `scripts/gh-api.py` 处理所有 HTTP/JSON/分页逻辑，各平台包装器统一引用（Windows 通过 `../gh-api.py` 引用）

---

## 🚀 快速开始

### 环境要求

- **Linux / macOS**: Bash + Python 3.8+
- **Windows**: PowerShell 7+ + Python 3.8+

### 1. 克隆仓库

```bash
git clone https://github.com/yang12535/github-ops.git
cd github-ops
```

### 2. 配置认证（三选一）

**方式 A — 推荐**：使用 GitHub CLI
```bash
gh auth login
```

**方式 B**：环境变量
```bash
export GITHUB_TOKEN="ghp_xxxxxxxx"
```

**方式 C**：私有 token 文件
```bash
echo "ghp_xxxxxxxx" > ~/.github_token
chmod 600 ~/.github_token
```

### 3. 跑起来！

**Linux / macOS**（Bash 脚本）
```bash
# 查看当前用户
./scripts/linux/gh-user.sh

# 查看仓库信息
./scripts/linux/gh-repo.sh yang12535/github-ops view

# 列出开放 Issues
./scripts/linux/gh-issue.sh yang12535/github-ops list

# 查看最近活动
./scripts/linux/gh-activity.sh yang12535 10
```

**Windows**（PowerShell 7+ 脚本）
```powershell
# 查看当前用户
./scripts/windows/gh-user.ps1

# 查看仓库信息
./scripts/windows/gh-repo.ps1 yang12535/github-ops view

# 列出开放 PRs
./scripts/windows/gh-pr.ps1 yang12535/github-ops list
```

---

## 📁 项目结构

```
github-ops/
├── scripts/                  # 旧版通用脚本（向后兼容）
│   ├── gh-api.py            # 🐍 核心 API 引擎（分页/字段过滤/认证）
│   ├── gh-user.sh           # 用户资料查询
│   ├── gh-repo.sh           # 仓库操作
│   ├── gh-issue.sh          # Issue 管理
│   ├── gh-pr.sh             # PR 管理
│   ├── gh-pr-review.sh      # PR Review 评论查看
│   ├── gh-comment.sh        # 通用评论
│   ├── gh-activity.py       # 活动流查询
│   └── ...
├── scripts/linux/           # Linux / macOS 平台脚本
├── scripts/windows/         # Windows PowerShell 脚本
│   ├── _common.ps1          # 认证 + API 调用共享模块
│   ├── gh-user.ps1
│   ├── gh-repo.ps1
│   ├── gh-issue.ps1
│   └── gh-pr.ps1
├── tests/                   # 测试用例
├── SKILL.md                 # 🤖 AI Agent 使用文档
├── README.md                # 本文档
├── CHANGELOG.md             # 更新日志
└── LICENSE                  # CC BY 4.0
```

---

## 🔧 高级用法

### 通用 API 调用

```bash
# GET 请求
./scripts/gh-api-call.sh user

# POST 请求创建 Issue
./scripts/gh-api-call.sh repos/owner/repo/issues -X POST \
  -d '{"title":"bug","body":"something broke"}'

# 自动分页（需 Python 后端支持；curl fallback 不支持分页）
./scripts/gh-api-call.sh repos/owner/repo/issues -p

# 字段过滤（直接调用 Python 后端）
python3 scripts/gh-api.py repos/owner/repo/issues -p -f "0.title"
```

### Python 底层引擎

```bash
# 查询并提取字段
python3 scripts/gh-api.py repos/owner/repo -f owner.login

# 自动分页获取所有 Issues
python3 scripts/gh-api.py repos/owner/repo/issues -p -c

# PATCH 更新 Issue
python3 scripts/gh-api.py -X PATCH -d '{"state":"closed"}' \
  repos/owner/repo/issues/1
```

### PR Review 工作流

```bash
# 查看最新一轮 Review 评论
./scripts/gh-pr-review.sh owner/repo 8 --latest

# 查看全部 Review 轮次摘要
./scripts/gh-pr-reviews.sh owner/repo 8

# 回复指定评论
./scripts/gh-pr-reply.sh owner/repo 8 12345678 "Fixed in commit abc"
```

---

## 🔐 安全说明

### Token 存储

| 优先级 | 来源 | 说明 |
|--------|------|------|
| 1 | `gh auth token` | 最安全，推荐（`gh` CLI 可选） |
| 2 | `GITHUB_TOKEN` / `GH_TOKEN` | 环境变量，CI/CD 常用 |
| 3 | `~/.github_token` | 私有文件，**必须限制权限** |
| 4 | `~/.config/github-ops/token` | 备选私有文件 |
| 5 | `~/github_token.txt` | 备选私有文件（向后兼容） |

### 文件权限检查

- **Linux/macOS**: 拒绝 `group` 或 `others` 有任何权限的 token 文件（读/写/执行均不允许）
- **Windows**: 拒绝 `Users`/`Everyone`/`Authenticated Users` 可读取的 token 文件

```bash
# 正确示例
chmod 600 ~/.github_token
```

---

## 🆚 与 `gh` CLI 对比

| 能力 | `gh` CLI | github-ops |
|------|:--------:|:----------:|
| 安装依赖 | 需要安装 `gh` | 只需 Python 3 |
| Windows 兼容性 | GraphQL 警告 | 原生 PowerShell |
| 脚本组合 | 受限 | 完全可组合 |
| API 粒度 | 高层封装 | 直接访问 REST API |
| AI Agent 消费 | 无结构化文档 | 完整 `SKILL.md` |
| 字段过滤 | ❌ | ✅ 点号路径 |
| 自动分页 | 部分支持 | ✅ 完整支持 |

---

## 🧪 测试与验证

```bash
# Shell 脚本语法检查
find scripts -name "*.sh" -exec bash -n {} \;

# Python 编译检查（含 scripts/ 与 scripts/linux/）
find scripts -name "*.py" -exec python3 -m py_compile {} \;

# PowerShell 语法检查（Windows）
Get-ChildItem scripts/windows -Filter "*.ps1" | ForEach-Object {
    $null = [System.Management.Automation.PSParser]::Tokenize(
        (Get-Content $_.FullName -Raw), [ref]$null
    )
}
```

---

## 🤝 贡献

欢迎 Issue 和 PR！提交前请确保：

1. **脚本逻辑同步**：修改 `scripts/` 或 `scripts/linux/` 下的 `.py` 逻辑时，需同步更新另一份副本（当前为复制关系，未来可考虑 symlink）
2. Windows 脚本与 Bash 脚本同步更新
3. 更新 `SKILL.md` 和 `README.md`
4. 新增脚本需补充到本表格

---

## 📜 License

本作品采用 [Creative Commons Attribution 4.0 International License](LICENSE) 授权。

您可以自由地共享和改编，只需适当署名。

---

<div align="center">

**⭐ 如果这个项目对你有帮助，请点个 Star！**

</div>
