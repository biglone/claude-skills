# AI Coding Skills 集合

一个可共享的 AI 编程助手 Skills 仓库，支持 **Claude Code** 和 **OpenAI Codex CLI**，方便团队成员和多设备快速安装使用。

## 支持的平台

| 平台 | Skills 目录 |
|------|-------------|
| Claude Code | `~/.claude/skills/` |
| OpenAI Codex CLI | `~/.codex/skills/` |

## 包含的 Skills

| Skill | 描述 |
|-------|------|
| `code-reviewer` | 代码审查，检查代码质量和最佳实践 |
| `commit-message` | 生成规范的 Git 提交信息 |
| `security-audit` | 安全代码审计，检查常见漏洞 |
| `code-explainer` | 代码解释器，帮助理解代码 |
| `test-generator` | 生成单元测试代码 |
| `refactoring` | 代码重构建议，识别代码异味 |
| `api-designer` | REST/GraphQL API 设计 |
| `doc-generator` | 自动生成代码文档、README |
| `performance-optimizer` | 性能分析和优化建议 |
| `bug-finder` | 调试助手，帮助定位 Bug |
| `regex-helper` | 正则表达式编写和解释 |
| `sql-helper` | SQL 查询编写和优化 |
| `git-helper` | Git 操作指导 |
| `changelog-generator` | 生成 Changelog |
| `pr-description` | 生成 PR 描述 |
| `dependency-analyzer` | 依赖分析和安全检查 |
| `i18n-helper` | 国际化辅助 |
| `migration-helper` | 数据库迁移和框架升级 |
| `technical-writer` | 技术文档写作 |
| `blog-writer` | 博客文章写作 |
| `translator` | 多语言翻译 |
| `data-analyzer` | 数据分析和解读 |
| `chart-generator` | 图表生成和可视化 |
| `concept-explainer` | 概念解释（通俗易懂） |
| `tutorial-creator` | 教程和学习指南创建 |
| `task-planner` | 任务规划和项目分解 |
| `meeting-notes` | 会议记录和纪要整理 |

## 快速安装

运行安装脚本后，会提示选择安装目标（Claude Code / Codex CLI / 两者都安装）。

### macOS / Linux

```bash
curl -fsSL https://raw.githubusercontent.com/biglone/claude-skills/main/scripts/install.sh | bash
```

### Windows (PowerShell)

```powershell
irm https://raw.githubusercontent.com/biglone/claude-skills/main/scripts/install.ps1 | iex
```

### 环境变量配置

通过环境变量控制安装行为：

| 变量 | 值 | 说明 |
|------|-----|------|
| `INSTALL_TARGET` | `claude` / `codex` / `both` | 安装目标平台 |
| `UPDATE_MODE` | `ask` / `skip` / `force` | 已存在 skill 的处理方式 |

**UPDATE_MODE 说明：**
- `ask` (默认): 逐个询问是否更新已存在的 skill
- `skip`: 跳过所有已存在的 skill
- `force`: 强制更新所有 skill

**macOS / Linux:**
```bash
# 只安装到 Claude Code
INSTALL_TARGET=claude curl -fsSL https://raw.githubusercontent.com/biglone/claude-skills/main/scripts/install.sh | bash

# 强制更新所有 skills
UPDATE_MODE=force curl -fsSL https://raw.githubusercontent.com/biglone/claude-skills/main/scripts/install.sh | bash

# 跳过已存在的 skills（静默安装）
UPDATE_MODE=skip INSTALL_TARGET=both curl -fsSL https://raw.githubusercontent.com/biglone/claude-skills/main/scripts/install.sh | bash
```

**Windows:**
```powershell
# 只安装到 Claude Code
$env:INSTALL_TARGET="claude"; irm https://raw.githubusercontent.com/biglone/claude-skills/main/scripts/install.ps1 | iex

# 强制更新所有 skills
$env:UPDATE_MODE="force"; irm https://raw.githubusercontent.com/biglone/claude-skills/main/scripts/install.ps1 | iex
```

### 手动安装

**macOS / Linux:**
```bash
git clone https://github.com/biglone/claude-skills.git

# Claude Code
cp -r claude-skills/skills/* ~/.claude/skills/

# Codex CLI
cp -r claude-skills/skills/* ~/.codex/skills/
```

**Windows:**
```powershell
git clone https://github.com/biglone/claude-skills.git

# Claude Code
Copy-Item -Recurse claude-skills\skills\* $env:USERPROFILE\.claude\skills\

# Codex CLI
Copy-Item -Recurse claude-skills\skills\* $env:USERPROFILE\.codex\skills\
```

## 更新 Skills

**macOS / Linux:**
```bash
curl -fsSL https://raw.githubusercontent.com/biglone/claude-skills/main/scripts/update.sh | bash
```

**Windows:**
```powershell
irm https://raw.githubusercontent.com/biglone/claude-skills/main/scripts/update.ps1 | iex
```

## 卸载 Skills

**macOS / Linux:**
```bash
curl -fsSL https://raw.githubusercontent.com/biglone/claude-skills/main/scripts/uninstall.sh | bash
```

**Windows:**
```powershell
irm https://raw.githubusercontent.com/biglone/claude-skills/main/scripts/uninstall.ps1 | iex
```

## 目录结构

```
claude-skills/
├── README.md
├── skills/
│   ├── code-reviewer/
│   │   └── SKILL.md
│   ├── commit-message/
│   │   └── SKILL.md
│   ├── security-audit/
│   │   └── SKILL.md
│   ├── code-explainer/
│   │   └── SKILL.md
│   └── test-generator/
│       └── SKILL.md
└── scripts/
    ├── install.sh      # macOS / Linux
    ├── install.ps1     # Windows
    ├── update.sh
    ├── update.ps1
    ├── uninstall.sh
    └── uninstall.ps1
```

## 添加新的 Skill

1. 在 `skills/` 目录下创建新文件夹
2. 创建 `SKILL.md` 文件，包含必要的 frontmatter:

```markdown
---
name: my-skill
description: 描述这个 skill 的功能和触发条件
allowed-tools: Read, Grep, Glob
---

# Skill 标题

你的 skill 内容...
```

3. 提交并推送到仓库
4. 其他人运行更新脚本即可获取

## 贡献指南

1. Fork 本仓库
2. 创建你的 Skill 分支 (`git checkout -b skill/my-new-skill`)
3. 提交更改 (`git commit -m 'feat: add my-new-skill'`)
4. 推送到分支 (`git push origin skill/my-new-skill`)
5. 创建 Pull Request

## License

MIT
