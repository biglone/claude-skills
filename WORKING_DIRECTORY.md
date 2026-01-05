# 工作目录说明

## 默认行为

### ✅ 默认使用当前目录

**`full-auto-development` 默认使用您执行 `claude` 命令所在的当前目录作为工作目录。**

```bash
# 示例 1: 在项目根目录执行
cd /Users/yourname/my-project
claude

# 此时工作目录 = /Users/yourname/my-project
# Claude 会在这个目录下生成文件、读取配置
```

```bash
# 示例 2: 在子目录执行
cd /Users/yourname/my-project/src
claude

# 此时工作目录 = /Users/yourname/my-project/src
# ⚠️  可能不是您想要的位置
```

## 工作目录范围限制（安全零干预模式）

在使用 `.claude-config.safe-zero-intervention.json` 时：

```json
{
  "scope_limits": {
    "working_directory": ".",           // 当前目录
    "allowed_paths": [                  // 只能操作这些子目录
      "src",
      "tests",
      "components",
      "pages",
      "api",
      "lib",
      "utils"
    ],
    "forbidden_paths": [                // 绝对禁止访问
      "/",
      "../",
      "~",
      "/etc",
      "/usr"
    ],
    "path_traversal_prevention": true   // 防止路径穿越攻击
  }
}
```

### 工作原理

```
假设在 /Users/yourname/my-project 执行 claude：

✅ 允许的操作：
  /Users/yourname/my-project/src/components/Login.tsx  ← 在 allowed_paths 中
  /Users/yourname/my-project/tests/login.test.ts       ← 在 allowed_paths 中
  /Users/yourname/my-project/lib/auth.ts               ← 在 allowed_paths 中

❌ 禁止的操作：
  /Users/yourname/my-project/../../etc/passwd          ← 路径穿越
  /Users/yourname/other-project/src/file.ts            ← 超出工作目录
  ~/.ssh/id_rsa                                        ← forbidden_paths
  /etc/hosts                                           ← forbidden_paths
```

## 如何指定工作目录

### 方法 1: 先 cd 到项目目录（推荐）

```bash
cd /path/to/your/project
claude
```

然后说：
```
"全自动开发：实现用户登录功能"
```

### 方法 2: 在配置文件中指定

如果您有多个项目，可以在各项目中创建独立的配置文件：

**项目 A: `/Users/yourname/project-a/.claude-config.json`**
```json
{
  "scope_limits": {
    "working_directory": "/Users/yourname/project-a",
    "allowed_paths": ["src", "tests"]
  }
}
```

**项目 B: `/Users/yourname/project-b/.claude-config.json`**
```json
{
  "scope_limits": {
    "working_directory": "/Users/yourname/project-b",
    "allowed_paths": ["app", "components"]
  }
}
```

### 方法 3: 在提示词中明确说明

```
"在当前目录下全自动开发：实现登录功能"
```

或者

```
"工作目录是当前目录，全自动开发：实现购物车功能"
```

## 验证工作目录

在开始全自动开发前，Claude 会显示工作目录信息：

```
🚀 全自动开发工作流启动

📂 工作目录: /Users/yourname/my-project
📋 允许操作的路径:
   • src/
   • tests/
   • components/
   • pages/
   • lib/

🔒 安全限制:
   • 只能在当前目录及其子目录操作
   • 禁止访问系统目录
   • 防止路径穿越攻击

确认开始？(yes/no)
```

## 不同场景的最佳实践

### 场景 1: 单个项目开发

```bash
# 进入项目目录
cd ~/projects/my-app

# 启动 Claude
claude

# 开始开发
"全自动开发：实现用户注册功能"
```

**工作目录:** `~/projects/my-app`

### 场景 2: Monorepo 中的特定包

```bash
# 进入 monorepo 的某个包
cd ~/projects/monorepo/packages/frontend

# 启动 Claude
claude

# 开发时明确范围
"在当前包中全自动开发：实现 Header 组件"
```

**工作目录:** `~/projects/monorepo/packages/frontend`

### 场景 3: 新项目创建

```bash
# 先创建项目目录
mkdir ~/projects/new-app
cd ~/projects/new-app

# 启动 Claude
claude

# 从零开始
"全自动开发：创建一个 React + TypeScript 项目，实现 TODO 应用"
```

**工作目录:** `~/projects/new-app`

## 工作目录相关的配置选项

### 完整配置示例

```json
{
  "scope_limits": {
    "working_directory": ".",
    "allowed_paths": [
      "src",
      "tests",
      "components",
      "pages",
      "api"
    ],
    "forbidden_paths": [
      "/",
      "../",
      "~",
      "/etc",
      "/usr",
      "/var",
      "/System"
    ],
    "path_traversal_prevention": true,
    "symlink_follow": false
  },

  "safety": {
    "work_directory_only": true,          // 强制只在工作目录内操作
    "allowed_file_patterns": [            // 只允许操作这些文件类型
      "src/**/*",
      "tests/**/*",
      "*.js",
      "*.ts",
      "*.tsx",
      "*.json"
    ],
    "excluded_files": [                   // 排除的文件
      ".env",
      ".env.*",
      "credentials.json"
    ],
    "excluded_directories": [             // 排除的目录
      "node_modules",
      ".git",
      "dist",
      "build"
    ]
  }
}
```

