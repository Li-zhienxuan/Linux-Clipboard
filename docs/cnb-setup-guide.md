# CNB (腾讯云) 配置指南

本文档说明如何配置 CNB（腾讯 CodeBunk）的 Git 访问权限。

---

## 🔧 CNB 身份验证配置

### 方式 1: HTTPS + 凭据缓存（推荐）

#### 步骤 1: 配置 Git 凭据助手

```bash
# 配置 Git 使用凭据缓存
git config --global credential.helper store

# 或使用缓存（1小时）
git config --global credential.helper 'cache --timeout=3600'
```

#### 步骤 2: 首次推送时输入凭据

```bash
# 推送到 CNB（会提示输入用户名和密码）
git push cnb main

# 输入:
# Username: 你的用户名
# Password: 你的密码或 Token
```

**注意**:
- CNB 可能使用个人访问令牌（PAT）而不是密码
- 请在 CNB 设置中生成 Token
- Token 只会显示一次，请妥善保存

#### 步骤 3: 凭据保存后自动使用

```bash
# 下次推送无需输入密码
git push cnb main
git push cnb v0.4.0
```

---

### 方式 2: SSH 密钥认证（最安全）

#### 步骤 1: 生成 SSH 密钥

```bash
# 生成 SSH 密钥对
ssh-keygen -t ed25519 -C "your_email@example.com"

# 或使用 RSA（如果 ed25519 不可用）
ssh-keygen -t rsa -b 4096 -C "your_email@example.com"

# 按提示操作:
# - 保存位置: 默认 (~/.ssh/id_ed25519)
# - 密码短语: 可选（建议设置）
```

#### 步骤 2: 查看公钥

```bash
# 查看公钥内容
cat ~/.ssh/id_ed25519.pub

# 或
cat ~/.ssh/id_rsa.pub
```

#### 步骤 3: 添加 SSH 密钥到 CNB

1. 访问 CNB 设置页面: https://cnb.cool/-/profile/keys
2. 点击 **"Add SSH Key"** 或 **"添加 SSH 密钥"**
3. 粘贴公钥内容（从 `ssh-ed25519` 开始到结束）
4. 点击 **"Add Key"** 或 **"添加密钥"**

#### 步骤 4: 修改 CNB 远程地址为 SSH

```bash
# 查看当前远程地址
git remote -v

# 修改为 SSH 地址
git remote set-url cnb git@cnb.cool:ZhienXuan/Linux-Clipboard.git

# 验证
git remote -v
# 应该显示:
# cnb  git@cnb.cool:ZhienXuan/Linux-Clipboard.git (fetch)
# cnb  git@cnb.cool:ZhienXuan/Linux-Clipboard.git (push)
```

#### 步骤 5: 测试 SSH 连接

```bash
# 测试 SSH 连接
ssh -T git@cnb.cool

# 成功输出示例:
# Hi username! You've successfully authenticated...
```

#### 步骤 6: 推送到 CNB

```bash
# 现在可以无需密码推送
git push cnb main
git push cnb v0.4.0
```

---

### 方式 3: 使用 Personal Access Token (PAT)

#### 步骤 1: 在 CNB 生成 Token

1. 访问 CNB: https://cnb.cool
2. 进入 **Settings** → **Personal Access Tokens**
3. 点击 **"Add new token"**
4. 设置名称和权限:
   - `read_api`
   - `read_repository`
   - `write_repository`
5. 点击 **"Create personal access token"**
6. **复制 Token**（只会显示一次！）

#### 步骤 2: 使用 Token 推送

```bash
# 方式 A: 命令行输入
git push cnb main
# Username: your_username
# Password: paste_token_here

# 方式 B: 在 URL 中包含 Token
git remote set-url cnb https://your_token@cnb.cool/ZhienXuan/Linux-Clipboard.git
git push cnb main

# 方式 C: 使用 .netrc（不推荐，安全性低）
echo "machine cnb.cool login your_username password your_token" >> ~/.netrc
chmod 600 ~/.netrc
```

