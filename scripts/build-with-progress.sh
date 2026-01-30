#!/bin/bash
# Linux-Clipboard 构建脚本 - 简洁版

# 颜色定义
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# 获取构建目标
TARGET=${1:-"deb"}

# 获取版本号
VERSION=$(node -p "require('./package.json').version" 2>/dev/null || echo "unknown")

echo -e "${BLUE}========================================${NC}"
echo -e "${BLUE}  Linux-Clipboard 构建${NC}"
echo -e "${BLUE}  版本: ${VERSION}${NC}"
echo -e "${BLUE}  目标: ${TARGET}${NC}"
echo -e "${BLUE}========================================${NC}\n"

# 清理旧文件
echo -e "${YELLOW}[1/3] 清理旧文件...${NC}"
rm -rf dist dist-electron release 2>/dev/null || true
echo -e "${GREEN}✓ 清理完成${NC}\n"

# 构建项目
echo -e "${YELLOW}[2/3] 构建项目 (前端 + Electron)...${NC}"
npm run build || {
    echo -e "\033[0;31m✗ 构建失败\033[0m"
    exit 1
}
echo -e "${GREEN}✓ 构建完成${NC}\n"

# 打包
echo -e "${YELLOW}[3/3] 打包 ${TARGET}...${NC}"
case $TARGET in
    "deb")
        npx electron-builder --linux deb || {
            echo -e "\033[0;31m✗ DEB 打包失败\033[0m"
            exit 1
        }
        ;;
    "appimage")
        npx electron-builder --linux AppImage || {
            echo -e "\033[0;31m✗ AppImage 打包失败\033[0m"
            exit 1
        }
        ;;
    "all")
        npx electron-builder --linux deb --linux AppImage || {
            echo -e "\033[0;31m✗ 打包失败\033[0m"
            exit 1
        }
        ;;
    *)
        echo -e "\033[0;31m✗ 未知目标: $TARGET\033[0m"
        echo "可用目标: deb, appimage, all"
        exit 1
        ;;
esac

echo -e "${GREEN}✓ 打包完成${NC}\n"

# 显示结果
echo -e "${BLUE}========================================${NC}"
echo -e "${GREEN}  ✓ 构建完成！${NC}"
echo -e "${BLUE}========================================${NC}\n"

echo "生成的文件:"
ls -lh release/*.{deb,AppImage} 2>/dev/null | awk '{printf "  • %s (%s)\n", $9, $5}'
echo ""
