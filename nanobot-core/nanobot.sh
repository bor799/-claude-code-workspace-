#!/bin/bash
# Nanobot 快速启动

case "$1" in
    load)
        cat ~/claude-code-workspace/nanobot-core/.system/principles.md
        ;;
    start)
        cd ~/claude-code-workspace/nanobot-core && ./.system/loader.sh
        ;;
    status)
        echo "📍 工作区: ~/claude-code-workspace/nanobot-core"
        echo "📋 原则: $(cat ~/claude-code-workspace/nanobot-core/.system/principles.md | wc -l) 行"
        echo "🔧 规则: $(find ~/claude-code-workspace/nanobot-core/rules -name "*.md" | wc -l) 篇"
        echo "🎨 模式: $(find ~/claude-code-workspace/nanobot-core/patterns -name "*.md" | wc -l) 种"
        ;;
    *)
        echo "用法: nanobot {load|start|status}"
        ;;
esac
