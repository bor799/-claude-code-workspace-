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

# 合并检查：分类有效性和 frontmatter 精简度（性能优化：一次遍历完成两个检查）
perform_all_checks() {
    log_step "检查分类有效性和 frontmatter 精简度..."
    local invalid_count=0
    local unsimplified_count=0
    local valid_categories="AI Agent研究解读|实践案例|技术创业|财经"
    local deprecated_attrs="status|date:|author:|priority:|created:"
    local invalid_results=""
    local unsimplified_results=""

    # 一次遍历完成所有检查
    while IFS= read -r -d '' file; do
        if [ -f "$file" ]; then
            # 检查分类
            category=$(grep "^category:" "$file" 2>/dev/null | head -1 | sed 's/category: *//' | tr -d '"'"'" | xargs)
            if [ -n "$category" ] && ! echo "$category" | grep -qE "^($valid_categories)$"; then
                invalid_results="${invalid_results}${file}|${category}"$'\n'
                ((invalid_count++))
            fi

            # 检查 frontmatter
            if grep -qE "^($deprecated_attrs):" "$file" 2>/dev/null; then
                unsimplified_results="${unsimplified_results}${file}"$'\n'
                ((unsimplified_count++))
            fi
        fi
    done < <(find "$SOURCE_DIR" -name "*.md" -type f -print0 2>/dev/null | grep -z -v "归档")

    # 输出结果（格式兼容原有调用方式）
    if [ $invalid_count -gt 0 ]; then
        echo -n "$invalid_results" | head -n -1
    fi
    echo "---"  # 分隔符
    if [ $unsimplified_count -gt 0 ]; then
        echo -n "$unsimplified_results" | head -n -1
    fi
    echo "---"  # 分隔符
    echo "$invalid_count|$unsimplified_count"
}

# 兼容性包装函数（保持向后兼容）
check_invalid_categories() {
    local result=$(perform_all_checks)
    echo "$result" | grep -A 1000 "^---" | head -n -1 | tail -n +2 | grep -v "^---"
}

check_unsimplified_frontmatter() {
    local result=$(perform_all_checks)
    echo "$result" | tail -n +2 | grep -v "^---"
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
    local invalid_category_count=0
    local unsimplified_count=0

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

    # 检查无效分类
    local invalid_categories=$(check_invalid_categories)
    if [ "$invalid_categories" != "0" ]; then
        echo ""
        log_warn "发现 $invalid_categories 个文件使用了无效的分类"
        echo "$invalid_categories" | while IFS= read -r line; do
            if [ -n "$line" ]; then
                file=$(echo "$line" | cut -d'|' -f1)
                category=$(echo "$line" | cut -d'|' -f2)
                echo "  - $file (category: $category)"
            fi
        done
    fi

    # 检查未精简的 frontmatter
    local unsimplified=$(check_unsimplified_frontmatter)
    if [ "$unsimplified" != "0" ]; then
        echo ""
        log_warn "发现 $unsimplified 个文件使用了已废弃的 frontmatter 属性"
        echo "$unsimplified" | while IFS= read -r file; do
            if [ -f "$file" ]; then
                # 找出具体是哪些属性
                deprecated=$(grep -E "^(status|date:|author:|priority:|created:):" "$file" 2>/dev/null | cut -d':' -f1 | tr '\n' ', ' | sed 's/,$//')
                echo "  - $file (包含: $deprecated)"
            fi
        done
    fi

    # 生成报告
    {
        echo "| 指标 | 数量 |"
        echo "|------|------|"
        echo "| 原始文件数 | $original_count |"
        echo "| 清理文件数 | $removed_count |"
        echo "| 清理后数量 | $((original_count - removed_count)) |"
        if [ $original_count -gt 0 ]; then
            echo "| 清理比例 | $(echo "scale=1; $removed_count * 100 / $original_count" | bc)% |"
        fi
        echo ""
        echo "## 分类验证"
        echo ""
        echo "- 无效分类文件: $invalid_categories 个"
        echo "- 未精简 frontmatter: $unsimplified 个"
        echo ""
        echo "## 备份位置"
        echo ""
        echo "\`$BACKUP_DIR\`"
        echo ""
        echo "## 后续建议"
        echo ""
        echo "1. 检查备份目录确认无误后可删除"
        echo "2. 更新索引文件"
        echo "3. 处理无效分类的文件（使用 reclassify_info_sources.py）"
        echo "4. 精简未简化的 frontmatter"
    } >> "$REPORT_FILE"

    echo ""
    log_info "清理完成！"
    echo ""
    echo "📊 清理统计:"
    echo "  原始文件: $original_count"
    echo "  清理文件: $removed_count"
    if [ $original_count -gt 0 ]; then
        echo "  清理比例: $(echo "scale=1; $removed_count * 100 / $original_count" | bc)%"
    fi
    echo ""
    echo "🔍 分类验证:"
    echo "  无效分类: $invalid_categories 个"
    echo "  未精简 frontmatter: $unsimplified 个"
    echo ""
    echo "📁 备份位置: $BACKUP_DIR"
    echo "📄 报告文件: $REPORT_FILE"
}

# 执行
main_cleanup
