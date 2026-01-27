#!/bin/bash

###############################################################################
# Linux-Clipboard 自动化构建脚本
# 功能: 自动构建前端、Electron 主进程和 .deb 安装包
# 用法: ./build.sh [version]
###############################################################################

set -e  # 遇到错误立即退出

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# 日志函数
log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

log_warn() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# 获取当前北京时间
get_beijing_time() {
    date -d '8 hour' "+%Y-%m-%d %H:%M:%S (Beijing Time, UTC+8)"
}

# 检查依赖
check_dependencies() {
    log_info "检查构建依赖..."

    # 检查 Node.js
    if ! command -v node &> /dev/null; then
        log_error "Node.js 未安装"
        exit 1
    fi

    # 检查 npm
    if ! command -v npm &> /dev/null; then
        log_error "npm 未安装"
        exit 1
    fi

    log_success "依赖检查通过 (Node.js $(node -v), npm $(npm -v))"
}

# 清理旧的构建产物
clean_build() {
    log_info "清理旧的构建产物..."

    rm -rf dist/
    rm -rf dist-electron/
    rm -rf release/

    log_success "清理完成"
}

# 更新版本号
update_version() {
    local new_version=$1

    if [ -z "$new_version" ]; then
        log_warn "未提供新版本号，跳过版本更新"
        return
    fi

    log_info "更新版本号: $new_version"

    # 更新 package.json
    if [[ "$OSTYPE" == "darwin"* ]]; then
        # macOS
        sed -i '' "s/\"version\": \".*\"/\"version\": \"$new_version\"/" package.json
    else
        # Linux
        sed -i "s/\"version\": \".*\"/\"version\": \"$new_version\"/" package.json
    fi

    log_success "版本号已更新到 $new_version"
}

# 构建前端和 Electron
build_project() {
    log_info "开始构建项目..."

    # 构建前端
    log_info "构建前端 (Vite)..."
    npm run build

    if [ ! -d "dist" ] || [ ! -d "dist-electron" ]; then
        log_error "构建失败：输出目录不存在"
        exit 1
    fi

    log_success "项目构建完成"
}

# 构建 .deb 包
build_deb() {
    log_info "构建 .deb 安装包..."

    npm run electron:build:deb

    if [ ! -f "release/linux-clipboard_"*"_amd64.deb" ]; then
        log_error ".deb 包构建失败"
        exit 1
    fi

    # 获取构建的包文件名
    DEB_FILE=$(ls -t release/linux-clipboard_*_amd64.deb | head -1)

    log_success ".deb 包构建完成: $DEB_FILE"
}

# 验证构建产物
verify_build() {
    log_info "验证构建产物..."

    # 检查前端文件
    if [ ! -f "dist/index.html" ]; then
        log_error "前端构建文件缺失"
        exit 1
    fi

    # 检查 Electron 文件
    if [ ! -f "dist-electron/main.js" ] || [ ! -f "dist-electron/preload.js" ]; then
        log_error "Electron 构建文件缺失"
        exit 1
    fi

    # 检查 .deb 包
    if ! ls release/linux-clipboard_*_amd64.deb 1> /dev/null 2>&1; then
        log_error ".deb 包缺失"
        exit 1
    fi

    # 检查图标文件
    if ! find release/linux-unpacked/resources -name "icon.png" | grep -q .; then
        log_error "图标文件未包含在安装包中"
        exit 1
    fi

    log_success "构建产物验证通过"
}

# 显示构建结果
show_results() {
    echo ""
    log_success "========================================"
    log_success "构建完成！"
    log_success "========================================"
    echo ""

    # 显示构建信息
    echo -e "${BLUE}构建时间:${NC} $(get_beijing_time)"
    echo -e "${BLUE}当前版本:${NC} $(grep '"version"' package.json | head -1 | cut -d'"' -f4)"
    echo ""

    # 显示构建产物
    echo -e "${BLUE}构建产物:${NC}"
    echo "  📄 前端: dist/"
    echo "  ⚡ Electron: dist-electron/"
    echo "  📦 安装包: $(ls -t release/linux-clipboard_*_amd64.deb | head -1)"
    echo ""

    # 显示文件大小
    echo -e "${BLUE}文件大小:${NC}"
    du -sh dist/ dist-electron/ release/*.deb 2>/dev/null | sed 's/^/  /'
    echo ""

    # 显示下一步操作
    echo -e "${BLUE}下一步操作:${NC}"
    echo "  1. 测试安装: sudo dpkg -i $(ls -t release/linux-clipboard_*_amd64.deb | head -1)"
    echo "  2. 运行应用: /opt/Linux-Clipboard/linux-clipboard"
    echo "  3. 创建 Git 提交: ./release.sh"
    echo ""
}

###############################################################################
# 主流程
###############################################################################

main() {
    echo ""
    log_success "========================================"
    log_success "Linux-Clipboard 自动构建脚本"
    log_success "========================================"
    echo ""
    log_info "开始时间: $(get_beijing_time)"
    echo ""

    # 检查依赖
    check_dependencies
    echo ""

    # 如果提供了版本号，更新版本
    if [ ! -z "$1" ]; then
        update_version "$1"
        echo ""
    fi

    # 清理旧构建
    clean_build
    echo ""

    # 构建项目
    build_project
    echo ""

    # 构建 .deb 包
    build_deb
    echo ""

    # 验证构建
    verify_build
    echo ""

    # 显示结果
    show_results
}

# 执行主流程
main "$@"
