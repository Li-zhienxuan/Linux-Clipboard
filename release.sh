#!/bin/bash

###############################################################################
# Linux-Clipboard 自动化发布脚本
# 功能: Git 提交、创建标签、生成发布说明
# 用法: ./release.sh [version]
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

# 获取当前版本
get_current_version() {
    grep '"version"' package.json | head -1 | cut -d'"' -f4
}

# 获取北京时间
get_beijing_time() {
    date -d '8 hour' "+%Y-%m-%d %H:%M:%S (Beijing Time, UTC+8)"
}

# 检查 Git 状态
check_git_status() {
    log_info "检查 Git 状态..."

    # 检查是否有未提交的更改
    if [ -n "$(git status --porcelain)" ]; then
        log_warn "存在未提交的更改:"
        git status --short
        echo ""

        read -p "是否继续发布？(y/N) " -n 1 -r
        echo
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            log_info "发布已取消"
            exit 0
        fi
    fi

    log_success "Git 状态检查完成"
}

# 添加所有更改
add_changes() {
    log_info "添加所有更改到 Git..."

    git add -A

    log_success "文件已添加到暂存区"
}

# 创建提交
create_commit() {
    local version=$1
    local commit_message="Release v${version} - $(get_beijing_time)"

    log_info "创建 Git 提交..."
    log_info "提交信息: $commit_message"

    git commit -m "$commit_message" -m "主要更新:
- 实现了 API Key 的安全存储（AES-256-GCM 加密）
- 添加了从 v0.2.0 明文配置自动迁移到加密存储的功能
- 修复了系统托盘图标未被打包的问题
- 配置 extraResources 确保图标文件包含在安装包中

详细记录请查看:
- Build.md: 构建记录
- Repair.md: 问题排查与修复记录"

    log_success "Git 提交创建成功"
}

# 创建标签
create_tag() {
    local version=$1

    log_info "创建 Git 标签: v$version"

    # 检查标签是否已存在
    if git rev-parse "v$version" >/dev/null 2>&1; then
        log_warn "标签 v$version 已存在，删除旧标签..."
        git tag -d "v$version"
        log_warn "如需删除远程标签，请执行: git push origin :refs/tags/v$version"
    fi

    # 创建带注释的标签
    git tag -a "v$version" -m "Release v$version

构建时间: $(get_beijing_time)
版本内容:
- API Key 安全存储（AES-256-GCM 加密）
- 自动迁移旧配置
- 系统托盘图标修复

详细记录: Build.md, Repair.md"

    log_success "标签 v$version 创建成功"
}

# 显示发布信息
show_release_info() {
    local version=$1

    echo ""
    log_success "========================================"
    log_success "发布准备完成！"
    log_success "========================================"
    echo ""

    echo -e "${BLUE}版本:${NC} v$version"
    echo -e "${BLUE}发布时间:${NC} $(get_beijing_time)"
    echo ""

    echo -e "${BLUE}已完成的操作:${NC}"
    echo "  ✓ Git 提交已创建"
    echo "  ✓ Git 标签 v$version 已创建"
    echo ""

    echo -e "${BLUE}下一步操作:${NC}"
    echo ""
    echo "1. 推送到远程仓库:"
    echo "   git push origin main"
    echo "   git push origin v$version"
    echo ""

    echo "2. 在 GitHub 上创建 Release:"
    echo "   - 访问: https://github.com/你的用户名/Linux-Clipboard/releases"
    echo "   - 点击 'Draft a new release'"
    echo "   - 选择标签: v$version"
    echo "   - 上传 .deb 文件: release/linux-clipboard_${version}_amd64.deb"
    echo ""

    echo "3. 测试安装:"
    echo "   sudo ./install.sh release/linux-clipboard_${version}_amd64.deb"
    echo ""

    echo "4. 查看提交历史:"
    echo "   git log --oneline -5"
    echo ""

    echo "5. 查看标签:"
    echo "   git tag -l"
    echo ""
}

# 生成发布说明模板
generate_release_notes() {
    local version=$1
    local notes_file="RELEASE_NOTES_v${version}.md"

    log_info "生成发布说明: $notes_file"

    cat > "$notes_file" << EOF
# Linux-Clipboard v${version} 发布说明

**发布时间**: $(get_beijing_time)

## 📦 下载

- **Linux .deb**: \`linux-clipboard_${version}_amd64.deb\`

## ✨ 新功能

### API Key 安全存储
- 使用 AES-256-GCM 加密算法
- 基于机器 ID 的密钥派生（scrypt）
- 配置文件权限设置为 600
- 防止 API Key 泄露

### 自动迁移
- 从 v0.2.0 明文配置自动迁移到加密存储
- 无需用户手动操作
- 迁移后自动删除明文密钥

### 系统托盘修复
- 修复图标未包含在安装包的问题
- 配置 \`extraResources\` 确保资源文件正确打包

## 🔧 技术改进

- 环境检测: 使用 \`app.isPackaged\` 替代 \`NODE_ENV\`
- 资源路径: 正确处理生产环境的资源文件路径
- 安全加固: 敏感数据加密存储

## 📝 安装

\`\`\`bash
# 下载 .deb 包
wget https://github.com/你的用户名/Linux-Clipboard/releases/download/v${version}/linux-clipboard_${version}_amd64.deb

# 安装
sudo dpkg -i linux-clipboard_${version}_amd64.deb

# 如果有依赖问题，运行:
sudo apt-get install -f -y
\`\`\`

## 🚀 使用

\`\`\`bash
# 启动应用
/opt/Linux-Clipboard/linux-clipboard

# 或在应用菜单中搜索 "Linux-Clipboard"
\`\`\`

## ⚠️ 升级说明

从 v0.2.0 升级时，API Key 会自动迁移到加密存储。迁移过程：
1. 读取旧的明文配置
2. 加密 API Key 并存储到新位置
3. 从旧配置中删除明文密钥
4. 设置新配置文件权限为 600

## 🐛 已知问题

无

## 📚 文档

- \`Build.md\` - 构建记录
- \`Repair.md\` - 问题排查与修复记录
- \`CODEBUDDY.md\` - 项目架构文档

## 🔗 相关链接

- GitHub: https://github.com/你的用户名/Linux-Clipboard
- 问题反馈: https://github.com/你的用户名/Linux-Clipboard/issues

---

**完整变更日志**: [v$(echo $version | awk -F. '{print $1"."$2"."($3-1)}"...v${version}](https://github.com/你的用户名/Linux-Clipboard/compare/v$(echo $version | awk -F. '{print $1"."$2"."($3-1)}')...v${version})
EOF

    log_success "发布说明已生成: $notes_file"
}

###############################################################################
# 主流程
###############################################################################

main() {
    local version=$1

    echo ""
    log_success "========================================"
    log_success "Linux-Clipboard 发布脚本"
    log_success "========================================"
    echo ""

    # 获取当前版本
    if [ -z "$version" ]; then
        version=$(get_current_version)
        log_info "使用当前版本: $version"
    else
        log_info "使用指定版本: $version"
    fi
    echo ""

    # 检查 Git 状态
    check_git_status
    echo ""

    # 添加所有更改
    add_changes
    echo ""

    # 创建提交
    create_commit "$version"
    echo ""

    # 创建标签
    create_tag "$version"
    echo ""

    # 生成发布说明
    generate_release_notes "$version"
    echo ""

    # 显示发布信息
    show_release_info "$version"
}

# 执行主流程
main "$@"
