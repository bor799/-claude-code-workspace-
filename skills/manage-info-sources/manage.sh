#!/bin/bash
# 信息源管理脚本 - 清理和整理 Obsidian 信息源目录
# 创建日期: 2026-03-07
# 版本: v2.0.0 - 支持多目录和知识库管理
# 工作流: 先清理 → 再整理 → 生成看板

set -euo pipefail

# =====================================================
# 配置
# =====================================================

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIG_FILE="${SCRIPT_DIR}/config/directories.yaml"

# Vault 根目录（用于 Dataview 路径计算）
VAULT_ROOT="/Users/murphy/Documents/Obsidian Vault"

# 默认目录（向后兼容）
SOURCE_DIR="/Users/murphy/Documents/Obsidian Vault/信息源"
BACKUP_DIR="${SOURCE_DIR}/归档/清理备份_$(date +%Y%m%d_%H%M%S)"
LOG_FILE="${SOURCE_DIR}/management_log.txt"

# 标准分类
CATEGORIES=("商业" "技术" "投资" "推特" "播客" "文章" "访谈")

# v2 新增：目录类型
DIR_TYPE="info_source"  # "info_source" 或 "knowledge_base"
PRESERVE_STRUCTURE=false
ADD_METADATA=false

# 颜色输出
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# =====================================================
# 日志函数
# =====================================================

log_info() {
    echo -e "${GREEN}[INFO]${NC} $1" | tee -a "$LOG_FILE"
}

log_warn() {
    echo -e "${YELLOW}[WARN]${NC} $1" | tee -a "$LOG_FILE"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1" | tee -a "$LOG_FILE"
}

log_step() {
    echo -e "${BLUE}[STEP]${NC} $1" | tee -a "$LOG_FILE"
}

# =====================================================
# v2.0.0 新增：配置和目录管理
# =====================================================

# 读取配置文件
read_config() {
    if [ ! -f "$CONFIG_FILE" ]; then
        log_warn "配置文件不存在: $CONFIG_FILE，使用默认配置"
        return 1
    fi

    log_info "读取配置文件: $CONFIG_FILE"
    # 简单解析 YAML（仅支持基本格式）
    # 生产环境建议使用 yq 工具
    source <(grep -E '^[[:space:]]*(name|path|type|has_metadata|preserve_structure|add_metadata):' "$CONFIG_FILE" | sed 's/^[[:space:]]*//')
}

# 设置当前工作目录
set_target_directory() {
    local target_name=${1:-"信息源"}

    if [ -f "$CONFIG_FILE" ]; then
        # 从配置文件读取（支持带引号和不带引号的 name）
        while IFS= read -r line; do
            if [[ "$line" =~ name:[[:space:]]*\"?$target_name\"? ]]; then
                SOURCE_DIR=$(grep -A 1 "name:.*$target_name" "$CONFIG_FILE" | grep "path:" | sed 's/.*path: *"\(.*\)".*/\1/' | sed 's/.*path: *\(.*\)/\1/')
                DIR_TYPE=$(grep -A 3 "name:.*$target_name" "$CONFIG_FILE" | grep "type:" | sed 's/.*type: *\(.*\)/\1/')
                PRESERVE_STRUCTURE=$(grep -A 4 "name:.*$target_name" "$CONFIG_FILE" | grep "preserve_structure:" | sed 's/.*preserve_structure: *\(.*\)/\1/')
                ADD_METADATA=$(grep -A 5 "name:.*$target_name" "$CONFIG_FILE" | grep "add_metadata:" | sed 's/.*add_metadata: *\(.*\)/\1/')

                # 转换布尔值
                [ "$PRESERVE_STRUCTURE" = "true" ] && PRESERVE_STRUCTURE=true || PRESERVE_STRUCTURE=false
                [ "$ADD_METADATA" = "true" ] && ADD_METADATA=true || ADD_METADATA=false

                BACKUP_DIR="${SOURCE_DIR}/归档/清理备份_$(date +%Y%m%d_%H%M%S)"
                LOG_FILE="${SOURCE_DIR}/management_log.txt"

                log_info "目标目录: $SOURCE_DIR (类型: $DIR_TYPE)"
                return 0
            fi
        done < "$CONFIG_FILE"
    fi

    log_warn "未找到目录配置: $target_name，使用默认"
    return 1
}

# =====================================================
# v2.0.0 新增：元数据推断（知识库模式）
# =====================================================

# 推断文档类型
infer_doc_type() {
    local filename=$1
    local dirname=$(dirname "$filename")

    # 从文件名推断
    case "$(basename "$filename" | tr '[:upper:]' '[:lower:]')" in
        *readme*|*说明*|*文档*|*指南*)
            echo "文档"
            return
            ;;
        *设计*|*架构*|*方案*|*规格*)
            echo "设计"
            return
            ;;
        *分析*|*报告*|*研究*)
            echo "报告"
            return
            ;;
        *配置*|*config*|*setting*)
            echo "配置"
            return
            ;;
    esac

    # 从目录名推断
    local dir_basename=$(basename "$dirname")
    case "$dir_basename" in
        *实践*|*项目*|*案例*)
            echo "项目"
            return
            ;;
        *概念*|*基础*|*入门*|*笔记*)
            echo "笔记"
            return
            ;;
        *思考*|*沉淀*|*总结*)
            echo "总结"
            return
            ;;
    esac

    # 默认
    echo "文档"
}

