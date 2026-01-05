---
name: knowledge-base
description: 个人知识库管理和组织。当用户要求整理知识、建立知识体系、管理学习资料时使用。
allowed-tools: Read, Grep, Glob
related-skills: note-taker, learning-tracker, concept-explainer
---

# 知识库管理助手

## 知识库结构

### 推荐目录结构
```
knowledge-base/
├── 00-Inbox/              # 收集箱（待整理）
├── 01-Projects/           # 进行中的项目
│   ├── project-a/
│   └── project-b/
├── 02-Areas/              # 持续关注的领域
│   ├── career/            # 职业发展
│   ├── health/            # 健康
│   ├── finance/           # 财务
│   └── relationships/     # 人际关系
├── 03-Resources/          # 主题资源
│   ├── programming/
│   │   ├── javascript/
│   │   ├── python/
│   │   └── databases/
│   ├── design/
│   └── business/
├── 04-Archives/           # 已完成/归档
├── Templates/             # 模板
└── README.md              # 知识库说明
```

### PARA 方法
```
P - Projects (项目)
    有明确目标和截止日期的任务集合

A - Areas (领域)
    需要持续维护的责任范围

R - Resources (资源)
    感兴趣的主题或可能有用的资料

A - Archives (归档)
    已完成或不再活跃的内容
```

## 知识条目模板

### 概念卡片
```markdown
---
title: [概念名称]
category: [分类]
tags: [标签1, 标签2]
created: YYYY-MM-DD
updated: YYYY-MM-DD
status: draft | review | final
---

# [概念名称]

## 一句话定义
[简洁定义]

## 详细解释
[展开说明]

## 核心要点
1.
2.
3.

## 示例
[具体例子]

## 应用场景
- 场景1
- 场景2

## 常见误区
- ❌ 误区：
- ✅ 正确：

## 相关概念
- [[相关概念1]] - 关系说明
- [[相关概念2]] - 关系说明

## 参考资料
- [来源1](链接)
- [来源2](链接)
```

### 技能卡片
```markdown
---
title: [技能名称]
level: beginner | intermediate | advanced
tags: [标签]
---

# [技能名称]

## 技能描述
[这个技能是什么，为什么重要]

## 能力等级

### 🌱 入门级
- [ ] 能够...
- [ ] 了解...

### 🌿 中级
- [ ] 能够独立...
- [ ] 掌握...

### 🌳 高级
- [ ] 能够指导他人...
- [ ] 精通...

## 学习路径
1. 第一步：[学习内容]
2. 第二步：[学习内容]
3. 第三步：[学习内容]

## 推荐资源
- 📚 书籍：
- 🎓 课程：
- 🔗 网站：

## 实践项目
- [ ] 项目1
- [ ] 项目2

## 我的进度
- 当前等级：
- 学习记录：
```

### 问题解决卡片
```markdown
---
title: [问题描述]
category: troubleshooting
tags: [相关技术]
---

# 问题：[简短描述]

## 问题现象
[详细描述问题]

## 环境信息
- 系统：
- 版本：
- 相关配置：

## 解决方案

### 方案1（推荐）
```code
解决代码/步骤
```

### 方案2
[备选方案]

## 根本原因
[为什么会出现这个问题]

## 预防措施
[如何避免再次发生]

## 参考链接
- [链接]
```

## 知识管理流程

### 1. 收集 (Capture)
```
来源：
- 阅读的文章/书籍
- 学习的课程
- 工作中的经验
- 灵感和想法

原则：
- 快速记录，不追求完美
- 记录来源，方便追溯
- 先放入 Inbox，稍后整理
```

### 2. 整理 (Organize)
```
定期处理 Inbox：
- 决定保留还是删除
- 分类到合适的位置
- 添加标签和元数据
- 建立与其他笔记的链接
```

### 3. 提炼 (Distill)
```
加工原始笔记：
- 提取核心要点
- 用自己的话重写
- 添加个人见解
- 创建摘要和索引
```

### 4. 表达 (Express)
```
输出知识：
- 写博客文章
- 制作教程
- 分享给他人
- 应用到项目中
```

## 标签系统

### 标签类型
```
内容类型：#concept #tutorial #reference #troubleshooting
状态标签：#draft #review #final #archived
优先级：#important #todo #someday
来源：#book #course #article #experience
```

### 标签命名规范
```
- 使用小写
- 使用连字符连接：#machine-learning
- 层级用斜杠：#programming/python
- 保持简洁：3个单词以内
```

## 定期维护

### 每周回顾
```markdown
## 本周知识库回顾

### 新增内容
- [ ] 整理 Inbox 中的 X 条笔记

### 需要更新
- [ ] 更新 [过时的内容]

### 链接检查
- [ ] 修复断开的链接

### 下周计划
- 深入学习：[主题]
- 整理输出：[内容]
```

### 每月整理
```
- 归档不再活跃的项目
- 合并重复内容
- 更新索引和目录
- 检查知识结构的完整性
```

## 输出格式

管理知识库时，提供：
1. **结构建议** - 合理的目录组织
2. **模板** - 标准化的条目格式
3. **标签方案** - 统一的分类体系
4. **关联建议** - 知识点之间的联系
5. **维护计划** - 定期回顾清单

## 相关 Skills
- `note-taker` - 笔记记录和整理
- `learning-tracker` - 追踪学习进度
- `concept-explainer` - 深入理解概念
