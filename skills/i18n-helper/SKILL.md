---
name: i18n-helper
description: 国际化和本地化辅助。当用户要求国际化、多语言支持、翻译时使用。
allowed-tools: Read, Grep, Glob, Bash
---

# 国际化(i18n)助手

## 基本概念

| 术语 | 说明 |
|------|------|
| i18n | Internationalization，国际化（i和n之间18个字母） |
| L10n | Localization，本地化 |
| Locale | 语言+地区，如 zh-CN, en-US |
| Translation Key | 翻译键，如 `common.button.submit` |

## React + react-i18next

### 安装配置
```bash
npm install react-i18next i18next i18next-browser-languagedetector
```

### 配置文件
```javascript
// i18n.js
import i18n from 'i18next';
import { initReactI18next } from 'react-i18next';
import LanguageDetector from 'i18next-browser-languagedetector';

import enTranslation from './locales/en/translation.json';
import zhTranslation from './locales/zh/translation.json';

i18n
  .use(LanguageDetector)
  .use(initReactI18next)
  .init({
    resources: {
      en: { translation: enTranslation },
      zh: { translation: zhTranslation },
    },
    fallbackLng: 'en',
    interpolation: {
      escapeValue: false,
    },
  });

export default i18n;
```

### 翻译文件
```json
// locales/en/translation.json
{
  "common": {
    "button": {
      "submit": "Submit",
      "cancel": "Cancel"
    }
  },
  "greeting": "Hello, {{name}}!",
  "items": {
    "one": "{{count}} item",
    "other": "{{count}} items"
  }
}

// locales/zh/translation.json
{
  "common": {
    "button": {
      "submit": "提交",
      "cancel": "取消"
    }
  },
  "greeting": "你好，{{name}}！",
  "items": {
    "one": "{{count}} 个项目",
    "other": "{{count}} 个项目"
  }
}
```

### 使用方式
```jsx
import { useTranslation, Trans } from 'react-i18next';

function MyComponent() {
  const { t, i18n } = useTranslation();

  return (
    <div>
      {/* 基本使用 */}
      <button>{t('common.button.submit')}</button>

      {/* 带参数 */}
      <p>{t('greeting', { name: 'John' })}</p>

      {/* 复数 */}
      <p>{t('items', { count: 5 })}</p>

      {/* 切换语言 */}
      <button onClick={() => i18n.changeLanguage('zh')}>
        中文
      </button>

      {/* Trans 组件（包含 HTML） */}
      <Trans i18nKey="welcome">
        Welcome to <strong>our app</strong>
      </Trans>
    </div>
  );
}
```

## Vue + vue-i18n

### 安装配置
```bash
npm install vue-i18n
```

### 配置
```javascript
// i18n.js
import { createI18n } from 'vue-i18n';

const messages = {
  en: {
    message: {
      hello: 'Hello',
      greeting: 'Hello, {name}!',
    }
  },
  zh: {
    message: {
      hello: '你好',
      greeting: '你好，{name}！',
    }
  }
};

const i18n = createI18n({
  locale: 'en',
  fallbackLocale: 'en',
  messages,
});

export default i18n;
```

### 使用方式
```vue
<template>
  <div>
    <!-- 基本使用 -->
    <p>{{ $t('message.hello') }}</p>

    <!-- 带参数 -->
    <p>{{ $t('message.greeting', { name: 'John' }) }}</p>

    <!-- 切换语言 -->
    <button @click="$i18n.locale = 'zh'">中文</button>
  </div>
</template>
```

## 后端国际化

### Node.js + i18next
```javascript
const i18next = require('i18next');
const Backend = require('i18next-fs-backend');

i18next.use(Backend).init({
  lng: 'en',
  fallbackLng: 'en',
  backend: {
    loadPath: './locales/{{lng}}/{{ns}}.json',
  },
});

// 使用
const greeting = i18next.t('greeting', { name: 'John' });
```

### Python + gettext
```python
import gettext

# 设置翻译
lang = gettext.translation('messages', localedir='locales', languages=['zh'])
lang.install()
_ = lang.gettext

# 使用
print(_('Hello, World!'))
```

## 翻译键命名规范

### 推荐结构
```
<namespace>.<page/component>.<element>.<action/state>
```

### 示例
```json
{
  "common": {
    "button": {
      "submit": "Submit",
      "cancel": "Cancel",
      "save": "Save"
    },
    "label": {
      "email": "Email",
      "password": "Password"
    },
    "message": {
      "success": "Operation successful",
      "error": "An error occurred"
    }
  },
  "user": {
    "profile": {
      "title": "User Profile",
      "edit": "Edit Profile"
    },
    "settings": {
      "title": "Settings",
      "language": "Language"
    }
  }
}
```

## 日期和数字格式化

### JavaScript Intl API
```javascript
// 日期格式化
const date = new Date();

new Intl.DateTimeFormat('en-US').format(date);  // 1/15/2024
new Intl.DateTimeFormat('zh-CN').format(date);  // 2024/1/15
new Intl.DateTimeFormat('de-DE').format(date);  // 15.1.2024

// 数字格式化
const number = 1234567.89;

new Intl.NumberFormat('en-US').format(number);  // 1,234,567.89
new Intl.NumberFormat('de-DE').format(number);  // 1.234.567,89

// 货币格式化
new Intl.NumberFormat('en-US', {
  style: 'currency',
  currency: 'USD'
}).format(99.99);  // $99.99

new Intl.NumberFormat('zh-CN', {
  style: 'currency',
  currency: 'CNY'
}).format(99.99);  // ¥99.99

// 相对时间
const rtf = new Intl.RelativeTimeFormat('en', { numeric: 'auto' });
rtf.format(-1, 'day');   // yesterday
rtf.format(2, 'hour');   // in 2 hours
```

## 检查清单

### 代码检查
- [ ] 所有用户可见文本都使用翻译键
- [ ] 无硬编码的文本字符串
- [ ] 日期/数字使用本地化格式
- [ ] 图片中的文字已处理
- [ ] 错误信息已国际化

### 翻译检查
- [ ] 所有键在所有语言中都有翻译
- [ ] 无遗漏的翻译
- [ ] 翻译质量已审核
- [ ] 复数形式正确处理
- [ ] 占位符变量一致

### 测试检查
- [ ] 各语言 UI 布局正常
- [ ] 长文本不会破坏布局
- [ ] RTL 语言（如阿拉伯语）正确显示
- [ ] 语言切换功能正常

## 输出格式

```markdown
## i18n 分析报告

### 统计
- 翻译键总数: X
- 支持语言: en, zh, ja
- 缺失翻译: X

### 缺失翻译
| 键 | 缺失语言 |
|-----|----------|
| key1 | zh, ja |

### 未国际化的文本
| 文件 | 行号 | 文本 |
|------|------|------|
| file.tsx | 10 | "Hard coded" |

### 建议
1. [具体建议]
```
