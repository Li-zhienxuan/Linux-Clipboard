#!/bin/bash

###############################################################################
# Linux-Clipboard 自动化发布脚本（交互式密码输入）
# 功能: 自动构建、推送到 GitHub/CNB、创建 Release
# 用法: ./auto-release.sh [version]
###############################################################################

set -e  # 遇到错误立即退出

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
BOLD='\033[1m'
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

# 交互式输入 Token（不回显）
prompt_token() {
    local token_name=$1
    local token_var=$2
    local prompt_msg=$3

    echo ""
    echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${BOLD}${CYAN}  ${token_name} 配置${NC}"
    echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo ""
    echo -e "${YELLOW}获取 ${token_name}:${NC}"
    echo "  ${prompt_msg}"
    echo ""
    echo -e "${RED}⚠️  注意: 密码仅用于本次操作，不会保存！${NC}"
    echo ""

    # 交互式输入（不回显）
    read -s -p "请输入 ${token_name} (输入后按 Enter): " token_value
    echo ""
    echo ""

    # 验证不为空
    while [ -z "$token_value" ]; do
        echo -e "${RED}${token_name} 不能为空！${NC}"
        read -s -p "请重新输入 ${token_name}: " token_value
        echo ""
    done

    # 设置环境变量
    export "$token_var"="$token_value"

    echo -e "${GREEN}✓ ${token_name} 已设置${NC}"
    echo ""
}

# 从配置文件读取 GitHub Token（如果存在）
load_tokens_from_files() {
    local loaded=false

    # 从 .github-token 文件读取 GitHub Token
    if [ -f ".github-token" ]; then
        export GITHUB_TOKEN=$(cat .github-token | tr -d ' \n')
        log_info "从 .github-token 文件加载 GitHub Token"
        loaded=true
    fi

    return 0
}

###############################################################################
# 主流程
###############################################################################

