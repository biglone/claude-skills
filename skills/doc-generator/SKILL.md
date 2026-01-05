---
name: doc-generator
description: 自动生成代码文档、README、API 文档。当用户要求生成文档、写 README、创建 API 文档时使用。
allowed-tools: Read, Grep, Glob
---

# 文档生成器

## README 模板

```markdown
# 项目名称

简短描述项目的用途和特点。

## 功能特性

- 特性 1
- 特性 2
- 特性 3

## 快速开始

### 环境要求

- Node.js >= 18
- npm >= 9

### 安装

```bash
npm install package-name
```

### 使用

```javascript
import { something } from 'package-name';

something.doWork();
```

## 配置

| 选项 | 类型 | 默认值 | 说明 |
|------|------|--------|------|
| option1 | string | 'default' | 说明 |

## API 文档

### `functionName(param1, param2)`

描述函数用途。

**参数**:
- `param1` (string): 参数说明
- `param2` (number): 参数说明

**返回值**: 返回值说明

**示例**:
```javascript
const result = functionName('hello', 42);
```

## 开发

```bash
# 安装依赖
npm install

# 运行测试
npm test

# 构建
npm run build
```

## 贡献指南

1. Fork 本仓库
2. 创建特性分支 (`git checkout -b feature/amazing`)
3. 提交更改 (`git commit -m 'Add amazing feature'`)
4. 推送分支 (`git push origin feature/amazing`)
5. 创建 Pull Request

## License

MIT
```

## JSDoc 注释

```javascript
/**
 * 计算两个数的和
 * @param {number} a - 第一个加数
 * @param {number} b - 第二个加数
 * @returns {number} 两数之和
 * @throws {TypeError} 如果参数不是数字
 * @example
 * // returns 5
 * add(2, 3);
 */
function add(a, b) {
    if (typeof a !== 'number' || typeof b !== 'number') {
        throw new TypeError('Arguments must be numbers');
    }
    return a + b;
}

/**
 * 用户类
 * @class
 * @classdesc 表示系统中的用户
 */
class User {
    /**
     * 创建用户实例
     * @param {Object} options - 用户选项
     * @param {string} options.name - 用户名
     * @param {string} options.email - 邮箱
     * @param {number} [options.age] - 年龄（可选）
     */
    constructor({ name, email, age }) {
        this.name = name;
        this.email = email;
        this.age = age;
    }
}
```

## Python Docstring

```python
def calculate_total(items: list[dict], tax_rate: float = 0.1) -> float:
    """
    计算商品总价（含税）

    根据商品列表计算总价，并加上税费。

    Args:
        items: 商品列表，每个商品包含 price 和 quantity 字段
            示例: [{"price": 10.0, "quantity": 2}]
        tax_rate: 税率，默认为 0.1 (10%)

    Returns:
        含税总价

    Raises:
        ValueError: 如果商品列表为空
        KeyError: 如果商品缺少必要字段

    Examples:
        >>> items = [{"price": 10.0, "quantity": 2}]
        >>> calculate_total(items)
        22.0

        >>> calculate_total(items, tax_rate=0.2)
        24.0
    """
    if not items:
        raise ValueError("Items list cannot be empty")

    subtotal = sum(item["price"] * item["quantity"] for item in items)
    return subtotal * (1 + tax_rate)
```

## TypeScript 接口文档

```typescript
/**
 * 用户配置选项
 */
interface UserOptions {
    /** 用户名，长度 3-50 字符 */
    name: string;
    /** 邮箱地址 */
    email: string;
    /** 年龄，可选 */
    age?: number;
    /** 用户角色 */
    role: 'admin' | 'user' | 'guest';
}

/**
 * 用户服务类
 *
 * @example
 * ```typescript
 * const service = new UserService();
 * const user = await service.getUser('123');
 * ```
 */
class UserService {
    /**
     * 根据 ID 获取用户
     *
     * @param id - 用户 ID
     * @returns 用户对象，如果不存在则返回 null
     * @throws {NotFoundError} 当用户不存在时
     */
    async getUser(id: string): Promise<User | null> {
        // ...
    }
}
```

## OpenAPI/Swagger 文档

```yaml
openapi: 3.0.0
info:
  title: 用户 API
  version: 1.0.0
  description: 用户管理相关接口

paths:
  /users:
    get:
      summary: 获取用户列表
      tags:
        - Users
      parameters:
        - name: page
          in: query
          schema:
            type: integer
            default: 1
      responses:
        '200':
          description: 成功
          content:
            application/json:
              schema:
                type: array
                items:
                  $ref: '#/components/schemas/User'

components:
  schemas:
    User:
      type: object
      required:
        - id
        - name
        - email
      properties:
        id:
          type: string
          description: 用户 ID
        name:
          type: string
          description: 用户名
        email:
          type: string
          format: email
          description: 邮箱地址
```

## 生成原则

1. **简洁明了** - 避免冗余，直达重点
2. **示例优先** - 用示例说明比文字更清晰
3. **保持更新** - 文档需与代码同步
4. **面向用户** - 站在使用者角度编写
5. **结构清晰** - 使用标题、列表、表格组织内容
