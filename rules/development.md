---
name: development
preamble-tier: 2
version: 0.1.0
description: |
  开发工作流：功能规划 → 代码实现 → 代码审查 → 会话评估 → 架构学习。
  Use when asked to: "规划", "设计", "写代码", "review", "重构", "debug",
  "代码审查", "功能开发", "评估会话", "怎么设计", "架构".
  Proactively suggest when: 用户开始新项目、需要审查代码、或遇到 bug。
allowed-tools:
  - Bash
  - Read
  - Write
  - Edit
  - Glob
  - Grep
  - AskUserQuestion
benefits-from: [content-creation]
workflow:
  suggest: [evaluate-session]
---

# 开发专家

## 触发器

**一旦**出现以下信号，**务必**激活此专家：

| 信号 | 示例 |
|------|------|
| 功能规划 | "帮我规划", "怎么设计", "技术方案", "需求分析" |
| 代码实现 | "写代码", "实现这个", "开发" |
| 代码审查 | "review", "代码审查", "检查代码" |
| 调试 | "debug", "报错了", "为什么不行", "fix" |
| 会话评估 | "评估", "这次做得怎么样", "/evaluate" |

## 工作流

### Step 1: 识别开发阶段

```
用户请求
    │
    ├── 规划阶段 → /plan-feature
    ├── 实现阶段 → 直接编码
    ├── 审查阶段 → /code-review
    ├── 调试阶段 → gstack /investigate
    └── 评估阶段 → /evaluate-session
```

### Step 2: 脚本开发规则

**必须遵循**：

| 场景 | 避免 | 推荐 |
|------|------|------|
| 多行内容写入文件 | `sed` 替换占位符 | heredoc 直接写入 |
| 复杂文本处理 | 多层 `sed` 管道 | `awk` |
| 日志输出 | 输出到 stdout | 输出到 stderr (`>&2`) |

**macOS 特有**：
- 扩展属性阻止脚本执行：`xattr -cr <file>`
- `sed -i` 语法：macOS 用 `sed -i ''`，Linux 用 `sed -i`
- Python fcntl 文件锁防止多实例竞争

**推荐模式**：
```bash
# 结构化文档生成（不污染输出）
{
    echo "# 标题"
    echo
    # 动态内容...
} > "$OUTPUT_FILE"

# 日志函数（输出到 stderr）
log_info() { echo -e "${GREEN}[INFO]${NC} $1" >&2; }
```

### Step 3: 代码审查规则

- 从多维度分析：正确性、安全性、性能、可维护性
- 按影响级别排序问题
- 提供具体可操作的改进建议
- 不要只说"这里有问题"，要说"改成这样"

### Step 4: 会话评估

六维度评估框架：
1. **Spec Stability** (25%) - 需求稳定性
2. **First-Attempt Accuracy** (25%) - 首次执行准确性
3. **Feedback Sentiment** (20%) - 反馈情感倾向
4. **Autonomy Level** (15%) - 自主工作能力
5. **Completion Quality** (15%) - 完成质量

红旗警示：
- 忽略明确指令：-20分
- 重复相同错误：-15分
- wrong path 纠正：-10分
- 需要重做大量工作：-25分

## 管辖的技能

| 技能 | 用途 | 触发 |
|------|------|------|
| /plan-feature | 功能规划 | 新功能开发、复杂任务规划 |
| /code-review | 代码审查 | PR review、代码质量检查 |
| /evaluate-session | 会话评估 | 会话总结、改进识别 |
| agent-architecture-learning | 架构学习 | 理解 Agent 设计模式 |

## 常见错误

| 错误 | 正确做法 |
|------|----------|
| 用 sed 做多行替换 | 用 heredoc 或 awk |
| macOS 上用 Linux sed 语法 | 用 `sed -i ''` |
| 日志输出到 stdout | 输出到 stderr (`>&2`) |
| 直接修复不明原因的 bug | 先调查根因再修复 |

## 与其他专家的关系

| 关系 | 专家 |
|------|------|
| **协作** | information-processing（技术概念理解辅助开发） |
| **协作** | content-creation（技术文档写作） |
| **参考** | gstack 的 /investigate（系统性调试方法论） |
