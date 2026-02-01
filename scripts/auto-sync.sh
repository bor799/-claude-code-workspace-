#!/bin/bash

###############################################################################
# Claude Code 自动化同步脚本
# 功能：每周自动备份到 GitHub，创建版本 Tags
# 作者：Murphy
# 创建日期：2026-02-02
###############################################################################

# 配置
REPO_DIR="$HOME/claude-code-workspace"
LOG_FILE="$REPO_DIR/sync.log"
LOCK_FILE="/tmp/claudecode-sync.lock"

# 颜色输出
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# 日志函数
log_info() {
    echo -e "${GREEN}[INFO]${NC} $1" | tee -a "$LOG_FILE"
}

log_warn() {
    echo -e "${YELLOW}[WARN]${NC} $1" | tee -a "$LOG_FILE"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1" | tee -a "$LOG_FILE"
}

log_debug() {
    echo -e "${BLUE}[DEBUG]${NC} $1" | tee -a "$LOG_FILE"
}

# 检查锁文件（防止重复执行）
check_lock() {
    if [ -f "$LOCK_FILE" ]; then
        local pid=$(cat "$LOCK_FILE")
        if ps -p "$pid" > /dev/null 2>&1; then
            log_warn "另一个同步进程正在运行 (PID: $pid)"
            exit 1
        else
            log_warn "清理过期的锁文件"
            rm -f "$LOCK_FILE"
        fi
    fi

    # 创建锁文件
    echo $$ > "$LOCK_FILE"
    trap 'rm -f "$LOCK_FILE"' EXIT
}

# 检查 VPN 连接
check_vpn() {
    log_info "检查 VPN 连接状态..."

    # 尝试 ping GitHub
    if ping -c 1 -W 5 github.com > /dev/null 2>&1; then
        log_info "✅ VPN 连接正常"
        return 0
    else
        log_error "❌ VPN 未连接或无法访问 GitHub"
        return 1
    fi
}

# 检查 Git 仓库状态
check_repo_status() {
    log_info "检查仓库状态..."

    cd "$REPO_DIR" || exit 1

    # 检查是否有未推送的提交
    local unpushed=$(git log @{u}..HEAD 2>/dev/null | wc -l)
    if [ "$unpushed" -gt 0 ]; then
        log_info "发现 $unpushed 个未推送的提交"
    fi

    # 检查是否有未提交的更改
    if git diff --quiet && git diff --cached --quiet; then
        log_info "✅ 没有未提交的更改"
        return 1
    else
        log_info "发现未提交的更改"
        return 0
    fi
}

