#!/bin/bash

###############################################################################
# Claude Code 自动同步测试脚本
# 功能：全面测试自动同步机制的可靠性
# 作者：Murphy
# 创建日期：2026-02-02
###############################################################################

# 测试结果记录
TESTS_PASSED=0
TESTS_FAILED=0
TEST_RESULTS=()

# 颜色输出
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# 日志函数
log_test() {
    echo -e "${BLUE}[TEST]${NC} $1"
}

log_pass() {
    echo -e "${GREEN}[PASS]${NC} $1"
    ((TESTS_PASSED++))
    TEST_RESULTS+=("✅ $1")
}

log_fail() {
    echo -e "${RED}[FAIL]${NC} $1"
    ((TESTS_FAILED++))
    TEST_RESULTS+=("❌ $1")
}

log_info() {
    echo -e "${YELLOW}[INFO]${NC} $1"
}

# 测试 1: 脚本文件存在性
test_script_exists() {
    log_test "测试 1: 检查脚本文件是否存在"

    local script="$HOME/claude-code-workspace/scripts/auto-sync.sh"

    if [ -f "$script" ]; then
        log_pass "脚本文件存在: $script"
    else
        log_fail "脚本文件不存在: $script"
        return 1
    fi

    if [ -x "$script" ]; then
        log_pass "脚本具有执行权限"
    else
        log_fail "脚本没有执行权限"
        return 1
    fi
}

# 测试 2: Launchd 配置文件
test_launchd_config() {
    log_test "测试 2: 检查 Launchd 配置文件"

    local plist="$HOME/Library/LaunchAgents/com.claudecode.sync.plist"

    if [ -f "$plist" ]; then
        log_pass "Launchd 配置文件存在"
    else
        log_fail "Launchd 配置文件不存在"
        return 1
    fi

    # 验证 plist 格式
    if plutil -lint "$plist" > /dev/null 2>&1; then
        log_pass "Launchd 配置文件格式正确"
    else
        log_fail "Launchd 配置文件格式错误"
        return 1
    fi
}

# 测试 3: Git 配置
test_git_config() {
    log_test "测试 3: 检查 Git 配置"

    # 检查 credential helper
    if git config --global credential.helper | grep -q "osxkeychain"; then
        log_pass "Git Credential Helper 已配置"
    else
        log_fail "Git Credential Helper 未配置"
        return 1
    fi

    # 检查用户信息
    local user_name=$(git config --global user.name)
    local user_email=$(git config --global user.email)

    if [ -n "$user_name" ]; then
        log_pass "Git 用户名已配置: $user_name"
    else
        log_fail "Git 用户名未配置"
        return 1
    fi

    if [ -n "$user_email" ]; then
        log_pass "Git 邮箱已配置: $user_email"
    else
        log_fail "Git 邮箱未配置"
        return 1
    fi
}

# 测试 4: 脚本帮助功能
test_script_help() {
    log_test "测试 4: 测试脚本帮助功能"

    local script="$HOME/claude-code-workspace/scripts/auto-sync.sh"

    if "$script" help > /dev/null 2>&1; then
        log_pass "脚本帮助功能正常"
    else
        log_fail "脚本帮助功能异常"
        return 1
    fi
}

# 测试 5: 脚本状态功能
test_script_status() {
    log_test "测试 5: 测试脚本状态功能"

    local script="$HOME/claude-code-workspace/scripts/auto-sync.sh"

    if "$script" status > /dev/null 2>&1; then
        log_pass "脚本状态功能正常"
    else
        log_fail "脚本状态功能异常"
        return 1
    fi
}

# 测试 6: VPN 检测功能
test_vpn_detection() {
    log_test "测试 6: 测试 VPN 检测功能"

    if ping -c 1 -W 2 github.com > /dev/null 2>&1; then
        log_pass "可以访问 GitHub（VPN 已连接）"
    else
        log_fail "无法访问 GitHub（VPN 未连接）"
        return 1
    fi
}

# 测试 7: Git 仓库状态
test_repo_status() {
    log_test "测试 7: 测试 Git 仓库状态"

    local repo="$HOME/claude-code-workspace"

    if [ -d "$repo/.git" ]; then
        log_pass "Git 仓库存在"
    else
        log_fail "Git 仓库不存在"
        return 1
    fi

    cd "$repo" || return 1

    # 检查远程仓库
    if git remote get-url origin > /dev/null 2>&1; then
        local remote_url=$(git remote get-url origin)
        log_pass "远程仓库已配置: $remote_url"
    else
        log_fail "远程仓库未配置"
        return 1
    fi
}

