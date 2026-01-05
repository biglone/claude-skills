# 配置指南

自定义全自动开发工作流的行为和参数。

## 配置文件位置

在项目根目录创建 `.claude-config.json`：

```
your-project/
├── .claude-config.json    # 配置文件
├── src/
└── package.json
```

## 完整配置示例

```json
{
  "version": "1.0",

  "global": {
    "log_level": "info",
    "max_concurrent_tasks": 3,
    "timeout": 600000,
    "auto_save_interval": 30
  },

  "requirements_doc": {
    "template": "default",
    "detail_level": "detailed",
    "include_diagrams": true,
    "language": "zh-CN",
    "skip_sections": []
  },

  "autonomous_dev": {
    "auto_commit": false,
    "auto_push": false,
    "max_retries": 3,
    "auto_fix": true,
    "skip_tests": false,
    "skip_review": false,
    "checkpoint_frequency": "every_stage",
    "log_retention_days": 7
  },

  "full_auto_development": {
    "skip_confirmation": false,
    "auto_approve_safe_changes": false,
    "require_manual_review": true,
    "timeout_per_phase": {
      "requirements": 300,
      "confirmation": -1,
      "development": 3600
    }
  },

  "safety": {
    "excluded_files": [
      ".env",
      ".env.*",
      "credentials.json",
      "secrets.*",
      "*.key",
      "*.pem"
    ],
    "excluded_directories": [
      "node_modules",
      ".git",
      "dist",
      "build"
    ],
    "dangerous_operations": {
      "delete_confirmation_threshold": 10,
      "require_confirmation": [
        "database_migration",
        "config_change",
        "dependency_update"
      ]
    },
    "max_file_size_mb": 10,
    "max_files_per_task": 50
  },

  "commands": {
    "test": "npm test",
    "lint": "npm run lint",
    "build": "npm run build",
    "format": "npm run format",
    "typecheck": "npm run typecheck"
  },

  "git": {
    "auto_stage": true,
    "commit_message_template": "feat: {summary}\n\n{details}\n\n🤖 Generated with Claude Code\nCo-Authored-By: Claude Sonnet 4.5 <noreply@anthropic.com>",
    "branch_naming": "feature/{feature-name}",
    "require_hooks": true,
    "pre_commit_checks": ["lint", "test"]
  },

  "monitoring": {
    "enabled": true,
    "metrics_file": ".claude-metrics.json",
    "track_performance": true,
    "track_errors": true,
    "send_telemetry": false
  },

  "ui": {
    "show_progress_bar": true,
    "use_emojis": true,
    "verbose_mode": false,
    "color_output": true
  },

  "advanced": {
    "parallel_execution": true,
    "cache_enabled": true,
    "cache_ttl": 3600,
    "optimize_for_speed": false,
    "debug_mode": false
  }
}
```

---

## 配置项详解

### 1. 全局配置（global）

```json
{
  "global": {
    "log_level": "info",           // 日志级别: debug, info, warn, error
    "max_concurrent_tasks": 3,     // 最大并发任务数
    "timeout": 600000,             // 全局超时(毫秒)
    "auto_save_interval": 30       // 自动保存间隔(秒)
  }
}
```

**log_level 说明：**
- `debug` - 显示所有调试信息（非常详细）
- `info` - 显示一般信息（推荐）
- `warn` - 只显示警告和错误
- `error` - 只显示错误

### 2. 需求文档配置（requirements_doc）

```json
{
  "requirements_doc": {
    "template": "default",         // 模板: default, simple, detailed, minimal
    "detail_level": "detailed",    // 详细程度: simple, detailed
    "include_diagrams": true,      // 是否包含架构图
    "language": "zh-CN",           // 语言: zh-CN, en-US
    "skip_sections": []            // 跳过的章节: ["risks", "non_functional"]
  }
}
```

**template 选项：**
- `default` - 标准模板（11个章节）
- `simple` - 简化模板（6个核心章节）
- `detailed` - 详细模板（15个章节，包含更多细节）
- `minimal` - 最小模板（只有核心3个章节）

