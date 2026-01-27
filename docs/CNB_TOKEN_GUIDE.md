# CNB Token 配置快速指南

## 🚀 快速开始（3 步完成）

### 步骤 1: 获取 CNB Token

1. 访问 CNB: https://cnb.cool
2. 点击右上角头像 → **Settings**（设置）
3. 左侧菜单 → **Personal Access Tokens**（个人访问令牌）
4. 点击 **Add new token**（添加新令牌）
5. 填写信息：
   - **Name**: Linux-Clipboard Release
   - **Expires date**: 选择过期时间（建议 90 天或更长）
   - **Select scopes**: 勾选 `api`, `read_api`, `read_repository`, `write_repository`
6. 点击 **Create personal access token**
7. ⚠️ **重要**: 复制 Token（只会显示一次！）

### 步骤 2: 创建 Token 配置文件

在项目根目录执行：

```bash
# 创建 CNB Token 文件
echo '你的CNB_Token粘贴到这里' > .cnb-token

# 设置安全权限（只有你能读写）
chmod 600 .cnb-token

# 验证文件已创建
ls -lh .cnb-token
# 应该显示: -rw------- (600)
```

### 步骤 3: 运行自动发布

```bash
# 现在可以自动发布到 GitHub 和 CNB
./auto-release.sh 0.4.0
```

---

## 🔐 安全说明

### ✅ 安全做法

- ✅ Token 文件已添加到 `.gitignore`（不会被提交到 Git）
- ✅ 文件权限设置为 600（只有你能读写）
- ✅ Token 只在本地使用，不会泄露

### ❌ 危险做法

- ❌ 不要在代码中硬编码 Token
- ❌ 不要将 Token 文件提交到 Git
- ❌ 不要在命令历史中使用明文 Token
- ❌ 不要分享 Token 给他人

---

## 📋 验证配置

### 检查 Token 文件

```bash
# 1. 检查文件是否存在
ls -la .cnb-token

# 2. 检查文件权限
stat -c %a .cnb-token
# 应该显示: 600

# 3. 检查文件内容（确认 Token 正确）
cat .cnb-token
```

### 测试推送到 CNB

```bash
# 测试推送（会自动使用 .cnb-token 中的 Token）
git push cnb main
```

---

## 💡 使用方式

### 方式 1: 使用配置文件（推荐）

```bash
# 创建 .cnb-token 文件
echo 'your_token_here' > .cnb-token
chmod 600 .cnb-token

# 直接运行（自动读取 Token）
./auto-release.sh 0.4.0
```

### 方式 2: 使用命令行参数

```bash
# 在命令中提供 Token
./auto-release.sh 0.4.0 $GITHUB_TOKEN your_cnb_token_here
```

**注意**: 方式 2 会将 Token 留在命令历史中，不推荐！

### 方式 3: 使用环境变量

```bash
# 设置环境变量
export CNB_TOKEN='your_token_here'

# 运行发布
./auto-release.sh 0.4.0
```

---

## 🔄 自动发布流程

配置好 Token 后，执行 `./auto-release.sh` 会自动：

1. ✅ 检查工作区状态
2. ✅ 构建 .deb 包
3. ✅ 推送代码到 GitHub
4. ✅ 推送标签到 GitHub
5. ✅ **推送代码到 CNB**（使用 Token）
6. ✅ **推送标签到 CNB**（使用 Token）
7. ✅ 创建 GitHub Release（如果提供 GitHub Token）
8. ✅ 上传 .deb 文件到 Release
9. ✅ 生成发布信息

---

## 🛠️ 故障排查

### 问题 1: Token 无效

**错误信息**:
```
remote: Invalid username or password
fatal: Authentication failed
```

**解决方案**:
```bash
# 1. 检查 Token 是否正确
cat .cnb-token

# 2. 重新生成 Token
# 访问: https://cnb.cool/-/profile/personal_access_tokens

# 3. 更新 .cnb-token 文件
echo 'new_token_here' > .cnb-token
chmod 600 .cnb-token
```

### 问题 2: 权限不足

**错误信息**:
```
remote: You are not allowed to push code to this project
fatal: could not read Username
```

**解决方案**:
1. 检查 Token 是否有 `write_repository` 权限
2. 重新生成 Token 并勾选正确的权限
3. 确认你有该项目的写入权限

### 问题 3: 文件权限错误

**错误信息**:
```
bash: .cnb-token: Permission denied
```

**解决方案**:
```bash
# 修复文件权限
chmod 600 .cnb-token

# 检查所有者
ls -la .cnb-token
```

---

## 📚 相关文档

- `auto-release.sh` - 自动化发布脚本
- `AUTO_RELEASE_GUIDE.md` - 完整发布指南
- `cnb-setup-guide.md` - CNB 详细配置指南

---

**⚠️ 重要提醒**:
- Token 只会显示一次，请妥善保存
- 定期更新 Token（建议每 90 天）
- 如果 Token 泄露，立即撤销并重新生成
- 不要在公共场合展示 Token

---

**最后更新**: 2026-01-27 (CST, UTC+8)
