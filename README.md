# 📋 Smart Clipboard Pro | 智能剪贴板专家

[English](#english) | [简体中文](#chinese)

---

<a name="english"></a>
## 🌍 English Version

A sophisticated, Spotlight-style smart clipboard manager built with React and powered by Google Gemini AI. It enables seamless searching, indexing, and categorization of both text and image content.

![License](https://img.shields.io/badge/license-MIT-blue.svg)
![React](https://img.shields.io/badge/React-19-61dafb.svg)
![Tailwind](https://img.shields.io/badge/Tailwind-CSS-38b2ac.svg)
![Gemini AI](https://img.shields.io/badge/AI-Google_Gemini-orange.svg)

### ✨ Key Features
*   **🔍 AI-Powered Search**: Search through your history using natural language. The AI understands image content and text context.
*   **🖼️ Image Recognition**: Upload or paste images to have them automatically described and tagged by Gemini 3 Flash.
*   **🏷️ Intelligent Tagging**: Automatic keyword generation for code snippets, links, and long-form text.
*   **📂 Smart Filters**: Instantly filter by content type: Text, Code, Links, or Images.
*   **⭐ Favorites**: Star important snippets for quick access in the "Starred" tab.
*   **🚀 Instant Copy**: One-click recovery of previous clipboard items.

### 🛠️ Tech Stack
- **Frontend**: React 19, TypeScript
- **Styling**: Tailwind CSS (Glassmorphism design)
- **Icons**: Lucide React
- **AI Engine**: @google/genai (Gemini 3 Flash Preview)

### 🚦 Getting Started
1.  Obtain an API key from [Google AI Studio](https://aistudio.google.com/).
2.  The application expects the key via `process.env.API_KEY`.

---

<a name="chinese"></a>
## 🇨🇳 中文版

一个精致的、Spotlight 风格的智能剪贴板管理器。基于 React 构建，由 Google Gemini AI 提供动力。支持对文本和图片内容进行无缝搜索、索引和分类。

### ✨ 核心功能
*   **🔍 AI 驱动搜索**: 使用自然语言搜索历史记录。AI 能够理解图片内容和文本上下文。
*   **🖼️ 图像识别**: 上传或粘贴图片，Gemini 3 Flash 会自动生成描述并添加标签。
*   **🏷️ 智能标签**: 为代码片段、链接和长文本自动生成关键词。
*   **📂 智能过滤**: 按内容类型快速过滤：文本、代码、链接或图片。
*   **⭐ 收藏夹**: 收藏重要片段，在“已星标”选项卡中快速访问。
*   **🚀 快速复制**: 一键恢复之前的剪贴板内容。

### 🛠️ 技术栈
- **前端**: React 19, TypeScript
- **样式**: Tailwind CSS (磨砂玻璃设计)
- **图标**: Lucide React
- **AI 引擎**: @google/genai (Gemini 3 Flash Preview)

### 🚦 开始使用
1.  从 [Google AI Studio](https://aistudio.google.com/) 获取 API 密钥。
2.  应用程序通过 `process.env.API_KEY` 使用该密钥。

### 📖 使用说明
1.  **添加内容**: 使用 **+** 图标上传图片，或使用 **布局** 图标手动添加文本。
2.  **搜索**: 在顶部搜索栏输入。你可以搜索片段内的文本，甚至是图片中的概念（例如，搜索“机器人”将找到包含机器人的图片）。
3.  **管理**: 
    - 点击 **复制** 图标将项目放回系统剪贴板。
    - 点击 **星标** 图标将项目保存到收藏夹。
    - 点击 **删除** 图标从历史记录中移除。

---

*Developed with ❤️ by a World-Class Frontend Engineer.*