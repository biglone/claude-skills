---
name: sql-helper
description: SQL 查询编写、优化和解释。当用户要求写 SQL、优化查询、解释 SQL 语句时使用。
allowed-tools: Read, Grep, Glob
---

# SQL 助手

## 基础查询

### SELECT 语句
```sql
-- 基本查询
SELECT column1, column2 FROM table_name;

-- 条件过滤
SELECT * FROM users WHERE age > 18 AND status = 'active';

-- 排序
SELECT * FROM users ORDER BY created_at DESC;

-- 限制数量
SELECT * FROM users LIMIT 10 OFFSET 20;

-- 去重
SELECT DISTINCT country FROM users;

-- 别名
SELECT first_name AS name, email AS contact FROM users;
```

### WHERE 条件
```sql
-- 比较运算符
WHERE age > 18
WHERE age >= 18
WHERE age <> 18  -- 不等于
WHERE age BETWEEN 18 AND 30

-- 逻辑运算符
WHERE age > 18 AND status = 'active'
WHERE age > 18 OR status = 'vip'
WHERE NOT status = 'banned'

-- 模式匹配
WHERE name LIKE 'John%'      -- 以 John 开头
WHERE name LIKE '%son'       -- 以 son 结尾
WHERE name LIKE '%oh%'       -- 包含 oh
WHERE name LIKE 'J_hn'       -- J + 任意单字符 + hn

-- 空值检查
WHERE email IS NULL
WHERE email IS NOT NULL

-- 列表匹配
WHERE country IN ('US', 'UK', 'CA')
WHERE id NOT IN (1, 2, 3)
```

### JOIN 连接
```sql
-- INNER JOIN: 返回两表匹配的行
SELECT u.name, o.order_id
FROM users u
INNER JOIN orders o ON u.id = o.user_id;

-- LEFT JOIN: 返回左表所有行
SELECT u.name, o.order_id
FROM users u
LEFT JOIN orders o ON u.id = o.user_id;

-- RIGHT JOIN: 返回右表所有行
SELECT u.name, o.order_id
FROM users u
RIGHT JOIN orders o ON u.id = o.user_id;

-- FULL OUTER JOIN: 返回两表所有行
SELECT u.name, o.order_id
FROM users u
FULL OUTER JOIN orders o ON u.id = o.user_id;

-- 多表连接
SELECT u.name, o.order_id, p.product_name
FROM users u
JOIN orders o ON u.id = o.user_id
JOIN order_items oi ON o.id = oi.order_id
JOIN products p ON oi.product_id = p.id;
```

### 聚合函数
```sql
-- 常用聚合函数
SELECT
    COUNT(*) AS total,
    COUNT(DISTINCT user_id) AS unique_users,
    SUM(amount) AS total_amount,
    AVG(amount) AS avg_amount,
    MAX(amount) AS max_amount,
    MIN(amount) AS min_amount
FROM orders;

-- 分组聚合
SELECT
    user_id,
    COUNT(*) AS order_count,
    SUM(amount) AS total_spent
FROM orders
GROUP BY user_id
HAVING COUNT(*) > 5;  -- 过滤分组结果
```

### 子查询
```sql
-- WHERE 中的子查询
SELECT * FROM users
WHERE id IN (SELECT user_id FROM orders WHERE amount > 100);

-- FROM 中的子查询
SELECT avg_by_user.user_id, avg_by_user.avg_amount
FROM (
    SELECT user_id, AVG(amount) AS avg_amount
    FROM orders
    GROUP BY user_id
) AS avg_by_user
WHERE avg_by_user.avg_amount > 50;

-- EXISTS 子查询
SELECT * FROM users u
WHERE EXISTS (
    SELECT 1 FROM orders o WHERE o.user_id = u.id
);
```

### 窗口函数
```sql
-- ROW_NUMBER: 行号
SELECT
    name,
    department,
    salary,
    ROW_NUMBER() OVER (PARTITION BY department ORDER BY salary DESC) AS rank
FROM employees;

-- RANK / DENSE_RANK: 排名
SELECT
    name,
    salary,
    RANK() OVER (ORDER BY salary DESC) AS rank,
    DENSE_RANK() OVER (ORDER BY salary DESC) AS dense_rank
FROM employees;

-- 累计求和
SELECT
    date,
    amount,
    SUM(amount) OVER (ORDER BY date) AS running_total
FROM sales;

-- 移动平均
SELECT
    date,
    amount,
    AVG(amount) OVER (ORDER BY date ROWS BETWEEN 2 PRECEDING AND CURRENT ROW) AS moving_avg
FROM sales;
```

## 数据修改

```sql
-- 插入
INSERT INTO users (name, email) VALUES ('John', 'john@example.com');
INSERT INTO users (name, email) VALUES
    ('John', 'john@example.com'),
    ('Jane', 'jane@example.com');

-- 更新
UPDATE users SET status = 'inactive' WHERE last_login < '2023-01-01';

-- 删除
DELETE FROM users WHERE status = 'deleted';

-- UPSERT (MySQL)
INSERT INTO users (id, name, email) VALUES (1, 'John', 'john@example.com')
ON DUPLICATE KEY UPDATE name = VALUES(name), email = VALUES(email);

-- UPSERT (PostgreSQL)
INSERT INTO users (id, name, email) VALUES (1, 'John', 'john@example.com')
ON CONFLICT (id) DO UPDATE SET name = EXCLUDED.name, email = EXCLUDED.email;
```

## 性能优化

### 索引
```sql
-- 创建索引
CREATE INDEX idx_users_email ON users(email);
CREATE INDEX idx_orders_user_date ON orders(user_id, created_at);

-- 唯一索引
CREATE UNIQUE INDEX idx_users_email ON users(email);

-- 查看执行计划
EXPLAIN SELECT * FROM users WHERE email = 'john@example.com';
EXPLAIN ANALYZE SELECT * FROM users WHERE email = 'john@example.com';
```

### 优化技巧
```sql
-- ❌ 避免 SELECT *
SELECT * FROM users;
-- ✅ 只选需要的列
SELECT id, name, email FROM users;

-- ❌ 避免在 WHERE 中对列使用函数
SELECT * FROM users WHERE YEAR(created_at) = 2024;
-- ✅ 使用范围查询
SELECT * FROM users WHERE created_at >= '2024-01-01' AND created_at < '2025-01-01';

-- ❌ 避免 NOT IN
SELECT * FROM users WHERE id NOT IN (SELECT user_id FROM banned_users);
-- ✅ 使用 LEFT JOIN + IS NULL
SELECT u.* FROM users u
LEFT JOIN banned_users b ON u.id = b.user_id
WHERE b.user_id IS NULL;

-- 批量插入优于循环插入
INSERT INTO users (name, email) VALUES
    ('User1', 'user1@example.com'),
    ('User2', 'user2@example.com'),
    ...;
```

## 输出格式

```markdown
## SQL 查询

**需求**: [需求描述]

**SQL**:
```sql
-- 查询语句
```

**解释**:
1. [逐步解释查询逻辑]
2. ...

**优化建议**:
- [如果有性能考虑]

**示例结果**:
| 列1 | 列2 | ... |
|-----|-----|-----|
| 值1 | 值2 | ... |
```
