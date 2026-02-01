#!/bin/bash

# Claude Code 工作区同步脚本 (macOS 版本)
# 用法: ./sync-mac.sh [push|pull|status]

set -e

REPO_DIR="$HOME/claude-code-workspace"
SKILLS_SOURCE="$REPO_DIR/skills"
SKILLS_TARGET_AGENT="$HOME/.agents/skills"
SKILLS_TARGET_CLAUDE="$HOME/.claude/skills"
CLAUDE_MD_SOURCE="$REPO_DIR/CLAUDE.md"
CLAUDE_MD_TARGET="$HOME/CLAUDE.md"

# 颜色输出
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

log_info() { echo -e "${GREEN}[INFO]${NC} $1"; }
log_warn() { echo -e "${YELLOW}[WARN]${NC} $1"; }
log_error() { echo -e "${RED}[ERROR]${NC} $1"; }

# 显示用法
show_usage() {
    echo "用法: $0 [push|pull|status|help]"
    echo ""
    echo "命令:"
    echo "  push    - 推送本地更改到 GitHub"
    echo "  pull    - 从 GitHub 拉取更新"
    echo "  status  - 查看同步状态"
    echo "  help    - 显示此帮助信息"
    echo ""
    echo "示例:"
    echo "  $0 push   # 推送到 GitHub"
    echo "  $0 pull   # 拉取更新"
}

# Git 操作
git_push() {
    log_info "推送到 GitHub..."

    cd "$REPO_DIR"

    # 检查是否有更改
    if git diff --quiet && git diff --cached --quiet; then
        log_warn "没有需要推送的更改"
        return
    fi

    # 添加所有更改
    git add .

    # 提交
    echo ""
    read -p "请输入提交信息 (默认: Update workspace): " commit_msg
    commit_msg=${commit_msg:-"Update workspace"}

    git commit -m "$commit_msg"

    # 推送
    git push

    log_info "✅ 推送成功！"
}

git_pull() {
    log_info "从 GitHub 拉取更新..."

    cd "$REPO_DIR"

    # 拉取更新
    git pull origin main

    log_info "✅ 拉取成功！"

    # 安装更新
    install_to_system
}

git_status() {
    log_info "查看同步状态..."

    cd "$REPO_DIR"

    echo ""
    git status
    echo ""

    # 显示最近提交
    echo "最近的提交:"
    git log --oneline -5
}

# 安装到系统
install_to_system() {
    log_info "安装更新到系统..."

    # 备份现有配置
    BACKUP_DIR="$HOME/.claude-backup-$(date +%Y%m%d-%H%M%S)"
    mkdir -p "$BACKUP_DIR"

    if [ -f "$CLAUDE_MD_TARGET" ]; then
        cp "$CLAUDE_MD_TARGET" "$BACKUP_DIR/"
        log_info "已备份现有 CLAUDE.md"
    fi

    if [ -d "$SKILLS_TARGET_AGENT" ]; then
        cp -r "$SKILLS_TARGET_AGENT" "$BACKUP_DIR/"
        log_info "已备份现有技能"
    fi

    # 安装 CLAUDE.md
    cp "$CLAUDE_MD_SOURCE" "$CLAUDE_MD_TARGET"
    log_info "✅ 已更新 CLAUDE.md"

    # 安装技能
    mkdir -p "$SKILLS_TARGET_AGENT"
    cp -r "$SKILLS_SOURCE"/* "$SKILLS_TARGET_AGENT/"

    # 创建符号链接
    mkdir -p "$SKILLS_TARGET_CLAUDE"
    for skill in "$SKILLS_SOURCE"/*; do
        skill_name=$(basename "$skill")
        ln -sf "../../.agents/skills/$skill_name" "$SKILLS_TARGET_CLAUDE/$skill_name"
    done
    log_info "✅ 已更新技能"

    # 验证安装
    echo ""
    log_info "验证安装:"
    ls -la "$SKILLS_TARGET_CLAUDE" | grep -E "code-review|evaluate-session|plan-feature|doc-manager"

    echo ""
    log_info "✅ 安装完成！"
    log_info "备份位置: $BACKUP_DIR"
}

# 主函数
main() {
    case "${1:-help}" in
        push)
            git_push
            ;;
        pull)
            git_pull
            ;;
        status)
            git_status
            ;;
        help|--help|-h)
            show_usage
            ;;
        *)
            log_error "未知命令: $1"
            echo ""
            show_usage
            exit 1
            ;;
    esac
}

main "$@"