# 推断二级分类
infer_subcategory() {
    local file=$1
    local relative_path="${file#$SOURCE_DIR/}"

    # 获取目录深度
    local depth=$(echo "$relative_path" | tr -cd '/' | wc -c | tr -d ' ')

    # 如果在周目录下，需要调整
    if [[ "$(echo "$relative_path" | cut -d'/' -f1)" =~ ^[0-9]{4}-[0-9]{2}-W[0-9]+$ ]]; then
        # 二级分类在周目录下是第3级
        if [ $depth -ge 2 ]; then
            echo "$relative_path" | cut -d'/' -f3
        fi
    else
        # 二级分类是第2级
        if [ $depth -ge 1 ]; then
            echo "$relative_path" | cut -d'/' -f2
        fi
    fi
}

# 添加元数据到文件（知识库模式）
add_metadata_to_file() {
    local file=$1

    # 检查是否已有 frontmatter
    if head -5 "$file" | grep -q "^---"; then
        return 0
    fi

    # 推断元数据
    local title=$(basename "$file" .md)
    local category=$(infer_category "$file")
    local subcategory=$(infer_subcategory "$file")
    local doc_type=$(infer_doc_type "$file")
    local created=$(stat -f "%Sm" -t "%Y-%m-%d" "$file" 2>/dev/null || stat -c "%y" "$file" 2>/dev/null | cut -d'.' -f1)

    # 创建临时文件
    local tmp_file="${file}.tmp"

    {
        echo "---"
        echo "title: $title"
        echo "category: $category"
        [ -n "$subcategory" ] && echo "subcategory: $subcategory"
        echo "type: $doc_type"
        echo "created: $created"
        echo "tags: []"
        echo "status: 进行中"
        echo "---"
        echo ""
        cat "$file"
    } > "$tmp_file"

    mv "$tmp_file" "$file"
    log_info "已添加元数据: $file"
}

# 批量添加元数据
batch_add_metadata() {
    log_step "=== 批量添加元数据（知识库模式）==="

    local count=0
    local skipped=0

    while IFS= read -r -d '' file; do
        # 跳过看板文件
        if [[ "$(basename "$file")" == "📊"* ]]; then
            ((skipped++))
            continue
        fi

        # 检查是否已有 frontmatter
        if ! head -5 "$file" | grep -q "^---"; then
            add_metadata_to_file "$file"
            ((count++))
        else
            ((skipped++))
        fi
    done < <(find "$SOURCE_DIR" -name "*.md" -type f -print0)

    log_info "已添加元数据: $count 个文件，跳过: $skipped 个文件"
}

# =====================================================
# v2.0.0 新增：知识库看板生成
# =====================================================