## 常见问题

### Q1: Claude 会修改工作目录之外的文件吗？

**A:** 在安全零干预模式下，**绝对不会**。配置中有多层保护：

1. `working_directory` 限制
2. `allowed_paths` 白名单
3. `forbidden_paths` 黑名单
4. `path_traversal_prevention` 防护

### Q2: 如果我想 Claude 能访问整个项目（包括根目录配置文件）？

**A:** 修改 `allowed_paths`：

```json
{
  "scope_limits": {
    "working_directory": ".",
    "allowed_paths": [
      "src",
      "tests",
      ".",              // ← 允许根目录文件
      "config"
    ]
  }
}
```

或者使用通配符：

```json
{
  "safety": {
    "allowed_file_patterns": [
      "**/*",           // 允许所有文件（不推荐）
      "!.env",          // 但排除 .env
      "!secrets/**"     // 排除 secrets 目录
    ]
  }
}
```

### Q3: Claude 会创建新目录吗？

**A:** 会，但有限制：

```json
{
  "safety": {
    "constraints": {
      "max_directory_depth": 5,     // 最多 5 层深度
      "max_files_created": 20       // 最多创建 20 个文件
    }
  }
}
```

### Q4: 如何在不同项目间切换？

**方法 1: 退出 Claude，cd 到新项目，重新启动**
```bash
# 在项目 A
cd ~/project-a
claude
# ... 工作 ...
# exit

# 切换到项目 B
cd ~/project-b
claude
```

**方法 2: 在 Claude 内部明确说明**
```
"切换工作目录到 ~/project-b，然后全自动开发：..."
```

⚠️  注意：方法 2 可能受到 `scope_limits` 限制，推荐使用方法 1。

### Q5: 能否同时操作多个项目？

**A:** 不推荐。应该：

1. 每个项目单独开启一个 Claude 会话
2. 使用不同的终端窗口
3. 各自有独立的工作目录和配置

## 测试工作目录设置

创建一个测试脚本验证配置：

```bash
#!/bin/bash
# test-workdir.sh

echo "当前目录: $(pwd)"
echo ""
echo "测试文件操作："

# 测试 1: 允许的目录
echo "1. 尝试在 src/ 创建文件 (应该成功)"
# ... Claude 会测试 ...

# 测试 2: 禁止的目录
echo "2. 尝试访问 /etc (应该被阻止)"
# ... Claude 会测试 ...

# 测试 3: 路径穿越
echo "3. 尝试 ../ 路径穿越 (应该被阻止)"
# ... Claude 会测试 ...
```

在 Claude 中运行：
```
"帮我测试工作目录的安全限制是否生效"
```

## 推荐配置

### 🟢 保守模式（推荐用于团队项目）

```json
{
  "scope_limits": {
    "working_directory": ".",
    "allowed_paths": ["src", "tests"],
    "path_traversal_prevention": true
  },
  "safety": {
    "work_directory_only": true,
    "require_confirmation": ["delete", "refactor"]
  }
}
```

### 🟡 平衡模式（推荐用于个人项目）

```json
{
  "scope_limits": {
    "working_directory": ".",
    "allowed_paths": ["src", "tests", "components", "pages", "lib", "utils"],
    "path_traversal_prevention": true
  },
  "safety": {
    "work_directory_only": true,
    "delete_confirmation_threshold": 5
  }
}
```

### 🔴 激进模式（仅用于实验项目，不推荐）

```json
{
  "scope_limits": {
    "working_directory": ".",
    "allowed_paths": ["**/*"],       // 允许所有路径
    "path_traversal_prevention": false
  },
  "safety": {
    "work_directory_only": false,
    "require_confirmation": []
  }
}
```

## 总结

| 问题 | 答案 |
|------|------|
| **默认工作目录是？** | 执行 `claude` 命令的当前目录 (`pwd`) |
| **需要手动指定吗？** | ❌ 不需要，自动使用当前目录 |
| **如何切换项目？** | `cd` 到新项目目录，重新启动 `claude` |
| **能操作工作目录外的文件吗？** | ❌ 在安全模式下不能，有多层防护 |
| **如何验证工作目录？** | Claude 启动时会显示工作目录和权限范围 |

**核心建议：**
1. ✅ 始终在项目根目录执行 `claude`
2. ✅ 使用 `.claude-config.json` 配置允许的路径
3. ✅ 验证工作目录信息再开始开发
4. ✅ 一个项目一个 Claude 会话
