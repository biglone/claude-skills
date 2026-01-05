# Claude Skills 集合

一个可共享的 Claude Code Skills 仓库，方便团队成员和多设备快速安装使用。

## 包含的 Skills

| Skill | 描述 |
|-------|------|
| `code-reviewer` | 代码审查，检查代码质量和最佳实践 |
| `commit-message` | 生成规范的 Git 提交信息 |
| `security-audit` | 安全代码审计，检查常见漏洞 |
| `code-explainer` | 代码解释器，帮助理解代码 |
| `test-generator` | 生成单元测试代码 |

## 快速安装

### 方式一：一键安装脚本

```bash
# 设置仓库地址（替换为你的仓库）
export CLAUDE_SKILLS_REPO="https://github.com/biglone/claude-skills.git"

# 执行安装
curl -fsSL https://raw.githubusercontent.com/biglone/claude-skills/main/scripts/install.sh | bash
```

### 方式二：手动安装

```bash
# 克隆仓库
git clone https://github.com/biglone/claude-skills.git

# 复制 skills 到本地
cp -r claude-skills/skills/* ~/.claude/skills/

# 重启 Claude Code
```

### 方式三：选择性安装

```bash
# 只安装需要的 skill
git clone https://github.com/biglone/claude-skills.git
cp -r claude-skills/skills/code-reviewer ~/.claude/skills/
```

## 更新 Skills

```bash
export CLAUDE_SKILLS_REPO="https://github.com/biglone/claude-skills.git"
curl -fsSL https://raw.githubusercontent.com/biglone/claude-skills/main/scripts/update.sh | bash
```

## 卸载 Skills

```bash
curl -fsSL https://raw.githubusercontent.com/biglone/claude-skills/main/scripts/uninstall.sh | bash
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
    ├── install.sh
    ├── update.sh
    └── uninstall.sh
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
4. 其他人运行 `update.sh` 即可获取

## 贡献指南

1. Fork 本仓库
2. 创建你的 Skill 分支 (`git checkout -b skill/my-new-skill`)
3. 提交更改 (`git commit -m 'feat: add my-new-skill'`)
4. 推送到分支 (`git push origin skill/my-new-skill`)
5. 创建 Pull Request

## License

MIT
