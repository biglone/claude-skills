# 安全与应急参考

## 安全检查机制

### 1. 文件保护

**自动排除的敏感文件：**
```
.env
.env.*
credentials.json
secrets.*
*.key
*.pem
*.crt
api_keys.json
config/secrets/*
```

**执行前检查：**
```
AI: ⚠️  检测到以下敏感文件

将要修改的文件：
  • .env.local
  • credentials.json

这些文件可能包含敏感信息。

选择操作：
  1️⃣  "跳过这些文件" - 排除敏感文件
  2️⃣  "仅读取不修改" - 只读取参考
  3️⃣  "我确认要修改" - 继续修改（需明确确认）
  4️⃣  "取消" - 终止任务
```

### 2. 危险操作检测

**需要二次确认的操作：**

**大规模删除**
```
AI: ⚠️  危险操作警告

即将删除 15 个文件：
  • src/old/*.js (12 个文件)
  • tests/deprecated/*.test.js (3 个文件)

这是一个大规模删除操作。

确认删除？输入 "确认删除" 继续
```

**数据库相关操作**
```
AI: ⚠️  数据库操作警告

即将执行数据库迁移：
  • 修改 users 表结构
  • 删除 sessions 表的 2 个字段
  • 这个操作不可逆

建议：
  1. 先备份数据库
  2. 在开发环境测试
  3. 确认迁移脚本正确

确认执行？输入 "确认执行数据库迁移"
```

**配置文件修改**
```
AI: ⚠️  配置文件修改警告

即将修改核心配置文件：
  • package.json - 更新依赖版本
  • tsconfig.json - 修改编译选项
  • .env.example - 添加新环境变量

这些修改可能影响项目运行。

查看变更详情？(y/n)
```

### 3. 依赖管理安全

**依赖更新检查：**
```
AI: 📦 依赖更新检查

即将更新以下依赖：
  • react: 17.0.2 → 18.2.0 (主版本升级)
  • axios: 0.27.2 → 1.4.0 (主版本升级)
  • lodash: 4.17.20 → 4.17.21 (补丁版本)

⚠️  主版本升级可能包含破坏性变更

建议：
  1. 查看 CHANGELOG
  2. 检查迁移指南
  3. 在测试环境验证

继续更新？(y/n)
```

**新依赖安装检查：**
```
AI: 📦 新依赖安装

即将安装新依赖：
  • some-unknown-package@1.0.0

安全检查：
  ✅ NPM 官方包
  ✅ 每周下载量: 50,000+
  ✅ 最近更新: 2 个月前
  ⚠️  未知发布者

确认安装？(y/n)
```

### 4. 代码安全扫描

**自动检测的安全问题：**

**SQL 注入**
```javascript
// ❌ 检测到潜在的 SQL 注入
const query = `SELECT * FROM users WHERE id = ${userId}`;

AI: ⚠️  安全问题检测

文件: src/api/users.ts:45
问题: 潜在的 SQL 注入风险
严重程度: 高

建议修复:
  使用参数化查询：
  const query = 'SELECT * FROM users WHERE id = ?';
  db.query(query, [userId]);

自动修复？(y/n)
```

**XSS 风险**
```javascript
// ❌ 检测到潜在的 XSS
element.innerHTML = userInput;

AI: ⚠️  安全问题检测

文件: src/components/Comment.tsx:67
问题: 潜在的 XSS 风险
严重程度: 高

建议修复:
  使用 textContent 或进行转义：
  element.textContent = userInput;
  // 或
  element.innerHTML = escapeHtml(userInput);

自动修复？(y/n)
```

**硬编码凭证**
```javascript
// ❌ 检测到硬编码密钥
const API_KEY = "sk_live_123456789";

AI: ⚠️  安全问题检测

文件: src/config.ts:12
问题: 硬编码的 API 密钥
严重程度: 严重

建议修复:
  使用环境变量：
  const API_KEY = process.env.API_KEY;

  并在 .env 中设置：
  API_KEY=sk_live_123456789

自动修复？(y/n)
```

### 5. 权限检查

**文件权限：**
```
AI: ⚠️  文件权限问题

以下文件权限过于宽松：
  • scripts/deploy.sh (777)
  • config/production.json (666)

建议：
  chmod 755 scripts/deploy.sh
  chmod 644 config/production.json

自动修复权限？(y/n)
```

### 6. 代码规模限制

