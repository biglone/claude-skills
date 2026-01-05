---
name: pr-description
description: 生成规范的 Pull Request 描述。当用户要求写 PR 描述、创建 PR 时使用。
allowed-tools: Bash, Read, Grep, Glob
---

# PR 描述生成器

## PR 描述模板

### 标准模板
```markdown
## Summary
<!-- 简要描述这个 PR 做了什么 -->

一句话描述本次更改的目的和内容。

## Changes
<!-- 详细列出主要更改 -->

- 更改 1：描述
- 更改 2：描述
- 更改 3：描述

## Related Issues
<!-- 关联的 Issue -->

Closes #123
Fixes #456
Related to #789

## Test Plan
<!-- 如何测试这些更改 -->

- [ ] 单元测试已通过
- [ ] 手动测试场景 A
- [ ] 手动测试场景 B

## Screenshots
<!-- 如果有 UI 变更，添加截图 -->

| Before | After |
|--------|-------|
| ![before](url) | ![after](url) |

## Checklist
<!-- 确认已完成以下事项 -->

- [ ] 代码已自测
- [ ] 已添加/更新测试
- [ ] 已更新文档
- [ ] 无 breaking changes（或已在描述中说明）
```

### 功能开发模板
```markdown
## 🚀 Feature: [功能名称]

### Summary
实现了 [功能描述]，用户现在可以 [用户价值]。

### Motivation
<!-- 为什么需要这个功能 -->
- 用户需求：[描述]
- 业务价值：[描述]

### Implementation
<!-- 实现方案 -->

#### Architecture
[简要描述架构设计]

#### Key Changes
1. `file1.ts` - 新增 XXX 功能
2. `file2.ts` - 修改 YYY 逻辑
3. `file3.ts` - 添加 ZZZ 组件

### Test Plan
- [ ] 单元测试覆盖核心逻辑
- [ ] E2E 测试覆盖主流程
- [ ] 边界情况测试

### Screenshots / Demo
[截图或 GIF]

### Documentation
- [ ] README 已更新
- [ ] API 文档已更新
```

### Bug 修复模板
```markdown
## 🐛 Fix: [Bug 简述]

### Problem
<!-- 问题描述 -->
用户在 [场景] 下会遇到 [问题]。

**复现步骤**:
1. 步骤 1
2. 步骤 2
3. 出现问题

**期望行为**: [描述]
**实际行为**: [描述]

### Root Cause
<!-- 根本原因分析 -->
问题出在 [位置]，因为 [原因]。

### Solution
<!-- 解决方案 -->
通过 [方案] 解决此问题。

### Changes
- `file.ts:L123` - [修改描述]

### Test Plan
- [ ] 添加回归测试
- [ ] 验证原始问题已修复
- [ ] 验证无副作用

Fixes #123
```

### 重构模板
```markdown
## ♻️ Refactor: [重构内容]

### Summary
重构 [模块/组件]，改善 [代码质量/性能/可维护性]。

### Motivation
- 当前问题：[描述现有代码的问题]
- 改进目标：[描述重构后的改进]

### Changes
#### Before
```code
// 旧代码示例
```

#### After
```code
// 新代码示例
```

### Impact
- [ ] 无功能变化
- [ ] 无 API 变化
- [ ] 性能无负面影响

### Test Plan
- [ ] 现有测试全部通过
- [ ] 无需新增测试（行为未变）
```

## PR 标题规范

### Conventional Commits 格式
```
<type>(<scope>): <description>

feat(auth): add two-factor authentication
fix(api): handle null response in user service
docs(readme): update installation instructions
style(lint): fix eslint warnings
refactor(user): extract validation logic
perf(query): optimize database queries
test(auth): add unit tests for login
build(deps): update dependencies
ci(github): add automated release workflow
chore(config): update editor settings
```

### 类型说明
| 类型 | 说明 | Emoji |
|------|------|-------|
| feat | 新功能 | ✨ |
| fix | Bug 修复 | 🐛 |
| docs | 文档 | 📝 |
| style | 格式 | 💄 |
| refactor | 重构 | ♻️ |
| perf | 性能 | ⚡ |
| test | 测试 | ✅ |
| build | 构建 | 📦 |
| ci | CI/CD | 👷 |
| chore | 杂项 | 🔧 |
| revert | 回滚 | ⏪ |

## 生成流程

1. **分析更改**
   ```bash
   # 查看当前分支与目标分支的差异
   git diff main...HEAD --stat
   git log main..HEAD --oneline
   ```

2. **提取信息**
   - 主要修改的文件
   - 提交信息摘要
   - 关联的 Issue

3. **生成描述**
   - 根据更改类型选择模板
   - 填充具体内容
   - 添加测试计划

## 最佳实践

1. **简明扼要** - Summary 一句话说清楚
2. **关联 Issue** - 使用关键词自动关闭 Issue
3. **提供上下文** - 说明 Why，不只是 What
4. **易于 Review** - 拆分大 PR，提供足够信息
5. **更新文档** - 功能变更同步更新文档
6. **添加截图** - UI 变更必须有前后对比

## Issue 关联关键词

```
close, closes, closed
fix, fixes, fixed
resolve, resolves, resolved

# 示例
Closes #123
Fixes #123, #456
Resolves #789
```
