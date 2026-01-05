---
name: performance-optimizer
description: 性能分析和优化建议。当用户要求优化性能、提升速度、减少内存使用时使用。
allowed-tools: Read, Grep, Glob, Bash
---

# 性能优化专家

## 性能优化清单

### 1. 算法与数据结构
- [ ] 使用合适的数据结构（Map vs Object, Set vs Array）
- [ ] 避免 O(n²) 及更高复杂度
- [ ] 使用索引优化查找
- [ ] 考虑空间换时间（缓存/记忆化）

### 2. 前端性能
- [ ] 代码分割和懒加载
- [ ] 图片优化（压缩、WebP、懒加载）
- [ ] 减少重排重绘
- [ ] 虚拟滚动（长列表）
- [ ] Web Workers（计算密集型）
- [ ] 资源预加载/预连接

### 3. 后端性能
- [ ] 数据库查询优化
- [ ] 添加适当索引
- [ ] 使用缓存（Redis/Memcached）
- [ ] 连接池管理
- [ ] 异步处理
- [ ] 批量操作

### 4. 网络性能
- [ ] 启用 Gzip/Brotli 压缩
- [ ] 使用 CDN
- [ ] HTTP/2 或 HTTP/3
- [ ] 减少请求数量
- [ ] 合理设置缓存策略

## 常见性能问题

### JavaScript 性能

```javascript
// ❌ 低效：频繁 DOM 操作
for (let i = 0; i < 1000; i++) {
    document.body.innerHTML += '<div>' + i + '</div>';
}

// ✅ 高效：批量 DOM 操作
const fragment = document.createDocumentFragment();
for (let i = 0; i < 1000; i++) {
    const div = document.createElement('div');
    div.textContent = i;
    fragment.appendChild(div);
}
document.body.appendChild(fragment);
```

```javascript
// ❌ 低效：数组中查找
const arr = [1, 2, 3, ..., 10000];
arr.includes(9999); // O(n)

// ✅ 高效：使用 Set
const set = new Set([1, 2, 3, ..., 10000]);
set.has(9999); // O(1)
```

```javascript
// ❌ 低效：重复计算
function Component({ items }) {
    // 每次渲染都重新计算
    const total = items.reduce((sum, item) => sum + item.price, 0);
    return <div>{total}</div>;
}

// ✅ 高效：记忆化
function Component({ items }) {
    const total = useMemo(
        () => items.reduce((sum, item) => sum + item.price, 0),
        [items]
    );
    return <div>{total}</div>;
}
```

### 数据库优化

```sql
-- ❌ 低效：SELECT *
SELECT * FROM users WHERE status = 'active';

-- ✅ 高效：只选需要的列
SELECT id, name, email FROM users WHERE status = 'active';

-- ❌ 低效：N+1 查询
SELECT * FROM orders;
-- 然后循环查询每个订单的用户
SELECT * FROM users WHERE id = ?;

-- ✅ 高效：JOIN 或预加载
SELECT o.*, u.name as user_name
FROM orders o
JOIN users u ON o.user_id = u.id;

-- 添加索引
CREATE INDEX idx_users_status ON users(status);
CREATE INDEX idx_orders_user_id ON orders(user_id);
```

### Python 性能

```python
# ❌ 低效：字符串拼接
result = ""
for i in range(10000):
    result += str(i)

# ✅ 高效：使用 join
result = "".join(str(i) for i in range(10000))

# ❌ 低效：列表中查找
items = list(range(10000))
if 9999 in items:  # O(n)
    pass

# ✅ 高效：使用集合
items = set(range(10000))
if 9999 in items:  # O(1)
    pass

# ❌ 低效：重复计算属性
for item in items:
    if item.expensive_property > threshold:  # 每次都计算
        process(item)

# ✅ 高效：缓存属性
from functools import cached_property

class Item:
    @cached_property
    def expensive_property(self):
        return heavy_computation()
```

## 性能分析工具

### 前端
- Chrome DevTools Performance
- Lighthouse
- WebPageTest
- Bundle Analyzer

### 后端
- 数据库 EXPLAIN
- APM 工具（New Relic, Datadog）
- 火焰图（Flame Graph）
- 内存分析器

### 命令行
```bash
# Node.js 性能分析
node --prof app.js
node --prof-process isolate-*.log > profile.txt

# Python 性能分析
python -m cProfile -s cumtime script.py
python -m memory_profiler script.py
```

## 输出格式

```markdown
## 性能分析报告

### 发现的问题
| 位置 | 问题类型 | 影响程度 | 当前耗时 |
|------|----------|----------|----------|

### 优化建议

#### 1. [问题名称]
- **位置**: 文件:行号
- **问题**: 问题描述
- **影响**: 性能影响说明
- **方案**: 优化方案
- **预期收益**: 优化后预期效果

#### 2. ...

### 优先级排序
1. P0 - 立即优化（影响大、改动小）
2. P1 - 近期优化
3. P2 - 长期优化

### 基准测试建议
提供可量化的测试方案
```
