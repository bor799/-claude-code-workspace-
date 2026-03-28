#!/bin/bash
# 100X 知识萃取系统 - Nanobot 技能
# 用法: 100x_extractor <URL>

URL="$1"

if [[ -z "$URL" ]]; then
    echo "❌ 请提供 URL"
    exit 1
fi

# 切换到 100X 目录
CD_PATH="/Users/murphy/Documents/Obsidian Vault/职业发展/项目案例/100X_知识萃取系统/knowledge-extractor"

if [[ ! -d "$CD_PATH" ]]; then
    echo "❌ 找不到 100X 知识萃取系统"
    exit 1
fi

cd "$CD_PATH"

# 调用 100X 分析单个 URL
python src/main.py --url "$URL" --no-write --verbose
