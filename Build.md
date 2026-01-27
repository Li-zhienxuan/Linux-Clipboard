# Build.md - 构建记录文档

本文档记录 Linux-Clipboard 项目的所有构建过程和发布记录。

---

## Version 0.3.3 - 构建记录

**构建时间**: 2026-01-28 03:56:18 (Beijing Time, UTC+8)

### 版本更新内容

- ✅ 修复了系统托盘图标未被打包的问题
- ✅ 配置 `extraResources` 确保图标文件包含在安装包中
- ✅ 验证图标文件正确复制到 `resources/icons/` 目录
- ✅ 包含 v0.3.2 的所有安全改进

### 构建步骤

#### Step 1: 发现并修复图标打包问题

**问题发现**:
```bash
# 检查 v0.3.2 的打包结果
find release/linux-unpacked/resources -name "*.png"
# 结果: 空 - 图标文件未包含
```

**修复方案**:
更新 `electron-builder.json`:
```json
{
  "extraResources": [
    {
      "from": "resources/icons/",
      "to": "icons/",
      "filter": ["**/*"]
    }
  ]
}
```

#### Step 2: 更新版本号
```bash
# package.json: 0.3.2 → 0.3.3
```

#### Step 3: 执行构建
```bash
npm run electron:build:deb
```

**构建结果**:
```
vite v6.4.1 building for production...
✓ 1704 modules transformed.
dist/index.html                  2.33 kB │ gzip:   1.01 kB
dist/assets/index-Bk2JSHcx.js  482.29 kB │ gzip: 120.63 kB

vite v6.4.1 building for production...
✓ 375 modules transformed.
dist-electron/main.js  410.74 kB │ gzip: 106.45 kB

vite v6.4.1 building for production...
✓ 1 modules transformed.
dist-electron/preload.js  0.80 kB │ gzip: 0.48 kB

  • building        target=deb arch=x64 file=release/linux-clipboard_0.3.3_amd64.deb
```

✅ **构建状态**: 成功

#### Step 4: 验证图标文件
```bash
find release/linux-unpacked/resources -name "*.png"
# 结果: release/linux-unpacked/resources/icons/icon.png ✓

ls -lh release/linux-unpacked/resources/icons/
# 总计 16K
# -rw-r--r-- 1 hajimi hajimi 9.7K icon.png
# -rw-r--r-- 1 hajimi hajimi 1.3K icon.svg
```

✅ **验证状态**: 图标文件已正确打包

### 构建产物

**安装包**:
- `release/linux-clipboard_0.3.3_amd64.deb` (75MB) - Debian 安装包

**打包文件清单**:
```
/opt/Linux-Clipboard/
├── linux-clipboard               # 可执行文件 (178MB)
├── resources/
│   ├── app.asar                  # 应用代码 (62MB)
│   ├── icons/                    # ✅ 图标资源 (新增)
│   │   ├── icon.png              # 9.7KB
│   │   └── icon.svg              # 1.3KB
│   └── app-update.yml
├── chrome_100_percent.pak
├── chrome_200_percent.pak
└── ... (Electron 运行时文件)
```

### 测试结果

**文件完整性检查**:
- ✅ 图标文件已包含在安装包中
- ✅ 图标大小正确 (9.7KB)
- ✅ SVG 图标也已包含

**待测试功能**:
- [ ] 安装 .deb 包
- [ ] 验证系统托盘图标显示正常
- [ ] 启动应用程序
- [ ] 测试全局快捷键
- [ ] 测试剪贴板监听
- [ ] 测试 API Key 加密存储
- [ ] 测试 AI 图像识别
- [ ] 测试迁移功能

### 发布检查

- [x] 版本号已更新 (0.3.3)
- [x] 代码已构建
- [x] 图标文件已包含
- [ ] 功能测试通过
- [ ] 已创建 Git 标签
- [ ] 已提交 Git 更改

### 备注

**修复内容**:
- 在 `electron-builder.json` 中添加 `extraResources` 配置
- 确保图标文件从 `resources/icons/` 复制到打包后的 `resources/icons/` 目录
- 图标路径在 `tray-manager.ts` 中使用 `process.resourcesPath/icons/icon.png`

---

## Version 0.3.2 - 构建记录

**构建时间**: 2026-01-28 03:51:27 (Beijing Time)

### 版本更新内容

