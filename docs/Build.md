# Linux-Clipboard 构建记录

## 版本 v0.3.5

### 构建时间
**开始时间**: 2026-01-28 14:00:00 (CST, UTC+8)
**完成时间**: 2026-01-28 15:30:00 (CST, UTC+8)
**总耗时**: 约 1.5 小时（含开发和测试）

### 构建环境
- **操作系统**: Linux 6.12.63+deb13-amd64
- **Node.js**: v22.x
- **npm**: 最新版本
- **Electron**: 33.4.11
- **Electron Builder**: 25.1.8
- **Vite**: 6.4.1

### 本版本主要更新

#### 1. 版本显示功能
- **功能**: 在应用中多处显示版本号，方便识别运行版本
- **实现位置**:
  - 窗口标题：`Linux-Clipboard v0.3.5`
  - 设置面板：醒目的渐变色版本卡片
  - 状态栏：始终可见的版本标识
- **技术实现**:
  - 添加 `app.getVersion()` IPC handler
  - 在 preload.ts 暴露 `getVersion()` API
  - React 前端获取并显示版本信息

#### 2. 统一管理菜单
- **文件**: `scripts/menu.sh`
- **功能**: 一站式管理界面，整合所有常用操作
- **包含功能**:
  - 开发工具：启动开发模式、构建、打包
  - 版本发布：交互式发布、创建 Release、查看版本
  - 配置管理：CNB Token 配置、项目状态
  - 仓库操作：推送到 GitHub/CNB
- **使用方法**: `./scripts/menu.sh`

#### 3. 改进的发布流程
- **脚本**: `scripts/release-version.sh`
- **改进**:
  - 交互式输入版本号
  - 自动完成所有发布步骤
  - 生成 Release Notes
  - 传递版本号给 Release 创建脚本

#### 4. GitHub Release 自动化
- **脚本**: `scripts/create-release.sh`
- **改进**:
  - 接受环境变量 `VERSION`
  - 自动检查 deb 文件存在性
  - 自动生成默认 Release Notes
  - Token 保存在项目本地 (`.github-token-local`)

#### 5. CI/CD 配置
- **文件**: `.github/workflows/release.yml`
- **功能**:
  - Tag 推送时自动触发
  - 自动构建应用
  - 创建 GitHub Release
  - 同步到 CNB

### 构建步骤

```bash
# 方式 1：使用统一菜单（推荐）
./scripts/menu.sh
# 选择: 4 - 发布新版本
# 输入版本号: 0.3.5

# 方式 2：使用发布脚本
./scripts/release-version.sh
# 输入版本号: 0.3.5

# 方式 3：手动步骤
npm version 0.3.5
npm run electron:build:deb
git add .
git commit -m "chore: release v0.3.5"
git tag v0.3.5
git push origin main --tags
./scripts/create-release.sh
```

### 构建输出

#### Vite 构建结果
```
dist/index.html                  2.33 kB │ gzip:   1.01 kB
dist/assets/index-*.js          483.34 kB │ gzip: 120.90 kB
dist-electron/main.js          410.98 kB │ gzip: 106.53 kB
dist-electron/preload.js         0.87 kB │ gzip:   0.51 kB
```

#### Electron Builder 构建结果
```
• electron-builder  version=25.1.8 os=6.12.63+deb13-amd64
• packaging       platform=linux arch=x64 electron=33.4.11
• building        target=deb arch=x64 file=release/linux-clipboard_0.3.5_amd64.deb
```

### 构建产物

#### 文件信息
- **文件名**: `linux-clipboard_0.3.5_amd64.deb`
- **文件大小**: 75M
- **位置**: `/Code/Dev/Linux-Clipboard/release/`

### 测试结果

#### 功能测试
- ✓ 版本号在窗口标题显示
- ✓ 版本号在设置面板显示（醒目）
- ✓ 版本号在状态栏显示（始终可见）
- ✓ 统一菜单所有功能正常
- ✓ 发布流程自动化正常
- ✓ GitHub Release 创建成功

### Git 提交记录

```
2f6604f feat: enhance menu script with detailed descriptions
9ff62fe feat: add unified menu script and CI/CD workflow
fc03f4e fix: improve release scripts with dynamic version handling
cc786e0 feat: add version display in UI and release automation
9af9aed fix: correct Vite dev server port from 5173 to 3000
```

### 关键改进

1. **用户体验**：统一菜单让所有操作一目了然
2. **自动化**：发布流程全自动，减少人工错误
3. **CI/CD**：GitHub Actions 自动构建和发布
4. **可识别性**：多处显示版本，轻松区分不同运行版本

### 已知问题
无

---

## 版本 v0.3.4

### 构建时间
**开始时间**: 2026-01-28 10:05:40 (CST, UTC+8)
**完成时间**: 2026-01-28 10:13:00 (CST, UTC+8)
**总耗时**: 约 7 分 20 秒

### 构建环境
- **操作系统**: Linux 6.12.63+deb13-amd64
- **Node.js**: v22.x
- **npm**: 最新版本
- **Electron**: 33.4.11
- **Electron Builder**: 25.1.8
- **Vite**: 6.4.1

### 构建过程

#### 1. 版本号更新
- 更新 `package.json` 中的版本号从 `0.3.3` 到 `0.3.4`

#### 2. 代码修复
在构建过程中发现并修复了以下问题：

