---
name: api-designer
description: REST/GraphQL API 设计，遵循最佳实践。当用户要求设计 API、定义接口、创建 API 文档时使用。
allowed-tools: Read, Grep, Glob
---

# API 设计师

## RESTful API 设计原则

### 1. 资源命名
```
# 好的示例
GET    /users              # 获取用户列表
GET    /users/123          # 获取单个用户
POST   /users              # 创建用户
PUT    /users/123          # 更新用户
DELETE /users/123          # 删除用户

# 嵌套资源
GET    /users/123/orders   # 获取用户的订单
POST   /users/123/orders   # 为用户创建订单

# 避免
GET    /getUsers           # 动词不应出现在 URL
GET    /user/list          # 应使用复数
POST   /users/create       # 动作应由 HTTP 方法表示
```

### 2. HTTP 方法语义
| 方法 | 用途 | 幂等 | 安全 |
|------|------|------|------|
| GET | 获取资源 | 是 | 是 |
| POST | 创建资源 | 否 | 否 |
| PUT | 全量更新 | 是 | 否 |
| PATCH | 部分更新 | 否 | 否 |
| DELETE | 删除资源 | 是 | 否 |

### 3. HTTP 状态码
```
# 成功
200 OK              - 请求成功
201 Created         - 资源创建成功
204 No Content      - 成功但无返回内容

# 客户端错误
400 Bad Request     - 请求参数错误
401 Unauthorized    - 未认证
403 Forbidden       - 无权限
404 Not Found       - 资源不存在
409 Conflict        - 资源冲突
422 Unprocessable   - 验证错误

# 服务端错误
500 Internal Error  - 服务器错误
503 Unavailable     - 服务不可用
```

### 4. 响应格式
```json
// 成功响应
{
    "data": {
        "id": 123,
        "name": "John",
        "email": "john@example.com"
    },
    "meta": {
        "timestamp": "2024-01-01T00:00:00Z"
    }
}

// 列表响应（带分页）
{
    "data": [...],
    "meta": {
        "total": 100,
        "page": 1,
        "per_page": 20,
        "total_pages": 5
    },
    "links": {
        "self": "/users?page=1",
        "next": "/users?page=2",
        "last": "/users?page=5"
    }
}

// 错误响应
{
    "error": {
        "code": "VALIDATION_ERROR",
        "message": "Validation failed",
        "details": [
            {"field": "email", "message": "Invalid email format"}
        ]
    }
}
```

### 5. 查询参数
```
# 分页
GET /users?page=1&per_page=20

# 排序
GET /users?sort=created_at&order=desc

# 过滤
GET /users?status=active&role=admin

# 字段选择
GET /users?fields=id,name,email

# 搜索
GET /users?q=john

# 关联加载
GET /users?include=orders,profile
```

## GraphQL 设计

### Schema 设计
```graphql
type User {
    id: ID!
    name: String!
    email: String!
    orders: [Order!]!
    createdAt: DateTime!
}

type Order {
    id: ID!
    user: User!
    items: [OrderItem!]!
    total: Float!
    status: OrderStatus!
}

enum OrderStatus {
    PENDING
    PAID
    SHIPPED
    DELIVERED
}

type Query {
    user(id: ID!): User
    users(filter: UserFilter, pagination: Pagination): UserConnection!
}

type Mutation {
    createUser(input: CreateUserInput!): User!
    updateUser(id: ID!, input: UpdateUserInput!): User!
    deleteUser(id: ID!): Boolean!
}
```

## API 版本控制

```
# URL 路径版本（推荐）
GET /v1/users
GET /v2/users

# Header 版本
GET /users
Accept: application/vnd.api+json; version=1

# Query 参数版本
GET /users?version=1
```

## 安全设计

### 认证方式
- **API Key** - 简单场景
- **JWT** - 无状态认证
- **OAuth 2.0** - 第三方授权

### 安全 Headers
```
X-Content-Type-Options: nosniff
X-Frame-Options: DENY
X-XSS-Protection: 1; mode=block
Content-Security-Policy: default-src 'self'
```

### Rate Limiting
```
X-RateLimit-Limit: 100
X-RateLimit-Remaining: 95
X-RateLimit-Reset: 1640000000
```

## 输出格式

设计 API 时，输出应包含：

```markdown
## API 设计文档

### 概述
[API 用途说明]

### Base URL
`https://api.example.com/v1`

### 认证
[认证方式说明]

### Endpoints

#### GET /resource
**描述**: 获取资源列表

**参数**:
| 参数 | 类型 | 必填 | 说明 |
|------|------|------|------|

**响应**:
```json
{...}
```

**错误码**:
| 状态码 | 说明 |
|--------|------|
```