- ✅ 实现了 API Key 的安全存储（AES-256-GCM 加密）
- ✅ 添加了从 v0.2.0 明文配置自动迁移到加密存储的功能
- ✅ 更新了环境检测逻辑（使用 `app.isPackaged` 替代 `NODE_ENV`）
- ✅ 完善了托盘图标路径解析

### 构建前准备

```bash
# 1. 确认当前分支
git branch
# 当前分支: main

# 2. 检查未提交的更改
git status
```

**未提交的文件**:
- `electron/main.ts` - 添加了迁移逻辑
- `electron/store/config-store.ts` - 配置存储
- `electron/tray-manager.ts` - 托盘管理器修复
- `src/App.tsx` - 前端更新
- `src/services/geminiService.ts` - Gemini 服务更新
- `electron/store/secure-store.ts` - 新增安全存储

### 构建步骤

#### Step 1: 更新版本号
```bash
# 更新 package.json 版本: 0.3.1 → 0.3.2
```

#### Step 2: 执行构建
```bash
npm run build
```

**构建结果**:
```
vite v6.4.1 building for production...
✓ 1704 modules transformed.
dist/index.html                  2.33 kB │ gzip:   1.01 kB
dist/assets/index-Bk2JSHcx.js  482.29 kB │ gzip: 120.63 kB

vite v6.4.1 building for production...
✓ 375 modules transformed.
dist-electron/main.js  410.74 kB │ gzip: 106.45 kB

vite v6.4.1 building for production...
✓ 1 modules transformed.
dist-electron/preload.js  0.80 kB │ gzip: 0.48 kB
```

✅ **构建状态**: 成功

#### Step 3: 构建 .deb 包
```bash
npm run electron:build:deb
```

**预期输出**: (待执行)

### 构建产物

**前端构建**:
- `dist/index.html` - 主 HTML 文件
- `dist/assets/index-*.js` - 打包后的 JavaScript
- `dist/index.css` - 样式文件

**Electron 构建**:
- `dist-electron/main.js` - 主进程代码
- `dist-electron/preload.js` - 预加载脚本

**安装包**:
- `release/linux-clipboard_0.3.2_amd64.deb` - Debian 安装包

### 版本文件清单

**核心文件**:
```
Linux-Clipboard/
├── electron/
│   ├── main.ts                    # 主进程入口
│   ├── preload.ts                 # 预加载脚本
│   ├── clipboard-manager.ts       # 剪贴板管理器
│   ├── tray-manager.ts            # 系统托盘
│   ├── shortcuts-manager.ts       # 全局快捷键
│   └── store/
│       ├── config-store.ts        # 常规配置
│       └── secure-store.ts        # 安全存储 (新增)
├── src/
│   ├── App.tsx                    # React 主应用
│   ├── components/
│   │   └── ClipboardCard.tsx
│   └── services/
│       └── geminiService.ts
├── package.json                   # v0.3.2
└── vite.config.ts
```

### 技术栈版本

- **Electron**: 33.4.11
- **React**: 19.2.3
- **Vite**: 6.2.0
- **TypeScript**: 5.8.2
- **electron-builder**: 25.1.8
- **electron-store**: 8.2.0

### 测试清单

构建完成后需要测试的功能：

- [ ] 安装 .deb 包
- [ ] 启动应用程序
- [ ] 检查系统托盘图标
- [ ] 测试全局快捷键 (Ctrl+Shift+V)
- [ ] 测试剪贴板监听
- [ ] 测试 API Key 设置和加密存储
- [ ] 测试 AI 图像识别功能
- [ ] 测试智能标签生成
- [ ] 测试设置持久化
- [ ] 测试开机自启动

### 发布检查

- [x] 版本号已更新
- [ ] 代码已构建
- [ ] 功能测试通过
- [ ] 已创建 Git 标签
- [ ] 已提交 Git 更改

### 备注

**安全改进**:
- API Key 现在使用 AES-256-GCM 加密
- 密钥通过 scrypt 从机器 ID 派生
- 配置文件权限设置为 600
- 自动迁移旧配置中的明文 API Key

**已知问题**: 无

---

## 历史构建记录

### Version 0.3.1
- 初始安全存储实现
- 环境检测修复

### Version 0.2.0
- 重新品牌为 Linux-Clipboard
- Electron 桌面应用基础功能

---

**文档维护**: 每次构建后更新此文档
**格式**: 保持时间戳和构建步骤的详细记录
