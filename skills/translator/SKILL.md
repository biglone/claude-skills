---
name: translator
description: 文本翻译，支持多语言互译，保持原文风格和术语准确。当用户要求翻译文本、文档、技术内容时使用。
allowed-tools: Read
---

# 翻译助手

## 翻译原则

### 1. 信（Faithfulness）
- 准确传达原文含义
- 不添加或删减内容
- 保持原文的语气和态度

### 2. 达（Expressiveness）
- 译文流畅自然
- 符合目标语言表达习惯
- 读起来不像翻译

### 3. 雅（Elegance）
- 用词得体优美
- 保持原文风格
- 适合目标读者

## 翻译策略

### 直译 vs 意译

```
# 直译适用
- 技术文档
- 法律文件
- 学术论文

# 意译适用
- 营销文案
- 文学作品
- 口语表达
```

### 术语处理

```
# 技术术语
- 使用行业标准译法
- 保持全文一致
- 必要时保留原文

示例：
- API → API（保留）或 应用程序接口
- Container → 容器
- Middleware → 中间件
- Framework → 框架
```

### 文化适应

```
# 需要调整的内容
- 日期格式：01/15/2024 → 2024年1月15日
- 货币单位：$99 → ¥699（或 99 美元）
- 度量单位：100°F → 38°C
- 习语谚语：It's raining cats and dogs → 倾盆大雨
```

## 常见语言对

### 英译中

```
# 技术文档风格
原文：This feature allows users to customize their dashboard.
译文：此功能允许用户自定义其仪表板。

# 产品文案风格
原文：Discover the power of simplicity.
译文：发现简约的力量。/ 简约，自有力量。

# 口语化风格
原文：Let's get started!
译文：开始吧！/ 让我们开始吧！
```

### 中译英

```
# 技术文档
原文：请确保已安装最新版本的软件。
译文：Please ensure you have installed the latest version of the software.

# 商务邮件
原文：感谢您的来信，我们会尽快回复。
译文：Thank you for your email. We will respond as soon as possible.
```

## 特殊内容处理

### 代码和命令

```markdown
# 不翻译
- 代码片段
- 命令行指令
- 文件名/路径
- 变量名/函数名

# 翻译
- 代码注释（可选）
- 输出结果说明
- 错误信息描述
```

### 品牌和专有名词

```
# 通常不翻译
- 品牌名：Apple, Google, Microsoft
- 产品名：iPhone, Chrome, Windows
- 技术名词：JavaScript, Python, Docker

# 可能翻译
- 有官方译名：Facebook → 脸书（Meta）
- 描述性名称：App Store → 应用商店
```

### UI 文本

```
# 常见 UI 翻译
- Submit → 提交
- Cancel → 取消
- Save → 保存
- Delete → 删除
- Edit → 编辑
- Settings → 设置
- Profile → 个人资料
- Sign in → 登录
- Sign up → 注册
- Log out → 退出登录
```

## 翻译质量检查

### 检查清单
- [ ] 含义准确无误
- [ ] 术语使用一致
- [ ] 语法正确
- [ ] 标点符号正确
- [ ] 数字格式正确
- [ ] 无遗漏内容
- [ ] 无多余内容
- [ ] 读起来自然流畅

### 常见错误

```
# 误译
原文：I can't agree more.
错误：我不能同意更多。
正确：我完全同意。

# 漏译
原文：Click the button below to continue.
错误：点击按钮继续。
正确：点击下方按钮继续。

# 过度翻译
原文：API
错误：应用程序编程接口
正确：API（技术文档中通常保留）
```

## 输出格式

### 单段翻译
```
原文：[原文内容]
译文：[翻译内容]
```

### 文档翻译
```markdown
# [翻译后的标题]

[翻译后的正文内容]

---
注释：
- [术语说明]
- [文化背景说明]
```

### 对照翻译
```
| 原文 | 译文 |
|------|------|
| Original text | 翻译文本 |
```

## 翻译工具集成

### 术语表示例
```
| 英文 | 中文 | 备注 |
|------|------|------|
| repository | 仓库 | Git 上下文 |
| branch | 分支 | Git 上下文 |
| commit | 提交 | Git 上下文 |
| pull request | 拉取请求 / PR | 可保留英文 |
| deploy | 部署 | |
| instance | 实例 | |
```

## 翻译提示

翻译时请告知：
1. **原文语言**和**目标语言**
2. **文档类型**（技术文档/营销/口语等）
3. **目标读者**（专业人士/普通用户）
4. **特殊要求**（术语偏好/风格要求）
