---
name: commit-message
description: 生成规范的 Git 提交信息。当用户要求生成 commit message、提交代码时使用。
allowed-tools: Bash
---

# Git 提交信息生成器

遵循 Conventional Commits 规范生成提交信息。

## 提交格式

```
<type>(<scope>): <subject>

<body>

<footer>
```

## Type 类型

| 类型 | 说明 |
|------|------|
| feat | 新功能 |
| fix | Bug 修复 |
| docs | 文档更新 |
| style | 代码格式（不影响代码逻辑） |
| refactor | 重构（既不是新功能也不是修复） |
| perf | 性能优化 |
| test | 测试相关 |
| build | 构建系统或外部依赖 |
| ci | CI 配置 |
| chore | 其他杂项 |
| revert | 回滚提交 |

## 规则

1. **subject**:
   - 使用祈使语气（add 而非 added）
   - 首字母小写
   - 不加句号
   - 不超过 50 字符

2. **body**:
   - 解释做了什么和为什么
   - 每行不超过 72 字符
   - 可选

3. **footer**:
   - 关联 issue: `Closes #123`
   - Breaking change: `BREAKING CHANGE: description`

## 示例

```
feat(auth): add two-factor authentication

Implement TOTP-based 2FA for enhanced account security.
Users can enable 2FA from account settings page.

Closes #1234
```

```
fix(api): handle null response in user service

Added null check to prevent TypeError when API returns
empty response during network issues.

Fixes #567
```