main() {
    local version=$1

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

    # 尝试从文件加载 Token
    load_tokens_from_files

    # 如果没有从文件加载到 Token，提示用户是否交互式输入
    if [ -z "$GITHUB_TOKEN" ]; then
        echo ""
        echo -e "${YELLOW}检测到 GitHub Token 未配置${NC}"
        echo ""
        echo "你可以选择:"
        echo "  1) 交互式输入 GitHub Token（推荐，安全）"
        echo "  2) 跳过 GitHub Token（不创建 Release）"
        echo "  3) 取消发布"
        echo ""
        read -p "请选择 (1/2/3): " choice
        echo ""

        case $choice in
            1)
                # GitHub Token
                if [ -z "$GITHUB_TOKEN" ]; then
                    prompt_token "GitHub" "GITHUB_TOKEN" "https://github.com/settings/tokens"
                fi

                ;;
            2)
                log_warn "跳过 GitHub Token 配置"
                log_info "将不会创建 GitHub Release（需要手动操作）"
                echo ""
                read -p "是否继续？(y/N): " confirm
                echo ""
                if [[ ! $confirm =~ ^[Yy]$ ]]; then
                    log_info "发布已取消"
                    exit 0
                fi
                ;;
            3)
                log_info "发布已取消"
                exit 0
                ;;
            *)
                log_error "无效选择"
                exit 1
                ;;
        esac
    else
        log_success "GitHub Token 配置文件已找到"
    fi
    echo ""

    # CNB 密码输入（每次都要求输入）
    echo ""
    echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${BOLD}${CYAN}  CNB 推送配置${NC}"
    echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo ""
    echo "推送到 CNB 需要使用用户名 'cnb' 和密码"
    echo ""
    read -p "是否推送到 CNB？(y/N): " push_to_cnb
    echo ""

    if [[ $push_to_cnb =~ ^[Yy]$ ]]; then
        prompt_token "CNB 密码" "CNB_PASSWORD" "用户名: cnb"
    else
        log_warn "将跳过 CNB 推送"
    fi

    # 显示 Token 状态
    echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${BOLD}  Token 状态${NC}"
    echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo ""

    if [ -n "$GITHUB_TOKEN" ]; then
        echo -e "  GitHub Token: ${GREEN}✓ 已配置${NC}"
    else
        echo -e "  GitHub Token: ${YELLOW}✗ 未配置${NC} (将跳过 Release 创建)"
    fi

    if [ -n "$CNB_PASSWORD" ]; then
        echo -e "  CNB 密码:    ${GREEN}✓ 已配置${NC}"
    else
        echo -e "  CNB 密码:    ${YELLOW}✗ 未配置${NC} (将跳过 CNB 推送)"
    fi
    echo ""
    echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo ""

    # Step 1: 检查工作区状态
    log_step "1/9 检查工作区状态..."
    if [ -n "$(git status --porcelain)" ]; then
        log_error "工作区有未提交的更改，请先提交或暂存"
        git status --short
        exit 1
    fi
    log_success "工作区干净"
    echo ""

    # Step 2: 构建 .deb 包
    log_step "2/9 构建 .deb 安装包..."
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
    log_step "3/9 推送代码到 GitHub..."
    log_info "推送到 origin (GitHub)..."
    git push origin main

    if [ $? -ne 0 ]; then
        log_error "推送到 GitHub 失败"
        exit 1
    fi
    log_success "已推送到 GitHub"
    echo ""

    # Step 4: 推送标签到 GitHub
    log_step "4/9 推送标签到 GitHub..."
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
    log_step "5/9 推送代码到 CNB..."

    if [ -z "$CNB_PASSWORD" ]; then
        log_warn "未配置 CNB 密码，跳过 CNB 推送"
        log_info "如需推送到 CNB，请配置 CNB 密码 后重新运行"
    else
        log_info "使用 Token 推送到 CNB..."

        # 使用 Token 推送到 CNB
        local cnb_url="https://cnb:${CNB_PASSWORD}@cnb.cool/ZhienXuan/Linux-Clipboard.git"

        # 推送代码
        if git push "$cnb_url" main; then
            log_success "已推送到 CNB"
        else
            log_warn "推送到 CNB 失败（Token 可能无效）"
            log_info "请检查 Token 是否正确且有写入权限"
        fi
    fi
    echo ""

    # Step 6: 推送标签到 CNB
    log_step "6/9 推送标签到 CNB..."

    if [ -z "$CNB_PASSWORD" ]; then
        log_warn "未配置 CNB 密码，跳过标签推送"
    else
        local cnb_url="https://cnb:${CNB_PASSWORD}@cnb.cool/ZhienXuan/Linux-Clipboard.git"

        if git push "$cnb_url" "v${version}" 2>/dev/null; then
            log_success "标签已推送到 CNB"
        else
            log_warn "推送标签到 CNB 失败"
        fi
    fi
    echo ""

    # Step 7: 创建 GitHub Release
    log_step "7/9 创建 GitHub Release..."

    if [ -z "$GITHUB_TOKEN" ]; then
        log_warn "未配置 GitHub Token，跳过创建 Release"
        echo ""
        log_info "手动创建 Release 步骤:"
        echo "  1. 访问: https://github.com/Li-zhienxuan/Linux-Clipboard/releases/new"
        echo "  2. 选择标签: v${version}"
        echo "  3. 上传文件: release/linux-clipboard_${version}_amd64.deb"
        echo "  4. 点击 'Publish release'"
        echo ""
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
        local response=$(curl -s -X POST \
            -H "Authorization: token ${GITHUB_TOKEN}" \
            -H "Accept: application/vnd.github.v3+json" \
            "https://api.github.com/repos/Li-zhienxuan/Linux-Clipboard/releases" \
            -d "{
                \"tag_name\": \"v${version}\",
                \"target_commitish\": \"main\",
                \"name\": \"v${version}\",
                \"body\": $(echo "$release_notes" | jq -Rs .),
                \"draft\": false,
                \"prerelease\": false
            }")

        # 检查是否成功
        if echo "$response" | grep -q "html_url"; then
            log_success "Release 创建成功"

            # 获取 Release ID
            local release_id=$(echo "$response" | grep -o '"id": [0-9]*' | head -1 | cut -d' ' -f2)

            if [ -n "$release_id" ]; then
                log_info "上传 .deb 文件到 Release..."

                # 上传 .deb 文件
                local upload_response=$(curl -s -X POST \
                    -H "Authorization: token ${GITHUB_TOKEN}" \
                    -H "Content-Type: application/octet-stream" \
                    "https://uploads.github.com/repos/Li-zhienxuan/Linux-Clipboard/releases/${release_id}/assets?name=linux-clipboard_${version}_amd64.deb" \
                    --data-binary @"release/linux-clipboard_${version}_amd64.deb")

                if echo "$upload_response" | grep -q "browser_download_url"; then
                    log_success ".deb 文件上传成功"
                else
                    log_warn ".deb 文件上传失败，请手动上传"
                    echo "$upload_response" | head -3
                fi
            fi
        else
            log_warn "Release 创建失败，请手动创建"
            echo "$response" | head -5
        fi
    fi
    echo ""

    # Step 8: 保存 Token 到文件（可选）
    log_step "8/9 保存 Token 配置..."

    if [ -n "$GITHUB_TOKEN" ] && [ ! -f ".github-token" ]; then
        read -p "是否要保存 GitHub Token 到 .github-token 文件？(y/N): " save_gh
        echo ""
        if [[ $save_gh =~ ^[Yy]$ ]]; then
            echo "$GITHUB_TOKEN" > .github-token
            chmod 600 .github-token
            log_success "GitHub Token 已保存到 .github-token"
        fi
    fi

    echo ""
    echo ""

    # Step 9: 显示发布信息
    log_step "9/9 生成发布信息..."

    # 创建发布信息文件
    cat > "RELEASE_INFO_v${version}.txt" << EOF
