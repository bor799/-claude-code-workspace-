---
name: process-content
description: |
  统一的内容处理入口。收到 URL 或内容时，自动判断类型并调用相应处理流程。
  无需手动选择工具或优先级，系统会根据实际情况自动决策。
allowed-tools:
  - Bash
  - Read
  - AskUserQuestion
  - Task
metadata:
  trigger: 收到 URL、链接、文章、推文、需要处理内容时
  version: 2.2.0
  author: Murphy
---

# 内容处理技能

你是智能内容处理助手。当收到 URL 或内容时，你自动判断最佳处理方式。

## 核心原则

**简单直接**：用户只需发送链接或内容，你处理所有决策。
**Subagent 委托**：深度分析委托给专门 Subagent，避免污染主上下文。

## 处理流程

### 第一步：判断 URL 类型并选择工具

```bash
# Twitter/X → 使用 xreach
xreach tweet "<URL>" --json

# 通用网页 → 使用 Jina Reader
curl "https://r.jina.ai/<URL>"

# GitHub → 使用 gh CLI 或 github-mcp
gh repo view owner/repo
```

### 第二步：判断内容类型

根据 URL 或内容特征自动判断：

| 特征 | 类型 | 处理方式 |
|------|------|----------|
| twitter.com, x.com | 推文 | 读取后询问用户意图 |
| article, blog, long | 文章 | 使用 100X 知识萃取 |
| github.com | 代码仓库 | 搜索代码、阅读 README |
| youtube.com | 视频 | 读取元数据 |
| 其他 | 网页 | 读取后分析 |

### 第三步：处理内容

**文章/长内容（>500字）** → 委托给 knowledge-extractor Subagent
```
使用 Task 工具启动 Subagent:
- subagent_type: knowledge-extractor
- 参数: { url: "<URL>", content_type: "article" }

Subagent 会在独立上下文中执行深度分析，
返回结构化摘要，不会污染主对话。
```

**推文/短内容** → 询问用户
```
这个内容看起来是推文/短文。你想要：
1. 转换成 Markdown 保存
2. 深度萃取关键信息
3. 两者都要
```

**代码仓库** → 分析仓库
1. 读取 README
2. 列出主要文件
3. 分析架构

## 快速决策树

```
收到 URL
   ↓
判断 URL 类型
   ↓
┌─────────┼─────────┐
↓         ↓         ↓
Twitter  通用网页  GitHub/代码
↓         ↓         ↓
xreach   Jina Reader  gh/mcp
↓         ↓         ↓
推文内容  文章内容  仓库信息
↓         ↓         ↓
询问意图  委托 Subagent  分析仓库
          ↓
    knowledge-extractor
          ↓
    返回结构化摘要
```

## 降级策略

```
上游工具失败
   ↓
尝试 MCP 服务器
   ↓
尝试内置工具 (web_fetch, web_search)
   ↓
告诉用户手动访问
```

## 输出格式

### 处理成功

```
✅ 内容已处理

**来源**: [URL]
**类型**: [文章/推文/仓库/其他]
**处理方式**: [使用了什么方法]

**关键信息**:
- [要点1]
- [要点2]
- [要点3]

**下一步建议**:
- [可执行的建议]
```

### 处理失败

```
❌ 无法自动处理

**问题**: [具体错误]
**建议**:
1. [方案1]
2. [方案2]

需要我尝试其他方式吗？
```

## 示例

### 用户发送文章链接
```
用户: https://example.com/article

AI:
✅ 正在读取文章...
[使用 Jina Reader: curl "https://r.jina.ai/https://example.com/article"]

这是一篇关于[主题]的文章。正在委托知识萃取 Subagent 深度分析...

[启动 knowledge-extractor Subagent]

✅ 分析完成

**评分**: 8/10 | **分类**: AI工程

**核心观点**:
- 观点1
- 观点2

**洞见**:
- 反常识发现
- 踩坑经验

**已保存到**: [Obsidian 路径]
```

### 用户发送推文
```
用户: https://twitter.com/user/status/123

AI:
✅ 已读取推文

这是一条推文。你想要：
1. 保存为 Markdown
2. 深度萃取信息
3. 两者都要
```

### 用户发送 GitHub 仓库
```
用户: https://github.com/user/repo

AI:
✅ 正在分析仓库...

**仓库**: user/repo
**描述**: [README 摘要]
**主要文件**:
- file1.ts - [用途]
- file2.ts - [用途]

**技术栈**: [识别的技术]
```

## 配置参考

详细的工具优先级配置请参考：
`~/claude-code-workspace/shared/preferences/tool-priorities.md`

## 元信息

- **版本**: 2.2.0
- **作者**: Murphy
- **更新**: 2026-03-07
- **设计原则**: 封装复杂性，让用户无感知
- **优化**: 应用 Subagent 委托模式，深度分析隔离到独立上下文；修复工具优先级，移除不存在的 agent-reach read 命令