# 同步到系统
sync_to_system() {
    log_info "同步更新到系统..."

    local CLAUDE_MD_SOURCE="$REPO_DIR/CLAUDE.md"
    local CLAUDE_MD_TARGET="$HOME/CLAUDE.md"
    local SKILLS_SOURCE="$REPO_DIR/skills"
    local SKILLS_TARGET_AGENT="$HOME/.agents/skills"
    local SKILLS_TARGET_CLAUDE="$HOME/.claude/skills"

    # 备份现有配置
    local BACKUP_DIR="$HOME/.claude-backup-$(date +%Y%m%d-%H%M%S)"
    mkdir -p "$BACKUP_DIR"

    if [ -f "$CLAUDE_MD_TARGET" ]; then
        cp "$CLAUDE_MD_TARGET" "$BACKUP_DIR/"
        log_debug "已备份 CLAUDE.md"
    fi

    if [ -d "$SKILLS_TARGET_AGENT" ]; then
        cp -r "$SKILLS_TARGET_AGENT" "$BACKUP_DIR/" 2>/dev/null
        log_debug "已备份技能目录"
    fi

    # 安装 CLAUDE.md
    if [ -f "$CLAUDE_MD_SOURCE" ]; then
        cp "$CLAUDE_MD_SOURCE" "$CLAUDE_MD_TARGET"
        log_info "✅ 已更新 CLAUDE.md"
    fi

    # 安装技能
    mkdir -p "$SKILLS_TARGET_AGENT"
    if [ -d "$SKILLS_SOURCE" ]; then
        cp -r "$SKILLS_SOURCE"/* "$SKILLS_TARGET_AGENT/"

        # 创建符号链接
        mkdir -p "$SKILLS_TARGET_CLAUDE"
        for skill in "$SKILLS_SOURCE"/*; do
            if [ -d "$skill" ]; then
                local skill_name=$(basename "$skill")
                ln -sf "../../.agents/skills/$skill_name" "$SKILLS_TARGET_CLAUDE/$skill_name"
            fi
        done
        log_info "✅ 已更新技能"
    fi

    log_debug "备份位置: $BACKUP_DIR"
}

# 创建 Git Tag
create_tag() {
    local tag_name="v$(date +%Y-%m-%d)"
    local tag_message="Auto backup: $(date '+%Y-%m-%d %H:%M:%S')"

    log_info "创建 Git Tag: $tag_name"

    # 检查 Tag 是否已存在
    if git rev-parse "$tag_name" >/dev/null 2>&1; then
        log_warn "Tag $tag_name 已存在，跳过创建"
        return 0
    fi

    # 创建 annotated tag
    if git tag -a "$tag_name" -m "$tag_message"; then
        log_info "✅ Tag 创建成功: $tag_name"
        return 0
    else
        log_error "❌ Tag 创建失败"
        return 1
    fi
}

# 推送到 GitHub
push_to_github() {
    log_info "推送到 GitHub..."

    cd "$REPO_DIR" || exit 1

    # 推送 main 分支
    log_debug "推送 main 分支..."
    if git push origin main 2>&1 | tee -a "$LOG_FILE"; then
        log_info "✅ main 分支推送成功"
    else
        log_error "❌ main 分支推送失败"
        return 1
    fi

    # 推送所有 Tags
    log_debug "推送 Tags..."
    if git push origin --tags 2>&1 | tee -a "$LOG_FILE"; then
        log_info "✅ Tags 推送成功"
    else
        log_error "❌ Tags 推送失败"
        return 1
    fi

    return 0
}

# 主同步流程
main_sync() {
    log_info "========================================="
    log_info "开始自动同步: $(date '+%Y-%m-%d %H:%M:%S')"
    log_info "========================================="

    # 1. 检查锁文件
    check_lock

    # 2. 检查 VPN
    if ! check_vpn; then
        log_warn "VPN 未连接，跳过同步"
        exit 1
    fi

    # 3. 进入仓库目录
    if [ ! -d "$REPO_DIR" ]; then
        log_error "仓库目录不存在: $REPO_DIR"
        exit 1
    fi

    cd "$REPO_DIR" || exit 1

    # 4. 检查是否有更新
    if ! check_repo_status; then
        log_info "没有需要同步的更新"
        log_info "同步完成: $(date '+%Y-%m-%d %H:%M:%S')"
        exit 0
    fi

    # 5. 添加所有更改
    log_info "添加更改到 Git..."
    git add .

    # 6. 提交更改
    local commit_message="Auto sync: $(date '+%Y-%m-%d %H:%M:%S')"
    log_info "提交更改..."
    if git commit -m "$commit_message"; then
        log_info "✅ 提交成功"
    else
        log_error "❌ 提交失败"
        exit 1
    fi

    # 7. 创建 Tag
    if ! create_tag; then
        log_warn "Tag 创建失败，但继续推送代码"
    fi

    # 8. 推送到 GitHub
    if ! push_to_github; then
        log_error "推送失败，请检查网络和认证配置"
        exit 1
    fi

    # 9. 同步到系统
    sync_to_system

    # 10. 完成
    log_info "========================================="
    log_info "✅ 同步完成: $(date '+%Y-%m-%d %H:%M:%S')"
    log_info "========================================="
}

# 显示帮助
show_help() {
    echo "Claude Code 自动化同步脚本"
    echo ""
    echo "用法: $0 [命令]"
    echo ""
    echo "命令:"
    echo "  sync    - 执行同步（默认）"
    echo "  status  - 查看状态"
    echo "  test    - 测试模式（不实际推送）"
    echo "  tags    - 列出所有 Tags"
    echo "  log     - 查看同步日志"
    echo "  help    - 显示此帮助信息"
    echo ""
    echo "示例:"
    echo "  $0 sync   # 执行同步"
    echo "  $0 test   # 测试模式"
}

# 查看状态
show_status() {
    echo "========================================="
    echo "同步状态"
    echo "========================================="

    # VPN 状态
    echo -n "VPN: "
    if ping -c 1 -W 2 github.com > /dev/null 2>&1; then
        echo -e "${GREEN}✅ 已连接${NC}"
    else
        echo -e "${RED}❌ 未连接${NC}"
    fi

    # 仓库状态
    echo ""
    echo "仓库状态:"
    cd "$REPO_DIR" 2>/dev/null || return

    # 未推送的提交
    local unpushed=$(git log @{u}..HEAD 2>/dev/null | wc -l)
    echo "  未推送的提交: $unpushed"

    # 未提交的更改
    if git diff --quiet && git diff --cached --quiet; then
        echo "  未提交的更改: 无"
    else
        echo "  未提交的更改: 有"
    fi

    # 最近 Tags
    echo ""
    echo "最近的 Tags:"
    git tag -l | tail -5
}

# 测试模式
test_mode() {
    log_info "测试模式（不会实际推送）"

    # 检查 VPN
    check_vpn || return 1

    # 检查仓库
    check_repo_status

    log_info "✅ 测试通过"
}

# 列出 Tags
list_tags() {
    echo "========================================="
    echo "Git Tags"
    echo "========================================="

    cd "$REPO_DIR" 2>/dev/null || return

    git tag -l | sort -r | head -20
}

# 查看日志
show_log() {
    if [ -f "$LOG_FILE" ]; then
        tail -50 "$LOG_FILE"
    else
        echo "日志文件不存在: $LOG_FILE"
    fi
}

# 主函数
main() {
    case "${1:-sync}" in
        sync)
            main_sync
            ;;
        status)
            show_status
            ;;
        test)
            test_mode
            ;;
        tags)
            list_tags
            ;;
        log)
            show_log
            ;;
        help|--help|-h)
            show_help
            ;;
        *)
            log_error "未知命令: $1"
            show_help
            exit 1
            ;;
    esac
}

# 执行主函数
main "$@"
