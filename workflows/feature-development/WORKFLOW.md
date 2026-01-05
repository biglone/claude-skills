---
name: feature-development
description: 功能开发工作流。从需求分析到功能上线的完整开发流程。
skills:
  - api-designer
  - doc-generator
  - test-generator
  - code-reviewer
  - changelog-generator
  - pr-description
---

# 功能开发工作流

## 工作流概述

```
需求分析 → API设计 → 编码实现 → 测试编写 → 代码审查 → 文档更新 → 发布
```

## 流程步骤

### 步骤 1：API 设计
**使用 Skill**：`api-designer`

设计功能的接口：
- RESTful API 设计
- 请求/响应格式
- 错误处理

**触发方式**：
```
请帮我设计 [功能名称] 的 API 接口
```

**输出**：
- API 端点列表
- 请求/响应示例
- 错误码定义

### 步骤 2：代码实现
*（开发者手动完成）*

根据 API 设计进行编码：
- 实现业务逻辑
- 处理边界情况
- 编写内联注释

### 步骤 3：测试编写
**使用 Skill**：`test-generator`

生成测试用例：
- 单元测试
- 集成测试
- 边界测试

**触发方式**：
```
请为这个功能生成测试用例
```

### 步骤 4：代码审查
**使用 Skill**：`code-reviewer`

审查代码质量：
- 代码规范
- 最佳实践
- 潜在问题

**触发方式**：
```
请审查这个功能的实现代码
```

### 步骤 5：文档生成
**使用 Skill**：`doc-generator`

生成/更新文档：
- API 文档
- 使用说明
- 示例代码

**触发方式**：
```
请为这个功能生成文档
```

### 步骤 6：更新日志
**使用 Skill**：`changelog-generator`

更新 CHANGELOG：
- 新功能描述
- Breaking Changes
- 升级指南

**触发方式**：
```
请生成这个版本的 changelog
```

### 步骤 7：PR 提交
**使用 Skill**：`pr-description`

创建 Pull Request：
- 完整的 PR 描述
- 测试说明
- 截图/演示

**触发方式**：
```
请帮我写这个功能的 PR 描述
```

## 快速启动

### 完整流程
```
我要开发一个 [功能名称] 功能，请帮我：
1. 设计 API
2. 生成测试框架
3. 准备文档模板
```

### 发布准备
```
功能开发完成了，请帮我准备发布：
1. 审查代码
2. 更新文档
3. 生成 changelog
4. 写 PR 描述
```

## 功能开发检查清单

### 开发前
- [ ] 需求已明确
- [ ] API 设计已完成
- [ ] 技术方案已确定

### 开发中
- [ ] 代码实现完成
- [ ] 单元测试通过
- [ ] 集成测试通过
- [ ] 代码审查通过

### 发布前
- [ ] 文档已更新
- [ ] Changelog 已更新
- [ ] PR 描述完整
- [ ] 相关人员已通知

## 相关 Skills

| Skill | 阶段 | 作用 |
|-------|------|------|
| api-designer | 设计 | API 接口设计 |
| test-generator | 开发 | 测试用例生成 |
| code-reviewer | 审查 | 代码质量检查 |
| doc-generator | 文档 | 文档生成 |
| changelog-generator | 发布 | 更新日志生成 |
| pr-description | 发布 | PR 描述生成 |
