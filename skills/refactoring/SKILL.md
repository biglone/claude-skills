---
name: refactoring
description: 代码重构建议，识别代码异味并提供改进方案。当用户要求重构代码、改善代码质量、识别代码异味时使用。
allowed-tools: Read, Grep, Glob
---

# 代码重构助手

## 代码异味识别

### 1. 臃肿类 (Bloaters)
- **过长方法** - 方法超过 20 行
- **过大类** - 类职责过多
- **过长参数列表** - 参数超过 3 个
- **数据泥团** - 总是一起出现的数据组

### 2. 滥用面向对象 (OO Abusers)
- **Switch 语句** - 可用多态替代
- **临时字段** - 仅在特定情况使用的字段
- **被拒绝的遗赠** - 子类不使用父类方法
- **平行继承** - 创建子类时必须创建另一个子类

### 3. 变革障碍 (Change Preventers)
- **发散式变化** - 一个类因多种原因修改
- **霰弹式修改** - 一个变化影响多个类
- **平行继承体系** - 同上

### 4. 非必要 (Dispensables)
- **注释过多** - 代码需要大量注释解释
- **重复代码** - 相似代码出现多处
- **冗余类** - 类做的事太少
- **死代码** - 未使用的代码

### 5. 耦合 (Couplers)
- **依恋情结** - 方法更多使用其他类的数据
- **不当亲密** - 类过度了解另一个类
- **消息链** - a.b().c().d()
- **中间人** - 类只做委托

## 重构技术

### 提取方法
```javascript
// 重构前
function printOwing() {
    printBanner();
    // print details
    console.log("name: " + name);
    console.log("amount: " + getOutstanding());
}

// 重构后
function printOwing() {
    printBanner();
    printDetails(getOutstanding());
}

function printDetails(outstanding) {
    console.log("name: " + name);
    console.log("amount: " + outstanding);
}
```

### 提取变量
```javascript
// 重构前
if (platform.toUpperCase().indexOf("MAC") > -1 &&
    browser.toUpperCase().indexOf("IE") > -1 &&
    wasInitialized() && resize > 0) {
    // ...
}

// 重构后
const isMacOS = platform.toUpperCase().indexOf("MAC") > -1;
const isIE = browser.toUpperCase().indexOf("IE") > -1;
const wasResized = resize > 0;

if (isMacOS && isIE && wasInitialized() && wasResized) {
    // ...
}
```

### 用多态替代条件
```javascript
// 重构前
function getSpeed(type) {
    switch (type) {
        case 'european': return getBaseSpeed();
        case 'african': return getBaseSpeed() - getLoadFactor();
        case 'norwegian_blue': return isNailed ? 0 : getBaseSpeed();
    }
}

// 重构后
class Bird {
    getSpeed() { return getBaseSpeed(); }
}
class European extends Bird {}
class African extends Bird {
    getSpeed() { return super.getSpeed() - getLoadFactor(); }
}
class NorwegianBlue extends Bird {
    getSpeed() { return this.isNailed ? 0 : super.getSpeed(); }
}
```

## 输出格式

```
## 重构分析报告

### 识别的代码异味
| 文件 | 行号 | 异味类型 | 严重程度 | 描述 |
|------|------|----------|----------|------|

### 重构建议
1. **[异味类型]** 文件:行号
   - 问题: 描述问题
   - 建议: 重构方案
   - 示例: 重构前后代码对比

### 优先级
- P0: 立即修复
- P1: 近期修复
- P2: 有空修复
```

## SOLID 原则检查

- **S** - 单一职责：类是否只有一个变化原因？
- **O** - 开闭原则：是否对扩展开放，对修改关闭？
- **L** - 里氏替换：子类是否可以替换父类？
- **I** - 接口隔离：接口是否足够小？
- **D** - 依赖倒置：是否依赖抽象而非具体？
