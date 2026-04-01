# 开发专家快速参考卡

## 🚀 核心工作流

```
用户请求 → 识别阶段 → 选择工具 → 执行任务 → 评估结果
```

## 📋 开发阶段识别

| 阶段 | 触发词 | 工具/技能 |
|------|--------|-----------|
| **规划** | "规划", "设计", "方案" | `/plan-feature` |
| **实现** | "写代码", "实现", "开发" | 直接编码 |
| **审查** | "review", "检查" | `/code-review` |
| **调试** | "debug", "报错", "fix" | `gstack /investigate` |
| **评估** | "评估", "总结" | `/evaluate-session` |

## 💻 脚本开发黄金规则

### ✅ 推荐做法

```bash
# 1. 多行内容写入 - heredoc
cat > "$output_file" << 'EOF'
Line 1
Line 2
Line 3
EOF

# 2. 复杂文本处理 - awk
awk '/pattern/ { action }' file.txt

# 3. 结构化文档生成
{
    echo "# Title"
    echo "## Section"
} > "$OUTPUT_FILE"

# 4. 日志函数（stderr）
log_info() { echo "[INFO] $1" >&2; }
```

### ❌ 避免做法

```bash
# ❌ 多层 sed 管道
sed 's/a/b/' | sed 's/c/d/' | sed 's/e/f/'

# ❌ 日志输出到 stdout
echo "Processing..."  # 会污染文件输出

# ❌ 复杂多行替换用 sed
sed -i 's/old/new/g' file.txt  # 跨平台问题
```

## 🔧 macOS 特殊处理

```bash
# 扩展属性问题
xattr -cr <file>

# sed -i 语法差异
macOS: sed -i '' 's/old/new/' file
Linux: sed -i 's/old/new/' file

# 文件锁（Python）
import fcntl
fcntl.flock(fd, fcntl.LOCK_EX)
```

## 🎯 代码审查维度

1. **正确性** - 逻辑是否正确
2. **安全性** - 是否有漏洞
3. **性能** - 效率如何
4. **可维护性** - 代码质量

## 📊 会话评估框架

| 维度 | 权重 | 说明 |
|------|------|------|
| Spec Stability | 25% | 需求稳定性 |
| First-Attempt Accuracy | 25% | 首次执行准确性 |
| Feedback Sentiment | 20% | 反馈情感倾向 |
| Autonomy Level | 15% | 自主工作能力 |
| Completion Quality | 15% | 完成质量 |

### 红旗警示

- ❌ 忽略明确指令: -20分
- ❌ 重复相同错误: -15分
- ❌ wrong path 纠正: -10分
- ❌ 需要重做大量工作: -25分

## 🛠️ 管辖的技能

| 技能 | 用途 | 触发 |
|------|------|------|
| `/plan-feature` | 功能规划 | 新功能、复杂任务 |
| `/code-review` | 代码审查 | PR review、质量检查 |
| `/evaluate-session` | 会话评估 | 总结、改进识别 |
| `agent-architecture-learning` | 架构学习 | 理解 Agent 设计 |

## 🤝 协作关系

| 关系 | 专家 |
|------|------|
| 🤝 协作 | `information-processing` - 技术概念理解 |
| 🤝 协作 | `content-creation` - 技术文档写作 |
| 📚 参考 | `gstack /investigate` - 系统性调试 |

## 📝 常见错误速查

| 错误 | 正确做法 |
|------|----------|
| `sed` 多行替换 | 用 heredoc 或 awk |
| macOS 用 Linux sed | 用 `sed -i ''` |
| 日志 → stdout | 输出到 stderr (`>&2`) |
| 直接修复不明 bug | 先调查根因 |

---

**记住**: 直接务实，用最简单的方案，不确定就问！