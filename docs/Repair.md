# Repair.md - 问题排查与修复记录

本文档记录 Linux-Clipboard 项目在开发、构建和测试过程中遇到的所有问题及其解决方案。

---

## Version 0.3.3 - 问题排查记录

**记录时间**: 2026-01-27 20:30:00 (CST, UTC+8)

### 构建测试阶段问题

#### 问题 #4: 系统托盘图标未包含在安装包中
**发现时间**: 2026-01-27 20:30:00 (CST, UTC+8)
**严重程度**: 🟡 中等
**影响版本**: v0.3.2

**问题描述**:
- 系统托盘图标文件在构建后没有被包含在安装包中
- 图标源文件存在于 `resources/icons/icon.png`
- 但打包后的 `release/linux-unpacked/resources/` 目录中没有 `icons/` 子目录

**排查过程**:
```bash
# 1. 检查源文件是否存在
ls -lh resources/icons/
# ✓ icon.png (9.7K) 存在

# 2. 检查打包后的文件
find release/linux-unpacked/resources -name "*.png"
# ✗ 结果为空 - 图标未包含

# 3. 检查 electron-builder 配置
cat electron-builder.json
# 发现缺少 extraResources 配置
```

**根本原因**:
- `electron-builder.json` 中只配置了 `buildResources: "resources"`
- 但这只用于构建过程（如应用图标），不会自动复制到最终包中
- 需要显式配置 `extraResources` 来包含额外的资源文件

**解决方案**:
```json
// electron-builder.json
{
  // ... 其他配置
  "extraResources": [
    {
      "from": "resources/icons/",
      "to": "icons/",
      "filter": ["**/*"]
    }
  ]
}
```

**实施步骤**:
1. 更新 `electron-builder.json` 添加 `extraResources` 配置
2. 更新版本号: 0.3.2 → 0.3.3
3. 重新构建: `npm run electron:build:deb`

**验证方法**:
```bash
# 检查打包后的图标文件
find release/linux-unpacked/resources -name "*.png"
# ✓ 应该显示: release/linux-unpacked/resources/icons/icon.png

# 检查文件大小
ls -lh release/linux-unpacked/resources/icons/
# ✓ 应该显示:
#   icon.png (9.7K)
#   icon.svg (1.3K)
```

**状态**: ✅ 已解决 (v0.3.3)

---

## Version 0.3.2 - 问题排查记录

**记录时间**: 2026-01-27 20:30:00 (CST, UTC+8)

### 构建前问题

#### 问题 #1: 明文存储 API Key 安全风险
**发现时间**: v0.2.0 版本
**严重程度**: 🔴 高危

**问题描述**:
- v0.2.0 版本中，Gemini API Key 以明文形式存储在配置文件中
- 配置文件位置: `~/.config/linux-clipboard/linux-clipboard-config.json`
- 任何可以访问用户目录的应用程序都能读取 API Key

**解决方案**:
```typescript
// 创建了 electron/store/secure-store.ts
// 实现 AES-256-GCM 加密存储
export class SecureStore {
  private readonly algorithm = 'aes-256-gcm';
  // 使用 scrypt 从机器 ID 派生密钥
  private key = scryptSync(machineId, 'linux-clipboard-salt', 32);
}
```

**实施步骤**:
1. 创建 `SecureStore` 类处理加密/解密
2. 创建 `SecureConfigStore` 类管理敏感配置
3. 设置配置文件权限为 600
4. 在 `main.ts` 中实现自动迁移逻辑

**验证方法**:
```bash
# 检查加密后的内容
cat ~/.config/linux-clipboard/linux-clipboard-secure.json
# 应该看到加密后的密文，而不是原始 API Key

# 检查文件权限
ls -la ~/.config/linux-clipboard/
# 应该显示: -rw------- (600)
```

**状态**: ✅ 已解决

---

#### 问题 #2: 环境检测在生产环境失效
**发现时间**: v0.3.0 开发阶段
**严重程度**: 🟡 中等

**问题描述**:
```typescript
// ❌ 旧代码 - 在打包后失效
const isDev = process.env.NODE_ENV !== 'production';

// 导致问题：打包后仍然连接 localhost:5173
// 错误信息: "Failed to load URL: localhost:5173"
```

**根本原因**:
- `electron-builder` 打包时不会设置 `NODE_ENV` 环境变量
- 依赖 `NODE_ENV` 的检测在生产环境中总是返回 `true`

**解决方案**:
```typescript
// ✅ 正确做法 - 使用 Electron 的打包状态
const isDev = !app.isPackaged;

// 需要修改的文件：
// - electron/main.ts:16
// - electron/tray-manager.ts:16
```

**修改位置**:
1. `electron/main.ts:16` - 主窗口环境检测
2. `electron/tray-manager.ts:16` - 托盘图标路径检测

**状态**: ✅ 已解决

---

#### 问题 #3: 托盘图标路径在生产环境中错误
**发现时间**: v0.3.0 开发阶段
**严重程度**: 🟡 中等

**问题描述**:
```typescript
// ❌ 旧代码
const iconPath = process.resourcesPath || app.getAppPath();
// 在某些情况下会 fallback 到错误的路径
```

