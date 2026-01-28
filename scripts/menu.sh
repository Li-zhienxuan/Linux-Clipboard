#!/bin/bash
# Linux-Clipboard 统一管理脚本
# 所有操作的一站式入口

set -e

# 颜色定义
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
RED='\033[0;31m'
BOLD='\033[1m'
NC='\033[0m'

# 获取脚本目录
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
cd "$PROJECT_ROOT"

# 显示主菜单
show_menu() {
    clear
    echo -e "${CYAN}╔════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${CYAN}║${NC} ${BOLD}Linux-Clipboard 管理工具${NC}                                ${CYAN}║${NC}"
    echo -e "${CYAN}╠════════════════════════════════════════════════════════════╣${NC}"
    echo -e "${CYAN}║${NC} ${GREEN}版本: $(node -p "require('./package.json').version")${NC}                                              ${CYAN}║${NC}"
    echo -e "${CYAN}╚════════════════════════════════════════════════════════════╝${NC}"
    echo ""
    echo -e "${BOLD}${PURPLE}请选择操作:${NC}"
    echo ""
    echo -e "  ${CYAN}[开发开发]${NC}"
    echo -e "    ${GREEN}1.${NC} 开发模式启动 (npm run electron:dev)"
    echo -e "    ${GREEN}2.${NC} 构建应用 (npm run build)"
    echo -e "    ${GREEN}3.${NC} 构建 deb 包 (npm run electron:build:deb)"
    echo ""
    echo -e "  ${CYAN}[版本发布]${NC}"
    echo -e "    ${YELLOW}4.${NC} 🚀 发布新版本 (交互式输入版本号)"
    echo -e "    ${YELLOW}5.${NC} 📦 创建 GitHub Release"
    echo -e "    ${YELLOW}6.${NC} 🏷️  查看当前版本"
    echo ""
    echo -e "  ${CYAN}[配置管理]${NC}"
    echo -e "    ${PURPLE}7.${NC} 🔑 配置 CNB Token"
    echo -e "    ${PURPLE}8.${NC} ⚙️  查看项目状态"
    echo ""
    echo -e "  ${CYAN}[仓库操作]${NC}"
    echo -e "    ${BLUE}9.${NC} 📤 推送到 GitHub"
    echo -e "    ${BLUE}10.${NC} 📤 推送到 CNB"
    echo -e "    ${BLUE}11.${NC} 📤 推送到所有远端"
    echo ""
    echo -e "  ${CYAN}[其他]${NC}"
    echo -e "    ${GRAY}0.${NC} 退出"
    echo ""
    echo -ne "${BOLD}请输入选项 [0-11]: ${NC}"
}

# 执行操作
execute_action() {
    local choice=$1

    case $choice in
        1)
            echo -e "${BLUE}启动开发模式...${NC}"
            npm run electron:dev
            ;;
        2)
            echo -e "${BLUE}构建应用...${NC}"
            npm run build
            echo -e "${GREEN}✓ 构建完成${NC}"
            read -p "按 Enter 键继续..."
            ;;
        3)
            echo -e "${BLUE}构建 deb 包...${NC}"
            npm run electron:build:deb
            echo -e "${GREEN}✓ 构建完成${NC}"
            ls -lh release/*.deb | tail -1
            read -p "按 Enter 键继续..."
            ;;
        4)
            echo -e "${YELLOW}发布新版本...${NC}"
            if [ -f "scripts/release-version.sh" ]; then
                bash scripts/release-version.sh
            else
                echo -e "${RED}✗ 脚本不存在${NC}"
            fi
            read -p "按 Enter 键继续..."
            ;;
        5)
            echo -e "${YELLOW}创建 GitHub Release...${NC}"
            if [ -f "scripts/create-release.sh" ]; then
                bash scripts/create-release.sh
            else
                echo -e "${RED}✗ 脚本不存在${NC}"
            fi
            read -p "按 Enter 键继续..."
            ;;
        6)
            echo -e "${PURPLE}当前版本信息:${NC}"
            echo ""
            echo -e "  ${GREEN}版本号:${NC} $(node -p "require('./package.json').version")"
            echo -e "  ${GREEN}Git 分支:${NC} $(git branch --show-current)"
            echo -e "  ${GREEN}最新提交:${NC} $(git log -1 --format='%h - %s')"
            echo ""
            echo -e "${CYAN}Tags:${NC}"
            git tag --sort=-v:refname | head -5 | sed 's/^/  /'
            read -p "按 Enter 键继续..."
            ;;
        7)
            echo -e "${PURPLE}配置 CNB Token...${NC}"
            if [ -f "scripts/setup-cnb-token.sh" ]; then
                bash scripts/setup-cnb-token.sh
            else
                echo -e "${RED}✗ 脚本不存在${NC}"
            fi
            read -p "按 Enter 键继续..."
            ;;
        8)
            echo -e "${PURPLE}项目状态:${NC}"
            echo ""
            echo -e "${CYAN}Git 状态:${NC}"
            git status --short
            echo ""
            echo -e "${CYAN}远端仓库:${NC}"
            git remote -v
            echo ""
            echo -e "${CYAN}未推送的提交:${NC}"
            git log origin/main..HEAD --oneline 2>/dev/null || echo "  (没有未推送的提交)"
            read -p "按 Enter 键继续..."
            ;;
        9)
            echo -e "${BLUE}推送到 GitHub...${NC}"
            git push origin main
            echo -e "${GREEN}✓ 推送成功${NC}"
            read -p "按 Enter 键继续..."
            ;;
        10)
            echo -e "${BLUE}推送到 CNB...${NC}"
            git push cnb main
            echo -e "${GREEN}✓ 推送成功${NC}"
            read -p "按 Enter 键继续..."
            ;;
        11)
            echo -e "${BLUE}推送到所有远端...${NC}"
            git push origin main
            git push cnb main
            echo -e "${GREEN}✓ 推送成功${NC}"
            read -p "按 Enter 键继续..."
            ;;
        0)
            echo -e "${GREEN}再见！${NC}"
            exit 0
            ;;
        *)
            echo -e "${RED}✗ 无效选项，请重新选择${NC}"
            sleep 2
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

# 运行主程序
main
