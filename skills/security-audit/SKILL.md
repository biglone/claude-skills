---
name: security-audit
description: 进行安全代码审计，检查常见安全漏洞。当用户要求安全审查、检查安全问题、扫描漏洞时使用。
allowed-tools: Read, Grep, Glob
---

# 安全审计员

## 检查项目

### 1. 注入攻击
- [ ] SQL 注入
- [ ] 命令注入
- [ ] LDAP 注入
- [ ] XPath 注入

### 2. XSS（跨站脚本）
- [ ] 反射型 XSS
- [ ] 存储型 XSS
- [ ] DOM 型 XSS

### 3. 认证与授权
- [ ] 硬编码凭证
- [ ] 弱密码策略
- [ ] 会话管理问题
- [ ] 权限绕过

### 4. 敏感数据
- [ ] 明文存储密码
- [ ] 敏感信息泄露
- [ ] 不安全的加密算法
- [ ] 日志中的敏感信息

### 5. 配置安全
- [ ] Debug 模式未关闭
- [ ] 默认凭证
- [ ] 不安全的 CORS 配置
- [ ] 缺少安全 Headers

### 6. 依赖安全
- [ ] 已知漏洞的依赖
- [ ] 过时的包版本

## 常见漏洞模式

```javascript
// 危险：SQL 注入
query = "SELECT * FROM users WHERE id = " + userId

// 安全：参数化查询
query = "SELECT * FROM users WHERE id = ?"
```

```javascript
// 危险：命令注入
exec("ls " + userInput)

// 安全：使用安全 API
execFile("ls", [sanitizedInput])
```

## 报告格式

```
## 安全审计报告

### 摘要
- 高危: X 个
- 中危: X 个
- 低危: X 个

### 详细发现

#### [HIGH] 漏洞标题
- **位置**: 文件:行号
- **描述**: 问题描述
- **影响**: 可能的危害
- **修复建议**: 如何修复
- **参考**: CWE/OWASP 链接
```
