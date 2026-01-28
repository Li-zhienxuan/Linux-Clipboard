#!/bin/bash
# CNB 令牌配置和推送脚本

echo "========================================="
echo "CNB 令牌配置和推送"
echo "========================================="
echo ""
echo "正在配置 CNB 认证..."
echo ""

# 交互式输入令牌
read -s -p "请输入 CNB 令牌 (Personal Access Token): " TOKEN
echo ""
echo ""

# 设置 Git 凭据
echo "正在保存 CNB 凭据到本地..."
git config credential.helper store

# 使用 git credential approve 存储凭据
cat <<EOF | git credential approve
protocol=https
host=cnb.cool
username=cnb
password=$TOKEN
EOF

echo "✓ CNB 令牌已保存到本地 Git 凭据存储"
echo ""
echo "正在推送到 CNB..."
echo ""

# 推送到 CNB
git push cnb main

if [ $? -eq 0 ]; then
    echo ""
    echo "========================================="
    echo "✓ 推送到 CNB 成功！"
    echo "========================================="
else
    echo ""
    echo "========================================="
    echo "✗ 推送到 CNB 失败"
    echo "========================================="
    echo "请检查："
    echo "1. 令牌是否正确"
    echo "2. 令牌是否有推送权限"
    echo "3. 网络连接是否正常"
fi
