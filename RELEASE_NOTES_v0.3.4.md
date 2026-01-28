# Linux-Clipboard v0.3.4

## 🎉 主要更新 / Major Updates

### 🐛 Bug 修复 / Bug Fixes
- 修复 ES Module 兼容性问题 (Fixed ES Module compatibility issues)
  - 替换所有 `require()` 调用为 ES6 `import` 语句
  - 影响: `electron/store/secure-store.ts`, `electron/main.ts`
  - 修复了应用启动时的 `require is not defined` 错误

- 修复开发模式窗口显示问题 (Fixed dev mode window display issue)
  - 更正 Vite 开发服务器端口配置: `5173` → `3000`
  - 现在开发模式下窗口可以正常加载

### 📁 项目结构优化 / Project Structure
- 整理文件结构，提高项目可维护性
  - 所有文档移至 `docs/` 目录
  - 所有脚本移至 `scripts/` 目录
  - 创建 `backup_md_sh/` 本地备份目录（不推送到远端）

### 📚 文档改进 / Documentation
- `docs/Build.md` - 详细的构建记录
- `docs/Repair.md` - 完整的修复记录
- `RELEASE_INFO_v0.3.4.txt` - 发布信息

## 📦 安装 / Installation

### 通过 .deb 包安装 / Install via .deb package

```bash
# 下载 / Download
wget https://github.com/Li-zhienxuan/Linux-Clipboard/releases/download/v0.3.4/linux-clipboard_0.3.4_amd64.deb

# 安装 / Install
sudo dpkg -i linux-clipboard_0.3.4_amd64.deb
```

### 从源码构建 / Build from source

```bash
# 克隆仓库 / Clone repository
git clone https://github.com/Li-zhienxuan/Linux-Clipboard.git
cd Linux-Clipboard

# 安装依赖 / Install dependencies
npm install

# 构建 / Build
npm run build

# 构建 deb 包 / Build deb package
npm run electron:build:deb
```

## ✨ 功能特性 / Features

- 📋 智能剪贴板管理 / Smart clipboard management
- 🏷️ AI 自动标签生成 / AI-powered automatic tagging
- 🔍 快速搜索 / Quick search
- ⌨️ 全局快捷键 (Ctrl+Shift+V) / Global shortcut
- 🔒 安全的 API Key 存储 / Secure API key storage
- 🎨 现代化 UI / Modern UI

## 🐛 已知问题 / Known Issues

无 / None

## 🙏 致谢 / Acknowledgments

感谢所有贡献者和用户的支持！

---

**完整更新日志 / Full Changelog**: https://github.com/Li-zhienxuan/Linux-Clipboard/compare/v0.3.3...v0.3.4