**可跳过的章节：**
```json
{
  "skip_sections": [
    "background",           // 背景和目标
    "user_stories",         // 用户故事
    "non_functional",       // 非功能需求
    "risks",                // 风险和注意事项
    "api_design",           // 接口设计
    "data_model"            // 数据模型
  ]
}
```

### 3. 自主开发配置（autonomous_dev）

```json
{
  "autonomous_dev": {
    "auto_commit": false,          // 完成后自动提交
    "auto_push": false,            // 自动推送到远程
    "max_retries": 3,              // 最大重试次数
    "auto_fix": true,              // 自动修复错误
    "skip_tests": false,           // 跳过测试阶段
    "skip_review": false,          // 跳过代码审查
    "checkpoint_frequency": "every_stage",  // 检查点频率
    "log_retention_days": 7        // 日志保留天数
  }
}
```

**checkpoint_frequency 选项：**
- `every_stage` - 每个阶段后保存（推荐）
- `every_task` - 每个任务后保存（更频繁）
- `manual` - 只手动保存
- `critical_only` - 只在关键点保存

### 4. 全自动开发配置（full_auto_development）

```json
{
  "full_auto_development": {
    "skip_confirmation": false,           // 跳过人工确认（不推荐）
    "auto_approve_safe_changes": false,   // 自动批准安全变更
    "require_manual_review": true,        // 要求人工审查
    "timeout_per_phase": {
      "requirements": 300,     // 需求分析超时(秒)，-1表示无限制
      "confirmation": -1,      // 确认阶段无超时
      "development": 3600      // 开发阶段超时(秒)
    }
  }
}
```

**⚠️ 警告：** `skip_confirmation: true` 会跳过人工确认，可能导致不符合预期的结果。

### 5. 安全配置（safety）

```json
{
  "safety": {
    "excluded_files": [
      ".env", ".env.*",
      "credentials.json",
      "secrets.*",
      "*.key", "*.pem"
    ],
    "excluded_directories": [
      "node_modules",
      ".git",
      "dist",
      "build"
    ],
    "dangerous_operations": {
      "delete_confirmation_threshold": 10,  // 删除超过N个文件需确认
      "require_confirmation": [
        "database_migration",    // 数据库迁移需确认
        "config_change",         // 配置文件修改需确认
        "dependency_update"      // 依赖更新需确认
      ]
    },
    "max_file_size_mb": 10,      // 单个文件最大大小(MB)
    "max_files_per_task": 50     // 单个任务最多处理文件数
  }
}
```

**默认排除的文件：**
- 环境变量文件（`.env*`）
- 凭证文件（`credentials.*`, `secrets.*`）
- 密钥文件（`*.key`, `*.pem`, `*.crt`）
- 编译产物（`dist/`, `build/`, `*.min.js`）
- 依赖目录（`node_modules/`, `vendor/`）

### 6. 命令配置（commands）

```json
{
  "commands": {
    "test": "npm test",               // 测试命令
    "lint": "npm run lint",           // Lint 命令
    "build": "npm run build",         // 构建命令
    "format": "npm run format",       // 格式化命令
    "typecheck": "npm run typecheck"  // 类型检查命令
  }
}
```

**支持的项目类型：**

**Node.js/JavaScript:**
```json
{
  "commands": {
    "test": "npm test",
    "lint": "eslint .",
    "build": "npm run build"
  }
}
```

**Python:**
```json
{
  "commands": {
    "test": "pytest",
    "lint": "flake8 .",
    "format": "black ."
  }
}
```

**Go:**
```json
{
  "commands": {
    "test": "go test ./...",
    "lint": "golangci-lint run",
    "build": "go build"
  }
}
```

### 7. Git 配置（git）

```json
{
  "git": {
    "auto_stage": true,            // 自动 stage 文件
    "commit_message_template": "feat: {summary}\n\n{details}",
    "branch_naming": "feature/{feature-name}",
    "require_hooks": true,         // 要求运行 Git hooks
    "pre_commit_checks": ["lint", "test"]  // 提交前检查
  }
}
```

