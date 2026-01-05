---
name: code-review-flow
description: 代码审查工作流。从代码提交到审查完成的完整流程。
skills:
  - code-reviewer
  - security-audit
  - bug-finder
  - refactoring
  - commit-message
  - pr-description
---

# 代码审查工作流

## 工作流概述

```
代码变更 → 自查 → 安全审计 → 代码审查 → 问题修复 → 提交
```

## 流程步骤

### 步骤 1：代码自查
**使用 Skill**：`code-reviewer`

开发者在提交前进行自查：
- 代码逻辑是否正确
- 是否符合编码规范
- 是否有明显的问题

**触发方式**：
```
请帮我审查这段代码的质量
```

### 步骤 2：Bug 检测
**使用 Skill**：`bug-finder`

自动检测潜在的 Bug：
- 空指针/未定义错误
- 边界条件问题
- 逻辑错误

**触发方式**：
```
请检查这段代码可能存在的 bug
```

### 步骤 3：安全审计
**使用 Skill**：`security-audit`

检查安全漏洞：
- SQL 注入
- XSS 攻击
- 敏感信息泄露
- 权限控制问题

**触发方式**：
```
请对这段代码进行安全审计
```

### 步骤 4：重构建议
**使用 Skill**：`refactoring`

如果代码质量需要改进：
- 代码复杂度
- 重复代码
- 设计模式应用

**触发方式**：
```
这段代码有重构建议吗？
```

### 步骤 5：生成提交信息
**使用 Skill**：`commit-message`

生成规范的提交信息：
- 遵循 Conventional Commits
- 清晰描述变更内容

**触发方式**：
```
请帮我生成这个变更的 commit message
```

### 步骤 6：创建 PR 描述
**使用 Skill**：`pr-description`

生成 PR 描述：
- 变更摘要
- 影响范围
- 测试说明

**触发方式**：
```
请帮我写这个 PR 的描述
```

## 快速启动

### 完整流程
```
请执行完整的代码审查流程，包括：
1. 代码质量审查
2. Bug 检测
3. 安全审计
4. 生成 commit message 和 PR 描述
```

### 快速审查
```
请快速审查这段代码，重点关注安全和Bug问题
```

## 检查清单

- [ ] 代码逻辑正确
- [ ] 无明显 Bug
- [ ] 无安全漏洞
- [ ] 符合编码规范
- [ ] 有适当的注释
- [ ] 有单元测试
- [ ] Commit message 规范
- [ ] PR 描述完整

## 相关 Skills

| Skill | 作用 |
|-------|------|
| code-reviewer | 代码质量审查 |
| security-audit | 安全漏洞检测 |
| bug-finder | Bug 检测 |
| refactoring | 重构建议 |
| commit-message | 提交信息生成 |
| pr-description | PR 描述生成 |
