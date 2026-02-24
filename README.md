# AI Skills 集合

一个可共享的 AI 助手 Skills 仓库，支持 **Claude Code** 和 **OpenAI Codex CLI**，方便团队成员和多设备快速安装使用。

## 支持的平台

| 平台 | Skills 目录 |
|------|-------------|
| Claude Code | `~/.claude/skills/` |
| OpenAI Codex CLI | `~/.codex/skills/` |

## 包含的 Skills

### 编程开发类

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
| `requirements-doc` | 需求文档生成器，将简单需求转换为结构化文档和任务列表 |

### 写作与翻译类

| Skill | 描述 |
|-------|------|
| `technical-writer` | 技术文档写作 |
| `blog-writer` | 博客文章写作 |
| `translator` | 多语言翻译 |
| `email-writer` | 邮件撰写和优化 |
| `presentation-maker` | 演示文稿结构和内容设计 |

### 数据与分析类

| Skill | 描述 |
|-------|------|
| `data-analyzer` | 数据分析和解读 |
| `chart-generator` | 图表生成和可视化 |

### 学习与知识管理类

| Skill | 描述 |
|-------|------|
| `concept-explainer` | 概念解释（通俗易懂） |
| `tutorial-creator` | 教程和学习指南创建 |
| `note-taker` | 笔记整理和知识提取 |
| `knowledge-base` | 个人知识库管理 |
| `learning-tracker` | 学习进度追踪和计划管理 |

### 个人效率类

| Skill | 描述 |
|-------|------|
| `task-planner` | 任务规划和项目分解 |
| `meeting-notes` | 会议记录和纪要整理 |
| `weekly-review` | 周报生成和周期性回顾 |
| `goal-setter` | 目标设定和拆解（SMART/OKR） |
| `habit-tracker` | 习惯追踪和养成 |
| `decision-maker` | 决策辅助和分析 |

### 职业发展类

| Skill | 描述 |
|-------|------|
| `resume-builder` | 简历撰写和优化 |
| `interview-helper` | 面试准备和模拟 |
| `career-planner` | 职业规划和发展 |
| `feedback-giver` | 反馈给予和接收 |

### 创意思考类

| Skill | 描述 |
|-------|------|
| `brainstormer` | 头脑风暴和创意发散 |
| `outline-creator` | 大纲创建和结构化 |
| `mind-mapper` | 思维导图和可视化思维 |

### 自动化类

| Skill | 描述 |
|-------|------|
| `autonomous-dev` | 自主开发模式，自动完成从需求到提交的完整流程 |
| `auto-code-pipeline` | 自动代码流水线，lint → test → review 自动执行 |
| `auto-fix-loop` | 自动修复循环，持续修复直到测试/构建通过 |

## Workflows 工作流

工作流将多个相关的 Skills 串联起来，形成完整的工作流程。

| Workflow | 描述 | 包含的 Skills |
|----------|------|--------------|
| `full-auto-development` | **全自动开发工作流** | requirements-doc, task-planner, autonomous-dev, auto-code-pipeline, code-reviewer |
| `code-review-flow` | 代码审查工作流 | code-reviewer, security-audit, bug-finder, refactoring, commit-message, pr-description |
| `feature-development` | 功能开发工作流 | api-designer, doc-generator, test-generator, code-reviewer, changelog-generator, pr-description |
| `content-creation` | 内容创作工作流 | brainstormer, outline-creator, blog-writer, technical-writer, translator |
| `weekly-planning` | 每周规划工作流 | weekly-review, goal-setter, task-planner, habit-tracker, decision-maker |
| `learning-path` | 学习路径工作流 | goal-setter, learning-tracker, note-taker, knowledge-base, concept-explainer, tutorial-creator |
| `project-kickoff` | 项目启动工作流 | task-planner, goal-setter, brainstormer, decision-maker, meeting-notes, presentation-maker |

## 📚 完整文档

### 快速开始

