#!/bin/bash

###############################################################################
# CNB 快速配置脚本
# 功能: 自动配置 CNB 的 Git 访问权限
# 用法: ./setup-cnb.sh
###############################################################################

set -e

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
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

echo ""
log_success "========================================"
log_success "CNB (腾讯云) 快速配置向导"
log_success "========================================"
echo ""

# 检查是否已有 SSH 密钥
log_info "检查 SSH 密钥..."
if [ -f "$HOME/.ssh/id_ed25519" ] || [ -f "$HOME/.ssh/id_rsa" ]; then
    log_success "找到现有 SSH 密钥"
    echo ""
    echo "你的 SSH 密钥:"
    if [ -f "$HOME/.ssh/id_ed25519.pub" ]; then
        cat "$HOME/.ssh/id_ed25519.pub"
    else
        cat "$HOME/.ssh/id_rsa.pub"
    fi
    echo ""
    log_info "请将上面的公钥添加到 CNB:"
    echo "  1. 访问: https://cnb.cool/-/profile/keys"
    echo "  2. 点击 '添加 SSH 密钥' 或 'Add SSH Key'"
    echo "  3. 粘贴上面的公钥内容"
    echo "  4. 点击 '添加密钥' 或 'Add Key'"
    echo ""
else
    log_warn "未找到 SSH 密钥，正在生成..."
    echo ""
    read -p "输入你的邮箱 (用于密钥注释): " email

    if [ -z "$email" ]; then
        email="user@example.com"
    fi

    log_info "生成 SSH 密钥 (ed25519)..."
    ssh-keygen -t ed25519 -C "$email" -f "$HOME/.ssh/id_ed25519" -N ""

    log_success "SSH 密钥生成成功！"
    echo ""
    echo "你的 SSH 公钥:"
    cat "$HOME/.ssh/id_ed25519.pub"
    echo ""
    log_warn "请将上面的公钥添加到 CNB:"
    echo "  1. 访问: https://cnb.cool/-/profile/keys"
    echo "  2. 点击 '添加 SSH 密钥' 或 'Add SSH Key'"
    echo "  3. 粘贴上面的公钥内容"
    echo "  4. 点击 '添加密钥' 或 'Add Key'"
    echo ""
    read -p "按 Enter 继续..."
fi

# 启动 SSH agent 并添加密钥
log_info "启动 SSH agent..."
eval "$(ssh-agent -s)"

log_info "添加 SSH 密钥到 agent..."
if [ -f "$HOME/.ssh/id_ed25519" ]; then
    ssh-add "$HOME/.ssh/id_ed25519" 2>/dev/null || true
elif [ -f "$HOME/.ssh/id_rsa" ]; then
    ssh-add "$HOME/.ssh/id_rsa" 2>/dev/null || true
fi

log_success "SSH agent 已配置"
echo ""

# 测试 SSH 连接
log_info "测试 SSH 连接到 CNB..."
if ssh -o StrictHostKeyChecking=no -o ConnectTimeout=5 git@cnb.cool 2>&1 | grep -q "Welcome\|successfully\|authenticated"; then
    log_success "SSH 连接成功！"
else
    log_warn "SSH 连接失败或需要配置"
    echo ""
    log_info "请手动测试:"
    echo "  ssh -T git@cnb.cool"
    echo ""
fi
echo ""

# 配置 Git 远程仓库
log_info "配置 Git 远程仓库..."
if git remote | grep -q "cnb"; then
    log_info "CNB 远程仓库已存在"
    git remote -v | grep cnb
    echo ""

    read -p "是否要修改为 SSH 地址？(y/N) " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        git remote set-url cnb git@cnb.cool:ZhienXuan/Linux-Clipboard.git
        log_success "CNB 远程地址已更新为 SSH"
        echo ""
    fi
else
    log_info "添加 CNB 远程仓库..."
    git remote add cnb git@cnb.cool:ZhienXuan/Linux-Clipboard.git
    log_success "CNB 远程仓库已添加"
    echo ""
fi

# 显示当前配置
log_info "当前 Git 远程仓库配置:"
git remote -v
echo ""

# 配置 Git 凭据助手（可选）
log_info "配置 Git 凭据缓存..."
read -p "是否要配置 Git 凭据缓存？(y/N) " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    git config --global credential.helper 'cache --timeout=3600'
    log_success "Git 凭据缓存已配置 (1小时)"
    echo ""
fi

# 完成
log_success "========================================"
log_success "配置完成！"
log_success "========================================"
echo ""

echo -e "${CYAN}下一步操作:${NC}"
echo ""
echo "1. 测试推送到 CNB:"
echo "   git push cnb main"
echo ""
echo "2. 或使用自动发布脚本:"
echo "   ./auto-release.sh 0.4.0"
echo ""
echo "3. 查看详细配置指南:"
echo "   cat cnb-setup-guide.md"
echo ""