# 生成知识库总看板
generate_knowledge_base_dashboard() {
    log_step "=== 生成知识库看板 ==="

    local dashboard_file="$SOURCE_DIR/📊 知识库看板.md"
    local dir_name=$(basename "$SOURCE_DIR")

    cat > "$dashboard_file" <<EOF
# 📊 ${dir_name}看板

> 自动生成时间: $(date '+%Y-%m-%d %H:%M:%S')
> 自动更新：每次打开文件时重新计算

---

## 📈 统计概览

\`\`\`dataview
TABLE WITHOUT ID
    "<b>" + count(rows) + "</b>" as "总文档数",
    length(filter(rows, (r) => r.status = "进行中")) as "进行中",
    length(filter(rows, (r) => r.status = "已完成")) as "已完成"
FROM "${dir_name}"
\`\`\`

---

## 📋 按主题统计

\`\`\`dataview
TABLE WITHOUT ID
    category as "主题",
    count(rows) as "文档数"
FROM "${dir_name}"
WHERE category
GROUP BY category
SORT count(rows) DESC
\`\`\`

---

## 🗂️ 按类型分类

\`\`\`dataview
TABLE WITHOUT ID
    type as "类型",
    count(rows) as "文档数"
FROM "${dir_name}"
WHERE type
GROUP BY type
SORT count(rows) DESC
\`\`\`

---

## 📄 最新文档

\`\`\`dataview
TABLE file.link as "标题", type as "类型", category as "主题", created as "创建时间"
FROM "${dir_name}"
SORT created DESC
LIMIT 30
\`\`\`

---

## 📂 按主题浏览

EOF

    # 动态生成主题列表
    find "$SOURCE_DIR" -maxdepth 1 -type d ! -name ".*" ! -name "归档" ! -name "$(basename "$SOURCE_DIR")" | while read dir; do
        local name=$(basename "$dir")
        echo "- [[$name]]" >> "$dashboard_file"
    done

    {
        echo ""
        echo "---"
        echo ""
        echo "*💡 此文件由管理脚本自动生成，请勿手动编辑*"
    } >> "$dashboard_file"

    log_info "已生成: $dashboard_file"
}

# 生成主题看板
generate_topic_dashboard() {
    local topic=$1
    local topic_dir=$2

    local dashboard_file="$topic_dir/📊 ${topic}看板.md"
    local dir_name=$(basename "$SOURCE_DIR")

    cat > "$dashboard_file" <<EOF
# 📊 ${topic}看板

> 自动生成时间: $(date '+%Y-%m-%d %H:%M:%S')

---

## 📈 统计

\`\`\`dataview
TABLE WITHOUT ID
    "<b>" + count(rows) + "</b>" as "总文档数",
    length(filter(rows, (r) => r.status = "进行中")) as "进行中",
    length(filter(rows, (r) => r.status = "已完成")) as "已完成"
FROM "${dir_name}/${topic}"
\`\`\`

---

## 📄 文档列表

\`\`\`dataview
TABLE file.link as "标题", type as "类型", created as "创建时间"
FROM "${dir_name}/${topic}"
SORT created DESC
\`\`\`

---

*💡 此文件由管理脚本自动生成*
EOF

    log_info "已生成: $dashboard_file"
}

# 生成所有主题看板
generate_all_topic_dashboards() {
    log_step "=== 生成所有主题看板 ==="

    find "$SOURCE_DIR" -maxdepth 1 -type d ! -name ".*" ! -name "归档" ! -name "$(basename "$SOURCE_DIR")" | while read dir; do
        local topic=$(basename "$dir")
        generate_topic_dashboard "$topic" "$dir"
    done
}

# =====================================================
# 工具函数
# =====================================================

# 获取最新的周目录
get_current_week_dir() {
    local latest_week=$(ls -dt "$SOURCE_DIR"/20*-W* 2>/dev/null | head -1)
    if [ -z "$latest_week" ]; then
        log_error "未找到周目录，请手动指定"
        return 1
    fi
    echo "$latest_week"
}

# 创建备份目录
create_backup() {
    if [ ! -d "$BACKUP_DIR" ]; then
        log_info "创建备份目录: $BACKUP_DIR"
        mkdir -p "$BACKUP_DIR"
    else
        log_info "备份目录已存在: $BACKUP_DIR"
    fi
}

# =====================================================
# 阶段一：清理功能
# =====================================================

# 删除测试文件
remove_test_files() {
    log_step "=== 删除测试文件 ==="

    # 更精确的测试文件匹配模式
    # 只匹配明确的测试文件，避免误删正常文件
    find "$SOURCE_DIR" -type f \( \
        -name "*无标题*.md" -o \
        -name "*_no-title.md" -o \
        -name "*_[no-title].md" -o \
        -name "Untitled*.md" \
    \) ! -path "*/归档/*" 2>/dev/null | while read file; do
        log_warn "发现测试文件: $file"
        local backup_path="$BACKUP_DIR/test_files/$(basename "$file")"
        mkdir -p "$(dirname "$backup_path")"
        mv "$file" "$backup_path" 2>/dev/null && log_info "已移动到备份: $backup_path"
    done
}

# 处理重复的 source_url
handle_duplicate_urls() {
    log_step "=== 处理重复的 source_url ==="

    # 使用临时文件存储 URL 映射（兼容 bash 3.2）
    local url_map_file=$(mktemp)

    # 第一遍：收集所有 URL 和对应的文件
    while IFS= read -r -d '' file; do
        while IFS= read -r url; do
            if [ -n "$url" ]; then
                # 检查是否已存在此 URL
                if grep -q "^$url|" "$url_map_file" 2>/dev/null; then
                    # 发现重复
                    local existing_file=$(grep "^$url|" "$url_map_file" | cut -d'|' -f2)
                    log_warn "重复 URL: $url"
                    log_info "  保留: $existing_file"
                    log_info "  删除: $file"

                    local backup_path="$BACKUP_DIR/duplicates/$(basename "$file")"
                    mkdir -p "$(dirname "$backup_path")"
                    mv "$file" "$backup_path" 2>/dev/null
                else
                    # 记录新 URL
                    echo "$url|$file" >> "$url_map_file"
                fi
            fi
        done < <(grep "^source_url:" "$file" 2>/dev/null | sed 's/source_url: *//' | tr -d '"' | tr -d "'" | tr -d ' ')
    done < <(find "$SOURCE_DIR" -name "*.md" -type f -print0)

    rm -f "$url_map_file"
}

# 处理重复的 title
handle_duplicate_titles() {
    log_step "=== 处理重复的 title ==="

    # 使用临时文件存储 title 映射（兼容 bash 3.2）
    local title_map_file=$(mktemp)

    while IFS= read -r -d '' file; do
        local title=$(grep "^title:" "$file" 2>/dev/null | sed 's/title: *//' | tr -d '"' | tr -d "'" | head -1)
        if [ -n "$title" ]; then
            # 检查是否已存在此 title
            if grep -q "^$title|" "$title_map_file" 2>/dev/null; then
                local existing_file=$(grep "^$title|" "$title_map_file" | cut -d'|' -f2)
                log_warn "重复标题: $title"
                log_info "  保留: $existing_file"
                log_info "  重复: $file"
            else
                # 记录新 title
                echo "$title|$file" >> "$title_map_file"
            fi
        fi
    done < <(find "$SOURCE_DIR" -name "*.md" -type f -print0)

    rm -f "$title_map_file"
}

# 检查缺少元数据的文件
check_metadata() {
    log_step "=== 检查缺少元数据的文件 ==="

    local week_dir=$(get_current_week_dir)
    [ $? -ne 0 ] && return 1

    while IFS= read -r -d '' file; do
        local missing=()
        ! grep -q "^source_url:" "$file" 2>/dev/null && missing+=("source_url")
        ! grep -q "^title:" "$file" 2>/dev/null && missing+=("title")
        ! grep -q "^category:" "$file" 2>/dev/null && missing+=("category")

        if [ ${#missing[@]} -gt 0 ]; then
            log_warn "缺少元数据 [${missing[*]}]: $file"
        fi
    done < <(find "$week_dir" -name "*.md" -type f -print0)
}

# =====================================================
# 阶段二：整理功能
# =====================================================

# 统一元数据 (rating → score)
unify_metadata() {
    log_step "=== 统一元数据 (rating → score) ==="

    local week_dir=$(get_current_week_dir)
    [ $? -ne 0 ] && return 1

    local count=0
    while IFS= read -r -d '' file; do
        if grep -q "^rating:" "$file" 2>/dev/null; then
            # 使用 sed 替换（macOS 兼容）
            sed -i '' 's/^rating:/score:/' "$file"
            ((count++))
        fi
    done < <(find "$week_dir" -name "*.md" -type f -print0)

    log_info "已统一 $count 个文件的元数据"
}

# 分类模式变量
CATEGORIZE_MODE="auto"  # "auto" (自动提取) 或 "structure" (现有结构)

# 智能分类推断 - 模式一：自动从 tags/title 提取
infer_category_from_content() {
    local file=$1
    local tags=$(grep "^tags:" "$file" 2>/dev/null | sed 's/tags: *//' | tr -d '"' | tr -d "'" | tr ',' ' ')
    local title=$(grep "^title:" "$file" 2>/dev/null | sed 's/title: *//' | tr -d '"' | tr -d "'")
    local content=$(cat "$file" 2>/dev/null)

    # 组合所有可用的文本信息
    local all_text="$tags $title $content"

    # 按优先级匹配分类
    case "$all_text" in
        *twitter.com*|*x.com*|*推特*|*Tweet*)
            echo "推特"
            ;;
        *podcast*|*播客*|*对话*|*Podcast*)
            echo "播客"
            ;;
        *interview*|*访谈*|*Interview*)
            echo "访谈"
            ;;
        *股票*|*投资*|*财报*|*港股*|*A股*|*美股*|*基金*|*证券*)
            echo "投资"
            ;;
        *产品*|*商业*|*创业*|*Business*|*Product*|*Startup*)
            echo "商业"
            ;;
        *AI*|*Claude*|*编程*|*Agent*|*工程*|*代码*|*开发*|*技术*|*Tech*|*LLM*|*GPT*)
            echo "技术"
            ;;
        *article*|*微信文章*|*文章*)
            echo "文章"
            ;;
        *)
            # 默认分类
            echo "文章"
            ;;
    esac
}

# 智能分类推断 - 模式二：根据现有目录结构
infer_category_from_structure() {
    local file=$1
    local current_dir=$(dirname "$file")

    # 知识库模式：从目录结构直接提取分类
    if [ "$DIR_TYPE" = "knowledge_base" ]; then
        # 计算相对路径（从 SOURCE_DIR 开始）
        local relative_path="${current_dir#$SOURCE_DIR/}"
        # 提取第一级目录作为分类
        local category=$(echo "$relative_path" | cut -d'/' -f1)
        if [ -n "$category" ] && [ "$category" != "$current_dir" ]; then
            echo "$category"
            return
        fi
    fi

    # 信息源模式：检查文件当前所在目录是否匹配标准分类
    for category in "${CATEGORIES[@]}"; do
        if [[ "$current_dir" == *"$category"* ]]; then
            echo "$category"
            return
        fi
    done

    # 如果当前目录没有明确分类，尝试从内容推断
    infer_category_from_content "$file"
}

# 统一的分类推断入口
infer_category() {
    local file=$1
    local mode="${CATEGORIZE_MODE:-auto}"

    # 知识库模式：优先使用目录结构
    if [ "$DIR_TYPE" = "knowledge_base" ]; then
        infer_category_from_structure "$file"
        return
    fi

    # 信息源模式：根据 CATEGORIZE_MODE 选择
    if [ "$mode" = "structure" ]; then
        infer_category_from_structure "$file"
    else
        infer_category_from_content "$file"
    fi
}

# 整理分类文件
organize_categories() {
    log_step "=== 整理分类文件 ==="

    local week_dir=$(get_current_week_dir)
    [ $? -ne 0 ] && return 1

    local moved=0
    local skipped=0

    # 确保所有分类目录存在
    for category in "${CATEGORIES[@]}"; do
        mkdir -p "$week_dir/$category"
    done

    # 处理所有未分类的文件（在根目录下且没有 category 元数据的）
    while IFS= read -r -d '' file; do
        local dirname=$(dirname "$file")
        local basename=$(basename "$file")

        # 跳过已分类的文件（在分类目录中）
        local is_categorized=false
        for category in "${CATEGORIES[@]}"; do
            if [[ "$dirname" == *"$category"* ]]; then
                is_categorized=true
                break
            fi
        done

        if [ "$is_categorized" = true ]; then
            ((skipped++))
            continue
        fi

        # 跳过看板文件
        if [[ "$basename" == "📊"* ]]; then
            ((skipped++))
            continue
        fi

        # 推断分类
        local category=$(infer_category "$file")

        # 移动文件
        local target_dir="$week_dir/$category"
        local target_file="$target_dir/$basename"

        if [ "$file" != "$target_file" ]; then
            mv "$file" "$target_file" 2>/dev/null && {
                log_info "移动: $basename → $category"
                ((moved++))
            }

            # 更新文件中的 category 元数据
            if [ -f "$target_file" ]; then
                if grep -q "^category:" "$target_file" 2>/dev/null; then
                    sed -i '' "s/^category:.*/category: $category/" "$target_file"
                else
                    # 在 frontmatter 中添加 category
                    sed -i '' "/^---/a\\
category: $category
" "$target_file" 2>/dev/null || true
                fi
            fi
        fi
    done < <(find "$week_dir" -maxdepth 1 -name "*.md" -type f -print0)

    log_info "移动了 $moved 个文件，跳过 $skipped 个已分类文件"
}

# =====================================================
# 阶段三：看板生成
# =====================================================

# 生成单个分类看板
generate_dashboard() {
    local category=$1
    local category_dir=$2
    local output_file=$3

    # 计算相对路径（用于 Dataview 查询）
    # 需要从 vault 根目录开始计算，而不是 SOURCE_DIR
    local relative_path="${category_dir#$VAULT_ROOT/}"

    cat > "$output_file" <<EOF
# 📊 ${category}看板

> 自动生成时间: $(date '+%Y-%m-%d %H:%M:%S')
> 自动更新：每次打开文件时重新计算

---

## 📈 本周统计

> 总文章数: \`$(
    find "$category_dir" -name "*.md" -type f ! -name "📊*" | wc -l | tr -d ' '
)\` | 未读: \`$(
    grep -l "status: 未读" "$category_dir"/*.md 2>/dev/null | wc -l | tr -d ' '
)\` | 已读: \`$(
    grep -l "status: 已读" "$category_dir"/*.md 2>/dev/null | wc -l | tr -d ' '
)\`

---

## 📋 未读列表

\`\`\`dataview
TABLE file.link as "标题", score as "评分", date as "日期"
FROM "${relative_path}"
WHERE status = "未读"
SORT score DESC
\`\`\`

---

## ⭐ 高分内容 (8分以上)

\`\`\`dataview
TABLE file.link as "标题", score as "评分", status as "状态"
FROM "${relative_path}"
WHERE score >= 8
SORT score DESC
\`\`\`

---

## ✅ 已读归档

\`\`\`dataview
TABLE file.link as "标题", score as "评分"
FROM "${relative_path}"
WHERE status = "已读"
SORT score DESC
\`\`\`

---

*💡 此文件由管理脚本自动生成，请勿手动编辑*
EOF
}

# 生成所有分类看板
generate_category_dashboards() {
    log_step "=== 生成分类看板 ==="

    local week_dir=$(get_current_week_dir)
    [ $? -ne 0 ] && return 1

    for category in "${CATEGORIES[@]}"; do
        local category_dir="$week_dir/$category"
        local dashboard_file="$category_dir/📊 ${category}看板.md"

        if [ -d "$category_dir" ]; then
            generate_dashboard "$category" "$category_dir" "$dashboard_file"
            log_info "已生成: $dashboard_file"
        else
            log_warn "分类目录不存在: $category_dir"
        fi
    done
}

# 生成本周总看板
generate_weekly_dashboard() {
    log_step "=== 生成本周总看板 ==="

    local week_dir=$(get_current_week_dir)
    [ $? -ne 0 ] && return 1

    local week_name=$(basename "$week_dir")
    local dashboard_file="$week_dir/📊 本周概览.md"

    # 计算相对路径（用于 Dataview 查询）
    local week_path="${week_dir#$VAULT_ROOT/}"

    cat > "$dashboard_file" <<EOF
# 📊 本周概览 (${week_name})

> 自动生成时间: $(date '+%Y-%m-%d %H:%M:%S')
> 自动更新：每次打开文件时重新计算

---

## 📈 本周统计

> 总文章数: \`$(
    find "$week_dir" -name "*.md" -type f ! -name "📊*" | wc -l | tr -d ' '
)\` | 未读: \`$(
    grep -rl "status: 未读" "$week_dir"/*/*.md 2>/dev/null | wc -l | tr -d ' '
)\` | 已读: \`$(
    grep -rl "status: 已读" "$week_dir"/*/*.md 2>/dev/null | wc -l | tr -d ' '
)\`

---

## 📋 按分类统计

\`\`\`dataview
TABLE WITHOUT ID
    category as "分类",
    count(rows) as "数量"
FROM "${week_path}"
WHERE category
GROUP BY category
\`\`\`

---

## 🔥 本周高分 Top 10

\`\`\`dataview
TABLE file.link as "标题", category as "分类", score as "评分"
FROM "${week_path}"
SORT score DESC
LIMIT 10
\`\`\`

---

## 📂 快速导航

- [[商业/📊 商业看板|📊 商业]]
- [[技术/📊 技术看板|📊 技术]]
- [[投资/📊 投资看板|📊 投资]]
- [[推特/📊 推特看板|📊 推特]]
- [[播客/📊 播客看板|📊 播客]]
- [[文章/📊 文章看板|📊 文章]]
- [[访谈/📊 访谈看板|📊 访谈]]

---

*💡 此文件由管理脚本自动生成*
EOF

    log_info "已生成: $dashboard_file"
}

# 生成整体知识库看板
generate_main_dashboard() {
    log_step "=== 生成整体知识库看板 ==="

    local dashboard_file="$SOURCE_DIR/📊 知识库看板.md"
    local dir_name=$(basename "$SOURCE_DIR")

    cat > "$dashboard_file" <<EOF
# 📊 ${dir_name}知识库看板

> 自动更新：每次打开文件时重新计算
> 依赖插件：Dataview

---

## 📚 全库概览

> 总文章数: \`$(find "$SOURCE_DIR" -name "*.md" -type f ! -name "📊*" | wc -l | tr -d ' ' )\`

---

## 📋 按分类统计

\`\`\`dataview
TABLE WITHOUT ID
    category as "分类",
    count(rows) as "文章数"
FROM "${dir_name}"
WHERE category
GROUP BY category
SORT count(rows) DESC
\`\`\`

---

## 📅 按周统计

\`\`\`dataview
TABLE WITHOUT ID
    week as "周",
    count(rows) as "文章数"
FROM "${dir_name}"
WHERE week
GROUP BY week
SORT week DESC
\`\`\`

---

## ⭐ 全库高分 Top 20

\`\`\`dataview
TABLE file.link as "标题", category as "分类", score as "评分", status as "状态"
FROM "${dir_name}"
WHERE score >= 9
SORT score DESC
LIMIT 20
\`\`\`

---

*💡 此文件由管理脚本自动生成*
EOF

    log_info "已生成: $dashboard_file"
}

# 生成所有看板
generate_all_dashboards() {
    log_info "=== 开始生成看板系统 ==="
    echo ""

    generate_main_dashboard
    generate_weekly_dashboard
    generate_category_dashboards

    echo ""
    log_info "=== 看板系统生成完成 ==="
}

# =====================================================
# 报告生成
# =====================================================

generate_report() {
    log_step "=== 生成管理报告 ==="

    local report_file="$SOURCE_DIR/management_report.md"
    local week_dir=$(get_current_week_dir)

    {
        echo "# 信息源管理报告"
        echo ""
        echo "**生成时间**: $(date '+%Y-%m-%d %H:%M:%S')"
        echo ""
        echo "## 清理统计"
        echo ""
        echo "- 备份位置: $BACKUP_DIR"
        echo "- 测试文件清理: $(find "$BACKUP_DIR/test_files" -name "*.md" 2>/dev/null | wc -l | tr -d ' ')"
        echo "- 重复文件清理: $(find "$BACKUP_DIR/duplicates" -name "*.md" 2>/dev/null | wc -l | tr -d ' ')"
        echo ""
        echo "## 分类统计"
        echo ""

        if [ -d "$week_dir" ]; then
            for category in "${CATEGORIES[@]}"; do
                local count=$(find "$week_dir/$category" -name "*.md" -type f 2>/dev/null | wc -l | tr -d ' ')
                echo "- **$category**: $count 个文件"
            done
        fi

        echo ""
        echo "## 待处理问题"
        echo ""
        echo "- [ ] 检查并补充缺失的 source_url"
        echo "- [ ] 检查并补充缺失的 category"
        echo "- [ ] 更新索引文件"
    } > "$report_file"

    log_info "报告已生成: $report_file"
}

# =====================================================
# 主函数
# =====================================================

show_usage() {
    cat <<EOF
信息源管理脚本 v2.0.0

用法: $0 [选项]

选项:
  --cleanup-only     仅执行清理（删除测试文件、处理重复）
  --organize-only    仅执行整理（统一元数据、智能分类/添加元数据）
  --dashboard-only   仅生成看板
  --full             完整流程（默认）
  --mode-auto        智能分类：从 tags/title 自动提取（默认，仅信息源）
  --mode-structure   智能分类：根据现有目录结构（仅信息源）
  --dir <name>       指定目标目录（信息源/兴趣领域/职业发展）
  -h, --help         显示此帮助信息

工作流: 先清理 → 再整理 → 生成看板

目录类型:
  信息源      标准分类（商业、技术、投资等），移动文件到分类目录
  兴趣领域    主题分类，保留现有结构，添加元数据
  职业发展    主题分类，保留现有结构，添加元数据

分类模式说明（仅信息源）:
  --mode-auto      根据文章的 tags 和 title 关键词自动推断分类
  --mode-structure 优先保留现有目录结构，未分类的才自动推断

示例:
  $0 --full                         # 默认：信息源目录，完整流程
  $0 --dir 兴趣领域 --organize-only # 仅整理兴趣领域（添加元数据）
  $0 --dir 职业发展 --dashboard     # 生成职业发展看板
  $0 --full --mode-auto             # 信息源，完整流程 + 自动分类
EOF
}

# 询问分类模式（如果未指定）
ask_categorize_mode() {
    if [ -t 0 ]; then  # 检查是否在交互终端中
        echo ""
        echo -e "${BLUE}请选择智能分类模式:${NC}"
        echo "  1) 自动提取 - 根据文章的 tags 和 title 关键词自动推断分类"
        echo "  2) 现有结构 - 优先保留现有目录结构，未分类的才自动推断"
        echo ""
        read -p "请输入选项 [1/2，默认 1]: " choice
        echo ""

        case "$choice" in
            2|"结构"|"structure")
                CATEGORIZE_MODE="structure"
                log_info "已选择分类模式: 现有结构优先"
                ;;
            *|"1"|"自动"|"auto"|"")
                CATEGORIZE_MODE="auto"
                log_info "已选择分类模式: 自动提取"
                ;;
        esac
    else
        # 非交互模式，使用默认
        CATEGORIZE_MODE="auto"
        log_info "非交互模式，使用默认分类模式: 自动提取"
    fi
}

main() {
    local mode="full"
    local categorize_mode_set=false
    local target_dir="信息源"

    # 解析参数
    while [[ $# -gt 0 ]]; do
        case $1 in
            --cleanup-only)
                mode="cleanup"
                shift
                ;;
            --organize-only)
                mode="organize"
                shift
                ;;
            --dashboard-only|--dashboard)
                mode="dashboard"
                shift
                ;;
            --full)
                mode="full"
                shift
                ;;
            --mode-auto)
                CATEGORIZE_MODE="auto"
                categorize_mode_set=true
                shift
                ;;
            --mode-structure)
                CATEGORIZE_MODE="structure"
                categorize_mode_set=true
                shift
                ;;
            --dir)
                target_dir="$2"
                shift 2
                ;;
            -h|--help)
                show_usage
                exit 0
                ;;
            *)
                echo "未知选项: $1"
                show_usage
                exit 1
                ;;
        esac
    done

    # 设置目标目录
    set_target_directory "$target_dir"

    # 初始化日志
    : > "$LOG_FILE"
    log_info "信息源管理开始 - 目录: $target_dir, 类型: $DIR_TYPE, 流程: $mode"
    echo ""

    # 创建备份
    create_backup

    # 阶段一：清理（所有目录类型都支持）
    if [ "$mode" = "cleanup" ] || [ "$mode" = "full" ]; then
        log_info "=== 阶段一：清理 ==="
        echo ""
        remove_test_files
        handle_duplicate_urls
        handle_duplicate_titles
        check_metadata
        echo ""
    fi

    # 阶段二：整理
    if [ "$mode" = "organize" ] || [ "$mode" = "full" ]; then
        if [ "$DIR_TYPE" = "knowledge_base" ]; then
            # 知识库模式：添加元数据
            log_info "=== 阶段二：整理（知识库模式：添加元数据） ==="
            echo ""
            batch_add_metadata
        else
            # 信息源模式：智能分类
            # 如果没有指定分类模式，询问用户
            if [ "$categorize_mode_set" = false ] && [ -t 0 ]; then
                ask_categorize_mode
            fi
            # 确保 CATEGORIZE_MODE 有值
            : "${CATEGORIZE_MODE:=auto}"
            log_info "=== 阶段二：整理（信息源模式：分类模式: ${CATEGORIZE_MODE}) ==="
            echo ""
            unify_metadata
            organize_categories
        fi
        echo ""
    fi

    # 阶段三：看板
    if [ "$mode" = "dashboard" ] || [ "$mode" = "full" ]; then
        log_info "=== 阶段三：生成看板 ==="
        echo ""
        if [ "$DIR_TYPE" = "knowledge_base" ]; then
            generate_knowledge_base_dashboard
            generate_all_topic_dashboards
        else
            generate_all_dashboards
        fi
        echo ""
    fi

    # 生成报告
    if [ "$mode" = "full" ]; then
        generate_report
    fi

    log_info "信息源管理完成！"
    log_info "日志文件: $LOG_FILE"
}

# 执行
main "$@"