---

## 🎯 推荐配置

### 开发环境（个人电脑）

使用 **SSH 密钥认证**:
```bash
# 1. 生成 SSH 密钥
ssh-keygen -t ed25519 -C "your_email@example.com"

# 2. 添加到 CNB
# 访问: https://cnb.cool/-/profile/keys

# 3. 修改远程地址
git remote set-url cnb git@cnb.cool:ZhienXuan/Linux-Clipboard.git

# 4. 测试
ssh -T git@cnb.cool
```

### CI/CD 环境

使用 **Personal Access Token**:
```bash
# 在 CI 环境变量中设置
export CNB_TOKEN="your_token_here"

# 推送时使用
git push https://$CNB_TOKEN@cnb.cool/ZhienXuan/Linux-Clipboard.git main
```

---

## 📋 验证配置

### 测试 GitHub 连接

```bash
# 测试 GitHub SSH
ssh -T git@github.com

# 或测试 HTTPS
git ls-remote git@github.com:Li-zhienxuan/Linux-Clipboard.git
```

### 测试 CNB 连接

```bash
# 测试 CNB SSH（如果已配置）
ssh -T git@cnb.cool

# 或测试 HTTPS
git ls-remote https://cnb.cool/ZhienXuan/Linux-Clipboard.git
```

### 查看远程仓库配置

```bash
# 查看所有远程仓库
git remote -v

# 查看远程仓库详细信息
git remote show origin
git remote show cnb
```

---

## 🔄 自动化脚本配置

### 配置 .gitignore

确保 `.gitignore` 包含：
```gitignore
# Git 配置
.github-token
.gitconfig.local
.netrc
```

### 创建本地配置文件

```bash
# 创建 .gitconfig.local
cat > .gitconfig.local << 'EOF'
[credential]
    helper = store --file .git-credentials
EOF

# 添加到 .gitignore
echo ".gitconfig.local" >> .gitignore
echo ".git-credentials" >> .gitignore
```

---

## 🐛 常见问题

### 问题 1: SSH 密钥被拒绝

**错误**:
```
Permission denied (publickey)
fatal: Could not read from remote repository
```

**解决方案**:
```bash
# 1. 检查 SSH 密钥是否存在
ls -la ~/.ssh/id_*

# 2. 检查 SSH agent 是否运行
eval "$(ssh-agent -s)"
ssh-add ~/.ssh/id_ed25519

# 3. 测试 SSH 连接
ssh -v git@cnb.cool

# 4. 确认公钥已添加到 CNB
# 访问: https://cnb.cool/-/profile/keys
```

### 问题 2: Token 失效

**错误**:
```
401 Unauthorized
fatal: Authentication failed
```

**解决方案**:
```bash
# 1. 生成新的 Token
# 访问 CNB 设置页面

# 2. 更新 Git 凭据
git config --global credential.helper store

# 3. 清除旧的凭据
rm ~/.git-credentials

# 4. 重新推送（会要求输入新 Token）
git push cnb main
```

### 问题 3: HTTPS 和 SSH 混用

**错误**:
```
fatal: remote origin already exists
```

**解决方案**:
```bash
# 查看当前配置
git remote -v

# 统一使用 SSH
git remote set-url origin git@github.com:Li-zhienxuan/Linux-Clipboard.git
git remote set-url cnb git@cnb.cool:ZhienXuan/Linux-Clipboard.git

# 或统一使用 HTTPS
git remote set-url origin https://github.com/Li-zhienxuan/Linux-Clipboard.git
git remote set-url cnb https://cnb.cool/ZhienXuan/Linux-Clipboard.git
```

---

## 📚 相关链接

- CNB 文档: https://cnb.cool/help
- SSH 密钥文档: https://cnb.cool/help/ssh/README
- Personal Access Tokens: https://cnb.cool/-/profile/personal_access_tokens

---

**最后更新**: 2026-01-27 (CST, UTC+8)
