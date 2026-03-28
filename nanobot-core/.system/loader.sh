#!/bin/bash
# Nanobot 工作区加载器

WORKSPACE="$HOME/claude-code-workspace/nanobot-core"

echo "🤖 Nanobot Core 工作区"
echo
echo "📍 位置: $WORKSPACE"
echo "📋 模式: 独立项目 / 直接执行"
echo
echo "🔧 加载中..."
sleep 0.5

# 创建会话上下文
cat > "$WORKSPACE/context/session.md" <<EOF
# 会话上下文

**开始时间**: $(date '+%Y-%m-%d %H:%M:%S')
**工作区**: $WORKSPACE
**模式**: 直接执行

## 当前状态

- 原则已加载
- 无审批模式
- agent-reach 优先

EOF

echo "✅ 工作区已就绪"
echo
echo "📖 项目结构:"
tree -L 2 "$WORKSPACE" 2>/dev/null || find "$WORKSPACE" -type f -name "*.md" | head -10
echo
echo "⚡ 执行协议: 直接执行 → 返回结果"
