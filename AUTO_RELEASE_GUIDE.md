# 自动化发布指南

本文档说明如何使用自动化脚本发布新版本到 GitHub 和 CNB。

---

## 🚀 快速开始

### 方式 1: 基本发布（手动创建 Release）

```bash
./auto-release.sh 0.4.0
```

这个命令会：
1. 检查工作区状态
2. 构建 .deb 包
3. 推送代码到 GitHub
4. 推送标签到 GitHub
5. 推送代码到 CNB
6. 推送标签到 CNB
7. **跳过** 自动创建 Release（需要手动操作）

### 方式 2: 完全自动化发布（推荐）

```bash
./auto-release.sh 0.4.0 YOUR_GITHUB_TOKEN
```

这个命令会：
1. 执行所有基本发布的步骤
2. **自动创建** GitHub Release
3. **自动上传** .deb 文件到 Release

---

## 📋 获取 GitHub Token

### 步骤 1: 创建 Personal Access Token

1. 访问 GitHub Settings: https://github.com/settings/tokens
2. 点击 **"Generate new token"** → **"Generate new token (classic)"**
3. 设置 Token 名称（如：Linux-Clipboard Release）
4. 选择权限（scopes）:
   - ✅ `repo` (完整仓库访问权限)
   - ✅ `repo:status` (提交状态权限)
   - ✅ `repo_deployment` (部署权限)
5. 点击 **"Generate token"**
6. **重要**: 复制 Token（只会显示一次！）

### 步骤 2: 保存 Token

**方式 A: 环境变量（推荐）**
```bash
# 添加到 ~/.bashrc 或 ~/.zshrc
export GITHUB_TOKEN="your_github_token_here"

# 重新加载配置
source ~/.bashrc

# 使用
./auto-release.sh 0.4.0 $GITHUB_TOKEN
```

**方式 B: 配置文件**
```bash
# 创建配置文件
cat > .github-token << EOF
your_github_token_here
EOF

# 设置权限（只有你能读写）
chmod 600 .github-token

# 使用
./auto-release.sh 0.4.0 $(cat .github-token)
```

**方式 C: 命令行参数**
```bash
# 直接输入（不推荐，会留在命令历史）
./auto-release.sh 0.4.0 ghp_xxxxxxxxxxxxxxxxxxxx
```

---

## 📝 完整发布流程

### 开发新版本

```bash
# 1. 编辑代码
vim src/App.tsx

# 2. 测试更改
npm run dev

# 3. 构建测试
npm run build
```

### 创建版本

```bash
# 方式 A: 使用自动化脚本
./build.sh 0.4.0          # 构建版本 0.4.0
./release.sh 0.4.0        # 创建 Git 提交和标签

# 方式 B: 手动步骤
vim package.json          # 修改版本号
npm run electron:build:deb
git add -A
git commit -m "Release v0.4.0"
git tag -a v0.4.0 -m "Release v0.4.0"
```

### 发布到 GitHub 和 CNB

```bash
# 自动发布（不创建 Release）
./auto-release.sh 0.4.0

# 或自动发布（创建 Release）
./auto-release.sh 0.4.0 $GITHUB_TOKEN
```

---

## 🔧 脚本功能说明

### auto-release.sh 执行步骤

```
1/8 检查工作区状态
   └─ 确保没有未提交的更改

2/8 构建 .deb 安装包
   └─ 如果不存在则自动构建

3/8 推送代码到 GitHub
   └─ git push origin main

4/8 推送标签到 GitHub
   └─ git push origin v0.4.0

5/8 推送代码到 CNB
   └─ git push cnb main

6/8 推送标签到 CNB
   └─ git push cnb v0.4.0

7/8 创建 GitHub Release
   └─ 使用 GitHub API（如果提供 Token）

8/8 显示发布信息
   └─ 显示下载链接和安装命令
```

---

## 📊 发布检查清单

发布前检查：
- [ ] 代码已测试
- [ ] 版本号已更新
- [ ] .deb 包已构建
- [ ] Git 提交已创建
- [ ] Git 标签已创建
- [ ] Release Notes 已编写

发布后验证：
- [ ] GitHub Release 已创建
- [ ] .deb 文件已上传
- [ ] CNB 代码已同步
- [ ] 下载链接可用
- [ ] 安装测试通过

---

## 🌍 多平台发布

### GitHub (origin)
```bash
# 推送代码
git push origin main

# 推送标签
git push origin v0.4.0

# 创建 Release（使用脚本）
./auto-release.sh 0.4.0 $GITHUB_TOKEN
```

### CNB (cnb)
```bash
# 推送代码
git push cnb main

# 推送标签
git push cnb v0.4.0

# 查看 CNB 仓库
# https://cnb.cool/ZhienXuan/Linux-Clipboard
```

---

## 🐛 故障排查

### 问题 1: CNB 推送失败

**错误信息**:
```
fatal: could not read Username for 'https://cnb.cool'
```

**解决方案**:
```bash
# 配置 Git 凭据
git config --global credential.helper store

# 再次推送（会要求输入用户名和密码）
git push cnb main
```

### 问题 2: GitHub Token 无效

**错误信息**:
```
401 Unauthorized
```

**解决方案**:
1. 检查 Token 是否正确
2. 确认 Token 有 `repo` 权限
3. Token 可能已过期，重新生成

### 问题 3: .deb 文件上传失败

**错误信息**:
```
Upload failed: 413 Payload Too Large
```

**解决方案**:
GitHub Release 文件限制为 2GB，当前 .deb 只有 75MB，应该不会超过限制。

如果是网络问题，可以手动上传：
```bash
# 使用 GitHub CLI
gh release upload v0.4.0 release/linux-clipboard_0.4.0_amd64.deb

# 或在网页上传
# https://github.com/Li-zhienxuan/Linux-Clipboard/releases/edit/v0.4.0
```

### 问题 4: 标签已存在

**错误信息**:
```
! [rejected] v0.4.0 -> v0.4.0 (would clobber existing tag)
```

**解决方案**:
```bash
# 删除本地标签
git tag -d v0.4.0

# 删除远程标签
git push origin :refs/tags/v0.4.0
git push cnb :refs/tags/v0.4.0

# 重新创建和推送
git tag -a v0.4.0 -m "Release v0.4.0"
git push origin v0.4.0
git push cnb v0.4.0
```

---

## 📚 相关文档

- `DEVELOPMENT.md` - 完整开发指南
- `Build.md` - 构建记录
- `Repair.md` - 问题排查
- `release.sh` - 发布脚本（仅 Git）

---

## 🎯 最佳实践

### 版本号管理
```bash
# 遵循语义化版本
MAJOR.MINOR.PATCH

示例:
0.3.3 → 0.4.0  (功能更新)
0.4.0 → 0.4.1  (Bug 修复)
0.4.1 → 1.0.0  (重大版本)
```

### 发布频率
- 主版本: 每月或重大功能
- 次版本: 每周或新功能
- 修订版: 随时或 Bug 修复

### 发布前测试
```bash
# 1. 本地测试
sudo ./install.sh release/linux-clipboard_0.4.0_amd64.deb

# 2. 功能测试
/opt/Linux-Clipboard/linux-clipboard

# 3. 卸载测试
sudo dpkg -r linux-clipboard
```

---

**最后更新**: 2026-01-27 (CST, UTC+8)
**当前版本**: v0.3.3
