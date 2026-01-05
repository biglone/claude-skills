---
name: dependency-analyzer
description: 分析项目依赖，检查过时包和安全问题。当用户要求检查依赖、更新包、分析安全漏洞时使用。
allowed-tools: Bash, Read, Grep, Glob
---

# 依赖分析器

## 依赖检查命令

### npm/Node.js
```bash
# 查看过时的包
npm outdated

# 查看安全漏洞
npm audit
npm audit --json  # JSON 格式

# 自动修复漏洞
npm audit fix
npm audit fix --force  # 强制修复（可能有破坏性更新）

# 查看依赖树
npm ls
npm ls --depth=0  # 只显示直接依赖
npm ls <package>  # 查看特定包

# 检查未使用的依赖
npx depcheck

# 检查包大小
npx bundlephobia <package>
```

### yarn
```bash
# 查看过时的包
yarn outdated

# 查看安全漏洞
yarn audit

# 查看依赖树
yarn list --depth=0

# 升级交互式
yarn upgrade-interactive
```

### pnpm
```bash
# 查看过时的包
pnpm outdated

# 查看安全漏洞
pnpm audit

# 查看依赖树
pnpm list --depth=0
```

### Python
```bash
# 查看过时的包
pip list --outdated

# 检查安全漏洞
pip-audit
safety check

# 导出依赖
pip freeze > requirements.txt
pipreqs . --force  # 只导出实际使用的

# 查看依赖树
pipdeptree
```

### Go
```bash
# 查看依赖
go list -m all

# 检查更新
go list -u -m all

# 更新依赖
go get -u ./...

# 整理依赖
go mod tidy
```

## 依赖分析报告

### 安全漏洞报告
```markdown
## 安全漏洞报告

### 摘要
- 严重 (Critical): X 个
- 高危 (High): X 个
- 中危 (Moderate): X 个
- 低危 (Low): X 个

### 详细信息

#### [CRITICAL] CVE-XXXX-YYYY
- **包名**: package-name
- **当前版本**: 1.0.0
- **修复版本**: 1.0.1
- **描述**: 漏洞描述
- **建议**: 升级到 >= 1.0.1

#### [HIGH] CVE-XXXX-ZZZZ
...
```

### 过时依赖报告
```markdown
## 过时依赖报告

| 包名 | 当前版本 | 最新版本 | 类型 | 更新建议 |
|------|----------|----------|------|----------|
| lodash | 4.17.20 | 4.17.21 | patch | 建议更新 |
| react | 17.0.2 | 18.2.0 | major | 谨慎评估 |
| typescript | 4.9.5 | 5.3.3 | major | 测试后更新 |

### 更新建议

#### 可直接更新（patch/minor）
```bash
npm update lodash
```

#### 需要评估（major）
- **react**: 17 → 18 有 breaking changes
  - 需要更新 ReactDOM.render → createRoot
  - 检查 Concurrent Mode 兼容性
```

## 依赖健康检查

### 检查项目
- [ ] 无已知安全漏洞
- [ ] 无严重过时的依赖
- [ ] 无未使用的依赖
- [ ] 无重复的依赖
- [ ] 许可证合规

### 许可证检查
```bash
# npm
npx license-checker --summary

# 检查特定许可证
npx license-checker --onlyAllow "MIT;ISC;Apache-2.0"
```

## 依赖更新策略

### 语义化版本
```
主版本.次版本.修订号
MAJOR.MINOR.PATCH

^1.2.3  → 1.x.x (允许 minor 和 patch)
~1.2.3  → 1.2.x (只允许 patch)
1.2.3   → 精确版本
```

### 更新建议

| 更新类型 | 风险 | 建议 |
|----------|------|------|
| patch | 低 | 可直接更新 |
| minor | 中 | 测试后更新 |
| major | 高 | 详细评估，逐步更新 |

### 安全更新流程
```bash
# 1. 查看漏洞详情
npm audit

# 2. 尝试自动修复
npm audit fix

# 3. 如果有 breaking changes
npm audit fix --force  # 或手动更新

# 4. 运行测试
npm test

# 5. 提交更改
git add package.json package-lock.json
git commit -m "fix(deps): update dependencies for security"
```

## 常见问题

### 依赖冲突
```bash
# 查看冲突的版本
npm ls <package>

# 解决方案
# 1. 更新到兼容版本
# 2. 使用 resolutions (yarn) 或 overrides (npm 8.3+)

# package.json
{
  "overrides": {
    "vulnerable-package": "^2.0.0"
  }
}
```

### 减小包体积
```bash
# 分析包大小
npx webpack-bundle-analyzer

# 检查可替代的轻量包
npx bundlephobia lodash      # 69.9kB
npx bundlephobia lodash-es   # 支持 tree-shaking

# 使用更轻量的替代
moment → dayjs (2kB vs 67kB)
lodash → lodash-es (支持 tree-shaking)
uuid → nanoid (更小)
```

### lock 文件
```bash
# 重新生成 lock 文件
rm package-lock.json
npm install

# 同步 lock 文件
npm ci  # 严格按 lock 文件安装
```

## 输出格式

```markdown
## 依赖分析报告

**项目**: project-name
**日期**: 2024-01-15
**包管理器**: npm

### 📊 统计
- 总依赖数: X (直接: Y, 间接: Z)
- 过时依赖: X
- 安全漏洞: X

### 🔒 安全问题
[漏洞列表]

### 📦 过时依赖
[过时依赖表格]

### 🗑️ 未使用依赖
[未使用依赖列表]

### 💡 建议
1. [具体建议]
2. [具体建议]
```
