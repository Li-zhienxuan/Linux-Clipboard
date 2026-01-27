# Linux-Clipboard 文档索引

本文档汇总了 Linux-Clipboard 项目的所有文档链接。

---

## 📚 快速导航

| 文档 | 说明 | 位置 |
|------|------|------|
| [README.md](../README.md) | 项目介绍和快速开始 | 根目录 |
| [CODEBUDDY.md](CODEBUDDY.md) | 项目架构和开发规范 | docs/ |
| [DEVELOPMENT.md](DEVELOPMENT.md) | 完整开发指南 | docs/ |
| [Build.md](Build.md) | 构建记录和版本历史 | docs/ |
| [Repair.md](Repair.md) | 问题排查与修复记录 | docs/ |

---

## 🚀 开发相关

### 项目架构
- **[CODEBUDDY.md](CODEBUDDY.md)** - CodeBuddy 开发指南
  - 项目概述
  - 常用命令
  - 架构设计
  - 技术栈版本

### 开发指南
- **[DEVELOPMENT.md](DEVELOPMENT.md)** - 完整开发指南
  - 快速开始
  - 开发流程
  - 自动化脚本
  - 发布流程
  - 故障排查
  - 版本管理

### 构建相关
- **[Build.md](Build.md)** - 构建记录文档
  - 版本构建记录
  - 每次迭代的详细记录
  - 构建步骤和产物

---

## 🔧 维护相关

### 问题排查
- **[Repair.md](Repair.md)** - 问题排查与修复记录
  - 版本问题记录
  - 常见问题解决
  - 开发环境问题
  - 安装问题
  - Git 问题

---

## 📦 发布相关

### 自动化发布
- **[AUTO_RELEASE_GUIDE.md](AUTO_RELEASE_GUIDE.md)** - 自动化发布指南
  - 获取 GitHub Token
  - 自动发布流程
  - 多平台发布
  - 发布检查清单

### CNB 配置
- **[cnb-setup-guide.md](cnb-setup-guide.md)** - CNB 详细配置指南
  - SSH 密钥认证
  - HTTPS + Token 认证
  - 常见问题解决

### Token 配置
- **[CNB_TOKEN_GUIDE.md](CNB_TOKEN_GUIDE.md)** - CNB Token 快速配置
  - 3 步完成配置
  - 安全说明
  - 使用方式

### 发布记录
- **[RELEASE_NOTES_v0.3.3.md](RELEASE_NOTES_v0.3.3.md)** - v0.3.3 发布说明
  - 新功能介绍
  - 技术改进
  - 安装指南

---

## 🤖 AI 助手配置

- **[CLAUDE.md](CLAUDE.md)** - Claude Code 项目指南
  - 项目概述
  - 常用命令
  - 环境变量配置
  - 架构设计

---

## 🛠️ 脚本索引

所有脚本位于 `scripts/` 目录：

| 脚本 | 功能 | 用法 |
|------|------|------|
| [build.sh](../scripts/build.sh) | 一键构建 | `./scripts/build.sh [version]` |
| [install.sh](../scripts/install.sh) | 一键安装 | `sudo ./scripts/install.sh [deb]` |
| [release.sh](../scripts/release.sh) | Git 发布 | `./scripts/release.sh [version]` |
| [auto-release.sh](../scripts/auto-release.sh) | 自动发布 | `./scripts/auto-release.sh [version]` |
| [setup-cnb.sh](../scripts/setup-cnb.sh) | CNB 配置 | `./scripts/setup-cnb.sh` |

---

## 📖 使用方式

### 查看文档

```bash
# 方式 1: 直接打开（在项目根目录）
cat docs/DEVELOPMENT.md

# 方式 2: 使用 less 浏览
less docs/DEVELOPMENT.md

# 方式 3: 在编辑器中打开
vim docs/DEVELOPMENT.md
```

### 运行脚本

```bash
# 方式 1: 从 scripts/ 目录运行
cd scripts
./build.sh 0.4.0

# 方式 2: 从根目录运行
./scripts/build.sh 0.4.0

# 方式 3: 添加到 PATH（推荐）
export PATH="$PATH:./scripts"
build.sh 0.4.0
```

---

## 🎯 按场景查找文档

### 我想...

**开始开发项目**
→ [DEVELOPMENT.md](DEVELOPMENT.md) - 快速开始部分

**构建新版本**
→ [Build.md](Build.md) - 查看构建记录

**发布新版本**
→ [AUTO_RELEASE_GUIDE.md](AUTO_RELEASE_GUIDE.md) - 完整发布流程

**解决问题**
→ [Repair.md](Repair.md) - 问题排查部分

**配置 CNB**
→ [CNB_TOKEN_GUIDE.md](CNB_TOKEN_GUIDE.md) - 快速配置

**了解项目架构**
→ [CODEBUDDY.md](CODEBUDDY.md) - 项目架构部分

---

## 📝 文档维护

### 文档更新规则

1. **每次构建后更新** - Build.md
2. **每次修复问题后更新** - Repair.md
3. **每次发布后更新** - DEVELOPMENT.md 和 AUTO_RELEASE_GUIDE.md
4. **时间戳使用北京时间** - `date "+%Y-%m-%d %H:%M:%S (CST, UTC+8)"`

### 文档格式

所有 Markdown 文档遵循以下格式：
- 使用北京时间戳（CST, UTC+8）
- 使用代码高亮
- 使用表格和列表
- 添加目录导航（如果需要）

---

## 🔗 相关链接

- **GitHub**: https://github.com/Li-zhienxuan/Linux-Clipboard
- **CNB**: https://cnb.cool/ZhienXuan/Linux-Clipboard
- **Issues**: https://github.com/Li-zhienxuan/Linux-Clipboard/issues

---

**最后更新**: 2026-01-27 (CST, UTC+8)
**维护者**: Linux-Clipboard Team
