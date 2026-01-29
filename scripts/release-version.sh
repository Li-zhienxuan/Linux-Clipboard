#!/bin/bash
# 交互式版本发布脚本
# 用法：./release-version.sh
# 功能：输入版本号 → 更新 package.json → 构建 → 提交 → 推送 → 创建 Release

set -e

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}=========================================${NC}"
echo -e "${BLUE}  Linux-Clipboard 版本发布工具${NC}"
echo -e "${BLUE}=========================================${NC}"
echo ""

# 获取当前版本
CURRENT_VERSION=$(node -p "require('./package.json').version")
echo -e "当前版本: ${YELLOW}${CURRENT_VERSION}${NC}"
echo ""

# 输入新版本号
read -p "请输入新版本号 (例如: 0.3.5, v0.3.5): " INPUT_VERSION
VERSION=$(echo "$INPUT_VERSION" | sed 's/^v//')

# 验证版本号
if [[ ! "$VERSION" =~ ^[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
    echo -e "${RED}✗ 版本号格式错误！应为 x.y.z 格式${NC}"
    exit 1
fi

VERSION_TAG="v${VERSION}"
echo -e "${GREEN}目标版本: ${VERSION_TAG}${NC}"
echo ""

# 确认
read -p "确认发布 ${VERSION_TAG}? (y/n): " CONFIRM
if [ "$CONFIRM" != "y" ]; then
    echo "已取消"
    exit 0
fi
echo ""

# 1. 更新版本号
echo -e "${BLUE}[1/7]${NC} 更新 package.json..."

# 检查版本号是否相同
if [ "$CURRENT_VERSION" = "$VERSION" ]; then
    echo -e "${YELLOW}注意: 版本号与当前版本相同，将覆盖${NC}"
    # 使用 --allow-same-version 允许相同版本号
    npm version "$VERSION" --no-git-tag-version --allow-same-version
else
    npm version "$VERSION" --no-git-tag-version
fi

echo -e "${GREEN}✓ 版本已更新${NC}"
echo ""

# 2. 构建
echo -e "${BLUE}[2/7]${NC} 构建应用..."
npm run build
echo -e "${GREEN}✓ 构建成功${NC}"
echo ""

# 3. 构建 deb 和 AppImage
echo -e "${BLUE}[3/7]${NC} 构建 deb 包和 AppImage..."
npm run electron:build:all
echo -e "${GREEN}✓ deb 包和 AppImage 构建成功${NC}"
echo ""

# 4. 生成 Release Notes
echo -e "${BLUE}[4/7]${NC} 生成 Release Notes..."
cat > "RELEASE_NOTES_${VERSION}.md" <<EOF
# Linux-Clipboard ${VERSION_TAG}

## 🎉 主要更新

### 📦 版本信息
- **版本**: ${VERSION_TAG}
- **发布时间**: $(date '+%Y-%m-%d %H:%M:%S (CST, UTC+8)')
- **基于版本**: v${CURRENT_VERSION}

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

---

**完整更新日志**: https://github.com/Li-zhienxuan/Linux-Clipboard/compare/v${CURRENT_VERSION}...${VERSION_TAG}
EOF
echo -e "${GREEN}✓ Release Notes 已生成${NC}"
echo ""

# 5. Git 提交
echo -e "${BLUE}[5/7]${NC} Git 提交..."
git add package.json package-lock.json "RELEASE_NOTES_${VERSION}.md"

# 尝试提交，如果没有任何变化则跳过
if git diff --cached --quiet; then
    echo -e "${YELLOW}注意: 没有检测到文件变化，跳过提交${NC}"
else
    git commit -m "chore: release version ${VERSION_TAG}

- Update version to ${VERSION}
- Generate Release Notes

🤖 Generated with [Claude Code](https://claude.com/claude-code)"
    echo -e "${GREEN}✓ 提交已创建${NC}"
fi

# 检查 tag 是否已存在
if git rev-parse "${VERSION_TAG}" >/dev/null 2>&1; then
    echo -e "${YELLOW}注意: Tag ${VERSION_TAG} 已存在，将删除并重新创建${NC}"
    git tag -d "${VERSION_TAG}"
    git push origin ":refs/tags/${VERSION_TAG}" 2>/dev/null || true
fi

git tag -a "${VERSION_TAG}" -m "Release ${VERSION_TAG}"
echo -e "${GREEN}✓ Tag 已创建${NC}"
echo ""

# 6. 推送
echo -e "${BLUE}[6/7]${NC} 推送到远端..."
git push origin main
git push origin "${VERSION_TAG}"
echo -e "${GREEN}✓ GitHub 推送成功${NC}"

# 推送到 CNB
echo -e "${CYAN}推送到 CNB...${NC}"
git push cnb main

# 尝试推送 Tag 到 CNB（可能会失败，但不影响整体流程）
echo -e "${CYAN}推送 Tag 到 CNB...${NC}"
if git push cnb "${VERSION_TAG}" 2>/dev/null; then
    echo -e "${GREEN}✓ CNB Tag 推送成功${NC}"
else
    echo -e "${YELLOW}⚠️  CNB Tag 推送失败（可能 CNB 不支持或权限不足）${NC}"
    echo -e "${YELLOW}提示: 代码已推送，Tag 可以稍后手动推送${NC}"
fi
echo ""

# 7. 创建 Release
echo -e "${BLUE}[7/7]${NC} 创建 GitHub Release..."
read -p "是否创建 GitHub Release? (y/n): " CREATE_RELEASE

if [ "$CREATE_RELEASE" = "y" ]; then
    if [ -f "scripts/create-release.sh" ]; then
        # 使用环境变量传递版本号
        VERSION="${VERSION}" ./scripts/create-release.sh
    else
        echo -e "${YELLOW}⚠ Release 创建脚本不存在${NC}"
    fi
fi

echo ""
echo -e "${GREEN}=========================================${NC}"
echo -e "${GREEN}🎉 发布 ${VERSION_TAG} 完成！${NC}"
echo -e "${GREEN}=========================================${NC}"
echo ""
echo "后续步骤："
echo "1. 访问: https://github.com/Li-zhienxuan/Linux-Clipboard/releases"
echo "2. 验证 Release 是否创建成功"
echo "3. 通知用户更新"
