---
name: ljg-trend-research
description: |
  趋势研究助手 - 集成 last30days + 100X 系统。
  先用 last30days 扫描市场情绪和热点，再用 100X 深度萃取关键内容。
  用于投资研究、选题调研、内容创作的前置信息搜集。
version: 1.0.0
author: Murphy
---

# ljg-trend-research

趋势研究助手：广度扫描 + 深度萃取。

## 触发场景

- **投资研究前**：了解市场对某公司/行业的情绪
- **选题调研**：发现当前热点和讨论趋势
- **内容创作**：找到社区验证过的最佳实践
- **竞品分析**：监控竞品动态和用户反馈

## 工作流

```
话题输入
    ↓
last30days 扫描（广度）
    ↓
筛选高价值内容（评分）
    ↓
100X 深度萃取（深度）
    ↓
结构化输出（知识库）
```

## 使用方法

### 快速测试（推荐先运行）

```bash
# 测试单个话题（约 1-3 分钟）
python3 ~/.ljg-trend-research/quick_test.py
```

### 自动定时运行（推荐）

**每天凌晨4点自动生成日报：**

```bash
# 管理定时任务
cd ~/claude-code-workspace/shared/skills/ljg-trend-research

# 快速测试（单个话题，推荐先运行）
python3 ~/.ljg-trend-research/quick_test.py

# 完整测试（所有话题，10-30分钟）
./schedule.sh test

# 管理定时任务
./schedule.sh install    # 安装定时任务
./schedule.sh status     # 查看状态
./schedule.sh logs       # 查看日志
./schedule.sh edit       # 编辑话题配置
./schedule.sh uninstall  # 卸载定时任务
```

**监控的话题：**
- AI 行业趋势
- AI 应用
- AI 信息处理
- 加密货币稳定币
- 泡泡玛特
- 名创优品
- Lemonade (LMND)
- BitGo
- 紫金矿业

**日报输出位置：**
`~/Documents/Obsidian Vault/趋势研究/日报/日报-YYYY-MM-DD.md`

### 手动运行

#### 基础用法

```bash
/ljg-trend-research "[话题/公司名/行业]"
```

#### 高级用法

```bash
# 投资研究：市场情绪
/ljg-trend-research "Tesla 市场情绪" --type investment

# 选题调研：热点发现
/ljg-trend-research "AI 视频工具趋势" --type content

# 竞品分析：用户反馈
/ljg-trend-research "OpenAI vs Anthropic" --type competitor

# 技术趋势：最佳实践
/ljg-trend-research "Claude Code 技能开发" --type tech
```

## 输出格式

```markdown
## 趋势研究报告：[话题]

**扫描时间**: [时间戳]
**数据来源**: Reddit, X, YouTube, HN, Polymarket等
**时间窗口**: 过去30天

### 一、市场情绪概览

**讨论热度**: [高/中/低]
**主导观点**: [看多/看空/中立]
**情绪趋势**: [升温/降温/稳定]

### 二、关键发现

#### 热点话题
1. [话题1] - 提及次数: [X]次
2. [话题2] - 提及次数: [X]次
3. [话题3] - 提及次数: [X]次

#### 预测市场信号（如果有）
- [事件A]: 当前赔率 [X]%
- [事件B]: 当前赔率 [X]%

#### 争议点
- [争议1]: [不同观点概述]
- [争议2]: [不同观点概述]

### 三、深度萃取（Top 3 高价值内容）

#### 1. [内容标题]
**来源**: [平台]
**评分**: [X]/10
**核心洞见**:
- [洞见1]
- [洞见2]
**金句**:
> "[金句]"
**行动建议**:
- [建议1]

#### 2. [内容标题]
[同上格式]

#### 3. [内容标题]
[同上格式]

### 四、趋势判断

**短期趋势（1-3个月）**: [判断]
**中期趋势（3-6个月）**: [判断]
**长期趋势（6个月+）**: [判断]

### 五、行动建议

**投资相关**:
- [建议]

**内容创作相关**:
- [建议]

**产品/技术相关**:
- [建议]

---

**数据保存**:
- 完整报告: ~/Documents/Obsidian Vault/趋势研究/[年份]-[月份]/[话题].md
- 萃取内容: ~/Documents/Obsidian Vault/信息源/[年份]-[周次]/[平台]/
```

## 配置要求

### 依赖工具

```bash
# 1. last30days-skill
cd ~/claude-code-workspace/shared/skills/
git clone https://github.com/mvanhorn/last30days-skill.git

# 2. 100X 知识萃取系统
# (已安装)

# 3. agent-reach (用于获取原始内容)
# (已安装)
```

### 配置文件

```yaml
# ~/.ljg-trend-research/config.yaml
output_dir: ~/Documents/Obsidian Vault/趋势研究
knowledge_base_dir: ~/Documents/Obsidian Vault/信息源
last30days_path: ~/claude-code-workspace/shared/skills/last30days-skill
knowledge_extractor_path: ~/Documents/Obsidian Vault/职业发展/项目案例/100X_知识萃取系统/knowledge-extractor
```

## 与其他技能的协作

| 技能 | 关系 | 说明 |
|------|------|------|
| /ljg-invest | 下游 | 趋势研究 → 投资分析 |
| /ljg-writes | 下游 | 趋势研究 → 内容创作 |
| knowledge-extractor | 协作 | 趋势扫描提供URL → 深度萃取 |
| /ljg-card | 下游 | 趋势研究 → 制作信息图卡片 |

## 常见使用场景

### 场景1：投资研究

```bash
# 用户：我想投资 Tesla，但不知道市场现在怎么看
/ljg-trend-research "Tesla 市场情绪" --type investment

# 输出：
# - 市场是看多还是看空
# - 大家在担心什么
# - 预测市场怎么押注
# - 关键深度分析（100X萃取）
```

### 场景2：选题调研

```bash
# 用户：我想写一篇关于 AI 视频工具的文章
/ljg-trend-research "AI 视频工具趋势" --type content

# 输出：
# - 什么工具最火
# - 用户最关心什么功能
# - 有哪些最佳实践
# - 可以写什么角度
```

### 场景3：竞品分析

```bash
# 用户：我想了解 OpenAI 和 Anthropic 的竞争态势
/ljg-trend-research "OpenAI vs Anthropic" --type competitor

# 输出：
# - 社区怎么看两家公司
# - 各自的优势和劣势
# - 用户在讨论什么
# - 预测市场怎么看
```

## 定时任务配置

**当前配置：**
- 运行时间：每天凌晨 4:00
- 监控话题：9个（AI/投资相关）
- 输出格式：Markdown 日报
- 保存位置：Obsidian 知识库

**编辑话题配置：**
```bash
~/claude-code-workspace/shared/skills/ljg-trend-research/schedule.sh edit
```

**配置文件位置：**
`~/.ljg-trend-research/topics.yaml`

## 工作流示意图

```
每天凌晨 4:00
    ↓
launchd 触发
    ↓
daily_report.py
    ↓
扫描 9 个话题
    ↓
last30days 扫描（广度）
    ↓
100X 深度萃取（深度）
    ↓
生成 Markdown 日报
    ↓
保存到 Obsidian
    ↓
[可选] 发送到 Telegram
```

## 版本历史

**v1.0.0** (2026-04-01)
- 初始版本
- 集成 last30days + 100X 系统
- 支持 4 种研究类型（投资/内容/竞品/技术）
- 定时任务：每天凌晨4点自动运行
- 日报生成：自动扫描9个话题
- Obsidian 集成：自动保存到知识库