**单个文件限制：**
```
AI: ⚠️  文件过大警告

文件 src/utils/helpers.ts 包含 850 行代码

建议：
  • 拆分为多个小文件
  • 按功能模块组织
  • 提高代码可维护性

继续？(y/n) 或 "重构这个文件"
```

**单次修改限制：**
```
AI: ⚠️  修改范围过大

本次任务将修改 65 个文件

建议：
  • 拆分为多个小任务
  • 分阶段实施
  • 降低风险

继续？(y/n) 或 "拆分任务"
```

### 7. Git 安全

**防止意外提交：**
```
AI: ⚠️  提交检查

检测到以下文件将被提交：
  ✅ src/api/auth.ts
  ✅ src/components/Login.tsx
  ⚠️  .env.local

.env.local 不应该提交到版本控制

操作：
  • 已自动添加到 .gitignore
  • 已从暂存区移除

继续提交其他文件？(y/n)
```

**分支保护：**
```
AI: ⚠️  分支保护警告

当前在 main 分支，直接提交可能违反团队规范

建议：
  1. 创建功能分支：feature/user-login
  2. 在功能分支开发
  3. 通过 PR 合并到 main

创建新分支？(y/n)
```

### 8. 运行时安全

**资源限制：**
```
AI: ⚠️  资源使用警告

任务运行时间: 45 分钟
CPU 使用率: 85%
内存使用: 2.3 GB

是否继续？(y/n) 或 "优化性能"
```

**网络访问：**
```
AI: ⚠️  网络访问检测

代码尝试访问外部 API：
  • https://api.example.com
  • https://unknown-service.io

建议检查：
  • API 端点是否可信
  • 是否需要添加到白名单

继续？(y/n)
```

### 9. 配置安全检查

**读取安全配置：**
```
AI: 📋 读取安全配置

从 .claude-config.json 加载：
  • 排除文件: 8 个模式
  • 排除目录: 5 个
  • 删除确认阈值: 10 个文件
  • 必须确认操作: 3 类

安全配置已激活 ✅
```

### 10. 审计日志

**记录所有安全相关事件：**
```
[2024-01-01 10:15:00] [SECURITY] 检测到敏感文件: .env
[2024-01-01 10:15:01] [SECURITY] 用户选择: 跳过敏感文件
[2024-01-01 10:20:30] [SECURITY] 危险操作: 删除 15 个文件
[2024-01-01 10:20:45] [SECURITY] 用户确认: 确认删除
[2024-01-01 10:25:00] [SECURITY] 安全扫描: 发现 SQL 注入风险
[2024-01-01 10:25:15] [SECURITY] 自动修复: 使用参数化查询
[2024-01-01 10:30:00] [SECURITY] 提交检查: 排除 .env.local
```

---

## 安全最佳实践

### 1. 定期审查

```bash
# 查看安全日志
"查看安全日志"

# 检查配置
"验证安全配置"

# 审计历史操作
"显示安全审计"
```

### 2. 自定义安全规则

在 `.claude-config.json` 中：
```json
{
  "safety": {
    "excluded_files": [
      ".env*",
      "secrets/*",
      "*.key"
    ],
    "custom_rules": [
      {
        "pattern": "password\\s*=\\s*['\"].*['\"]",
        "message": "硬编码密码",
        "severity": "high",
        "auto_fix": false
      }
    ]
  }
}
```

### 3. 团队安全策略

**共享安全配置：**
```bash
# 团队共享
.claude-config.json  # 提交到仓库

# 个人配置
.claude-config.local.json  # 添加到 .gitignore
```

### 4. CI/CD 集成

```bash
# 在 CI 环境中启用严格模式
export CLAUDE_SAFETY_STRICT=true
export CLAUDE_AUTO_FIX_SECURITY=true
```

---

## 紧急处理

### 如果意外修改了敏感文件

```bash
# 1. 立即停止
"停止"

# 2. 查看修改
git diff

# 3. 撤销修改
git checkout -- .env

# 4. 从检查点恢复
"从上个检查点恢复"
```

### 如果提交了敏感信息

```bash
# 1. 不要 push
# 2. 撤销提交
git reset HEAD~1

# 3. 修改文件
# 4. 重新提交

# 如果已经 push，需要：
# 1. 立即轮换密钥/密码
# 2. 使用 git filter-branch 清理历史（谨慎）
# 3. 通知团队
```
