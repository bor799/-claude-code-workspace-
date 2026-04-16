---
name: information-processing
preamble-tier: 1
version: 0.2.0
description: |
  信息处理专家 v2：三阶段管线（获取 → 消化 → 归档）。
  从信息输入到深度理解，完整交付认知。
  Use when asked to: "read this link", "看这个链接", "搜一下", "帮我查",
  "看这个", "帮我读", "extract", "帮我理解", "说人话", "解剖概念",
  "读论文", "脑暴一下", or user shares any URL.
  Proactively suggest when: 用户发送 URL、分享链接、提到需要研究某个话题、
  或对话中出现了可以深入研究的信号。
allowed-tools:
  - Bash
  - Read
  - Grep
  - Glob
  - AskUserQuestion
  - WebSearch
benefits-from: [knowledge-extractor, cleanup-info-sources, agent-reach, lets-go-rss, ljg-paper, ljg-learn, ljg-plain, ljg-roundtable, ljg-rank, last30days-skill, fireworks-tech-graph]
workflow:
  next: [cleanup-info-sources, content-creation]
  suggest: [knowledge-extractor, ljg-learn, ljg-plain]
---

# 信息处理专家

## 触发器

**一旦**出现以下信号，**务必**激活此专家：

| 信号 | 示例 |
|------|------|
| 用户发送 URL | `https://mp.weixin.qq.com/...` |
| 用户要求搜索 | "帮我搜一下...", "搜推特", "全网搜索" |
| 用户要求阅读 | "看这个链接", "帮我读", "extract" |
| 用户要求理解 | "帮我理解", "说人话", "解释一下" |
| 概念深度分析 | "解剖概念", "这个概念是什么" |
| 论文阅读 | "读论文", "分析论文", arxiv 链接 |
| 脑暴/思辨 | "脑暴一下", "多角度分析" |
| 领域降秩 | "这个领域靠什么撑着" |

## 工具优先级（严格遵守，不可跳级）

```
LEVEL 0 → LEVEL 1 → LEVEL 2
(本地)      (MCP)      (内置)
```

### LEVEL 0 — 本地工具（最快最可靠，优先使用）

| 平台 | 工具 | 命令 |
|------|------|------|
| **Twitter/X** | xreach | `xreach tweet "<url>" --json` |
| **微信公众号** | 本地工具 | `cd ~/.agent-reach/tools/wechat-article-for-ai && python main.py "<url>" --no-headless -c 3` |
| **微信公众号（别名）** | wechat-read | `wechat-read "<url>"` |
| **通用网页** | Jina Reader | `curl "https://r.jina.ai/<url>"` |
| **GitHub** | gh CLI | `gh search repos "query"` |

### LEVEL 1 — MCP 服务（LEVEL 0 不可用时降级）

| 平台 | 工具 | 前置检查 |
|------|------|----------|
| 通用搜索 | agent-reach | `gh auth status` |
| GitHub | github-mcp | `gh auth status` |

### LEVEL 2 — 内置工具（最后手段）

| 工具 | 用途 | 注意 |
|------|------|------|
| web_search | 搜索 | 效果最差，仅在前两级都失败时使用 |
| web_fetch | 网页读取 | 同上 |

**降级规则**：LEVEL 0 命令失败 → 记录失败原因 → 尝试 LEVEL 1 → 再失败 → LEVEL 2

## 工作流

### 阶段一：信息获取（入口）

**Step 1: 识别内容类型**

```
收到 URL 或内容
    │
    ├── mp.weixin.qq.com → 微信文章 → LEVEL 0 本地工具
    ├── x.com / twitter.com → 推文 → LEVEL 0 xreach
    ├── github.com → 代码仓库 → LEVEL 0 gh CLI
    ├── bilibili.com / youtu.be → 视频 → LEVEL 0 agent-reach
    ├── 其他 URL → 通用网页 → LEVEL 0 Jina Reader
    │
    └── 无 URL（纯话题） → 搜索 → LEVEL 0 agent-reach / LEVEL 1 MCP
```

**Step 2: 获取内容**

- 执行对应命令，获取 Markdown 格式内容
- 如果内容为空或失败，立即降级到下一级
- 获取成功后，展示内容的**前 3-5 行**让用户确认方向

**Step 3: 推送到 100X 知识萃取（前置筛选）**

URL 进来后先过 100X 知识萃取系统做前置筛选，告诉用户"这里有什么"：

```bash
cd "<萃取路径>" && python add-link.py "<链接>"
```

100X 是前置过滤器，不是终点。它的价值在于帮你快速判断内容是否值得深度消化。

### 阶段二：深度理解（消化）

如果用户觉得内容有价值，拉原文做深度消化：

| 内容类型 | 技能 | 触发 |
|----------|------|------|
| **论文/学术** | /ljg-paper | arxiv 链接、论文 PDF、学术研究 |
| **概念/术语** | /ljg-learn | "帮我理解 XXX"、"解剖这个概念" |
| **长文/复杂内容** | /ljg-plain | "说人话"、"白话翻译"、技术文档 |
| **脑暴/多角度** | /ljg-roundtable | "脑暴一下"、"多角度讨论" |
| **领域降秩** | /ljg-rank | "这个领域靠什么撑着"、"找根" |

