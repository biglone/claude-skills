---
name: changelog-generator
description: 根据提交历史生成 Changelog。当用户要求生成更新日志、发布说明时使用。
allowed-tools: Bash, Read, Grep
---

# Changelog 生成器

## Changelog 格式规范

### Keep a Changelog 格式
```markdown
# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

## [1.1.0] - 2024-01-15

### Added
- New feature X that allows users to do Y
- Support for Z format

### Changed
- Improved performance of A by 50%
- Updated dependency B to version 2.0

### Deprecated
- Method `oldMethod()` is deprecated, use `newMethod()` instead

### Removed
- Removed support for legacy API

### Fixed
- Fixed issue where X would fail under Y condition (#123)
- Resolved memory leak in Z component

### Security
- Updated crypto library to patch CVE-XXXX-YYYY

## [1.0.0] - 2024-01-01

### Added
- Initial release
- Core features A, B, C
```

## 变更类型

| 类型 | 说明 | 示例 |
|------|------|------|
| Added | 新功能 | 新增用户导出功能 |
| Changed | 现有功能的变更 | 优化搜索算法性能 |
| Deprecated | 即将移除的功能 | 废弃旧版 API |
| Removed | 已移除的功能 | 移除 IE11 支持 |
| Fixed | Bug 修复 | 修复登录失败问题 |
| Security | 安全相关 | 修复 XSS 漏洞 |

## 从 Git 提交生成

### 提取提交信息
```bash
# 获取两个标签之间的提交
git log v1.0.0..v1.1.0 --pretty=format:"%s" --reverse

# 获取最近的提交（按类型分组）
git log --since="2024-01-01" --pretty=format:"- %s (%h)" --reverse

# 获取合并的 PR
git log --merges --pretty=format:"%s" v1.0.0..HEAD
```

### Conventional Commits 映射
```
feat:     → Added
fix:      → Fixed
docs:     → Changed (Documentation)
style:    → Changed (Formatting)
refactor: → Changed
perf:     → Changed (Performance)
test:     → Changed (Tests)
build:    → Changed (Build)
ci:       → Changed (CI)
chore:    → Changed (Maintenance)
revert:   → Removed
security: → Security
```

## 生成模板

### 按版本生成
```markdown
## [版本号] - 日期

### Added
- feat: 新功能描述 (#PR号)

### Changed
- refactor: 重构描述
- perf: 性能优化描述

### Fixed
- fix: Bug 修复描述 (#Issue号)

### Security
- security: 安全修复描述
```

### 发布说明模板
```markdown
# Release v1.1.0

We're excited to announce the release of v1.1.0! 🎉

## Highlights

- **Feature A**: Brief description of the major feature
- **Performance**: X% improvement in Y

## Breaking Changes

- `oldAPI()` has been removed, use `newAPI()` instead
- Minimum Node.js version is now 18

## What's Changed

### New Features
- Add feature X by @contributor in #123
- Implement Y functionality by @contributor in #124

### Bug Fixes
- Fix issue with Z by @contributor in #125

### Other Changes
- Update dependencies by @contributor in #126

## New Contributors
- @newcontributor made their first contribution in #127

**Full Changelog**: https://github.com/user/repo/compare/v1.0.0...v1.1.0
```

## 自动化工具

### standard-version
```bash
# 安装
npm install --save-dev standard-version

# 使用
npx standard-version              # 自动确定版本
npx standard-version --release-as major  # 主版本
npx standard-version --release-as minor  # 次版本
npx standard-version --release-as patch  # 补丁版本
npx standard-version --dry-run    # 预览

# package.json 配置
{
  "scripts": {
    "release": "standard-version"
  }
}
```

### conventional-changelog
```bash
# 安装
npm install -g conventional-changelog-cli

# 生成
conventional-changelog -p angular -i CHANGELOG.md -s
```

## 输出格式

```markdown
## Changelog 生成报告

**版本**: v1.1.0
**日期**: 2024-01-15
**提交范围**: v1.0.0..v1.1.0

---

## [1.1.0] - 2024-01-15

### Added
- [功能描述] (#PR/Issue)

### Changed
- [变更描述]

### Fixed
- [修复描述] (#Issue)

---

**统计**:
- 总提交数: X
- 新功能: X
- Bug 修复: X
- 贡献者: X
```

## 最佳实践

1. **及时更新** - 每次发布都更新 Changelog
2. **面向用户** - 用用户能理解的语言描述
3. **关联 Issue** - 链接相关的 Issue 和 PR
4. **版本语义** - 遵循语义化版本规范
5. **保持一致** - 使用统一的格式和措辞
