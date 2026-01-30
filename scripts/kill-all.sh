#!/bin/bash
# Linux-Clipboard 进程清理脚本
# 快速终止所有相关的开发服务器和构建进程

set -e

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
BOLD='\033[1m'
NC='\033[0m'

echo -e "${CYAN}╔════════════════════════════════════════════════════════════╗${NC}"
echo -e "${CYAN}║${NC} ${BOLD}           Linux-Clipboard 进程清理工具                  ${NC}        ${CYAN}║${NC}"
echo -e "${CYAN}╚════════════════════════════════════════════════════════════╝${NC}"
echo ""

# 统计函数
count_processes() {
    echo -e "${CYAN}正在扫描相关进程...${NC}"
    echo ""

    # 查找 Electron 相关进程
    ELECTRON_COUNT=$(pgrep -f "electron.*Linux-Clipboard" | wc -l)
    VITE_COUNT=$(pgrep -f "vite.*linux-clipboard" | wc -l)
    NODE_COUNT=$(pgrep -f "node.*linux-clipboard" | wc -l)
    TOTAL_COUNT=$((ELECTRON_COUNT + VITE_COUNT + NODE_COUNT))

    echo -e "${BLUE}发现以下进程:${NC}"
    echo -e "  • Electron 进程: ${BOLD}${ELECTRON_COUNT}${NC}"
    echo -e "  • Vite 进程:     ${BOLD}${VITE_COUNT}${NC}"
    echo -e "  • Node 进程:     ${BOLD}${NODE_COUNT}${NC}"
    echo -e "  ${BOLD}总计: ${TOTAL_COUNT}${NC}"
    echo ""
}

# 显示当前进程详情
show_processes() {
    echo -e "${YELLOW}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${YELLOW}当前进程详情${NC}"
    echo -e "${YELLOW}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo ""

    local found=false

    # 查找并显示所有相关进程
    if pgrep -f "electron.*Linux-Clipboard" > /dev/null; then
        echo -e "${RED}Electron 进程:${NC}"
        pgrep -f "electron.*Linux-Clipboard" | while read pid; do
            echo -e "  ${YELLOW}PID $pid${NC} $(ps -p $pid -o comm=) - $(ps -p $pid -o args= | cut -c1-60)"
        done
        found=true
    fi

    if pgrep -f "vite" > /dev/null && pgrep -f "linux-clipboard" > /dev/null; then
        echo -e "${RED}Vite 进程:${NC}"
        pgrep -f "vite" | while read pid; do
            if ps -p $pid -o args= | grep -q "linux-clipboard"; then
                echo -e "  ${YELLOW}PID $pid${NC} $(ps -p $pid -o comm=) - $(ps -p $pid -o args= | cut -c1-60)"
            fi
        done
        found=true
    fi

    if ! $found; then
        echo -e "${GREEN}✓ 未发现相关进程${NC}"
    fi

    echo ""
}

# 终止进程
kill_processes() {
    echo -e "${YELLOW}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${YELLOW}开始终止进程${NC}"
    echo -e "${YELLOW}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo ""

    local killed_count=0

    # 终止 Electron 进程
    if pgrep -f "electron.*Linux-Clipboard" > /dev/null; then
        echo -e "${BLUE}终止 Electron 进程...${NC}"
        pkill -f "electron.*Linux-Clipboard" 2>/dev/null && {
            echo -e "${GREEN}✓ Electron 进程已终止${NC}"
            ((killed_count++))
        }
    fi

    # 终止 Vite 开发服务器
    if pgrep -f "vite" > /dev/null; then
        echo -e "${BLUE}终止 Vite 服务器...${NC}"
        pkill -f "vite" 2>/dev/null && {
            echo -e "${GREEN}✓ Vite 服务器已终止${NC}"
            ((killed_count++))
        }
    fi

    # 终止可能残留的 Node 进程
    if pgrep -f "node.*linux-clipboard" > /dev/null; then
        echo -e "${BLUE}终止 Node 进程...${NC}"
        pkill -f "node.*linux-clipboard" 2>/dev/null && {
            echo -e "${GREEN}✓ Node 进程已终止${NC}"
            ((killed_count++))
        }
    fi

    # 等待进程完全退出
    if [ $killed_count -gt 0 ]; then
        echo ""
        echo -e "${CYAN}等待进程退出...${NC}"
        sleep 1
    fi

    echo ""
    echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    if [ $killed_count -gt 0 ]; then
        echo -e "${GREEN}✓ 清理完成！已终止 ${killed_count} 组进程${NC}"
    else
        echo -e "${GREEN}✓ 没有需要清理的进程${NC}"
    fi
    echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
}

# 主函数
main() {
    # 显示当前统计
    count_processes

    # 显示进程详情
    show_processes

    # 询问是否继续
    echo -ne "${YELLOW}确定要终止这些进程吗? [y/N]: ${NC}"
    read -r confirm

    if [[ $confirm =~ ^[Yy]$ ]]; then
        echo ""
        kill_processes

        # 再次确认
        echo ""
        sleep 1
        echo -e "${CYAN}最终状态检查:${NC}"
        count_processes
    else
        echo -e "${YELLOW}✗ 操作已取消${NC}"
    fi
}

# 运行主程序
main
