# 工具调用优先级

> 📅 最后更新: 2026-03-06
> 🔄 版本: 3.0.0
> 🎯 基于 Claude Code 团队的 Agent 工具设计实践经验

## 🎯 核心原则

**工具越少越好，匹配模型能力，渐进式披露**

### Agent 工具设计哲学

> "You want to give it tools that are shaped to its own abilities. But how do you know what those abilities are? You pay attention, read its outputs, experiment. You learn to see like an agent."

**三大关键概念**:
1. **行动空间**: 工具必须匹配模型当前能力水平
2. **渐进式披露**: 让 Agent 通过探索递进式发现上下文
3. **像 Agent 一样思考**: 观察模型输出、实验、迭代

---

## LEVEL 0: 核心工具（最高优先级）

### xread (Twitter/X 专用)

**路径**: `/Users/murphy/.npm-global/bin/xreach`

**读推文**:
```bash
xreach tweet "<url>" --json
```

**特点**:
- 使用 Twitter API 读取完整推文
- 支持认证信息配置
- 输出 JSON 格式
- 适合 Twitter/X 内容

### Jina Reader (通用网页)

**使用方式**:
```bash
curl "https://r.jina.ai/<url>"
```

**特点**:
- 无需认证，直接使用
- 自动提取标题和正文
- 输出 Markdown 格式
- 支持微信公众号等复杂页面
- 适合所有网页（包括 Twitter、微信、博客等）

### 100X 知识萃取系统

**路径**: `/Users/murphy/Documents/Obsidian Vault/职业发展/项目案例/100X_知识萃取系统/knowledge-extractor`

**NBO 调用方式**:
```bash
# 写入链接到输入文件
echo "<URL>" >> ~/.nanobot/workspace/wechat_inbox.txt

# 执行分析
cd "/Users/murphy/Documents/Obsidian Vault/职业发展/项目案例/100X_知识萃取系统/knowledge-extractor" && /opt/miniconda3/bin/python3 src/main.py --verbose
```

**功能**:
- 读取用户发送的链接（Twitter、微信、网页等）
- AI 分析内容质量（评分 1-10 分）
- 提取核心洞察、方法论、金句
- 推送到 Telegram（所有评分）
- 存储高分内容到 Obsidian（>6 分）

**使用场景**: 深度分析文章内容

### agent-reach (平台搜索)

```bash
agent-reach search-twitter "<query>"
agent-reach search-reddit "<query>"
agent-reach search-youtube "<query>"
agent-reach search-github "<query>"
```

**使用场景**: 平台内搜索

---

## LEVEL 1: MCP 服务器

> 📋 **已配置 MCP** (settings.local.json): github, exa, web-search-prime
> 📋 **额外权限 MCP**: twitter-6551, ai-builders-coach, zread, web-reader

### 核心 MCP（推荐保留）

#### GitHub MCP
```bash
npx -y @iflow-mcp/server-github
```

**功能**: 完整的 GitHub API 访问
- 文件操作: `mcp__github-mcp__get_file_contents`
- Issue 管理: `mcp__github-mcp__list_issues`, `create_issue`
- PR 操作: `mcp__github-mcp__list_pull_requests`, `create_pull_request`
- 仓库操作: `mcp__github-mcp__search_repositories`, `fork_repository`

**使用场景**: 代码仓库相关操作

#### Exa MCP
```bash
npx -y @modelcontextprotocol/server-exa
```

**功能**: 高质量网络搜索和代码搜索
- Web 搜索: `mcp__exa__web_search_exa`
- 代码上下文: `mcp__exa__get_code_context_exa`

**使用场景**: 研究型查询、代码搜索

#### Twitter MCP (twitter-6551)
```bash
# 已配置但未在 enabledMcpjsonServers 中
# 通过权限直接访问
```

**功能**: Twitter 数据获取
- 搜索推文: `mcp__twitter-6551__search_twitter`
- 用户信息: `mcp__twitter-6551__get_twitter_user`
- 用户推文: `mcp__twitter-6551__get_twitter_user_tweets`