========================================
Linux-Clipboard v${version} 发布信息
========================================

发布时间: $(get_beijing_time)
版本: v${version}

安装包:
  文件名: linux-clipboard_${version}_amd64.deb
  大小: $(du -h "release/linux-clipboard_${version}_amd64.deb" | cut -f1)
  本地路径: $(pwd)/release/linux-clipboard_${version}_amd64.deb

下载链接:
  GitHub: https://github.com/Li-zhienxuan/Linux-Clipboard/releases/download/v${version}/linux-clipboard_${version}_amd64.deb
  或使用 wget:
  wget https://github.com/Li-zhienxuan/Linux-Clipboard/releases/download/v${version}/linux-clipboard_${version}_amd64.deb

安装命令:
  sudo dpkg -i linux-clipboard_${version}_amd64.deb

仓库链接:
  GitHub: https://github.com/Li-zhienxuan/Linux-Clipboard
  CNB: https://cnb.cool/ZhienXuan/Linux-Clipboard

Release Notes:
  查看 RELEASE_NOTES_v${version}.md

========================================
EOF

    log_success "发布信息已保存到: RELEASE_INFO_v${version}.txt"
    echo ""

    # 完成
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
    echo "  大小: $(du -h "release/linux-clipboard_${version}_amd64.deb" | cut -f1)"
    echo ""

    echo -e "${CYAN}仓库状态:${NC}"
    echo -e "  GitHub: ${GREEN}✓ 已推送${NC}"
    if [ -n "$CNB_PASSWORD" ]; then
        echo -e "  CNB:    ${GREEN}✓ 已推送${NC}"
    else
        echo -e "  CNB:    ${YELLOW}✗ 未推送${NC}"
    fi
    echo ""

    echo -e "${CYAN}Release 状态:${NC}"
    if [ -n "$GITHUB_TOKEN" ]; then
        echo -e "  GitHub Release: ${GREEN}✓ 已创建${NC}"
    else
        echo -e "  GitHub Release: ${YELLOW}✗ 未创建${NC} (需要手动操作)"
    fi
    echo ""

    echo -e "${CYAN}下载链接:${NC}"
    echo "  https://github.com/Li-zhienxuan/Linux-Clipboard/releases/tag/v${version}"
    echo ""

    echo -e "${CYAN}CNB 仓库:${NC}"
    echo "  https://cnb.cool/ZhienXuan/Linux-Clipboard"
    echo ""

    # 清理 Token 环境变量（安全）
    unset GITHUB_TOKEN
    unset CNB_PASSWORD

    echo -e "${GREEN}✓ Token 已从内存中清除${NC}"
    echo ""
    log_success "所有任务已完成！"
    echo ""
}

# 执行主流程
main "$@"