##### 问题 1: ES Module 兼容性问题 (electron/store/secure-store.ts:27)
- **错误信息**: `ReferenceError: require is not defined in ES module scope`
- **原因**: 在 ES Module 模式下使用了 `require('os')`
- **解决方案**:
  - 在文件顶部添加 `import os from 'os';`
  - 删除 `getMachineId()` 方法中的 `const os = require('os');`
- **修复时间**: 2026-01-28 10:06:30

##### 问题 2: ES Module 兼容性问题 (electron/main.ts:34)
- **错误信息**: `ReferenceError: require is not defined`
- **原因**: 在 `migrateApiKeyToSecureStore()` 函数中使用了 `const fs = require('fs');`
- **解决方案**:
  - 在文件顶部添加 `import fs from 'fs';`
  - 删除 `migrateApiKeyToSecureStore()` 函数中的 `const fs = require('fs');`
- **修复时间**: 2026-01-28 10:10:15

#### 3. 构建步骤

```bash
# 步骤 1: 更新版本号
# 编辑 package.json: "version": "0.3.4"

# 步骤 2: 首次构建（发现问题）
npm run build
# 结果: 构建成功，但运行时出错

# 步骤 3: 测试运行
npm run electron:dev
# 结果: 发现 require() 错误

# 步骤 4: 修复代码
# - 修复 electron/store/secure-store.ts
# - 修复 electron/main.ts

# 步骤 5: 重新构建
npm run build
# 结果: ✓ 构建成功
# - dist/index.html: 2.33 kB
# - dist/assets/index-Bk2JSHcx.js: 482.29 kB
# - dist-electron/main.js: 410.70 kB
# - dist-electron/preload.js: 0.80 kB

# 步骤 6: 再次测试
npm run electron:dev
# 结果: ✓ 应用成功启动
# - Secure permissions set
# - Registered shortcut: CommandOrControl+Shift+V

# 步骤 7: 构建 deb 包
npm run electron:build:deb
# 结果: ✓ 构建成功
```

#### 4. 构建输出

##### Vite 构建结果
```
dist/index.html                  2.33 kB │ gzip:   1.01 kB
dist/assets/index-Bk2JSHcx.js  482.29 kB │ gzip: 120.63 kB
dist-electron/main.js          410.70 kB │ gzip: 106.43 kB
dist-electron/preload.js         0.80 kB │ gzip:   0.48 kB
```

##### Electron Builder 构建结果
```
• electron-builder  version=25.1.8 os=6.12.63+deb13-amd64
• packaging       platform=linux arch=x64 electron=33.4.11
• building        target=deb arch=x64 file=release/linux-clipboard_0.3.4_amd64.deb
```

### 构建产物

#### 文件信息
- **文件名**: `linux-clipboard_0.3.4_amd64.deb`
- **文件大小**: 75M (77,721,950 字节)
- **包格式**: Debian 2.0
- **架构**: amd64
- **安装大小**: 331,045 字节

#### 包信息
```
Package: linux-clipboard
Version: 0.3.4
Architecture: amd64
Maintainer: Linux-Clipboard <admin@linuxclipboard.app>
Installed-Size: 331045
Depends: libgtk-3-0, libnotify4, libnss3, libxss1, libxtst6, xdg-utils, libatspi2.0-0, libuuid1, libappindicator3-1, libsecret-1-0
Section: default
Priority: optional
Homepage: https://github.com/Li-zhienxuan/Linux-Clipboard
Description: AI-powered clipboard manager with intelligent search and organization
```

#### 文件位置
- **本地路径**: `/Code/Dev/Linux-Clipboard/release/linux-clipboard_0.3.4_amd64.deb`
- **GitHub Releases**: 将发布到 https://github.com/Li-zhienxuan/Linux-Clipboard/releases/tag/v0.3.4
- **CNB Releases**: 将发布到 https://cnb.cool/ZhienXuan/Linux-Clipboard

### 测试结果

#### 功能测试
- ✓ 应用成功启动
- ✓ 安全存储权限设置成功
- ✓ 全局快捷键注册成功 (CommandOrControl+Shift+V)
- ✓ 无 JavaScript 错误
- ✓ 无 require() 相关错误

#### 运行时日志
```
✓ Secure permissions set for: /home/hajimi/.config/linux-clipboard/linux-clipboard-secure.json
Registered shortcut: CommandOrControl+Shift+V
```

### 关键改进

本版本主要修复了 ES Module 兼容性问题：
1. 将所有 `require()` 调用替换为 ES6 `import` 语句
2. 确保代码与 `"type": "module"` 配置完全兼容
3. 提高了应用的稳定性和兼容性

### 已知问题
无

### 下一步计划
1. 创建 Release Notes
2. 发布到 GitHub Releases
3. 发布到 CNB (cnb.cool)
4. 推送公告到用户社区

---

## 历史构建记录

### v0.3.3
- 发布时间: 2026-01-27 22:42:08
- 构建状态: ✓ 成功
- 文件大小: 75M

### v0.3.2
- 发布时间: 2026-01-27 19:53:00
- 构建状态: ✓ 成功
- 文件大小: 75M

### v0.3.1
- 发布时间: 2026-01-27 18:15:00
- 构建状态: ✓ 成功
- 文件大小: 75M

---

**文档维护**: 本文档由 Claude Code 自动生成和维护
**最后更新**: 2026-01-28 10:13:51 (CST, UTC+8)
