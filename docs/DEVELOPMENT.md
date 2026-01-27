# Linux-Clipboard 开发与发布指南

本文档提供 Linux-Clipboard 项目的完整开发、构建和发布流程说明。

---

## 📋 目录

1. [快速开始](#快速开始)
2. [开发流程](#开发流程)
3. [自动化脚本](#自动化脚本)
4. [发布流程](#发布流程)
5. [故障排查](#故障排查)
6. [版本管理](#版本管理)

---

## 🚀 快速开始

### 环境要求

- **Node.js**: >= 18.0.0
- **npm**: >= 9.0.0
- **Git**: >= 2.0.0
- **Linux 系统**: Ubuntu/Debian (用于 .deb 包构建)

### 安装依赖

```bash
# 克隆项目
git clone https://github.com/你的用户名/Linux-Clipboard.git
cd Linux-Clipboard

# 安装依赖
npm install
```

### 快速运行

```bash
# 开发模式（前端）
npm run dev

# 开发模式（Electron）
npm run electron:dev
```

---

## 💻 开发流程

### 1. 修改代码

编辑以下任一文件：
- `src/App.tsx` - React 前端代码
- `electron/main.ts` - Electron 主进程
- `electron/store/secure-store.ts` - 安全存储
- 其他源文件

### 2. 本地测试

```bash
# 方式1: 前端开发服务器
npm run dev
# 访问: http://localhost:5173

# 方式2: Electron 开发模式
npm run electron:dev
```

### 3. 构建测试

```bash
# 构建前端和 Electron
npm run build

# 检查构建产物
ls -lh dist/ dist-electron/
```

---

## 🔧 自动化脚本

项目提供了三个自动化脚本，简化开发和发布流程：

### build.sh - 构建脚本

**功能**: 自动构建前端、Electron 和 .deb 安装包

```bash
# 基本用法（使用当前版本号）
./build.sh

# 指定版本号构建
./build.sh 0.4.0

# 输出示例:
# [INFO] 检查构建依赖...
# [SUCCESS] 依赖检查通过 (Node.js v20.x.x, npm 10.x.x)
# [INFO] 清理旧的构建产物...
# [INFO] 开始构建项目...
# [INFO] 构建 .deb 安装包...
# [SUCCESS] 构建完成！
```

**执行内容**:
1. ✅ 检查构建依赖（Node.js, npm）
2. ✅ 清理旧的构建产物
3. ✅ 可选：更新版本号
4. ✅ 构建前端 (Vite)
5. ✅ 构建 Electron 主进程
6. ✅ 构建 .deb 安装包
7. ✅ 验证构建产物
8. ✅ 显示构建结果

### install.sh - 安装脚本

**功能**: 备份配置、安装 .deb 包、验证安装

```bash
# 需要 sudo 权限
sudo ./install.sh

# 指定 .deb 文件
sudo ./install.sh release/linux-clipboard_0.3.3_amd64.deb

# 输出示例:
# [INFO] 安装包信息:
#   文件: release/linux-clipboard_0.3.3_amd64.deb
#   版本: 0.3.3
#   大小: 75M
# [INFO] 备份当前配置...
# [SUCCESS] 配置已备份到: ~/linux-clipboard-backup-20260128-040755
# [SUCCESS] 安装完成！
```

**执行内容**:
1. ✅ 检查 root 权限
2. ✅ 查找或指定 .deb 包
3. ✅ 显示包信息
4. ✅ 备份当前配置
5. ✅ 安装 .deb 包
6. ✅ 验证安装
7. ✅ 检查配置文件权限
8. ✅ 显示安装后信息

### release.sh - 发布脚本

**功能**: Git 提交、创建标签、生成发布说明

```bash
# 使用当前版本号发布
./release.sh

# 指定版本号发布
./release.sh 0.4.0

# 输出示例:
# [INFO] 检查 Git 状态...
# [INFO] 添加所有更改到 Git...
# [INFO] 创建 Git 提交...
# [SUCCESS] Git 提交创建成功
# [INFO] 创建 Git 标签: v0.4.0
# [SUCCESS] 标签 v0.4.0 创建成功
# [INFO] 生成发布说明: RELEASE_NOTES_v0.4.0.md
# [SUCCESS] 发布准备完成！
```

**执行内容**:
1. ✅ 检查 Git 状态
2. ✅ 添加所有更改到暂存区
3. ✅ 创建 Git 提交
4. ✅ 创建 Git 标签
5. ✅ 生成发布说明
6. ✅ 显示下一步操作提示

---

## 📦 发布流程

### 完整发布流程（推荐）

#### Step 1: 开发和测试

```bash
# 1. 编辑代码
vim src/App.tsx

# 2. 本地测试
npm run dev

# 3. 构建测试
npm run build
```

#### Step 2: 版本号更新

```bash
# 方式1: 手动编辑 package.json
vim package.json
# 修改 "version": "0.3.3" → "0.4.0"

# 方式2: 使用 build.sh 自动更新
./build.sh 0.4.0
```

**版本规则**: 每次迭代 +0.0.1
- 0.3.3 → 0.4.0 (功能更新)
- 0.4.0 → 0.4.1 (Bug 修复)

#### Step 3: 构建安装包

```bash
# 使用自动化脚本
./build.sh

# 或手动构建
npm run electron:build:deb
```

#### Step 4: 测试安装

```bash
# 安装新版本
sudo ./install.sh

# 或手动安装
sudo dpkg -i release/linux-clipboard_0.3.3_amd64.deb

# 启动测试
/opt/Linux-Clipboard/linux-clipboard
```

**测试清单**:
- [ ] 应用正常启动
- [ ] 系统托盘图标显示
- [ ] 全局快捷键 (Ctrl+Shift+V) 工作
- [ ] 剪贴板监听功能
- [ ] API Key 加密存储
- [ ] AI 图像识别
- [ ] 智能标签生成

#### Step 5: 创建 Git 提交和标签

```bash
# 使用自动化脚本
./release.sh

# 或手动操作
git add -A
git commit -m "Release v0.4.0"
git tag -a v0.4.0 -m "Release v0.4.0"
```

#### Step 6: 推送到远程仓库

```bash
# 推送代码
git push origin main

# 推送标签
git push origin v0.4.0

# 或一次性推送所有标签
git push origin --tags
```

#### Step 7: 创建 GitHub Release

1. 访问: https://github.com/你的用户名/Linux-Clipboard/releases
2. 点击 "Draft a new release"
3. 选择标签: `v0.4.0`
4. 标题: `v0.4.0`
5. 复制 `RELEASE_NOTES_v0.4.0.md` 的内容到描述框
6. 上传 .deb 文件: `release/linux-clipboard_0.4.0_amd64.deb`
7. 点击 "Publish release"

#### Step 8: 更新文档

```bash
# 更新 Build.md
vim Build.md
# 添加新的版本记录

# 更新 Repair.md（如果有新问题）
vim Repair.md
# 添加问题排查记录

# 提交文档更新
git add Build.md Repair.md
git commit -m "docs: update build records for v0.4.0"
git push origin main
```

---

## 🔍 故障排查

### 构建问题

#### 问题1: npm install 失败

```bash
# 清理缓存
rm -rf node_modules package-lock.json
npm cache clean --force

# 重新安装
npm install
```

#### 问题2: Vite 构建失败

```bash
# 检查 Node.js 版本
node -v  # 应该 >= 18.0.0

# 清理并重建
rm -rf dist/ dist-electron/
npm run build
```

#### 问题3: electron-builder 失败

```bash
# 检查依赖
npm list electron electron-builder

# 重新安装 electron-builder
npm uninstall electron-builder
npm install electron-builder --save-dev

# 重新构建
npm run electron:build:deb
```

### 安装问题

#### 问题1: dpkg 依赖错误

```bash
# 自动修复依赖
sudo apt-get install -f -y

# 重新安装
sudo dpkg -i release/linux-clipboard_0.3.3_amd64.deb
```

#### 问题2: 应用无法启动

```bash
# 查看应用日志
/opt/Linux-Clipboard/linux-clipboard 2>&1 | tee debug.log

# 检查权限
ls -l /opt/Linux-Clipboard/linux-clipboard
# 应该是可执行的: -rwxr-xr-x

# 如果权限不正确
sudo chmod +x /opt/Linux-Clipboard/linux-clipboard
```

#### 问题3: 托盘图标不显示

```bash
# 检查图标文件
ls -l /opt/Linux-Clipboard/resources/icons/icon.png
# 应该存在且 > 0 bytes

# 检查文件类型
file /opt/Linux-Clipboard/resources/icons/icon.png
# 应该显示: PNG image data

# 如果图标缺失，重新安装
sudo dpkg -r linux-clipboard
sudo dpkg -i release/linux-clipboard_0.3.3_amd64.deb
```

### Git 问题

#### 问题1: 标签已存在

```bash
# 删除本地标签
git tag -d v0.4.0

# 删除远程标签
git push origin :refs/tags/v0.4.0

# 重新创建
git tag -a v0.4.0 -m "Release v0.4.0"
git push origin v0.4.0
```

#### 问题2: 推送被拒绝

```bash
# 拉取远程更新
git pull origin main --rebase

# 解决冲突（如果有）
git status

# 推送
git push origin main
```

---

## 📚 版本管理

### 版本号规则

项目采用语义化版本控制（Semantic Versioning）：

```
MAJOR.MINOR.PATCH

示例: 0.3.3
  └─ MAJOR: 主版本号（重大更改，不兼容）
     └─ MINOR: 次版本号（新功能，向后兼容）
        └─ PATCH: 修订号（Bug 修复）
```

**当前策略**: 每次发布迭代 +0.0.1
- 功能更新: MINOR +1
- Bug 修复: PATCH +1

### 版本历史

```bash
# 查看所有标签
git tag -l

# 查看标签详情
git show v0.3.3

# 查看版本间差异
git log v0.3.2..v0.3.3 --oneline

# 比较两个版本
git diff v0.3.2..v0.3.3
```

### 回滚版本

如果新版本有严重问题：

```bash
# 回滚到上一个版本
git checkout v0.3.2

# 重新构建
npm run electron:build:deb

# 创建热修复版本
./release.sh 0.3.4
```

---

## 📝 脚本详细说明

### build.sh 参数

```bash
./build.sh [version]

# 参数:
#   version  - 可选，新的版本号（如 0.4.0）
#            如果不提供，使用 package.json 中的当前版本

# 示例:
./build.sh           # 使用当前版本
./build.sh 0.4.0     # 更新到 v0.4.0 并构建
./build.sh 1.0.0     # 更新到 v1.0.0 并构建
```

### install.sh 参数

```bash
sudo ./install.sh [deb-path]

# 参数:
#   deb-path - 可选，.deb 文件路径
#             如果不提供，自动查找 release/ 目录中最新的 .deb 文件

# 示例:
sudo ./install.sh                                    # 自动查找最新版本
sudo ./install.sh release/linux-clipboard_0.3.3.deb # 安装指定版本
sudo ./install.sh ~/Downloads/linux-clipboard.deb   # 安装下载的文件
```

### release.sh 参数

```bash
./release.sh [version]

# 参数:
#   version  - 可选，版本标签（如 0.4.0）
#             如果不提供，使用 package.json 中的当前版本

# 示例:
./release.sh          # 使用当前版本
./release.sh 0.4.0    # 创建 v0.4.0 标签
```

---

## 🔐 安全注意事项

### API Key 存储

- ✅ 使用 AES-256-GCM 加密
- ✅ 配置文件权限 600
- ✅ 机器绑定的密钥派生
- ❌ 不要在代码中硬编码 API Key
- ❌ 不要将配置文件提交到 Git

### .gitignore 检查

确保 `.gitignore` 包含：
```
node_modules/
dist/
dist-electron/
release/
*.log
.DS_Store
```

---

## 📞 获取帮助

### 文档

- `Build.md` - 构建记录
- `Repair.md` - 问题排查与修复
- `CODEBUDDY.md` - 项目架构
- `README.md` - 项目介绍

### 命令帮助

```bash
# 查看脚本帮助（未来版本）
./build.sh --help      # 构建
./install.sh --help    # 安装
./release.sh --help    # 发布

# 查看 npm 脚本
npm run

# 查看 Git 状态
git status
git log --oneline -5
```

### 调试模式

```bash
# 启用详细输出
set -x  # 在脚本中或命令前

# 查看构建日志
npm run build --verbose

# 查看 Electron 日志
/opt/Linux-Clipboard/linux-clipboard --enable-logging
```

---

## 🎯 快速参考

### 常用命令

```bash
# 开发
npm run dev                    # 前端开发服务器
npm run electron:dev           # Electron 开发模式

# 构建
npm run build                  # 构建前端和 Electron
npm run electron:build:deb     # 构建 .deb 包

# 自动化脚本
./build.sh [version]           # 构建脚本
sudo ./install.sh [deb]        # 安装脚本
./release.sh [version]         # 发布脚本

# Git
git status                     # 查看状态
git add -A                     # 添加所有更改
git commit -m "message"        # 提交
git tag -a v0.4.0 -m "msg"     # 创建标签
git push origin main           # 推送代码
git push origin v0.4.0         # 推送标签
```

### 文件结构

```
Linux-Clipboard/
├── electron/                  # Electron 主进程
│   ├── main.ts
│   ├── preload.ts
│   └── store/
│       ├── config-store.ts
│       └── secure-store.ts
├── src/                       # React 前端
│   ├── App.tsx
│   └── components/
├── resources/                 # 资源文件
│   └── icons/
├── dist/                      # 前端构建输出
├── dist-electron/             # Electron 构建输出
├── release/                   # 安装包输出
├── build.sh                   # 构建脚本
├── install.sh                 # 安装脚本
├── release.sh                 # 发布脚本
├── Build.md                   # 构建记录
├── Repair.md                  # 问题排查
├── DEVELOPMENT.md             # 开发指南（本文档）
└── README.md                  # 项目介绍
```

---

**最后更新**: 2026-01-27 (CST, UTC+8)
**当前版本**: v0.3.3
**维护者**: Linux-Clipboard Team