- 📖 [**快速开始指南**](./GETTING_STARTED.md) - 5分钟上手全自动开发
- 🎯 [提示词优化指南](./PROMPT_OPTIMIZATION.md) - 写出更好的需求描述
- 📋 [项目模板](./TEMPLATES.md) - 不同项目类型的配置模板
- 🎨 [**技能选择机制**](./SKILL_SELECTION.md) - 如何让 Claude 选择正确的 skill
- 📂 [**工作目录说明**](./WORKING_DIRECTORY.md) - 工作目录和安全范围设置

### 配置和定制

- ⚙️  [**配置指南**](./CONFIG.md) - 自定义工作流行为
- 🔐 安全配置 - 敏感文件保护和危险操作检测（见 autonomous-dev skill 文档）
- 🔧 [Git 工作流集成](./GIT_WORKFLOW.md) - 与 Git 最佳实践结合

### 优化和故障排除

- 🚀 [性能优化指南](./PERFORMANCE.md) - 提升执行速度
- 🔍 [**故障排除指南**](./TROUBLESHOOTING.md) - 解决常见问题
- 📊 性能监控 - 查看执行指标和统计（见配置文档）

### 核心特性文档

- 📝 **需求文档生成** - 详见 [requirements-doc skill](./skills/requirements-doc/SKILL.md)
- 🤖 **自主开发** - 详见 [autonomous-dev skill](./skills/autonomous-dev/SKILL.md)
- 🔄 **进度记录与恢复** - 断点续传、检查点机制（见 autonomous-dev 文档）
- 🔒 **安全检查机制** - 文件保护、代码扫描（见 autonomous-dev 文档）

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
# 强制更新所有 skills 到 Claude Code
curl -fsSL https://raw.githubusercontent.com/biglone/claude-skills/main/scripts/install.sh | UPDATE_MODE=force INSTALL_TARGET=claude bash

# 强制更新到两个平台
curl -fsSL https://raw.githubusercontent.com/biglone/claude-skills/main/scripts/install.sh | UPDATE_MODE=force INSTALL_TARGET=both bash

# 跳过已存在的 skills（静默安装）
curl -fsSL https://raw.githubusercontent.com/biglone/claude-skills/main/scripts/install.sh | UPDATE_MODE=skip INSTALL_TARGET=both bash
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
├── skills/                     # Skills 目录
│   ├── code-reviewer/
│   │   └── SKILL.md
│   ├── commit-message/
│   │   └── SKILL.md
│   ├── ... (47 个 Skills)
│   └── mind-mapper/
│       └── SKILL.md
├── workflows/                  # 工作流目录
│   ├── full-auto-development/
│   │   └── WORKFLOW.md
│   ├── code-review-flow/
│   │   └── WORKFLOW.md
│   ├── feature-development/
│   │   └── WORKFLOW.md
│   ├── content-creation/
│   │   └── WORKFLOW.md
│   ├── weekly-planning/
│   │   └── WORKFLOW.md
│   ├── learning-path/
│   │   └── WORKFLOW.md
│   └── project-kickoff/
│       └── WORKFLOW.md
└── scripts/
    ├── install.sh              # macOS / Linux
    ├── install.ps1             # Windows
    ├── update.sh
    ├── update.ps1
    ├── uninstall.sh
    └── uninstall.ps1
```

## Skill 之间的关联

每个 Skill 都通过 `related-skills` 字段定义了与其他 Skill 的关联关系，让整个技能库形成一个有机的整体：

```yaml
---
name: note-taker
description: 笔记整理和知识提取
allowed-tools: Read
related-skills: knowledge-base, concept-explainer, meeting-notes
---
```

## 添加新的 Skill

1. 在 `skills/` 目录下创建新文件夹
2. 创建 `SKILL.md` 文件，包含必要的 frontmatter:

```markdown
---
name: my-skill
description: 描述这个 skill 的功能和触发条件
allowed-tools: Read, Grep, Glob
related-skills: skill-a, skill-b
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
