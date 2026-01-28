#!/bin/bash
# CNB Access Token 配置脚本（项目级别）
# 凭据保存在项目本地，不影响全局配置

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

echo "========================================="
echo "CNB Access Token 配置（项目级别）"
echo "========================================="
echo ""
echo "项目路径: $PROJECT_ROOT"
echo "凭据存储位置: $PROJECT_ROOT/.git/credentials.local"
echo ""

# 步骤 1: 提示用户生成 Token
echo "【步骤 1】生成 CNB Access Token"
echo "-----------------------------------------"
echo "1. 访问 CNB: https://cnb.cool"
echo "2. 登录后进入: 设置 → Access Token / 个人令牌"
echo "3. 点击「生成新令牌」"
echo "4. 设置令牌名称（如：linux-clipboard-push）"
echo "5. 选择权限：至少需要「推送代码」权限"
echo "6. 复制生成的 Token（只显示一次！请务必保存）"
echo ""
read -p "按 Enter 键继续，确认您已获取到 Token..."
echo ""

# 步骤 2: 交互式输入 Token
echo "【步骤 2】输入凭据信息"
echo "-----------------------------------------"
read -p "请输入您的 CNB 用户名（默认: cnb）: " USERNAME
USERNAME=${USERNAME:-cnb}
echo ""
read -s -p "请输入 CNB Access Token: " TOKEN
echo ""
echo ""

# 验证输入
if [ -z "$TOKEN" ]; then
    echo "✗ Token 不能为空，退出..."
    exit 1
fi

# 步骤 3: 配置项目级别的 credential helper
echo "【步骤 3】配置项目级 Git 凭据"
echo "-----------------------------------------"
cd "$PROJECT_ROOT"

# 使用 --local 配置，只影响当前项目
git config --local credential.helper 'store --file=.git/credentials.local'
echo "✓ 项目级 credential helper 已配置"
echo "  配置文件: .git/config"
echo ""

# 步骤 4: 存储凭据到项目本地
echo "【步骤 4】存储凭据到项目本地"
echo "-----------------------------------------"
cat <<EOF | git credential approve
protocol=https
host=cnb.cool
username=$USERNAME
password=$TOKEN
EOF

echo "✓ CNB 凭据已保存到: .git/credentials.local"
echo ""

# 步骤 5: 确保 credentials.local 不会被推送
echo "【步骤 5】配置 .gitignore"
echo "-----------------------------------------"
if ! grep -q "^\.git/credentials\.local$" .gitignore 2>/dev/null; then
    echo "" >> .gitignore
    echo "# Git 凭据文件（本地使用，不推送）" >> .gitignore
    echo ".git/credentials.local" >> .gitignore
    echo "✓ 已将 .git/credentials.local 添加到 .gitignore"
else
    echo "✓ .gitignore 已包含 .git/credentials.local"
fi
echo ""

# 步骤 6: 验证配置
echo "【步骤 6】验证配置"
echo "-----------------------------------------"
echo "Git 配置（项目级别）："
git config --local --get credential.helper
echo ""
echo "凭据文件内容（脱敏）："
cat .git/credentials.local | sed 's/:[^:]*@/:***@/'
echo ""

# 步骤 7: 推送
echo "【步骤 7】推送到 CNB"
echo "-----------------------------------------"
git push cnb main
PUSH_RESULT=$?

echo ""
if [ $PUSH_RESULT -eq 0 ]; then
    echo "========================================="
    echo "✓ 推送到 CNB 成功！"
    echo "========================================="
    echo ""
    echo "配置摘要："
    echo "  - 凭据存储: $PROJECT_ROOT/.git/credentials.local"
    echo "  - Git 配置: $PROJECT_ROOT/.git/config（仅当前项目）"
    echo "  - 已添加到 .gitignore，不会被推送"
    echo "  - 后续推送将自动使用已保存的 Token"
else
    echo "========================================="
    echo "✗ 推送到 CNB 失败"
    echo "========================================="
    echo ""
    echo "故障排查："
    echo "1. Token 是否正确？"
    echo "2. Token 是否有「推送代码」权限？"
    echo "3. 用户名是否正确？"
    echo "4. 网络连接是否正常？"
    echo ""
    echo "如需重新配置："
    echo "  rm .git/credentials.local"
    echo "  ./scripts/setup-cbn-token.sh"
    exit 1
fi
