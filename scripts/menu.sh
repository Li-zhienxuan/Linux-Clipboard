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
GRAY='\033[0;37m'
BOLD='\033[1m'
NC='\033[0m'

# 获取脚本目录
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
cd "$PROJECT_ROOT"

# 获取当前版本
CURRENT_VERSION=$(node -p "require('./package.json').version" 2>/dev/null || echo "unknown")

# 显示主菜单
show_menu() {
    clear
    echo -e "${CYAN}╔════════════════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${CYAN}║${NC} ${BOLD}               Linux-Clipboard 管理工具 v2.0                   ${NC}        ${CYAN}║${NC}"
    echo -e "${CYAN}╠════════════════════════════════════════════════════════════════════════╣${NC}"
    echo -e "${CYAN}║${NC}  ${GREEN}当前版本:${NC} ${BOLD}${CURRENT_VERSION}${NC}                                              ${CYAN}║${NC}"
    echo -e "${CYAN}╚════════════════════════════════════════════════════════════════════════╝${NC}"
    echo ""
    echo -e "${BOLD}${PURPLE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${BOLD}${PURPLE}  开发工具 (Development)                                         ${NC}"
    echo -e "${BOLD}${PURPLE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo ""
    echo -e "  ${GREEN}1.${NC} ${BOLD}开发模式${NC}                                              "
    echo -e "     启动 Electron + Vite 开发服务器，支持热重载"
    echo -e "     命令: npm run electron:dev"
    echo ""
    echo -e "  ${GREEN}2.${NC} ${BOLD}构建应用${NC}                                              "
    echo -e "     编译 React 和 Electron 代码到 dist/"
    echo -e "     命令: npm run build"
    echo ""
    echo -e "  ${GREEN}3.${NC} ${BOLD}构建安装包${NC}                                            "
    echo -e "     生成 .deb 安装包 (75M，约1分钟)"
    echo -e "     命令: npm run electron:build:deb"
    echo ""
    echo -e "${BOLD}${YELLOW}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${BOLD}${YELLOW}  版本发布 (Release)                                             ${NC}"
    echo -e "${BOLD}${YELLOW}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo ""
    echo -e "  ${YELLOW}4.${NC} ${BOLD}🚀 发布新版本${NC}                                          "
    echo -e "     完整的发布流程：更新版本→构建→提交→推送→创建 Release"
    echo -e "     交互式输入版本号 (如: 0.3.5, v0.3.5)"
    echo ""
    echo -e "  ${YELLOW}5.${NC} ${BOLD}📦 创建 GitHub Release${NC}                                "
    echo -e "     上传 deb 包到 GitHub Releases，自动生成 Release Notes"
    echo -e "     Token 保存在项目本地，不推送"
    echo ""
    echo -e "  ${YELLOW}6.${NC} ${BOLD}🏷️  查看版本信息${NC}                                        "
    echo -e "     显示当前版本、Git 状态、Tags、最新提交"
    echo ""
    echo -e "${BOLD}${PURPLE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${BOLD}${PURPLE}  配置管理 (Configuration)                                       ${NC}"
    echo -e "${BOLD}${PURPLE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo ""
    echo -e "  ${PURPLE}7.${NC} ${BOLD}🔑 配置 CNB Token${NC}                                      "
    echo -e "     设置 CNB 推送凭据，保存在项目本地，不推送"
    echo ""
    echo -e "  ${PURPLE}8.${NC} ${BOLD}⚙️  查看项目状态${NC}                                        "
    echo -e "     显示 Git 状态、远端仓库、未推送的提交"
    echo ""
    echo -e "${BOLD}${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${BOLD}${BLUE}  仓库操作 (Git Operations)                                       ${NC}"
    echo -e "${BOLD}${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo ""
    echo -e "  ${BLUE}9.${NC}  ${BOLD}推送到 GitHub${NC}                                          "
    echo -e "     git push origin main"
    echo ""
    echo -e "  ${BLUE}10.${NC} ${BOLD}推送到 CNB${NC}                                             "
    echo -e "     git push cnb main"
    echo ""
    echo -e "  ${BLUE}11.${NC} ${BOLD}推送到所有远端${NC}                                          "
    echo -e "     同时推送到 GitHub 和 CNB"
    echo ""
    echo -e "${BOLD}${GRAY}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${BOLD}${GRAY}  其他 (Others)                                                    ${NC}"
    echo -e "${BOLD}${GRAY}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo ""
    echo -e "  ${GRAY}0.${NC}  ${BOLD}退出${NC}                                                  "
    echo ""
    echo -ne "${BOLD}${CYAN}请输入选项 [0-11]: ${NC}"
}