**使用场景**: Twitter 搜索（当 xread 不可用时）

#### AI Builders Coach MCP
```bash
# 已配置但未在 enabledMcpjsonServers 中
```

**功能**: AI 开发助手
- API 规范: `mcp__ai-builders-coach__get_api_specification`
- 部署指南: `mcp__ai-builders-coach__get_deployment_guide`
- 认证模型: `mcp__ai-builders-coach__explain_authentication_model`

**使用场景**: AI 应用开发指导

### 冗余 MCP（建议移除）

#### Web Search Prime
**问题**: 与 Exa MCP 功能重复
**建议**: 移除，使用 Exa MCP

#### Web Reader
**问题**: 与 Jina Reader 功能重复
**建议**: 移除，使用 Jina Reader (CLI)

#### Zread
**问题**: 与 GitHub MCP 功能重复
**建议**: 移除，使用 GitHub MCP

---

## LEVEL 2: 内置工具（最后手段）

```bash
# 仅当以上都不可用时使用
web_search("<query>")
web_fetch("<url>")
```

---

## 🔄 决策流程

```
收到 URL → 判断类型 → 选择工具 → 提取内容 → 判断处理方式
   ↓           ↓           ↓          ↓           ↓
Twitter/X  →  xreach   →  推文内容  →  询问用户意图
微信文章  →  Jina Reader → 长文章    →  100X 深度分析
其他网页  →  Jina Reader → 网页内容   →  根据 URL 类型判断
代码仓库  →  github-mcp → 代码内容  →  分析或阅读
```

---

## 📊 工具选择矩阵

| 任务 | LEVEL 0 | LEVEL 1 | LEVEL 2 |
|------|---------|---------|---------|
| Twitter 推文 | xreach | Twitter MCP | web_fetch |
| 微信文章 | Jina Reader | - | web_fetch |
| 其他网页 | Jina Reader | - | web_fetch |
| 平台搜索 | agent-reach | Exa MCP | web_search |
| GitHub | agent-reach | GitHub MCP | - |
| 知识萃取 | 100X | - | - |

---

## 🎓 工具设计经验（来自 100X 集成）

### 避免的错误

1. **过度自主实现**: 遇到 URL 处理时，应该优先使用现有工具
2. **忽略用户明确指令**: 用户说"持续测试"时，应该绕过沙箱执行
3. **错误假设**: 假设系统架构而非查看文档

### 关键学习

1. **系统边界**: 100X 由 NBO 调用，不是独立运行
2. **网络依赖**: Telegram API 需要代理才能访问
3. **回退机制**: API 失败时应该有备用方案
4. **工具优先级**: 严格遵循 LEVEL 0 → LEVEL 1 → LEVEL 2

### 工具设计模式

| 模式 | 场景 | 方法 |
|------|------|------|
| 工具拆分 | 多功能工具导致认知冲突 | 拆分为独立、单一职责工具 |
| 约束解除 | 模型能力进化，工具成为束缚 | 移除过度保护机制 |
| 自主构建 | 系统被动提供上下文 | 提供搜索工具，让模型自主构建 |
| Subagent 委托 | 低频但复杂的专业任务 | 创建专门 Subagent 按需处理 |

---

## 📚 参考文档

- **NBO 工具参考**: `~/.nanobot/workspace/memory/TOOLS.md`
- **NBO 100X 调用指南**: `~/.nanobot/workspace/memory/100X_KNOWLEDGE_SYSTEM.md`
- **Agent 工具设计**: `~/Documents/Obsidian Vault/信息源/2026-03-W1/推特/构建 Agent 工具系统的核心矛盾.md`
- **配置演进**: `~/claude-code-workspace/shared/memory/preferences-evolution.md`

---

**最后更新**: 2026-03-06
**基于**: 100X 系统集成实战经验 + Claude Code 团队工具设计哲学