**短内容询问模板**（推文/短消息）：
> 收到一条推文，你想怎么处理？
> A) 深度萃取（推送到 100X）
> B) 快速翻译/摘要
> C) 两者都要

### 阶段三：整理归档（出口）

| 任务 | 说明 |
|------|------|
| 信息源去重 | cleanup-info-sources |
| 脏乱差清理 | 定期维护信息源目录 |
| 沉淀输出 | 将消化结果整理到知识库 |

## 100X 知识萃取系统

**路径**: `~/Documents/Obsidian Vault/职业发展/项目案例/100X_知识萃取系统/knowledge-extractor`

**AI 的角色是生产者，只负责推送链接：**

```bash
# 正确：推送链接到队列，然后退出
cd "<萃取路径>" && python add-link.py "<链接>"

# 错误：不要做以下任何事
# ❌ python src/main.py（这是消费端的事）
# ❌ 等待进程完成
# ❌ 终止正在运行的进程
# ❌ 越界管理消费端
```

**架构理解**：
```
AI（生产者） → 链接队列 → 100X 系统（消费者） → Obsidian
```

## 外部依赖预检

**在调用任何需要认证的服务之前，先检查认证状态：**

```bash
gh auth status 2>&1 | grep "Logged in" && echo "OK" || echo "NOT_AUTH"
```

- **已认证**：直接使用 MCP/API
- **未认证**：立即提供手动方案，不要尝试需要 token 的操作

## 管辖的技能

| 技能 | 用途 | 触发 |
|------|------|------|
| cleanup-info-sources | 信息源清理 | 去重、分类、备份 |
| knowledge-extractor | 知识萃取 | 深度分析、信号提取 |
| lets-go-rss | RSS 订阅 | 内容聚合、增量更新 |
| /ljg-paper | 论文深度阅读 | arxiv 链接、论文、研究论文 |
| /ljg-learn | 概念八维解剖 | "帮我理解 XXX"、"解剖概念" |
| /ljg-plain | 白话解释 | "说人话"、"解释一下"、技术文档 |
| /ljg-roundtable | 脑暴/多角度讨论 | "脑暴一下"、"多角度分析" |
| /ljg-rank | 领域降秩 | "这个领域靠什么撑着" |
| last30days-skill | 跨平台话题调研 | "最近30天XXX"、"市场对XXX的看法"、"追踪XXX动态" |
| fireworks-tech-graph | 技术图表生成 | "画图"、"架构图"、"流程图"、"可视化"、"出图"、"generate diagram" |

## last30days 跨平台调研系统

**能力**：扫描 Reddit、X、YouTube、TikTok、Instagram、Hacker News、Polymarket 等 10+ 平台最近 30 天的讨论，输出带引用的综合报告。

### 使用场景

| 场景 | 命令示例 | 输出 |
|------|----------|------|
| **话题调研** | `last30days "Claude Code 新功能"` | 8-12 条/源的综合报告 |
| **深度调研** | `last30days "AI Agent" --deep` | 50-70 Reddit + 40-60 X |
| **快速扫描** | `last30days "GPT-5" --quick` | 8-12 条/源，速度优先 |
| **时间范围** | `last30days "XXX" --days=7` | 只看最近 7 天 |
| **对比分析** | `last30days "Cursor vs Windsurf"` | 3 轮并行对比研究 |

### 定时追踪（Watchlist）

```bash
# 添加追踪话题
last30days watchlist add "AI Agent 最新动态"

# 配合 cron 定时执行，结果存入 SQLite
# 适合持续追踪竞品或行业趋势
```

### 输出处理

last30days 输出 → `/ljg-plain` 白话解释 → 沉淀到知识库

**配置文件**：`~/.config/last30days/.env`
**最低成本**：1 个 ScrapeCreators API Key（覆盖 Reddit + TikTok + Instagram）
**免费数据源**：Hacker News、Polymarket（无需 key）

## 常见错误

| 错误 | 正确做法 |
|------|----------|
| 直接用 web_search 搜微信文章 | 先用 LEVEL 0 本地工具 |
| 自己跑 100X 的 main.py | 只用 add-link.py 推送链接 |
| 未检查认证就调 GitHub API | 先 `gh auth status` |
| 等待 100X 处理完成 | 推送后立即退出 |
| URL 进来直接推 100X 就结束 | 100X 是前置筛选，用户觉得有价值要进一步深度消化 |

## 与其他专家的关系

| 关系 | 专家 | 说明 |
|------|------|------|
| **下游** | content-creation | 消化后的素材可供内容创作使用 |
| **上游** | investment-research | 为投资分析提供信息输入 |
| **协作** | development | 技术概念/论文消化辅助开发理解 |
