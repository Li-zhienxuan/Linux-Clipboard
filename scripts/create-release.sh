#!/bin/bash
# GitHub Release 创建脚本（交互式输入 Token）
# Token 保存在项目本地，不推送到远端
# 用法：VERSION=0.3.5 ./create-release.sh

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
cd "$PROJECT_ROOT"

TOKEN_FILE=".github-token-local"

# 接受版本号参数或从 package.json 读取
VERSION="${VERSION:-$(node -p "require('./package.json').version")}"
VERSION_TAG="v${VERSION}"

echo "========================================="
echo "GitHub Release 创建（项目本地 Token）"
echo "========================================="
echo ""
echo "项目路径: $PROJECT_ROOT"
echo "Token 存储: $TOKEN_FILE (本地，不推送)"
echo ""
echo "版本: ${VERSION_TAG}"
echo ""

# 检查是否已有 Token
if [ -f "$TOKEN_FILE" ]; then
    echo "发现已保存的 Token"
    read -p "是否使用已保存的 Token? (y/n，默认: y): " USE_SAVED
    USE_SAVED=${USE_SAVED:-y}
    echo ""

    if [ "$USE_SAVED" = "y" ]; then
        TOKEN=$(cat "$TOKEN_FILE")
    else
        rm -f "$TOKEN_FILE"
        read -s -p "请输入 GitHub Personal Access Token: " TOKEN
        echo ""
        echo ""
    fi
else
    # 交互式输入 Token
    read -s -p "请输入 GitHub Personal Access Token: " TOKEN
    echo ""
    echo ""

    # 验证输入
    if [ -z "$TOKEN" ]; then
        echo "✗ Token 不能为空，退出..."
        exit 1
    fi

    # 保存到项目本地
    echo "$TOKEN" > "$TOKEN_FILE"
    chmod 600 "$TOKEN_FILE"
    echo "✓ Token 已保存到项目本地: $TOKEN_FILE"
    echo ""
fi

# 设置 GitHub Token
export GH_TOKEN="$TOKEN"
echo "✓ GitHub Token 已设置"
echo ""

# 检查 Tag 是否存在
if ! git rev-parse "${VERSION_TAG}" >/dev/null 2>&1; then
    echo "正在创建 Git Tag: ${VERSION_TAG}..."
    git tag -a "${VERSION_TAG}" -m "Release ${VERSION_TAG}"
    git push origin "${VERSION_TAG}"
    echo "✓ Tag 已创建并推送"
    echo ""
fi

# 检查 deb 文件是否存在
DEB_FILE="release/linux-clipboard_${VERSION}_amd64.deb"
if [ ! -f "$DEB_FILE" ]; then
    echo "✗ 找不到 deb 文件: $DEB_FILE"
    echo "请先运行: npm run electron:build:deb"
    exit 1
fi

# 检查 Release Notes 是否存在
RELEASE_NOTES_FILE="RELEASE_NOTES_${VERSION}.md"
if [ ! -f "$RELEASE_NOTES_FILE" ]; then
    echo "⚠️  找不到 Release Notes: $RELEASE_NOTES_FILE"
    echo "将使用默认 Release Notes..."
    cat > "$RELEASE_NOTES_FILE" <<EOF
# Linux-Clipboard ${VERSION_TAG}

## 🎉 发布

### 📦 版本信息
- **版本**: ${VERSION_TAG}
- **发布时间**: $(date '+%Y-%m-%d %H:%M:%S (CST, UTC+8)')

### 📦 安装

\`\`\`bash
wget https://github.com/Li-zhienxuan/Linux-Clipboard/releases/download/${VERSION_TAG}/linux-clipboard_${VERSION}_amd64.deb
sudo dpkg -i linux-clipboard_${VERSION}_amd64.deb
\`\`\`

## ✨ 功能特性

- 📋 智能剪贴板管理
- 🏷️ AI 自动标签生成
- 🔍 快速搜索
- ⌨️ 全局快捷键 (Ctrl+Shift+V)
- 🔒 安全的 API Key 存储
- 🎨 现代化 UI
EOF
fi

# 创建 Release
echo "正在创建 GitHub Release..."
echo ""

gh release create "${VERSION_TAG}" \
    "$DEB_FILE" \
    --title "${VERSION_TAG} - Release / 发布版本" \
    --notes-file "$RELEASE_NOTES_FILE"

RELEASE_RESULT=$?

echo ""
if [ $RELEASE_RESULT -eq 0 ]; then
    echo "========================================="
    echo "✓ GitHub Release 创建成功！"
    echo "========================================="
    echo ""
    echo "Release 地址: https://github.com/Li-zhienxuan/Linux-Clipboard/releases/tag/${VERSION_TAG}"
    echo ""
    echo "Token 已保存到: $TOKEN_FILE"
    echo "下次创建 Release 时可直接使用"
    echo ""
    echo "后续步骤："
    echo "1. 访问 Release 页面验证"
    echo "2. 通知用户更新"
else
    echo "========================================="
    echo "✗ GitHub Release 创建失败"
    echo "========================================="
    echo ""
    echo "故障排查："
    echo "1. Token 是否有 'repo' 权限？"
    echo "2. Tag '${VERSION_TAG}' 是否已推送？"
    echo "3. 网络连接是否正常？"
    echo "4. deb 文件是否存在: $DEB_FILE"
    echo ""
    echo "如需重新配置 Token："
    echo "  rm $TOKEN_FILE"
    echo "  ./scripts/create-release.sh"
    exit 1
fi
