#!/bin/bash
# 信息源清理脚本
# 用法: cleanup.sh <信息源目录> [dry-run]

set -euo pipefail

# 颜色输出
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# 默认参数
SOURCE_DIR="${1:-./信息源}"
DRY_RUN="${2:-false}"
BACKUP_DIR=""
REPORT_FILE=""

# 日志函数
log_info() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

log_warn() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

log_step() {
    echo -e "${BLUE}[STEP]${NC} $1"
}

# 检查目录
check_directory() {
    if [ ! -d "$SOURCE_DIR" ]; then
        log_error "目录不存在: $SOURCE_DIR"
        exit 1
    fi
    log_info "目标目录: $SOURCE_DIR"
}

# 创建备份目录
create_backup() {
    BACKUP_DIR="$SOURCE_DIR/归档/清理备份_$(date +%Y%m%d_%H%M%S)"
    mkdir -p "$BACKUP_DIR"
    log_info "备份目录: $BACKUP_DIR"
}

# 初始化报告
init_report() {
    REPORT_FILE="$BACKUP_DIR/cleanup_report.md"
    {
        echo "# 信息源清理报告"
        echo ""
        echo "**清理时间**: $(date '+%Y-%m-%d %H:%M:%S')"
        echo "**目标目录**: $SOURCE_DIR"
        echo ""
        echo "## 清理统计"
        echo ""
    } > "$REPORT_FILE"
}

# 统计文件
count_files() {
    find "$SOURCE_DIR" -name "*.md" -type f | grep -v "归档" | wc -l | tr -d ' '
}

# 查找无标题文件
find_untitled() {
    log_step "查找无标题文件..."
    local count=0
    while IFS= read -r -d '' file; do
        if [ -f "$file" ]; then
            echo "$file"
            ((count++))
        fi
    done < <(find "$SOURCE_DIR" -name "*无标题*.md" -o -name "*no-title*.md" -o -name "*\[no-title\]*.md" -print0 2>/dev/null | grep -z -v "归档")

    echo "$count"
}

# 查找重复文件
find_duplicates() {
    log_step "查找重复文件..."
    local temp_file=$(mktemp)

    # 提取所有 source_url 并统计重复
    find "$SOURCE_DIR" -name "*.md" -type f -print0 2>/dev/null | \
        while IFS= read -r -d '' file; do
            if echo "$file" | grep -q "归档"; then
                continue
            fi
            url=$(grep "^source_url:" "$file" 2>/dev/null | head -1 | sed 's/source_url: *//' | tr -d '"'"'" | xargs)
            if [ -n "$url" ]; then
                echo "$url|$file"
            fi
        done | sort | uniq -d > "$temp_file"

    # 输出重复文件
    if [ -s "$temp_file" ]; then
        cat "$temp_file"
    fi

    rm -f "$temp_file"
}

# 移动文件到备份
move_to_backup() {
    local file=$1
    local reason=$2

    if [ "$DRY_RUN" = "true" ]; then
        echo "[DRY-RUN] 将移动: $file"
    else
        local filename=$(basename "$file")
        local target="$BACKUP_DIR/${reason}_${filename}"
        mv "$file" "$target"
        log_info "已移动: $filename"
    fi
}

# 主清理流程
main_cleanup() {
    check_directory
    create_backup
    init_report

    local original_count=$(count_files)
    local removed_count=0
    local duplicate_count=0
    local untitled_count=0

    echo ""
    log_step "开始清理..."
    echo ""

    # 处理无标题文件
    local untitled_files=$(find_untitled)
    if [ -n "$untitled_files" ]; then
        echo "$untitled_files" | while IFS= read -r file; do
            if [ -f "$file" ]; then
                move_to_backup "$file" "untitled"
                ((untitled_count++))
                ((removed_count++))
            fi
        done
    fi

    # 处理重复文件（保留非时间戳版本）
    # 这里需要更复杂的逻辑来识别哪一个是"规范"版本

    # 生成报告
    {
        echo "| 指标 | 数量 |"
        echo "|------|------|"
        echo "| 原始文件数 | $original_count |"
        echo "| 清理文件数 | $removed_count |"
        echo "| 清理后数量 | $((original_count - removed_count)) |"
        echo "| 清理比例 | $(echo "scale=1; $removed_count * 100 / $original_count" | bc)% |"
        echo ""
        echo "## 备份位置"
        echo ""
        echo "\`$BACKUP_DIR\`"
        echo ""
        echo "## 后续建议"
        echo ""
        echo "1. 检查备份目录确认无误后可删除"
        echo "2. 更新索引文件"
        echo "3. 检查元数据缺失的文件"
    } >> "$REPORT_FILE"

    echo ""
    log_info "清理完成！"
    echo ""
    echo "📊 清理统计:"
    echo "  原始文件: $original_count"
    echo "  清理文件: $removed_count"
    echo "  清理比例: $(echo "scale=1; $removed_count * 100 / $original_count" | bc)%"
    echo ""
    echo "📁 备份位置: $BACKUP_DIR"
    echo "📄 报告文件: $REPORT_FILE"
}

# 执行
main_cleanup
