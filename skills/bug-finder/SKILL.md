---
name: bug-finder
description: 调试助手，帮助定位和修复 Bug。当用户遇到错误、Bug、异常需要调试时使用。
allowed-tools: Read, Grep, Glob, Bash
---

# Bug 调试助手

## 调试方法论

### 1. 复现问题
- 确定复现步骤
- 记录环境信息
- 找到最小复现案例

### 2. 缩小范围
- 二分法定位
- 检查最近更改
- 隔离可疑代码

### 3. 分析原因
- 查看错误堆栈
- 检查日志输出
- 使用调试工具

### 4. 验证修复
- 编写测试用例
- 确认问题解决
- 检查副作用

## 常见错误类型

### JavaScript/TypeScript

```javascript
// TypeError: Cannot read property 'x' of undefined
// 原因：访问 undefined/null 的属性
// 修复：添加空值检查
const value = obj?.nested?.property ?? defaultValue;

// ReferenceError: x is not defined
// 原因：变量未声明或作用域问题
// 修复：检查变量声明和作用域

// SyntaxError: Unexpected token
// 原因：语法错误
// 修复：检查括号、引号、逗号等

// Maximum call stack size exceeded
// 原因：无限递归
// 修复：检查递归终止条件
function factorial(n) {
    if (n <= 1) return 1;  // 必须有终止条件
    return n * factorial(n - 1);
}

// Promise rejection unhandled
// 原因：Promise 错误未捕获
// 修复：添加 catch 或 try-catch
try {
    await asyncOperation();
} catch (error) {
    handleError(error);
}
```

### Python

```python
# AttributeError: 'NoneType' object has no attribute 'x'
# 原因：对 None 调用属性/方法
# 修复：添加空值检查
if obj is not None:
    obj.method()

# KeyError: 'key'
# 原因：字典中不存在的键
# 修复：使用 get() 或检查键存在
value = d.get('key', default_value)

# IndexError: list index out of range
# 原因：索引越界
# 修复：检查列表长度
if index < len(my_list):
    item = my_list[index]

# ImportError / ModuleNotFoundError
# 原因：模块未安装或路径问题
# 修复：安装模块或检查 PYTHONPATH

# IndentationError
# 原因：缩进不一致
# 修复：统一使用空格或 Tab
```

### 数据库相关

```sql
-- Deadlock
-- 原因：多个事务互相等待
-- 修复：统一加锁顺序，减小事务范围

-- Slow Query
-- 原因：缺少索引或查询不优化
-- 修复：EXPLAIN 分析，添加索引

-- Connection refused
-- 原因：数据库未启动或连接数满
-- 修复：检查服务状态，增加连接池
```

## 调试技巧

### 日志调试
```javascript
// 添加上下文信息
console.log('[UserService.getUser]', { userId, timestamp: Date.now() });

// 使用 console.table 查看数组/对象
console.table(users);

// 使用 console.trace 查看调用栈
console.trace('How did we get here?');

// 条件断点
debugger; // 在代码中设置断点
```

### Git 二分法
```bash
# 使用 git bisect 找出引入 bug 的提交
git bisect start
git bisect bad              # 当前版本有 bug
git bisect good v1.0.0      # 这个版本没有 bug
# Git 会自动切换到中间提交，测试后标记 good/bad
git bisect good  # 或 git bisect bad
# 重复直到找到问题提交
git bisect reset  # 完成后重置
```

### 网络调试
```bash
# 检查端口占用
lsof -i :3000
netstat -tlnp | grep 3000

# 测试连接
curl -v http://localhost:3000/api/health
telnet localhost 3000

# DNS 解析
nslookup example.com
dig example.com
```

## 错误信息解读

```
Error: ENOENT: no such file or directory
→ 文件或目录不存在，检查路径

Error: EACCES: permission denied
→ 权限不足，检查文件权限

Error: EADDRINUSE: address already in use
→ 端口被占用，换端口或杀掉占用进程

Error: ETIMEDOUT: connection timed out
→ 连接超时，检查网络或服务状态

Error: ECONNREFUSED: connection refused
→ 连接被拒绝，服务未启动或防火墙阻止
```

## 输出格式

```markdown
## Bug 分析报告

### 问题描述
[错误信息和现象]

### 复现步骤
1. 步骤一
2. 步骤二
3. ...

### 根本原因
[分析得出的原因]

### 解决方案
```code
// 修复代码
```

### 验证方法
[如何验证问题已修复]

### 预防措施
[如何避免类似问题]
```
