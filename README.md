# 📋 Linux-Clipboard | 智能剪贴板管理器

[English](README_en.md) | [简体中文](README.md)

---

## 🇨🇳 核心功能

![版本](https://img.shields.io/badge/版本-v0.4.4-blue.svg)
![协议](https://img.shields.io/badge/协议-MIT-blue.svg)
![Electron](https://img.shields.io/badge/Electron-33.4.11-9feaf9.svg)
![React](https://img.shields.io/badge/React-19.2.3-61dafb.svg)
![TypeScript](https://img.shields.io/badge/TypeScript-5.8.2-3178c6.svg)

一款精致的 Linux 智能剪贴板管理器，支持系统托盘。基于 Electron、React 和 Google Gemini AI 构建，支持对文本和图片内容进行无缝搜索、索引和分类。

### ✨ 核心特性

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
wget https://github.com/Li-zhienxuan/Linux-Clipboard/releases/download/v0.4.4/linux-clipboard_0.4.4_amd64.deb

# 安装
sudo dpkg -i linux-clipboard_0.4.4_amd64.deb

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

- **当前版本**: v0.4.4
- **最新发布**: [GitHub Releases](https://github.com/Li-zhienxuan/Linux-Clipboard/releases)
- **问题追踪**: [GitHub Issues](https://github.com/Li-zhienxuan/Linux-Clipboard/issues)
- **更新日志**: [Build.md](docs/Build.md)

## 🔗 相关链接

- **GitHub**: https://github.com/Li-zhienxuan/Linux-Clipboard
- **CNB**: https://cnb.cool/ZhienXuan/Linux-Clipboard
- **Issues**: https://github.com/Li-zhienxuan/Linux-Clipboard/issues

---

*用 ❤️ 开发 by Linux-Clipboard Team*
*基于 Electron, React, 和 Google Gemini AI 构建*
