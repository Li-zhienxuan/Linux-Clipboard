# 📋 Linux-Clipboard | 智能剪贴板管理器

[English](#english) | [简体中文](#chinese)

---

<a name="english"></a>
## 🌍 English Version

![Version](https://img.shields.io/badge/version-v0.3.8-blue.svg)
![License](https://img.shields.io/badge/license-MIT-blue.svg)
![Electron](https://img.shields.io/badge/Electron-33.4.11-9feaf9.svg)
![React](https://img.shields.io/badge/React-19.2.3-61dafb.svg)
![TypeScript](https://img.shields.io/badge/TypeScript-5.8.2-3178c6.svg)

A sophisticated AI-powered clipboard manager for Linux with system tray support. Built with Electron, React, and Google Gemini AI, it enables seamless searching, indexing, and categorization of both text and image content.

### ✨ Key Features

#### 🎯 Core Functionality
- **🔍 AI-Powered Search**: Search through clipboard history using natural language. AI understands image content and text context.
- **🖼️ Image Recognition**: Automatically describe and tag images using Gemini 3 Flash Preview
- **🏷️ Intelligent Tagging**: Auto-generate keywords for code snippets, links, and long-form text
- **📂 Smart Filters**: Instantly filter by content type: Text, Code, Links, or Images
- **⭐ Favorites**: Star important snippets for quick access
- **🚀 Quick Copy**: One-click recovery of previous clipboard items

#### 🖥️ Desktop Integration
- **🔔 System Tray**: Minimize to system tray, runs in background
- **⌨️ Global Shortcuts**: `Ctrl+Shift+V` to toggle window visibility
- **🔒 Secure Storage**: Encrypted storage for API keys using AES-256-GCM
- **⚙️ Settings Panel:**
  - Toggle auto-start on boot
  - Configure API keys
  - Customize clipboard behavior

#### 🛠️ Developer Features
- **Hot Module Replacement**: Fast development with Vite HMR
- **Type Safety**: Full TypeScript support
- **Modern UI**: Glassmorphism design with Tailwind CSS
- **Auto-updates**: Built-in update mechanism

### 🏗️ Architecture

```
linux-clipboard/
├── electron/              # Electron main process
│   ├── main.ts           # Application entry point
│   ├── preload.ts        # Preload script (IPC bridge)
│   ├── clipboard-manager.ts    # Clipboard monitoring
│   ├── tray-manager.ts         # System tray integration
│   ├── shortcuts-manager.ts    # Global shortcuts
│   └── store/            # Configuration & secure storage
│       ├── config-store.ts
│       └── secure-store.ts
├── src/                  # React frontend
│   ├── App.tsx           # Main application component
│   ├── components/       # React components
│   └── services/         # API services
├── scripts/              # Build & automation scripts
└── docs/                 # Documentation
```

### 🛠️ Tech Stack

#### Frontend
- **Framework**: React 19.2.3
- **Language**: TypeScript 5.8.2
- **Styling**: Tailwind CSS (Glassmorphism)
- **Icons**: Lucide React 0.562.0
- **Build Tool**: Vite 6.2.0

#### Backend (Electron Main)
- **Runtime**: Electron 33.4.11
- **Storage**: electron-store 8.2.0
- **Security**: crypto (Node.js built-in)

#### AI Services
- **Provider**: Google Gemini AI
- **SDK**: @google/genai 1.34.0
- **Model**: Gemini 3 Flash Preview

### 📦 Installation

#### From .deb Package (Recommended for Ubuntu/Debian)

```bash
# Download the latest release
wget https://github.com/Li-zhienxuan/Linux-Clipboard/releases/download/v0.3.8/linux-clipboard_0.3.8_amd64.deb

# Install
sudo dpkg -i linux-clipboard_0.3.8_amd64.deb

# Run
linux-clipboard
```

#### From Source

```bash
# Clone repository
git clone https://github.com/Li-zhienxuan/Linux-Clipboard.git
cd Linux-Clipboard

# Install dependencies
npm install

# Run in development mode
npm run electron:dev

# Build for production
npm run electron:build:deb
```

### 🚀 Usage

1. **First Launch**:
   - Open the application
   - Configure your Google Gemini API Key in settings
   - Grant necessary permissions

2. **Clipboard Monitoring**:
   - Copy text or images (Ctrl+C)
   - Content is automatically captured and indexed
   - AI generates tags and descriptions

3. **Search & Retrieve**:
   - Press `Ctrl+Shift+V` or click tray icon
   - Type in the search bar
   - Click item to copy back to clipboard

4. **Manage History**:
   - ⭐ Star important items
   - 🗑️ Delete unwanted entries
   - 📂 Filter by type or time

### 📚 Documentation

Detailed documentation available in [docs/](docs/):

| Document | Description |
|----------|-------------|
| [INDEX.md](docs/INDEX.md) | Complete documentation index |
| [DEVELOPMENT.md](docs/DEVELOPMENT.md) | Development guide |
| [cnb-cloud-build-guide.md](docs/cnb-cloud-build-guide.md) | CNB cloud native build guide |
| [Build.md](docs/Build.md) | Build history and records |
| [Repair.md](docs/Repair.md) | Troubleshooting guide |
| [AUTO_RELEASE_GUIDE.md](docs/AUTO_RELEASE_GUIDE.md) | Release automation |
| [CLAUDE.md](docs/CLAUDE.md) | Claude Code project guide |

### 🔧 Development

```bash
# Development server (React only)
npm run dev

# Electron development mode
npm run electron:dev

# Production build
npm run build

# Build .deb package
npm run electron:build:deb

# Preview production build
npm run preview
```

### 🤝 Contributing

Contributions are welcome! Please feel free to submit issues or pull requests.

### 📄 License

MIT License - see LICENSE file for details

---

<a name="chinese"></a>
## 🇨🇳 中文版

![版本](https://img.shields.io/badge/版本-v0.3.8-blue.svg)
![协议](https://img.shields.io/badge/协议-MIT-blue.svg)
![Electron](https://img.shields.io/badge/Electron-33.4.11-9feaf9.svg)
![React](https://img.shields.io/badge/React-19.2.3-61dafb.svg)
![TypeScript](https://img.shields.io/badge/TypeScript-5.8.2-3178c6.svg)

一款精致的 Linux 智能剪贴板管理器，支持系统托盘。基于 Electron、React 和 Google Gemini AI 构建，支持对文本和图片内容进行无缝搜索、索引和分类。

### ✨ 核心功能

#### 🎯 基础功能
- **🔍 AI 驱动搜索**: 使用自然语言搜索剪贴板历史，AI 理解图片内容和文本上下文
- **🖼️ 图像识别**: 使用 Gemini 3 Flash Preview 自动描述并标记图片
- **🏷️ 智能标签**: 为代码片段、链接和长文本自动生成关键词
- **📂 智能过滤**: 按内容类型快速过滤：文本、代码、链接或图片
- **⭐ 收藏夹**: 收藏重要片段，快速访问
- **🚀 快速复制**: 一键恢复之前的剪贴板内容

#### 🖥️ 桌面集成
- **🔔 系统托盘**: 最小化到系统托盘，后台运行
- **⌨️ 全局快捷键**: `Ctrl+Shift+V` 切换窗口显示/隐藏
- **🔒 安全存储**: 使用 AES-256-GCM 加密存储 API 密钥
- **⚙️ 设置面板**:
  - 开机自启动
  - 配置 API 密钥
  - 自定义剪贴板行为

#### 🛠️ 开发特性
- **热模块替换**: 使用 Vite HMR 快速开发
- **类型安全**: 完整的 TypeScript 支持
- **现代 UI**: Tailwind CSS 磨砂玻璃设计
- **自动更新**: 内置更新机制

### 🏗️ 项目架构

```
linux-clipboard/
├── electron/              # Electron 主进程
│   ├── main.ts           # 应用入口
│   ├── preload.ts        # 预加载脚本（IPC 桥接）
│   ├── clipboard-manager.ts    # 剪贴板监控
│   ├── tray-manager.ts         # 系统托盘集成
│   ├── shortcuts-manager.ts    # 全局快捷键
│   └── store/            # 配置和安全存储
│       ├── config-store.ts
│       └── secure-store.ts
├── src/                  # React 前端
│   ├── App.tsx           # 主应用组件
│   ├── components/       # React 组件
│   └── services/         # API 服务
├── scripts/              # 构建和自动化脚本
└── docs/                 # 文档
```

### 🛠️ 技术栈

#### 前端
- **框架**: React 19.2.3
- **语言**: TypeScript 5.8.2
- **样式**: Tailwind CSS（磨砂玻璃设计）
- **图标**: Lucide React 0.562.0
- **构建工具**: Vite 6.2.0

#### 后端（Electron 主进程）
- **运行时**: Electron 33.4.11
- **存储**: electron-store 8.2.0
- **安全**: crypto（Node.js 内置）

#### AI 服务
- **提供商**: Google Gemini AI
- **SDK**: @google/genai 1.34.0
- **模型**: Gemini 3 Flash Preview

### 📦 安装

#### 使用 .deb 包安装（Ubuntu/Debian 推荐）

```bash
# 下载最新版本
wget https://github.com/Li-zhienxuan/Linux-Clipboard/releases/download/v0.3.8/linux-clipboard_0.3.8_amd64.deb

# 安装
sudo dpkg -i linux-clipboard_0.3.8_amd64.deb

# 运行
linux-clipboard
```

#### 从源码构建

```bash
# 克隆仓库
git clone https://github.com/Li-zhienxuan/Linux-Clipboard.git
cd Linux-Clipboard

# 安装依赖
npm install

# 开发模式运行
npm run electron:dev

# 构建生产版本
npm run electron:build:deb
```

### 🚀 使用方法

1. **首次启动**:
   - 打开应用
   - 在设置中配置 Google Gemini API 密钥
   - 授予必要权限

2. **剪贴板监控**:
   - 复制文本或图片（Ctrl+C）
   - 内容自动捕获和索引
   - AI 生成标签和描述

3. **搜索和检索**:
   - 按 `Ctrl+Shift+V` 或点击托盘图标
   - 在搜索栏输入
   - 点击项目复制回剪贴板

4. **管理历史**:
   - ⭐ 标记重要项目
   - 🗑️ 删除不需要的条目
   - 📂 按类型或时间过滤

### 📚 完整文档

详细文档请查看 [docs/](docs/)：

| 文档 | 说明 |
|------|------|
| [INDEX.md](docs/INDEX.md) | 完整文档索引 |
| [DEVELOPMENT.md](docs/DEVELOPMENT.md) | 开发指南 |
| [cnb-cloud-build-guide.md](docs/cnb-cloud-build-guide.md) | CNB 云原生构建指南 |
| [Build.md](docs/Build.md) | 构建历史和记录 |
| [Repair.md](docs/Repair.md) | 问题排查指南 |
| [AUTO_RELEASE_GUIDE.md](docs/AUTO_RELEASE_GUIDE.md) | 自动发布指南 |
| [CLAUDE.md](docs/CLAUDE.md) | Claude Code 项目指南 |

### 🔧 开发

```bash
# 开发服务器（仅 React）
npm run dev

# Electron 开发模式
npm run electron:dev

# 生产构建
npm run build

# 构建 .deb 包
npm run electron:build:deb

# 预览生产构建
npm run preview
```

### 📖 快速链接

#### 开发相关
- 📖 [开发指南](docs/DEVELOPMENT.md) - 完整的开发和发布流程
- 🏗️ [项目架构](docs/CODEBUDDY.md) - 代码规范和架构设计
- 🤖 [Claude 指南](docs/CLAUDE.md) - AI 助手配置

#### 维护相关
- 📦 [构建记录](docs/Build.md) - 版本构建历史
- 🐛 [问题排查](docs/Repair.md) - 常见问题解决
- 🚀 [自动发布](docs/AUTO_RELEASE_GUIDE.md) - 自动化发布流程

#### 配置相关
- 🔑 [CNB Token 配置](docs/CNB_TOKEN_GUIDE.md) - 快速配置指南
- 📡 [CNB 详细配置](docs/cnb-setup-guide.md) - 完整配置教程

### 🤝 贡献

欢迎贡献！请随时提交 issues 或 pull requests。

### 📄 开源协议

MIT License - 详见 LICENSE 文件

---

## 📊 项目状态

- **当前版本**: v0.3.8
- **最新发布**: [GitHub Releases](https://github.com/Li-zhienxuan/Linux-Clipboard/releases)
- **问题追踪**: [GitHub Issues](https://github.com/Li-zhienxuan/Linux-Clipboard/issues)
- **更新日志**: [CHANGELOG.md](docs/Build.md)

## 🔗 相关链接

- **GitHub**: https://github.com/Li-zhienxuan/Linux-Clipboard
- **CNB**: https://cnb.cool/ZhienXuan/Linux-Clipboard
- **Issues**: https://github.com/Li-zhienxuan/Linux-Clipboard/issues

---

*Developed with ❤️ by Linux-Clipboard Team*
*Built with Electron, React, and Google Gemini AI*
