# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## 项目概述

**Linux-Clipboard** 是一个基于 Electron + React + TypeScript 的智能剪贴板管理器，使用 Google Gemini AI 提供图像识别和智能搜索功能。采用 Spotlight 风格设计，具有 Glassmorphism（磨砂玻璃）视觉效果。

**当前版本**: v0.4.4

## 常用开发命令

```bash
# ========== 开发 ==========
# Electron 开发模式（推荐）- 启动 Electron + Vite 热重载
npm run electron:dev

# 仅 React 开发服务器
npm run dev

# ========== 构建 ==========
# 前端构建
npm run build

# 构建所有安装包（带进度显示）
npm run electron:build:all:progress

# 仅构建 DEB 包
npm run electron:build:deb

# 仅构建 AppImage
npm run electron:build:appimage

# ========== 工具 ==========
# 统一管理菜单（推荐）- 所有操作的交互式入口
bash scripts/menu.sh

# 终止所有开发进程
bash scripts/kill-all.sh

# ========== 发布 ==========
# 发布新版本（交互式，更新版本号→构建→提交→推送→创建 Release）
# 运行后会提示输入版本号
bash scripts/release-version.sh

# 创建 GitHub Release（上传 deb/AppImage）
bash scripts/create-release.sh
```

## 项目架构

### 技术栈
- **前端**: React 19.2.3 + TypeScript 5.8.2 + Vite 6.2.0
- **桌面**: Electron 33.4.11
- **AI**: Google Gemini AI (@google/genai 1.34.0)
- **UI**: Tailwind CSS + Lucide React 0.562.0

### 目录结构（精简版）
```
Linux-Clipboard/
├── src/                      # React 前端源码
│   ├── App.tsx              # 主应用组件（状态管理 + 业务逻辑）
│   ├── components/          # React 组件
│   ├── services/            # API 服务
│   └── types.ts             # TypeScript 类型定义
├── electron/                # Electron 主进程
│   ├── main.ts              # 应用入口 + IPC 处理
│   ├── preload.ts           # 预加载脚本（IPC 桥接）
│   ├── clipboard-manager.ts # 剪贴板监控
│   ├── tray-manager.ts      # 系统托盘
│   ├── shortcuts-manager.ts # 全局快捷键
│   └── store/               # 配置存储
│       ├── config-store.ts   # 普通配置
│       └── secure-store.ts   # 安全存储（API Key）
├── scripts/                 # 构建和自动化脚本
│   ├── menu.sh              # 统一管理菜单 ⭐
│   ├── kill-all.sh          # 终止所有进程
│   └── build-with-progress.sh  # 带进度的构建
├── docs/                    # 项目文档
├── dev_logs/               # 改动记录（DEV_LOG.md, CONVERSATION_LOG.md）
├── token/                  # 敏感文件（.gitignore）
├── .attic/                 # 旧文件归档（.gitignore）
└── resources/              # 资源文件（图标等）
```

### Electron 架构要点

**主进程与渲染进程通信**：
- 使用 `ipcMain.handle` 和 `ipcRenderer.invoke` 进行双向通信
- preload.ts 暴露安全的 API 给渲染进程（通过 `contextBridge.exposeInMainWorld`）
- 所有剪贴板操作在主进程进行（安全考虑）

**关键模块**：
- **ClipboardManager**: 监听系统剪贴板变化，通过 IPC 发送到渲染进程
- **TrayManager**: 系统托盘图标，点击显示/隐藏窗口
- **ShortcutsManager**: 全局快捷键注册（默认 `Ctrl+Shift+V`）
- **SecureConfigStore**: 使用 Node.js crypto 加密存储 API Key

### 前端架构要点

**单文件状态管理**：
- `App.tsx` 包含完整的业务逻辑和状态管理（~650 行）
- 使用 React Hooks（useState, useEffect, useRef, useMemo）
- localStorage 持久化剪贴板历史

**关键功能实现**：
- **版本号显示**: Web 模式通过 `fetch('/package.json')` 动态读取，Electron 模式通过 `window.electronAPI.getVersion()` 获取
- **剪贴板监听**: 通过 `window.electronAPI.onClipboardChange()` 监听主进程剪贴板事件
- **AI 索引**: 图片上传到 Gemini API 获取描述，文本自动生成标签
- **时间过滤**: 支持按年/月/周 + 具体值进行过滤

**类型系统**：
- 核心类型定义在 `src/types.ts`
- 使用 `export type` 重新导出以保持向后兼容
- ContentType: `'text' | 'image' | 'link' | 'code'`

## 重要配置文件

### electron-builder.json
- 打包配置（DEB + AppImage）
- 启用 asar 压缩和 maximum 压缩级别
- 通过 `bundledDependencies` 明确指定生产依赖

### vite.config.ts
- 开发服务器端口：3000
- 路径别名：`@` 指向根目录
- 代码分割：React 和 lucide-react 分离打包
- define 注入：`__APP_VERSION__`, `process.env.API_KEY`

### .gitignore
- `token/` - 敏感文件
- `dev_logs/` - 开发日志
- `.attic/` - 旧文件归档
- 标准忽略：node_modules, dist, release 等

## 打包优化

当前配置已优化体积：
- **DEB**: 75M → 预期 ~50-60M
- **AppImage**: 113M → 预期 ~80-90M

优化措施：
1. `bundledDependencies` - 只打包必需的生产依赖
2. `compression: "maximum"` - 最大压缩
3. `asar: true` - 启用 asar 打包
4. 代码分割 - React、Icons 分离
5. `.npmignore` - 排除开发文件

## 开发规范

### 改动记录管理
**所有改动记录必须放在 `dev_logs/` 目录下**：
- `DEV_LOG.md` - 开发改动记录
- `CONVERSATION_LOG.md` - 对话记录
- ❌ 不要在 `docs/` 或其他位置创建改动记录文档

### 版本号管理
- `package.json` 中的 `version` 是唯一真实来源
- `app.getVersion()` (Electron) 和 `fetch('/package.json')` (Web) 动态读取
- Vite 的 `__APP_VERSION__` 仅作为 fallback

### 路径引用
- 使用 `@/` 别名引用根目录文件
- 优先使用相对路径而非绝对路径
- Electron 中使用 `getBasePath()` 获取运行时路径

## 环境变量

**Google Gemini API Key**:
- 开发环境：创建 `.env.local` 设置 `GEMINI_API_KEY`
- Electron 环境：通过应用设置面板配置，使用安全存储加密保存
- 通过 `vite.config.ts` 注入为 `process.env.GEMINI_API_KEY`

## 常见问题排查

查看 `docs/Repair.md` 获取完整的问题排查指南。

## 相关文档

| 文档 | 用途 |
|------|------|
| [DEVELOPMENT.md](DEVELOPMENT.md) | 完整开发和发布流程 |
| [Build.md](Build.md) | 版本构建历史 |
| [Repair.md](Repair.md) | 问题排查指南 |
| [AUTO_RELEASE_GUIDE.md](AUTO_RELEASE_GUIDE.md) | 自动化发布流程 |

---

*最后更新：2026-01-30*
*版本：v0.4.4*