# 测试 8: 日志文件创建
test_log_file() {
    log_test "测试 8: 测试日志文件创建"

    local log="$HOME/claude-code-workspace/sync.log"

    if [ -f "$log" ] || touch "$log" 2>/dev/null; then
        log_pass "日志文件可创建: $log"
    else
        log_fail "日志文件无法创建"
        return 1
    fi
}

# 测试 9: 测试模式
test_mode() {
    log_test "测试 9: 测试测试模式"

    local script="$HOME/claude-code-workspace/scripts/auto-sync.sh"

    if "$script" test > /dev/null 2>&1; then
        log_pass "测试模式执行成功"
    else
        log_fail "测试模式执行失败"
        return 1
    fi
}

# 测试 10: Tag 列表功能
test_tags_list() {
    log_test "测试 10: 测试 Tag 列表功能"

    local script="$HOME/claude-code-workspace/scripts/auto-sync.sh"

    if "$script" tags > /dev/null 2>&1; then
        log_pass "Tag 列表功能正常"
    else
        log_fail "Tag 列表功能异常"
        return 1
    fi
}

# 测试 11: 权限检查
test_permissions() {
    log_test "测试 11: 检查文件权限"

    local script="$HOME/claude-code-workspace/scripts/auto-sync.sh"

    if [ -r "$script" ] && [ -x "$script" ]; then
        log_pass "脚本具有读取和执行权限"
    else
        log_fail "脚本权限不足"
        return 1
    fi
}

# 测试 12: 环境变量
test_environment() {
    log_test "测试 12: 检查必要的环境变量"

    if [ -n "$HOME" ]; then
        log_pass "HOME 变量已设置: $HOME"
    else
        log_fail "HOME 变量未设置"
        return 1
    fi

    if command -v git > /dev/null 2>&1; then
        log_pass "Git 命令可用"
    else
        log_fail "Git 命令不可用"
        return 1
    fi

    if command -v ping > /dev/null 2>&1; then
        log_pass "Ping 命令可用"
    else
        log_fail "Ping 命令不可用"
        return 1
    fi
}

# 运行所有测试
run_all_tests() {
    echo "========================================="
    echo "Claude Code 自动同步测试套件"
    echo "========================================="
    echo ""

    test_script_exists
    test_launchd_config
    test_git_config
    test_script_help
    test_script_status
    test_vpn_detection
    test_repo_status
    test_log_file
    test_mode
    test_tags_list
    test_permissions
    test_environment

    echo ""
    echo "========================================="
    echo "测试结果汇总"
    echo "========================================="
    echo ""

    for result in "${TEST_RESULTS[@]}"; do
        echo "$result"
    done

    echo ""
    echo "========================================="
    echo "总计: $((TESTS_PASSED + TESTS_FAILED)) 个测试"
    echo "通过: $TESTS_PASSED 个 ✅"
    echo "失败: $TESTS_FAILED 个 ❌"
    echo "========================================="

    if [ $TESTS_FAILED -eq 0 ]; then
        echo -e "${GREEN}所有测试通过！${NC}"
        return 0
    else
        echo -e "${RED}部分测试失败，请检查配置${NC}"
        return 1
    fi
}

# 显示帮助
show_help() {
    echo "Claude Code 自动同步测试脚本"
    echo ""
    echo "用法: $0 [选项]"
    echo ""
    echo "选项:"
    echo "  all     - 运行所有测试（默认）"
    echo "  quick   - 快速测试（仅核心功能）"
    echo "  help    - 显示此帮助信息"
    echo ""
    echo "测试列表:"
    echo "  1. 脚本文件存在性"
    echo "  2. Launchd 配置文件"
    echo "  3. Git 配置"
    echo "  4. 脚本帮助功能"
    echo "  5. 脚本状态功能"
    echo "  6. VPN 检测"
    echo "  7. Git 仓库状态"
    echo "  8. 日志文件创建"
    echo "  9. 测试模式"
    echo "  10. Tag 列表"
    echo "  11. 权限检查"
    echo "  12. 环境变量"
}

# 快速测试
run_quick_tests() {
    echo "快速测试模式"
    echo ""
    test_script_exists
    test_git_config
    test_vpn_detection
    test_repo_status
}

# 主函数
main() {
    case "${1:-all}" in
        all)
            run_all_tests
            ;;
        quick)
            run_quick_tests
            ;;
        help|--help|-h)
            show_help
            ;;
        *)
            echo "未知选项: $1"
            show_help
            exit 1
            ;;
    esac
}

# 执行主函数
main "$@"