# 执行操作
execute_action() {
    local choice=$1

    case $choice in
        1)
            echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
            echo -e "${BLUE}启动开发模式${NC}"
            echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
            echo ""
            echo -e "${CYAN}命令: npm run electron:dev${NC}"
            echo -e "${YELLOW}提示: 按 Ctrl+C 停止开发服务器${NC}"
            echo ""
            read -p "按 Enter 键开始..."
            npm run electron:dev
            ;;
        2)
            echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
            echo -e "${BLUE}构建应用${NC}"
            echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
            echo ""
            npm run build
            echo ""
            echo -e "${GREEN}✓ 构建完成${NC}"
            echo -e "${CYAN}输出文件:${NC}"
            ls -lh dist/ dist-electron/ 2>/dev/null | tail -5
            read -p "按 Enter 键继续..."
            ;;
        3)
            echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
            echo -e "${BLUE}构建 deb 安装包${NC}"
            echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
            echo ""
            echo -e "${CYAN}命令: npm run electron:build:deb${NC}"
            echo -e "${YELLOW}预计耗时: ~1分钟，生成文件大小: ~75M${NC}"
            echo ""
            read -p "按 Enter 键开始构建..."
            npm run electron:build:deb
            echo ""
            echo -e "${GREEN}✓ 构建完成${NC}"
            echo -e "${CYAN}生成的文件:${NC}"
            ls -lh release/*.deb 2>/dev/null | tail -1
            read -p "按 Enter 键继续..."
            ;;
        4)
            echo -e "${YELLOW}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
            echo -e "${YELLOW}🚀 发布新版本${NC}"
            echo -e "${YELLOW}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
            echo ""
            echo -e "${CYAN}发布流程:${NC}"
            echo -e "  1. 输入新版本号 (如: 0.3.5)"
            echo -e "  2. 自动更新 package.json"
            echo -e "  3. 构建应用和 deb 包"
            echo -e "  4. 生成 Release Notes"
            echo -e "  5. Git 提交和打标签"
            echo -e "  6. 推送到 GitHub 和 CNB"
            echo -e "  7. 创建 GitHub Release"
            echo ""
            read -p "按 Enter 键继续..."
            if [ -f "scripts/release-version.sh" ]; then
                bash scripts/release-version.sh
            else
                echo -e "${RED}✗ 脚本不存在: scripts/release-version.sh${NC}"
            fi
            read -p "按 Enter 键继续..."
            ;;
        5)
            echo -e "${YELLOW}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
            echo -e "${YELLOW}📦 创建 GitHub Release${NC}"
            echo -e "${YELLOW}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
            echo ""
            echo -e "${CYAN}功能:${NC}"
            echo -e "  • 上传 deb 包到 GitHub Releases"
            echo -e "  • 自动生成或使用已有 Release Notes"
            echo -e "  • Token 保存在 .github-token-local (不推送)"
            echo ""
            read -p "按 Enter 键继续..."
            if [ -f "scripts/create-release.sh" ]; then
                bash scripts/create-release.sh
            else
                echo -e "${RED}✗ 脚本不存在: scripts/create-release.sh${NC}"
            fi
            read -p "按 Enter 键继续..."
            ;;
        6)
            echo -e "${YELLOW}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
            echo -e "${YELLOW}🏷️  版本信息${NC}"
            echo -e "${YELLOW}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
            echo ""
            echo -e "${GREEN}当前版本:${NC} ${BOLD}${CURRENT_VERSION}${NC}"
            echo ""
            echo -e "${CYAN}Git 信息:${NC}"
            echo -e "  分支: $(git branch --show-current)"
            echo -e "  提交: $(git log -1 --format='%h - %s')"
            echo ""
            echo -e "${CYAN}最近的 Tags:${NC}"
            git tag --sort=-v:refname | head -5 | sed 's/^/  /'
            echo ""
            echo -e "${CYAN}远端仓库:${NC}"
            git remote -v | sed 's/^/  /'
            read -p "按 Enter 键继续..."
            ;;
        7)
            echo -e "${PURPLE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
            echo -e "${PURPLE}🔑 配置 CNB Token${NC}"
            echo -e "${PURPLE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
            echo ""
            echo -e "${CYAN}说明:${NC}"
            echo -e "  • Token 保存在项目本地 (.git/credentials.local)"
            echo -e "  • 不推送到远端，安全可靠"
            echo -e "  • 后续推送自动使用已保存的 Token"
            echo ""
            read -p "按 Enter 键继续..."
            if [ -f "scripts/setup-cnb-token.sh" ]; then
                bash scripts/setup-cnb-token.sh
            else
                echo -e "${RED}✗ 脚本不存在: scripts/setup-cnb-token.sh${NC}"
            fi
            read -p "按 Enter 键继续..."
            ;;
        8)
            echo -e "${PURPLE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
            echo -e "${PURPLE}⚙️  项目状态${NC}"
            echo -e "${PURPLE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
            echo ""
            echo -e "${CYAN}Git 状态:${NC}"
            if [ -n "$(git status --porcelain)" ]; then
                git status --short | sed 's/^/  /'
            else
                echo -e "  ${GREEN}✓ 工作区干净${NC}"
            fi
            echo ""
            echo -e "${CYAN}远端仓库:${NC}"
            git remote -v | sed 's/^/  /'
            echo ""
            echo -e "${CYAN}未推送的提交:${NC}"
            UNPUSHED=$(git log origin/main..HEAD --oneline 2>/dev/null | wc -l)
            if [ "$UNPUSHED" -gt 0 ]; then
                git log origin/main..HEAD --oneline | sed 's/^/  /'
            else
                echo -e "  ${GREEN}✓ 所有提交已推送${NC}"
            fi
            echo ""
            echo -e "${CYAN}最新构建:${NC}"
            if [ -d "release" ]; then
                ls -lt release/*.deb 2>/dev/null | head -1 | awk '{print "  " $9 " (" $5 ")"}'
            else
                echo -e "  ${YELLOW}⚠ 未找到构建文件${NC}"
            fi
            read -p "按 Enter 键继续..."
            ;;
        9)
            echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
            echo -e "${BLUE}推送到 GitHub${NC}"
            echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
            echo ""
            git push origin main
            echo ""
            echo -e "${GREEN}✓ 推送成功${NC}"
            read -p "按 Enter 键继续..."
            ;;
        10)
            echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
            echo -e "${BLUE}推送到 CNB${NC}"
            echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
            echo ""
            git push cnb main
            echo ""
            echo -e "${GREEN}✓ 推送成功${NC}"
            read -p "按 Enter 键继续..."
            ;;
        11)
            echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
            echo -e "${BLUE}推送到所有远端${NC}"
            echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
            echo ""
            echo -e "${CYAN}推送 to GitHub...${NC}"
            git push origin main
            echo ""
            echo -e "${CYAN}推送 to CNB...${NC}"
            git push cnb main
            echo ""
            echo -e "${GREEN}✓ 推送成功${NC}"
            read -p "按 Enter 键继续..."
            ;;
        0)
            echo ""
            echo -e "${GREEN}再见！${NC}"
            echo ""
            exit 0
            ;;
        *)
            echo -e "${RED}✗ 无效选项: $choice${NC}"
            echo -e "${YELLOW}请输入 0-11 之间的数字${NC}"
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