**表现**:
- 系统托盘显示空白图标
- 控制台警告: "Tray icon is empty"

**解决方案**:
```typescript
// ✅ 正确做法
const isDev = !app.isPackaged;

if (isDev) {
  iconPath = path.join(process.cwd(), 'resources/icons/icon.png');
} else {
  // 生产环境直接使用 process.resourcesPath
  iconPath = path.join(process.resourcesPath, 'icons/icon.png');
}
```

**资源路径说明**:
- 开发环境: `Linux-Clipboard/resources/icons/icon.png`
- 生产环境: `/opt/Linux-Clipboard/resources/icons/icon.png`
- `process.resourcesPath` 在生产环境中指向 `/opt/Linux-Clipboard/resources/`

**状态**: ✅ 已解决

---

### 测试阶段问题

(本节将在测试过程中更新)

#### 问题 #4: 待记录
**发现时间**: 待测试
**严重程度**: 待评估

**问题描述**:
(待记录)

**解决方案**:
(待记录)

**状态**: ⏳ 待解决

---

### 迁移相关问题

#### 迁移测试: v0.2.0 → v0.3.2
**测试时间**: 待执行

**迁移场景**:
1. 用户已安装 v0.2.0，并配置了 API Key
2. 升级到 v0.3.2
3. 应用启动时自动检测并迁移

**预期行为**:
```bash
# 迁移前
~/.config/linux-clipboard/linux-clipboard-config.json
{
  "geminiApiKey": "AIzaSyC- plaintext key..."  # 明文
}

# 迁移后
~/.config/linux-clipboard/linux-clipboard-secure.json
{
  "geminiApiKey": "a4f8d2c1:8e9b... encrypted ..."  # 加密
}

~/.config/linux-clipboard/linux-clipboard-config.json
{
  # geminiApiKey 已被删除
}
```

**控制台输出**:
```
🔄 Migrating API key from plaintext config to secure storage...
✓ API key migration completed successfully
```

**测试步骤**:
1. 备份现有配置
2. 安装 v0.3.2
3. 启动应用
4. 验证 API Key 仍然可用
5. 检查配置文件已加密

**状态**: ⏳ 待测试

---

## 历史问题记录

### Version 0.3.1
- ✅ 实现基础加密存储
- ✅ 修复环境检测问题

### Version 0.2.0
- ✅ Electron 桌面应用初始实现
- ✅ 系统托盘集成
- ✅ 全局快捷键支持

---

## 常见问题排查指南

### 应用无法启动

**症状**: 双击应用无反应或立即崩溃

**排查步骤**:
```bash
# 1. 查看应用日志
/opt/Linux-Clipboard/linux-clipboard 2>&1 | tee debug.log

# 2. 检查依赖
ldd /opt/Linux-Clipboard/linux-clipboard

# 3. 检查配置文件权限
ls -la ~/.config/linux-clipboard/

# 4. 尝试以调试模式启动
/opt/Linux-Clipboard/linux-clipboard --enable-logging
```

### 托盘图标不显示

**症状**: 应用运行但托盘区域没有图标

**可能原因**:
1. 图标文件缺失
2. 图标路径错误
3. 图标格式不支持

**解决方案**:
```bash
# 检查图标文件是否存在
ls -l /opt/Linux-Clipboard/resources/icons/icon.png

# 检查图标格式
file /opt/Linux-Clipboard/resources/icons/icon.png
# 应该显示: PNG image data

# 检查文件大小
du -h /opt/Linux-Clipboard/resources/icons/icon.png
# 应该 > 0 bytes
```

### API Key 加密失败

**症状**: API Key 无法保存或读取

**排查步骤**:
```bash
# 1. 检查安全配置文件
ls -la ~/.config/linux-clipboard/linux-clipboard-secure.json
# 权限应该是 600

# 2. 如果权限不正确，手动修复
chmod 600 ~/.config/linux-clipboard/linux-clipboard-secure.json

# 3. 检查文件内容
cat ~/.config/linux-clipboard/linux-clipboard-secure.json
# 应该看到加密数据，格式: "iv:authTag:encrypted"
```

### 剪贴板监听失效

**症状**: 复制内容后应用没有反应

**可能原因**:
1. 权限问题
2. 剪贴板管理器进程崩溃
3. IPC 通信中断

**排查步骤**:
```bash
# 查看应用日志中的错误信息
# 检查是否有 "clipboard:new" 事件

# 重启应用尝试
killall linux-clipboard && /opt/Linux-Clipboard/linux-clipboard
```

---

## 开发环境问题

### Vite 开发服务器无法启动

**错误信息**: `Port 5173 is already in use`

**解决方案**:
```bash
# 查找占用端口的进程
lsof -i :5173

# 终止进程
kill -9 <PID>

# 或使用其他端口
vite --port 5174
```

### TypeScript 类型错误

**错误信息**: `Cannot find module 'electron'`

**解决方案**:
```bash
# 重新安装依赖
rm -rf node_modules package-lock.json
npm install

# 检查 @types/electron 是否安装
npm list @types/electron
```

---

**文档维护**: 每次遇到问题时更新此文档
**格式**: 问题描述 → 解决方案 → 验证方法
