# Git 工作流集成

将全自动开发与 Git 最佳实践结合。

## 配置 Git 集成

```json
{
  "git": {
    "auto_stage": true,
    "commit_message_template": "feat: {summary}\n\n{details}",
    "branch_naming": "feature/{feature-name}",
    "require_hooks": true,
    "pre_commit_checks": ["lint", "test"]
  }
}
```

## 推荐工作流

### 1. 功能分支流程

```bash
# AI 会自动创建功能分支
"全自动开发：实现用户登录"

# AI 提示：
AI: 建议创建新分支：feature/user-login
    创建？(y/n)

你: y

# AI 会：
# 1. 创建并切换到新分支
# 2. 开发功能
# 3. 本地提交（不push）
```

### 2. Commit 规范

**自动生成符合规范的提交信息：**

```
feat: implement user authentication

- Add login and registration components
- Implement JWT-based authentication  
- Add user session management

🤖 Generated with Claude Code
Co-Authored-By: Claude Sonnet 4.5 <noreply@anthropic.com>
```

**支持的类型：**
- `feat` - 新功能
- `fix` - Bug修复
- `docs` - 文档
- `refactor` - 重构
- `test` - 测试
- `chore` - 构建/工具

### 3. PR 流程

```bash
# 开发完成后
"创建 Pull Request"

# AI 会：
# 1. Push 到远程分支
# 2. 使用 gh CLI 创建 PR
# 3. 自动生成 PR 描述
```

## Git Hooks 集成

### Pre-commit Hook

```bash
# .husky/pre-commit
npm run lint
npm test
```

配置：
```json
{
  "git": {
    "pre_commit_checks": ["lint", "test"]
  }
}
```

### Commit-msg Hook

验证提交信息格式：
```bash
# .husky/commit-msg
npx commitlint --edit $1
```

## 最佳实践

1. ✅ 每个功能独立分支
2. ✅ 使用语义化的提交信息  
3. ✅ 提交前运行测试
4. ✅ 通过 PR 合并代码
5. ✅ 保护 main/master 分支

## 常见场景

### 场景 1：修复 Bug

```bash
"全自动开发：修复登录页面的XSS漏洞"

# AI 创建: fix/login-xss-vulnerability
# 提交信息: "fix: resolve XSS vulnerability in login page"
```

### 场景 2：添加功能

```bash
"全自动开发：添加用户头像上传功能"

# AI 创建: feature/avatar-upload
# 提交信息: "feat: add user avatar upload feature"
```

### 场景 3：重构代码

```bash
"重构用户认证模块"

# AI 创建: refactor/user-auth
# 提交信息: "refactor: improve user authentication module structure"
```
