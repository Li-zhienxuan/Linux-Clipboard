#!/bin/bash
# Linux-Clipboard 管理脚本 - 简洁版

# 颜色定义
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

VERSION=$(node -p "require('./package.json').version" 2>/dev/null || echo "unknown")

# 显示菜单
show_menu() {
    clear
    echo -e "${BLUE}Linux-Clipboard 管理工具 v${VERSION}${NC}"
    echo ""
    echo -e "${GREEN}【开发】${NC}"
    echo "  1. 开发模式        npm run electron:dev"
    echo "  2. 构建应用        npm run build"
    echo "  3. 构建安装包      DEB/AppImage"
    echo "  k. 终止所有进程"
    echo ""
    echo -e "${YELLOW}【发布】${NC}"
    echo "  4. 发布新版本      更新版本→构建→推送→Release"
    echo "  5. 创建 Release    上传到 GitHub"
    echo "  6. 查看版本信息    Git/Tags/提交"
    echo ""
    echo -e "${GREEN}【配置】${NC}"
    echo "  7. 配置 CNB Token"
    echo "  8. 项目状态        Git/构建文件"
    echo ""
    echo -e "${GREEN}【推送】${NC}"
    echo "  9. 推送到 GitHub"
    echo "  a. 推送到 CNB"
    echo "  b. 推送到所有"
    echo ""
    echo "  0. 退出"
    echo ""
    echo -n "请选择 [0-9,a-k,b]: "
}

# 执行操作
execute_action() {
    case $1 in
        1)
            echo -e "\n${GREEN}▶ 启动开发模式${NC}"
            npm run electron:dev
            ;;
        2)
            echo -e "\n${GREEN}▶ 构建应用${NC}"
            npm run build
            echo -e "${GREEN}✓ 完成${NC}"
            read
            ;;
        3)
            echo -e "\n${GREEN}▶ 选择构建目标${NC}"
            echo "1. DEB    2. AppImage    3. 全部"
            echo -n "选择: "
            read target
            case $target in
                1) bash scripts/build-with-progress.sh deb ;;
                2) bash scripts/build-with-progress.sh appimage ;;
                3) bash scripts/build-with-progress.sh all ;;
                *) echo "无效选择"; return ;;
            esac
            read
            ;;
        k)
            bash scripts/kill-all.sh
            read
            ;;
        4)
            echo -e "\n${YELLOW}▶ 发布新版本${NC}"
            bash scripts/release-version.sh
            read
            ;;
        5)
            echo -e "\n${YELLOW}▶ 创建 GitHub Release${NC}"
            bash scripts/create-release.sh
            read
            ;;
        6)
            echo -e "\n${YELLOW}▶ 版本信息${NC}"
            echo "版本: $VERSION"
            echo "分支: $(git branch --show-current)"
            echo "提交: $(git log -1 --format='%h - %s')"
            echo ""
            echo "Tags:"
            git tag --sort=-v:refname | head -5 | sed 's/^/  /'
            read
            ;;
        7)
            echo -e "\n${GREEN}▶ 配置 CNB Token${NC}"
            bash scripts/setup-cnb-token.sh
            read
            ;;
        8)
            echo -e "\n${GREEN}▶ 项目状态${NC}"
            echo "Git 状态:"
            git status --short | sed 's/^/  /' || echo "  干净"
            echo ""
            echo "最新构建:"
            ls -lt release/*.deb 2>/dev/null | head -1 | awk '{print "  " $9 " (" $5 ")"}' || echo "  无"
            read
            ;;
        9)
            echo -e "\n${GREEN}▶ 推送到 GitHub${NC}"
            git push origin main
            echo -e "${GREEN}✓ 完成${NC}"
            read
            ;;
        a)
            echo -e "\n${GREEN}▶ 推送到 CNB${NC}"
            git push cnb main
            echo -e "${GREEN}✓ 完成${NC}"
            read
            ;;
        b)
            echo -e "\n${GREEN}▶ 推送到所有远端${NC}"
            git push origin main && git push cnb main
            echo -e "${GREEN}✓ 完成${NC}"
            read
            ;;
        0)
            echo -e "\n${GREEN}再见！${NC}\n"
            exit 0
            ;;
        *)
            echo -e "\033[0;31m无效选项\033[0m"
            sleep 1
            ;;
    esac
}

# 主循环
main() {
    while true; do
        show_menu
        read choice
        execute_action "$choice"
    done
}

main
