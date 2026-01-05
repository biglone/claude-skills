# 项目模板和多项目支持

针对不同类型项目的配置模板和最佳实践。

## 项目模板

### 1. Web 应用（React/Next.js）

**.claude-config.json:**
```json
{
  "requirements_doc": {
    "template": "default"
  },
  "commands": {
    "test": "npm test",
    "lint": "npm run lint",
    "build": "npm run build",
    "typecheck": "tsc --noEmit"
  },
  "git": {
    "branch_naming": "feature/{feature-name}",
    "pre_commit_checks": ["lint", "typecheck", "test"]
  }
}
```

### 2. API 服务（Node.js/Express）

```json
{
  "requirements_doc": {
    "template": "default",
    "skip_sections": ["ui_design"]
  },
  "commands": {
    "test": "jest",
    "lint": "eslint src/",
    "build": "tsc"
  },
  "safety": {
    "require_confirmation": [
      "database_migration",
      "api_change"
    ]
  }
}
```

### 3. Python 项目

```json
{
  "commands": {
    "test": "pytest",
    "lint": "flake8 .",
    "format": "black .",
    "typecheck": "mypy ."
  }
}
```

### 4. 移动应用（React Native）

```json
{
  "commands": {
    "test": "jest",
    "lint": "eslint .",
    "ios": "npx react-native run-ios",
    "android": "npx react-native run-android"
  }
}
```

## 多项目管理

### 团队共享配置

**1. 基础配置（团队共享）**
`.claude-config.json` - 提交到 Git
```json
{
  "safety": {
    "excluded_files": [".env*", "secrets/*"]
  },
  "git": {
    "commit_message_template": "feat: {summary}"
  }
}
```

**2. 个人配置（本地覆盖）**
`.claude-config.local.json` - 添加到 .gitignore
```json
{
  "ui": {
    "verbose_mode": true
  },
  "advanced": {
    "debug_mode": true
  }
}
```

### 项目特定配置

使用环境变量区分：

```bash
# 开发环境
export CLAUDE_ENV=development
export CLAUDE_SKIP_TESTS=false

# 生产环境
export CLAUDE_ENV=production  
export CLAUDE_SAFETY_STRICT=true
```

## 示例项目

在 `templates/` 目录下提供了完整的示例项目：

```
templates/
├── react-app/           # React 应用模板
├── express-api/         # Express API模板
├── python-flask/        # Flask 应用模板
├── nextjs-fullstack/    # Next.js 全栈模板
└── mobile-app/          # React Native 模板
```

## 使用模板

```bash
# 复制模板
cp templates/react-app/.claude-config.json my-project/

# 根据项目调整配置
vi my-project/.claude-config.json
```

## 最佳实践

1. ✅ 团队共享基础配置
2. ✅ 个人配置使用 .local 后缀
3. ✅ 敏感配置使用环境变量
4. ✅ 文档化特殊配置原因
5. ✅ 定期同步团队配置

