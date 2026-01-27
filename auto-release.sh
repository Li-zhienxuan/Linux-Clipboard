#!/bin/bash

###############################################################################
# Linux-Clipboard 自动化发布脚本
# 功能: 自动构建、推送到 GitHub/CNB、创建 Release
# 用法: ./auto-release.sh [version] [github_token]
###############################################################################

set -e  # 遇到错误立即退出

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
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

log_step() {
    echo -e "${PURPLE}[STEP]${NC} $1"
}

# 获取北京时间
get_beijing_time() {
    date "+%Y-%m-%d %H:%M:%S (CST, UTC+8)"
}

# 获取当前版本
get_current_version() {
    grep '"version"' package.json | head -1 | cut -d'"' -f4
}

###############################################################################
# 主流程
###############################################################################

main() {
    local version=$1
    local github_token=$2

    echo ""
    log_success "========================================"
    log_success "Linux-Clipboard 自动化发布"
    log_success "========================================"
    echo ""
    log_info "开始时间: $(get_beijing_time)"
    echo ""

    # 如果没有提供版本号，使用当前版本
    if [ -z "$version" ]; then
        version=$(get_current_version)
        log_info "使用当前版本: $version"
    else
        log_info "使用指定版本: $version"
    fi
    echo ""

    # Step 1: 检查工作区状态
    log_step "1/8 检查工作区状态..."
    if [ -n "$(git status --porcelain)" ]; then
        log_error "工作区有未提交的更改，请先提交或暂存"
        git status --short
        exit 1
    fi
    log_success "工作区干净"
    echo ""

    # Step 2: 构建 .deb 包
    log_step "2/8 构建 .deb 安装包..."
    if [ ! -f "release/linux-clipboard_${version}_amd64.deb" ]; then
        log_info "开始构建..."
        npm run electron:build:deb

        if [ ! -f "release/linux-clipboard_${version}_amd64.deb" ]; then
            log_error "构建失败：找不到 .deb 文件"
            exit 1
        fi
    else
        log_info ".deb 包已存在，跳过构建"
    fi
    log_success "构建完成: release/linux-clipboard_${version}_amd64.deb"
    echo ""

    # Step 3: 推送到 GitHub
    log_step "3/8 推送代码到 GitHub..."
    log_info "推送到 origin (GitHub)..."
    git push origin main

    if [ $? -ne 0 ]; then
        log_error "推送到 GitHub 失败"
        exit 1
    fi
    log_success "已推送到 GitHub"
    echo ""

    # Step 4: 推送标签到 GitHub
    log_step "4/8 推送标签到 GitHub..."
    if git rev-parse "v${version}" >/dev/null 2>&1; then
        log_info "标签 v${version} 已存在，强制推送..."
        git push origin "refs/tags/v${version}" --force
    else
        log_error "标签 v${version} 不存在，请先运行 ./release.sh"
        exit 1
    fi
    log_success "标签已推送到 GitHub"
    echo ""

    # Step 5: 推送到 CNB
    log_step "5/8 推送代码到 CNB..."
    log_info "推送到 cnb (腾讯 CNB)..."
    git push cnb main

    if [ $? -ne 0 ]; then
        log_warn "推送到 CNB 失败（可能需要身份验证）"
        log_info "请手动执行: git push cnb main"
    else
        log_success "已推送到 CNB"
    fi
    echo ""

    # Step 6: 推送标签到 CNB
    log_step "6/8 推送标签到 CNB..."
    git push cnb "v${version}" 2>/dev/null || \
        log_warn "推送标签到 CNB 失败（可能需要身份验证）"
    log_success "标签推送完成"
    echo ""

    # Step 7: 创建 GitHub Release
    log_step "7/8 创建 GitHub Release..."

    if [ -z "$github_token" ]; then
        log_warn "未提供 GitHub Token，跳过创建 Release"
        log_info "手动创建 Release 步骤:"
        echo "  1. 访问: https://github.com/Li-zhienxuan/Linux-Clipboard/releases/new"
        echo "  2. 选择标签: v${version}"
        echo "  3. 上传文件: release/linux-clipboard_${version}_amd64.deb"
        echo "  4. 点击 'Publish release'"
        echo ""
        log_info "如需自动创建 Release，请提供 GitHub Token:"
        echo "  ./auto-release.sh ${version} YOUR_GITHUB_TOKEN"
    else
        log_info "使用 GitHub API 创建 Release..."

        # 读取 Release Notes
        local release_notes=""
        if [ -f "RELEASE_NOTES_v${version}.md" ]; then
            release_notes=$(cat "RELEASE_NOTES_v${version}.md")
        else
            release_notes="## Release v${version}\n\n**发布时间**: $(get_beijing_time)\n\n### 更新内容\n- 请查看提交历史了解详细变更"
        fi

        # 创建 Release
        local response=$(curl -X POST \
            -H "Authorization: token ${github_token}" \
            -H "Accept: application/vnd.github.v3+json" \
            "https://api.github.com/repos/Li-zhienxuan/Linux-Clipboard/releases" \
            -d "{
                \"tag_name\": \"v${version}\",
                \"target_commitish\": \"main\",
                \"name\": \"v${version}\",
                \"body\": $(echo "$release_notes" | jq -Rs .),
                \"draft\": false,
                \"prerelease\": false
            }" 2>/dev/null)

        # 检查是否成功
        if echo "$response" | grep -q "html_url"; then
            log_success "Release 创建成功"

            # 获取 Release ID
            local release_id=$(echo "$response" | grep -o '"id": [0-9]*' | head -1 | cut -d' ' -f2)

            if [ -n "$release_id" ]; then
                log_info "上传 .deb 文件到 Release..."

                # 上传 .deb 文件
                local upload_response=$(curl -X POST \
                    -H "Authorization: token ${github_token}" \
                    -H "Content-Type: application/octet-stream" \
                    "https://uploads.github.com/repos/Li-zhienxuan/Linux-Clipboard/releases/${release_id}/assets?name=linux-clipboard_${version}_amd64.deb" \
                    --data-binary @"release/linux-clipboard_${version}_amd64.deb" 2>/dev/null)

                if echo "$upload_response" | grep -q "browser_download_url"; then
                    log_success ".deb 文件上传成功"
                else
                    log_warn ".deb 文件上传失败，请手动上传"
                fi
            fi
        else
            log_warn "Release 创建失败，请手动创建"
            echo "$response" | head -5
        fi
    fi
    echo ""

    # Step 8: 显示发布信息
    log_step "8/8 发布完成！"
    echo ""
    log_success "========================================"
    log_success "发布成功！"
    log_success "========================================"
    echo ""

    echo -e "${CYAN}版本信息:${NC}"
    echo "  版本: v${version}"
    echo "  时间: $(get_beijing_time)"
    echo ""

    echo -e "${CYAN}安装包:${NC}"
    echo "  本地: release/linux-clipboard_${version}_amd64.deb"
    echo ""

    echo -e "${CYAN}GitHub Release:${NC}"
    echo "  URL: https://github.com/Li-zhienxuan/Linux-Clipboard/releases/tag/v${version}"
    echo ""

    echo -e "${CYAN}CNB 仓库:${NC}"
    echo "  URL: https://cnb.cool/ZhienXuan/Linux-Clipboard"
    echo ""

    echo -e "${CYAN}下载命令:${NC}"
    echo "  wget https://github.com/Li-zhienxuan/Linux-Clipboard/releases/download/v${version}/linux-clipboard_${version}_amd64.deb"
    echo "  sudo dpkg -i linux-clipboard_${version}_amd64.deb"
    echo ""

    echo -e "${CYAN}安装命令:${NC}"
    echo "  sudo ./install.sh"
    echo ""

    log_success "所有任务已完成！"
    echo ""
}

# 执行主流程
main "$@"
