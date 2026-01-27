#!/bin/bash

###############################################################################
# Linux-Clipboard 自动化安装脚本
# 功能: 备份旧版本、安装新版本、迁移配置
# 用法: sudo ./install.sh [deb文件路径]
###############################################################################

set -e  # 遇到错误立即退出

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

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

# 检查是否以 root 权限运行
check_root() {
    if [ "$EUID" -ne 0 ]; then
        log_error "此脚本需要 root 权限，请使用 sudo 运行"
        log_info "命令: sudo $0 $@"
        exit 1
    fi
}

# 备份当前配置
backup_config() {
    log_info "备份当前配置..."

    local config_dir="$HOME/.config/linux-clipboard"
    local backup_dir="$HOME/linux-clipboard-backup-$(date +%Y%m%d-%H%M%S)"

    if [ -d "$config_dir" ]; then
        cp -r "$config_dir" "$backup_dir"
        log_success "配置已备份到: $backup_dir"
    else
        log_info "未找到现有配置，跳过备份"
    fi
}

# 查找最新的 .deb 包
find_deb_package() {
    local deb_path="$1"

    if [ -z "$deb_path" ]; then
        # 自动查找最新的 .deb 包
        if [ -d "release" ]; then
            deb_path=$(ls -t release/linux-clipboard_*_amd64.deb 2>/dev/null | head -1)
        fi
    fi

    if [ -z "$deb_path" ] || [ ! -f "$deb_path" ]; then
        log_error "未找到 .deb 安装包"
        log_info "请指定 .deb 文件路径: sudo $0 <path-to-deb>"
        exit 1
    fi

    echo "$deb_path"
}

# 显示包信息
show_package_info() {
    local deb_path="$1"

    log_info "安装包信息:"
    echo "  文件: $deb_path"
    echo "  版本: $(dpkg -I "$deb_path" | grep 'Version:' | awk '{print $2}')"
    echo "  大小: $(du -h "$deb_path" | cut -f1)"
    echo ""
}

# 安装 .deb 包
install_package() {
    local deb_path="$1"

    log_info "开始安装 $deb_path ..."

    dpkg -i "$deb_path" || {
        log_warn "dpkg 安装出现依赖问题，尝试自动修复..."
        apt-get install -f -y
    }

    log_success "安装完成！"
}

# 验证安装
verify_installation() {
    log_info "验证安装..."

    # 检查可执行文件
    if [ ! -f "/opt/Linux-Clipboard/linux-clipboard" ]; then
        log_error "可执行文件未找到"
        exit 1
    fi

    # 检查图标文件
    if [ ! -f "/opt/Linux-Clipboard/resources/icons/icon.png" ]; then
        log_warn "图标文件未找到，可能导致托盘图标不显示"
    else
        log_success "图标文件已正确安装"
    fi

    log_success "安装验证通过"
}

# 检查配置文件权限
check_config_permissions() {
    log_info "检查配置文件权限..."

    local secure_config="$HOME/.config/linux-clipboard/linux-clipboard-secure.json"

    if [ -f "$secure_config" ]; then
        local perms=$(stat -c %a "$secure_config" 2>/dev/null || stat -f %A "$secure_config" 2>/dev/null)
        if [ "$perms" != "600" ]; then
            log_warn "安全配置文件权限不正确 (当前: $perms, 期望: 600)"
            log_info "修复权限: chmod 600 $secure_config"
            chmod 600 "$secure_config"
        else
            log_success "配置文件权限正确 (600)"
        fi
    fi
}

# 显示安装后信息
show_post_install_info() {
    echo ""
    log_success "========================================"
    log_success "安装完成！"
    log_success "========================================"
    echo ""

    echo -e "${BLUE}安装位置:${NC} /opt/Linux-Clipboard/"
    echo -e "${BLUE}可执行文件:${NC} /opt/Linux-Clipboard/linux-clipboard"
    echo -e "${BLUE}配置目录:${NC} ~/.config/linux-clipboard/"
    echo ""

    echo -e "${BLUE}启动应用:${NC}"
    echo "  方法1 (直接运行): /opt/Linux-Clipboard/linux-clipboard"
    echo "  方法2 (后台运行): nohup /opt/Linux-Clipboard/linux-clipboard > /dev/null 2>&1 &"
    echo "  方法3 (桌面环境): 从应用菜单启动"
    echo ""

    echo -e "${BLUE}卸载应用:${NC}"
    echo "  sudo dpkg -r linux-clipboard"
    echo "  sudo dpkg -P linux-clipboard  # 完全删除（包括配置）"
    echo ""

    echo -e "${BLUE}配置文件说明:${NC}"
    echo "  ~/.config/linux-clipboard/linux-clipboard-config.json   - 常规配置"
    echo "  ~/.config/linux-clipboard/linux-clipboard-secure.json   - 加密的 API Key"
    echo ""
}

###############################################################################
# 主流程
###############################################################################

main() {
    echo ""
    log_success "========================================"
    log_success "Linux-Clipboard 安装脚本"
    log_success "========================================"
    echo ""

    # 检查 root 权限
    check_root "$@"

    # 查找 .deb 包
    deb_path=$(find_deb_package "$1")
    echo ""

    # 显示包信息
    show_package_info "$deb_path"

    # 备份配置
    backup_config
    echo ""

    # 安装包
    install_package "$deb_path"
    echo ""

    # 验证安装
    verify_installation
    echo ""

    # 检查配置权限
    check_config_permissions
    echo ""

    # 显示安装后信息
    show_post_install_info
}

# 执行主流程
main "$@"
