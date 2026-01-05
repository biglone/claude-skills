# 技能选择机制说明

## Claude Code 如何选择技能

Claude Code 通过以下方式选择合适的 skill 或 workflow：

### 1. 关键词匹配

每个 skill 的 `description` 字段中包含**触发关键词**，Claude Code 会将用户输入与这些关键词进行匹配。

**示例：**

```yaml
---
name: requirements-doc
description: 需求文档生成器。将简单的需求描述转换为结构化的需求文档、功能划分和任务列表。当用户要求"生成需求文档"、"分析需求"、"需求拆解"时使用。
---
```

当用户说："帮我生成需求文档"时，Claude 会匹配到 `requirements-doc` skill。

### 2. 明确指定 Skill

您可以直接用 `/` 前缀调用特定 skill：

```bash
/requirements-doc
/autonomous-dev
/full-auto-development
```

### 3. Workflow vs Skill 的区别

| 类型 | 说明 | 使用场景 |
|------|------|----------|
| **Skill** | 单一功能的 AI 能力 | 明确的单一任务 |
| **Workflow** | 多个 skills 的组合流程 | 需要多个步骤的完整流程 |

**示例区分：**

```
❌ 用户说："自动开发登录功能"
   → Claude 可能匹配到 autonomous-dev (只做代码实现)

✅ 用户说："全自动开发：实现用户登录功能，支持邮箱和手机号"
   → 明确触发 full-auto-development workflow (需求→文档→确认→开发)
```

## 常见容易混淆的技能

### 1. 自动开发相关

| Skill/Workflow | 描述 | 触发关键词 | 何时使用 |
|----------------|------|-----------|----------|
| `autonomous-dev` | 纯代码实现阶段的自动化 | "自主开发"、"自动完成" | 需求已明确，直接写代码 |
| `full-auto-development` | 需求→文档→确认→开发完整流程 | "全自动开发：<需求>"、"完整自动化流程" | 只有简单需求描述，需要先生成文档 |
| `auto-code-pipeline` | 自动执行 lint→test→review | "自动流水线"、"CI流程" | 代码已写完，需要质量检查 |
| `auto-fix-loop` | 自动修复直到测试通过 | "自动修复"、"修到通过为止" | 测试/构建失败，需要自动修复 |

### 2. 文档生成相关

| Skill | 描述 | 触发关键词 |
|-------|------|-----------|
| `requirements-doc` | 生成需求文档和任务列表 | "生成需求文档"、"需求拆解" |
| `doc-generator` | 生成代码文档、README | "生成文档"、"写 README" |
| `pr-description` | 生成 PR 描述 | "写 PR 描述"、"创建 PR" |
| `commit-message` | 生成 commit message | "生成 commit message" |

### 3. 代码质量相关

| Skill | 描述 | 触发关键词 |
|-------|------|-----------|
| `code-reviewer` | 代码审查和最佳实践检查 | "审查代码"、"检查 PR" |
| `security-audit` | 安全漏洞检查 | "安全审查"、"扫描漏洞" |
| `refactoring` | 代码重构建议 | "重构代码"、"识别代码异味" |
| `performance-optimizer` | 性能优化建议 | "优化性能"、"提升速度" |

## 最佳实践

### ✅ 推荐做法

1. **使用明确的触发词**
   ```
   ✅ "全自动开发：实现用户登录功能"
   ✅ "审查代码质量和安全问题"
   ✅ "生成这个项目的需求文档"
   ```

2. **直接调用 skill**
   ```bash
   /full-auto-development
   /code-reviewer
   /requirements-doc
   ```

3. **查看可用 skills**
   ```bash
   ls ~/.claude/skills/
   ```

### ❌ 避免模糊表达

```
❌ "帮我做这个" (太模糊)
❌ "自动一下" (不明确要自动什么)
❌ "优化" (优化代码？性能？还是文档？)
```

## 如何避免选择错误的技能

### 方法 1: 在需求前加明确的 workflow 名称

```
"全自动开发：实现购物车功能"
                 ↑ 明确触发 full-auto-development
```

### 方法 2: 使用 / 命令直接调用

```bash
/full-auto-development

# 然后在交互中输入需求
"实现购物车功能，支持添加、删除、修改数量"
```

### 方法 3: 分步骤明确说明

```
第一步：生成需求文档
需求：实现购物车功能

第二步：审查需求文档
# 确认后

第三步：自主开发实现
# 基于上面的需求文档
```

## Workflow 执行流程示例

### 使用 full-auto-development

```bash
# 用户输入
"全自动开发：实现用户登录注册功能，支持邮箱和手机号"

# Claude 执行流程
┌─────────────────────────────────────┐
│ 1. requirements-doc                │
│    生成 REQUIREMENTS.md             │
│    生成 TASK_LIST.md                │
├─────────────────────────────────────┤
│ 2. task-planner                    │
│    分解任务到具体步骤                │
├─────────────────────────────────────┤
│ ⏸️  等待用户确认                     │
│    (查看需求文档和任务列表是否正确)   │
├─────────────────────────────────────┤
│ 3. autonomous-dev                  │
│    自动实现所有功能                  │
├─────────────────────────────────────┤
│ 4. auto-code-pipeline              │
│    自动 lint → test → review        │
├─────────────────────────────────────┤
│ 5. code-reviewer                   │
│    最终代码审查                      │
└─────────────────────────────────────┘
```

## 技能冲突解决优先级

当多个 skills 都匹配时，Claude Code 优先选择：

1. **Workflow > Skill** (组合流程优先于单一功能)
2. **明确度高的 > 模糊的** (关键词匹配度)
3. **用户历史偏好** (如果有上下文)

## 调试技能选择

如果 Claude 选择了错误的 skill，您可以：

1. **中断并重新指定**
   ```
   "停止，我要用 /full-auto-development，不是 /autonomous-dev"
   ```

2. **明确排除某个 skill**
   ```
   "生成需求文档，但不要自动开发"
   ```

3. **查看当前使用的 skill**
   ```
   "你现在用的是什么 skill?"
   ```

## 总结

| 场景 | 推荐做法 |
|------|----------|
| 从零开始开发功能 | 使用 `full-auto-development` workflow |
| 需求已明确，直接写代码 | 使用 `autonomous-dev` skill |
| 代码已写完，需要检查 | 使用 `auto-code-pipeline` workflow |
| 只需要需求文档 | 使用 `requirements-doc` skill |
| 测试失败需要修复 | 使用 `auto-fix-loop` skill |

**核心原则：越明确越好！** 🎯
