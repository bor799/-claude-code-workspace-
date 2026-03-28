---
name: information-processing
preamble-tier: 1
version: 0.1.0-pilot
description: |
  统一信息处理工作流：URL 识别 → 内容获取 → 知识萃取 → 存储归档。
  Use when asked to: "read this link", "看这个链接", "搜一下", "帮我查", "extract", "萃取",
  "看这个", "帮我读", or user shares any URL.
  Proactively suggest when: 用户发送 URL、分享链接、提到需要研究某个话题、
  或对话中出现了可以深入研究的信号。
allowed-tools:
  - Bash
  - Read
  - Grep
  - Glob
  - AskUserQuestion
  - WebSearch
benefits-from: [knowledge-extractor, cleanup-info-sources, agent-reach, lets-go-rss]
workflow:
  next: [cleanup-info-sources]
  suggest: [knowledge-extractor]
---

# 信息处理专家

## 触发器

**一旦**出现以下信号，**务必**激活此专家：

| 信号 | 示例 |
|------|------|
| 用户发送 URL | `https://mp.weixin.qq.com/...` |
| 用户要求搜索 | "帮我搜一下...", "搜推特", "全网搜索" |
| 用户要求阅读 | "看这个链接", "帮我读", "extract" |
| 用户要求研究 | "这个话题研究一下", "帮我查" |
| 对话中出现研究信号 | 用户提到某个新概念/新工具/新趋势 |

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

### Step 1: 识别内容类型

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

### Step 2: 获取内容

- 执行对应命令，获取 Markdown 格式内容
- 如果内容为空或失败，立即降级到下一级
- 获取成功后，展示内容的**前 3-5 行**让用户确认方向

### Step 3: 判断处理方式

| 内容类型 | 处理方式 | 原因 |
|----------|----------|------|
| **文章/长内容** (>500字) | 推送到 100X 知识萃取 | 深度分析有价值 |
| **推文/短内容** (<200字) | **询问用户意图** | 可能只需要快速翻译或归档 |
| **代码仓库** | 分析或阅读 | 非内容处理范畴 |
| **视频** | 提取字幕/摘要 | 需要 agent-reach |

**短内容询问模板**：
> 收到一条推文，你想怎么处理？
> A) 深度萃取（推送到 100X）
> B) 快速翻译/摘要
> C) 两者都要

### Step 4: 100X 知识萃取（生产者-消费者模式）

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

## 安全原则

1. **工具降级而非中断**：一级失败就降级，不要卡住
2. **内容验证**：获取后检查内容是否完整（不是空内容、不是错误页）
3. **备份优先**：修改任何文件前先备份
4. **认证预检**：调用外部 API 前先检查认证状态

## 与其他专家的关系

| 下一步 | 触发条件 |
|--------|----------|
| /cleanup-info-sources | 信息源积累较多，需要整理去重时 |
| /knowledge-extractor | 需要深度萃取单篇文章时 |
| /lets-go-rss | 需要订阅内容源时 |

## 常见错误

| 错误 | 正确做法 |
|------|----------|
| 直接用 web_search 搜微信文章 | 先用 LEVEL 0 本地工具 |
| 自己跑 100X 的 main.py | 只用 add-link.py 推送链接 |
| 未检查认证就调 GitHub API | 先 `gh auth status` |
| 等待 100X 处理完成 | 推送后立即退出 |
