---
name: agent-reach-auto-call
description: "URL读取和平台搜索的场景化优先级指南。基于工具能力选择最佳工具。"
allowed-tools:
  - Bash
  - ToolSearch
  - mcp__twitter-6551__search_twitter
  - mcp__exa__web_search_exa
  - mcp__github-mcp__*
metadata:
  priority: SCENARIO_BASED
  version: 3.0.0
  platforms: [twitter, reddit, github, youtube, bilibili, xhs, web, exa]
  references:
    - /Users/murphy/claude-code-workspace/shared/preferences/tool-priorities.md
---

# 互联网内容获取优先级指南 v3.0

> 📖 完整工具优先级: `~/TOOL_PRIORITIES.md` (指向 tool-priorities.md)

## 场景化优先级

### 场景 A: Twitter/X 内容获取

```
LEVEL 0: xreach CLI (最高优先级)
  ├─ xreach tweet "<url>" --json
  └─ 使用 Twitter API，完整数据

LEVEL 1: twitter-mcp (备选)
  ├─ mcp__twitter-6551__search_twitter
  └─ 搜索场景

LEVEL 2: web_fetch (最后手段)
  └─ 需代理访问
```

### 场景 B: 通用网页读取

```
LEVEL 0: Jina Reader (推荐)
  ├─ curl "https://r.jina.ai/<url>"
  └─ 支持 微信公众号/博客/新闻

LEVEL 1: web_fetch (备选)
  └─ 内置工具

LEVEL 2: web-reader MCP (已弃用)
  └─ 与 Jina Reader 功能重复
```

### 场景 C: 平台搜索

```
LEVEL 0: agent-reach CLI (最高优先级)
  ├─ agent-reach search-twitter "<query>"
  ├─ agent-reach search-reddit "<query>"
  ├─ agent-reach search-youtube "<query>"
  └─ agent-reach search-github "<query>"

LEVEL 1: Exa MCP (高质量搜索)
  └─ mcp__exa__web_search_exa

LEVEL 2: web_search (最后手段)
  └─ 内置工具
```

### 场景 D: 知识萃取

```
LEVEL 0: 100X 知识萃取系统 (深度分析)
  ├─ 读取链接 → AI分析 → 存储到Obsidian
  └─ 适用于文章/长内容

LEVEL 1: Jina Reader (快速读取)
  └─ 提取内容后手动分析
```

## 可用 CLI 工具

### xreach (Twitter 专用)

**路径**: `/Users/murphy/.npm-global/bin/xreach`

```bash
# 读推文
xreach tweet "<url>" --json

# 特点
# - 使用 Twitter API 读取完整推文
# - 输出 JSON 格式
# - 支持 Thread 和媒体
```

### agent-reach (平台搜索)

**路径**: `/Users/murphy/.local/bin/agent-reach`

```bash
# 平台搜索
agent-reach search-twitter "<query>"
agent-reach search-reddit "<query>"
agent-reach search-youtube "<query>"
agent-reach search-github "<query>"
agent-reach search-google "<query>"
```

### Jina Reader (通用网页)

```bash
# 读取任何网页
curl "https://r.jina.ai/<url>"

# 特点
# - 无需认证
# - 自动提取标题和正文
# - 输出 Markdown 格式
# - 支持微信公众号等复杂页面
```

## 可用 MCP 工具

### Twitter MCP
**工具**: `mcp__twitter-6551__search_twitter`

**触发词**：
- "搜索推文"、"Twitter"、"X平台"
- "搜推特"

**使用场景**：当 xreach 不可用时的备选方案

### Exa MCP
**工具**: `mcp__exa__web_search_exa`

**特点**：
- 高质量搜索结果
- 适合研究型查询
- 返回结构化内容

**使用场景**：当 agent-reach CLI 搜索质量不足时

### GitHub MCP
**工具**: `mcp__github-mcp__*`

**特点**：
- 完整的 GitHub API 访问
- 支持文件、Issue、PR 操作

**使用场景**：代码仓库相关操作

## 决策流程

```
收到 URL → 判断类型 → 选择工具
   ↓           ↓           ↓
Twitter/X  →  xreach   → 推文内容
微信文章  →  Jina Reader → 长文章
其他网页  →  Jina Reader → 网页内容
代码仓库  →  github-mcp → 代码内容
```

收到搜索请求 → 判断平台 → 选择工具
   ↓              ↓            ↓
Twitter     →  agent-reach → 推文列表
Reddit      →  agent-reach → 帖子列表
GitHub      →  agent-reach → 仓库列表
通用搜索    →  Exa MCP     → 高质量结果

## 数据获取策略

### 财报数据获取优先级

```
1. 公司官网投资者关系
   ├─ IR网站: ir.[company].com
   └─ 年报PDF: 港交所披露易

2. 金融数据网站
   ├─ Yahoo Finance
   ├─ AlphaSpread
   └─ Simply Wall St

3. 搜索引擎
   └─ Exa Web Search
```

### 执行示例

```python
# 搜索公司财报
mcp__exa__web_search_exa(
    query="Lemonade LMND 2024 annual report",
    numResults=5
)

# 搜索Twitter情绪
mcp__twitter_6551__search_twitter(
    keywords="LMND",
    limit=20
)
```

## 故障排查

```bash
# 检查MCP工具可用性
# 直接调用测试（系统自动处理）

# 降级策略
MCP失败 → 内置web_search
```

## 更新日志

**v3.0.0** (2026-03-07):
- 重构为场景化优先级（从 MCP 优先改为 CLI 优先）
- 与 tool-priorities.md 保持一致
- 添加 xreach (Twitter) 和 Jina Reader (通用网页) 作为 LEVEL 0
- 移除 web-reader MCP（功能重复）
- 添加对 tool-priorities.md 的引用

**v2.0.0** (2026-03-06):
- 移除agent-reach CLI的search/read功能（已不存在）
- 更新为使用MCP服务器
- 添加Exa Web搜索作为主要搜索工具

**v1.2.0**: 原始版本（假设agent-reach CLI支持search）