**commit_message_template 变量：**
- `{summary}` - 功能摘要
- `{details}` - 详细描述
- `{files}` - 修改的文件列表
- `{date}` - 当前日期

**branch_naming 变量：**
- `{feature-name}` - 功能名称（kebab-case）
- `{date}` - 日期 (YYYYMMDD)
- `{ticket}` - 任务编号（如果有）

### 8. 监控配置（monitoring）

```json
{
  "monitoring": {
    "enabled": true,                    // 启用监控
    "metrics_file": ".claude-metrics.json",  // 指标文件
    "track_performance": true,          // 跟踪性能
    "track_errors": true,               // 跟踪错误
    "send_telemetry": false             // 发送匿名遥测数据
  }
}
```

**收集的指标：**
- 执行时间
- 文件数量和代码行数
- 错误次数和类型
- 成功率
- 重试次数

### 9. UI 配置（ui）

```json
{
  "ui": {
    "show_progress_bar": true,    // 显示进度条
    "use_emojis": true,           // 使用 emoji
    "verbose_mode": false,        // 详细模式
    "color_output": true          // 彩色输出
  }
}
```

### 10. 高级配置（advanced）

```json
{
  "advanced": {
    "parallel_execution": true,    // 并行执行任务
    "cache_enabled": true,         // 启用缓存
    "cache_ttl": 3600,            // 缓存过期时间(秒)
    "optimize_for_speed": false,   // 优化速度（可能降低质量）
    "debug_mode": false            // 调试模式
  }
}
```

---

## 预设配置模板

### 1. 保守模式（推荐新手）

```json
{
  "autonomous_dev": {
    "auto_commit": false,
    "auto_push": false,
    "max_retries": 2,
    "checkpoint_frequency": "every_stage"
  },
  "full_auto_development": {
    "skip_confirmation": false,
    "require_manual_review": true
  },
  "safety": {
    "delete_confirmation_threshold": 5
  }
}
```

### 2. 安全零干预模式（推荐个人项目）

```json
{
  "full_auto_development": {
    "skip_confirmation": true  // 跳过确认
  },
  "safety": {
    "work_directory_only": true,
    "allowed_paths": ["src", "tests"],
    "constraints": {
      "max_files_created": 20,
      "max_files_deleted": 10,
      "max_lines_per_file": 500
    },
    "auto_reject_dangerous_ops": true
  },
  "git": {
    "auto_create_branch": true,
    "protect_branches": ["main", "master"]
  },
  "rollback": {
    "auto_create_backup": true
  }
}
```

**完整配置**：参见 `.claude-config.safe-zero-intervention.json`

### 3. 激进模式（经验用户，有风险）

```json
{
  "autonomous_dev": {
    "auto_commit": true,
    "max_retries": 5,
    "checkpoint_frequency": "critical_only"
  },
  "full_auto_development": {
    "skip_confirmation": true,
    "auto_approve_safe_changes": true
  },
  "safety": {
    "delete_confirmation_threshold": 999
  },
  "advanced": {
    "parallel_execution": true,
    "optimize_for_speed": true
  }
}
```

**⚠️ 警告**：此模式跳过大部分安全检查

### 4. 快速原型模式

```json
{
  "requirements_doc": {
    "template": "minimal",
    "detail_level": "simple"
  },
  "autonomous_dev": {
    "skip_tests": true,
    "skip_review": true,
    "auto_commit": true
  },
  "advanced": {
    "optimize_for_speed": true
  }
}
```

### 5. 生产模式（最严格）

```json
{
  "autonomous_dev": {
    "auto_commit": false,
    "auto_push": false,
    "skip_tests": false,
    "skip_review": false,
    "max_retries": 3
  },
  "full_auto_development": {
    "require_manual_review": true
  },
  "safety": {
    "delete_confirmation_threshold": 3,
    "require_confirmation": [
      "database_migration",
      "config_change",
      "dependency_update",
      "api_change"
    ]
  },
  "git": {
    "require_hooks": true,
    "pre_commit_checks": ["lint", "test", "typecheck"]
  }
}
```

