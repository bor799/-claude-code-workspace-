#!/bin/bash

# ljg-trend-research 定时任务管理脚本

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIG_DIR="$HOME/.ljg-trend-research"
PLIST_FILE="$CONFIG_DIR/com.ljg.trendresearch.plist"
LAUNCH_DAEMON="$HOME/Library/LaunchAgents/com.ljg.trendresearch.plist"

# 颜色输出
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

log_info() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

log_warn() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# 检查依赖
check_dependencies() {
    log_info "检查依赖..."

    if ! command -v python3 &> /dev/null; then
        log_error "Python3 未安装"
        return 1
    fi

    if ! command -v launchctl &> /dev/null; then
        log_error "launchctl 未找到"
        return 1
    fi

    log_info "✅ 依赖检查通过"
    return 0
}

# 安装定时任务
install_schedule() {
    log_info "安装定时任务..."

    # 检查依赖
    if ! check_dependencies; then
        log_error "依赖检查失败，安装中止"
        return 1
    fi

    # 创建必要的目录
    mkdir -p "$CONFIG_DIR/logs"
    mkdir -p "$HOME/Documents/Obsidian Vault/趋势研究/日报"

    # 复制 plist 文件
    cp "$PLIST_FILE" "$LAUNCH_DAEMON"

    # 加载 LaunchAgent
    launchctl unload "$LAUNCH_DAEMON" 2>/dev/null || true
    launchctl load "$LAUNCH_DAEMON"

    log_info "✅ 定时任务安装完成"
    log_info "📅 运行时间: 每天凌晨 4:00"
    log_info "📄 日志位置: $CONFIG_DIR/logs/"

    # 显示当前任务状态
    show_status
}

# 卸载定时任务
uninstall_schedule() {
    log_info "卸载定时任务..."

    if [ -f "$LAUNCH_DAEMON" ]; then
        launchctl unload "$LAUNCH_DAEMON"
        rm -f "$LAUNCH_DAEMON"
        log_info "✅ 定时任务已卸载"
    else
        log_warn "定时任务未安装"
    fi
}

# 显示状态
show_status() {
    log_info "定时任务状态:"

    if launchctl list | grep -q "com.ljg.trendresearch"; then
        echo "  状态: ✅ 运行中"
        echo "  配置: $LAUNCH_DAEMON"

        # 显示下次运行时间
        echo "  运行时间: 每天凌晨 4:00"

        # 检查日志
        if [ -f "$CONFIG_DIR/logs/daily_report.log" ]; then
            echo "  最新日志:"
            tail -n 5 "$CONFIG_DIR/logs/daily_report.log" | sed 's/^/    /'
        fi
    else
        echo "  状态: ❌ 未运行"
    fi
}

# 手动运行测试
run_test() {
    log_info "手动运行深度日报生成..."
    log_warn "⚠️  注意: 这将调用 last30days-skill，每个话题需要 1-3 分钟"

    python3 "$CONFIG_DIR/integrated_daily_report.py"

    log_info "✅ 测试运行完成"
    log_info "📄 报告位置: $HOME/Documents/Obsidian Vault/趋势研究/日报/"
}

# 查看日志
show_logs() {
    log_info "查看日志..."

    if [ -f "$CONFIG_DIR/logs/daily_report.log" ]; then
        echo "=== 标准输出日志 ==="
        tail -n 50 "$CONFIG_DIR/logs/daily_report.log"
    else
        log_warn "日志文件不存在"
    fi

    if [ -f "$CONFIG_DIR/logs/daily_report.error.log" ]; then
        echo ""
        echo "=== 错误日志 ==="
        tail -n 50 "$CONFIG_DIR/logs/daily_report.error.log"
    fi
}

# 编辑话题配置
edit_topics() {
    log_info "编辑话题配置..."

    if [ -f "$CONFIG_DIR/topics.yaml" ]; then
        ${EDITOR:-vi} "$CONFIG_DIR/topics.yaml"
        log_info "✅ 配置已更新"
    else
        log_error "配置文件不存在: $CONFIG_DIR/topics.yaml"
    fi
}

# 配置 Telegram
setup_telegram() {
    log_info "配置 Telegram..."

    if [ -f "$CONFIG_DIR/setup_telegram.sh" ]; then
        bash "$CONFIG_DIR/setup_telegram.sh"
    else
        log_error "Telegram 配置脚本不存在"
    fi
}

# 显示帮助
show_help() {
    cat << EOF
ljg-trend-research 定时任务管理（深度集成版）

用法: $0 [COMMAND]

命令:
  install    安装定时任务（每天凌晨4点运行）
  uninstall  卸载定时任务
  status     查看定时任务状态
  test       手动运行测试（调用真实的 last30days-skill）
  logs       查看日志
  edit       编辑话题配置
  telegram   配置 Telegram 推送
  help       显示此帮助信息

示例:
  $0 install     # 安装定时任务
  $0 test        # 手动运行测试（需要 10-30 分钟）
  $0 status      # 查看状态

深度集成:
  - last30days-skill: 真实调用 Reddit, X, YouTube, HN, Polymarket
  - 100X 系统: 深度知识萃取（可选）
  - 每个话题扫描时间: 1-3 分钟
  - 总运行时间: 约 10-30 分钟（取决于话题数量）

配置文件:
  - 话题配置: ~/.ljg-trend-research/topics.yaml
  - 日志目录: ~/.ljg-trend-research/logs/
  - 日报输出: ~/Documents/Obsidian Vault/趋势研究/日报/
  - 原始数据: ~/.ljg-trend-research/logs/data_YYYYMMDD_HHMMSS.json

EOF
}

# 主函数
main() {
    case "${1:-help}" in
        install)
            install_schedule
            ;;
        uninstall)
            uninstall_schedule
            ;;
        status)
            show_status
            ;;
        test)
            run_test
            ;;
        logs)
            show_logs
            ;;
        edit)
            edit_topics
            ;;
        telegram)
            setup_telegram
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

main "$@"
