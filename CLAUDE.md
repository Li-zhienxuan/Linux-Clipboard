# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## 项目概述

**Smart Clipboard Pro** 是一个基于 React 19 + TypeScript 的智能剪贴板管理器，使用 Google Gemini AI 提供图像识别和智能搜索功能。采用 Spotlight 风格设计，具有 Glassmorphism（磨砂玻璃）视觉效果。

## 常用命令

```bash
# 开发服务器（运行在 localhost:3000）
npm run dev

# 生产构建
npm run build

# 预览生产构建
npm run preview
```

## 环境变量配置

项目需要 Google Gemini API 密钥：

- 在 `.env.local` 文件中设置 `GEMINI_API_KEY`
- API 密钥通过 `vite.config.ts` 注入为 `process.env.API_KEY`
- 可从 [Google AI Studio](https://aistudio.google.com/) 获取

## 架构设计

### 目录结构

```
smartclipboard-1/
├── App.tsx                  # 主应用组件（包含完整状态管理和业务逻辑）
├── index.tsx                # React 应用入口
├── types.ts                 # TypeScript 类型定义
├── components/
│   └── ClipboardCard.tsx    # 剪贴板卡片展示组件
├── services/
│   └── geminiService.ts     # Gemini AI 服务封装
├── vite.config.ts           # Vite 构建配置
└── tsconfig.json            # TypeScript 配置
```

### 核心数据类型

项目在 [types.ts](types.ts) 中定义了以下核心类型：

- **`ContentType`**: 内容类型枚举 (`'text' | 'image' | 'link' | 'code'`)
- **`TimeMode`**: 时间过滤模式 (`'all' | 'year' | 'month' | 'week'`)
- **`ClipboardItem`**: 剪贴板项接口
  - `id`: 唯一标识符
  - `type`: 内容类型
  - `content`: 文本内容或 base64 图片数据
  - `description`: AI 生成的图片描述（仅图片类型）
  - `timestamp`: 时间戳
  - `tags`: AI 生成的标签数组
  - `isFavorite`: 是否已收藏
- **`AppState`**: 应用状态接口

### 应用架构

**单文件架构**：主要应用逻辑集中在 [App.tsx](App.tsx) 中，采用 React Hooks 进行状态管理。

**组件拆分**：
- **`ClipboardCard`** ([components/ClipboardCard.tsx](components/ClipboardCard.tsx))：负责单个剪贴板项的渲染，包含类型图标、内容展示、标签和操作按钮

**服务层**：
- **`geminiService`** ([services/geminiService.ts](services/geminiService.ts))：
  - `analyzeImage()`: 使用 Gemini 3 Flash Preview 分析图片，返回描述和标签
  - `suggestTags()`: 为文本内容生成智能标签

### 状态管理

应用使用 React 内置状态管理：
- `useState`: 管理剪贴板项目、搜索查询、过滤器等状态
- `useEffect`: 处理剪贴板监听、localStorage 持久化
- `useRef`: 管理 DOM 引用和滚动状态

### 样式系统

- **框架**: Tailwind CSS（通过 CDN 在 `index.html` 中引入）
- **设计风格**: Glassmorphism（磨砂玻璃效果）
- **特点**:
  - 大量使用透明度和半透明背景
  - 使用 `bg-white/5`、`bg-white/[0.03]` 等透明度类
  - 渐变边框和阴影效果
  - 悬停动画和过渡效果

### 路径别名

项目配置了 `@` 别名指向根目录：
- 可在代码中使用 `@/` 引用根目录文件
- 在 `vite.config.ts` 和 `tsconfig.json` 中均有配置

## 关键特性实现

### 剪贴板监听

应用使用 `navigator.clipboard.readText()` API 监听剪贴板变化。需要用户授权 `clipboard-read` 权限。

### AI 集成

- **图像识别**: 自动检测图片内容并生成描述
- **智能标签**: 根据内容类型（代码、链接、文本）自动生成相关标签
- **语义搜索**: 支持自然语言搜索历史记录

### 内容类型检测

应用自动识别内容类型：
- **图片**: 通过数据 URL 格式检测
- **链接**: 通过 URL 正则表达式检测
- **代码**: 通过代码格式特征检测
- **文本**: 默认类型

### 数据持久化

使用 `localStorage` 存储剪贴板历史：
- 键名: `clipboardHistory`
- JSON 序列化存储
- 包含完整的 `ClipboardItem` 数组

## 技术栈版本

- React: 19.2.3
- TypeScript: 5.8.2
- Vite: 6.2.0
- @google/genai: 1.34.0
- Lucide React: 0.562.0
