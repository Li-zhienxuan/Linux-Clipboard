#!/bin/bash
# CNB 推送修复脚本

echo "========================================="
echo "CNB 推送配置"
echo "========================================="
echo ""
echo "当前 CNB 远程 URL:"
git remote get-url cnb --push
echo ""
echo "问题: CNB 凭证未配置或已失效"
echo ""
echo "解决方案："
echo ""
echo "1️⃣  重新配置 CNB Token:"
echo "   ./scripts/setup-cnb-token.sh"
echo ""
echo "2️⃣  手动推送（使用密码）:"
echo "   git push https://cnb:PASSWORD@cnb.cool/ZhienXuan/Linux-Clipboard.git main"
echo ""
echo "3️⃣  跳过 CNB 推送（GitHub 已成功）:"
echo "   发布已成功，CNB 可选"
echo ""
echo "========================================="
echo ""

read -p "是否重新配置 CNB Token? (y/n): " choice

if [ "$choice" = "y" ]; then
    if [ -f "scripts/setup-cnb-token.sh" ]; then
        bash scripts/setup-cnb-token.sh
    else
        echo "❌ 脚本不存在，请手动配置"
    fi
else
    echo "跳过 CNB 配置"
fi