---

## 配置覆盖

### 优先级

1. 命令行参数（最高）
2. 项目配置文件（`.claude-config.json`）
3. 全局配置文件（`~/.claude/config.json`）
4. 默认配置（最低）

### 命令行覆盖示例

```bash
# 跳过测试
"全自动开发：实现登录功能，跳过测试"

# 使用简化模板
"生成需求文档：添加评论，使用简化模板"

# 详细模式
"全自动开发：实现支付，详细模式"
```

---

## 环境变量

支持通过环境变量配置：

```bash
# 日志级别
export CLAUDE_LOG_LEVEL=debug

# 最大重试次数
export CLAUDE_MAX_RETRIES=5

# 跳过确认（CI/CD 环境）
export CLAUDE_SKIP_CONFIRMATION=true

# 禁用遥测
export CLAUDE_DISABLE_TELEMETRY=true
```

---

## 配置验证

创建配置后，验证配置是否正确：

```bash
# 在 Claude Code 中
"验证配置"

# 或手动检查
cat .claude-config.json | jq .
```

AI 会检查：
- ✅ JSON 格式是否正确
- ✅ 配置项是否有效
- ✅ 值类型是否正确
- ✅ 命令是否可执行
- ⚠️  潜在的配置问题

---

## 常见配置场景

### 场景 1：多人协作项目

```json
{
  "autonomous_dev": {
    "auto_commit": false,
    "auto_push": false
  },
  "git": {
    "commit_message_template": "feat({ticket}): {summary}\n\n{details}\n\nCo-Authored-By: Claude Sonnet 4.5 <noreply@anthropic.com>",
    "branch_naming": "feature/{ticket}-{feature-name}",
    "require_hooks": true,
    "pre_commit_checks": ["lint", "test"]
  },
  "safety": {
    "require_confirmation": [
      "database_migration",
      "config_change"
    ]
  }
}
```

### 场景 2：个人项目快速迭代

```json
{
  "requirements_doc": {
    "template": "simple"
  },
  "autonomous_dev": {
    "auto_commit": true,
    "max_retries": 5
  },
  "advanced": {
    "parallel_execution": true,
    "optimize_for_speed": true
  }
}
```

### 场景 3：学习和实验

```json
{
  "ui": {
    "verbose_mode": true,
    "show_progress_bar": true
  },
  "monitoring": {
    "enabled": true,
    "track_performance": true,
    "track_errors": true
  },
  "advanced": {
    "debug_mode": true
  }
}
```

---

## 故障排除

### 配置不生效

**检查优先级：**
```bash
# 查看当前使用的配置
"显示当前配置"

# 查看配置来源
"配置来源"
```

### JSON 格式错误

**使用验证工具：**
```bash
# 验证 JSON 格式
cat .claude-config.json | jq .

# 或在线验证
# https://jsonlint.com/
```

### 命令执行失败

**检查命令是否可用：**
```bash
# 测试命令
npm test
npm run lint

# 检查 package.json 中是否定义了脚本
```

---

## 最佳实践

1. **从默认配置开始**
   - 先使用默认配置
   - 逐步调整满足需求

2. **版本控制配置文件**
   ```bash
   git add .claude-config.json
   git commit -m "chore: add claude config"
   ```

3. **团队共享配置**
   - 将配置提交到仓库
   - 团队成员使用统一配置

4. **敏感信息分离**
   - 不要在配置中包含密钥
   - 使用环境变量或单独的配置文件

5. **定期审查配置**
   - 随着项目发展调整配置
   - 移除不再需要的配置项

---

## 参考资料

- [快速开始指南](./GETTING_STARTED.md)
- [故障排除](./TROUBLESHOOTING.md)
- [性能优化](./PERFORMANCE.md)
- [GitHub 示例配置](https://github.com/biglone/claude-skills/tree/main/examples/configs)
