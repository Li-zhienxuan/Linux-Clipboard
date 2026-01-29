# Linux-Clipboard 开发日志

## 当前版本：v0.4.3

---

## 版本历史

### v0.4.3 (2026-01-29)

**构建系统升级**：
- ✅ 添加 AppImage 构建支持（通用 Linux 格式）
- ✅ 新增 `npm run electron:build:all` 同时构建 deb + AppImage
- ✅ 新增 `npm run electron:build:appimage` 单独构建 AppImage
- ✅ 更新发布脚本，支持同时上传两种格式到 GitHub

**发布工具改进**：
- ✅ `scripts/create-release.sh` 现在会检查并上传 deb 和 AppImage
- ✅ `scripts/release.sh` 添加 AppImage 安装说明
- ✅ Release notes 包含两种格式的下载和安装说明

**用户收益**：
- **deb 包**：Debian/Ubuntu 用户安装使用
- **AppImage**：所有 Linux 发行版通用，无需安装

**提交**：`aca635a` - feat: add AppImage build support and update release scripts

**使用方法**：
```bash
# 构建两种格式
npm run electron:build:all

# 或单独构建
npm run electron:build:deb      # 仅 deb
npm run electron:build:appimage # 仅 AppImage

# 发布到 GitHub（会同时上传两种格式）
./scripts/create-release.sh
```

---

### v0.4.0-v0.4.2 (2026-01-29)

**构建修复**：
- ✅ 修复版本号动态读取问题
- ✅ 使用 Vite define 注入版本号，避免直接导入 JSON

**提交**：
- `833a604` - fix: use Vite define for version injection instead of JSON import

---

### v0.3.9 (2026-01-29)

**新功能**：
- ✅ 添加应用标题栏：大号 "LinuxClipboard" 标题 + 版本号徽章
- ✅ 版本号动态从 package.json 读取，构建后自动更新

**改进**：
- ✅ 删除底部状态栏的重复版本号显示
- ✅ 类型定义重构：从根目录移至 src/types.tsx
- ✅ 图片复制功能优化（已测试通过）

**文档**：
- ✅ 添加 DEV_LOG.md 开发日志
- ✅ 添加 CONVERSATION_LOG.md 对话记录

**提交**：`8e04510` - feat: add app title header and improve version display

---

## 最新工作进度（2026-01-29）

### 已完成的任务

#### 1. 版本号显示修复 ✅
- **问题**：版本号在应用界面中不明显
- **解决方案**：在应用顶部添加明显的标题栏
- **修改文件**：`src/App.tsx:330-340`
- **显示效果**：
  - 大号 "LinuxClipboard" 渐变色标题（3xl，蓝色到紫色渐变）
  - 版本号徽章：v0.3.8（紫色，带边框和背景）
  - 位置：应用最顶部，在选项卡和搜索框之前
- **其他改进**：
  - 添加了调试日志用于诊断版本信息获取问题
  - 保留了底部状态栏的版本号显示
  - 设置模态框中显示完整版本信息

#### 2. 图片复制功能增强 ✅
- **测试状态**：已通过用户测试
- **功能**：图片可以正确复制到剪贴板

#### 3. 类型定义重构 ⚠️
- **状态**：部分完成
- **变更**：
  - ✅ 创建了新的 `src/types.tsx` 文件
  - ✅ 将类型定义从根目录的 `types.ts` 移动到 `src/types.tsx`
  - ✅ 在 `App.tsx` 和 `ClipboardCard.tsx` 中内联了类型定义
  - ⚠️ 待决定：是否保留 `src/types.tsx` 还是完全内联到各组件

---

## 当前 Git 状态

```
位于分支 main
您的分支与上游分支 'cnb/main' 一致。

### 已修改文件
- src/App.tsx（添加版本号显示、调试日志）
- src/components/ClipboardCard.tsx（内联类型定义）

### 已删除文件
- types.ts（已移至 src/types.tsx）

### 新增文件
- src/types.tsx（类型定义）
- DEV_LOG.md（开发日志）
- CONVERSATION_LOG.md（对话记录）

### 待提交变更
```

---

## 下一步计划

1. **完成类型重构**
   - [ ] 决定是否保留 `src/types.tsx` 还是完全内联到各组件
   - [ ] 如果保留，更新所有导入路径
   - [ ] 如果删除，确保所有组件都有内联类型定义

2. **测试所有功能**
   - [x] 测试图片复制功能（已完成）
   - [x] 测试版本号显示（已完成）
   - [ ] 验证所有交互功能正常

3. **提交变更**
   - [ ] 运行构建测试
   - [ ] 提交所有修改
   - [ ] 更新文档

---

## 技术栈

- **框架**: React + TypeScript
- **桌面框架**: Electron
- **UI**: Tailwind CSS + Lucide Icons
- **AI**: Google Gemini (图片分析和标签建议)
- **构建**: Vite
- **CI/CD**: CNB (Cloud Native Build)

---

## 重要文件位置

- 主应用: `src/App.tsx`
- 剪贴板卡片组件: `src/components/ClipboardCard.tsx`
- Gemini 服务: `src/services/geminiService.ts`
- 类型定义: `src/types.tsx` (新) 或各组件内
- Electron 主进程: `electron/main.ts`

---

## 注意事项

1. **断电/断网保护**：
   - 本文档记录所有开发进度
   - Git 提交前务必更新本文档
   - 重要功能完成后立即 commit

2. **类型定义一致性**：
   - 当前存在两份类型定义（`App.tsx` 和 `ClipboardCard.tsx` 内联）
   - 需要统一为单一来源
   - 建议使用 `src/types.tsx` 并导入到各组件

3. **图片功能**：
   - 图片复制使用 Clipboard API 需要安全上下文
   - 在 Electron 中应该可以正常工作
   - 需要测试实际图片复制到系统剪贴板

---

*最后更新：2026-01-29*
*此文档应在每次重要变更后更新*
