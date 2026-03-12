---
name: universal-tools
description: 统一工具调用技能 - Claude Code 和 nanobot 共享
allowed-tools:
  - Bash
  - AskUserQuestion
metadata:
  trigger: 工具调用、读取 URL、搜索、知识萃取
  version: 1.0.0
---

# Universal Tools - 统一工具调用

## 🎯 目标

在 Claude Code 和 Nanobot 中使用一致的工具调用规范。

## 📊 工具优先级

### LEVEL 0: 自定义工具（最高优先级）

#### xreach CLI (Twitter/X)
```bash
# 读取推文
exec("xreach tweet \"<url>\" --json")

# 搜索推文
exec("xreach search \"<query>\" --json")
```

#### Jina Reader (通用网页)
```bash
# 读取任意网页
exec("curl \"https://r.jina.ai/<url>\"")
```

#### 100X 知识萃取
```bash
exec("cd \"/Users/murphy/Documents/Obsidian Vault/职业发展/项目案例/100X_知识萃取系统/knowledge-extractor\" && python src/main.py")
```

### LEVEL 1: MCP 服务器

#### GitHub MCP
```bash
npx -y @iflow-mcp/server-github
```

#### Exa MCP
```bash
npx -y @modelcontextprotocol/server-exa
```

### LEVEL 2: 内置工具（最后手段）

```bash
# 仅当以上都不可用时使用
web_search("<query>")
web_fetch("<url>")
```

## 🔄 使用流程

1. **判断 URL 类型**
   - Twitter/X → 使用 xreach
   - 通用网页 → 使用 Jina Reader
   - GitHub → 使用 github-mcp 或 gh CLI

2. **尝试上游工具**
   ```bash
   # Twitter/X
   xreach tweet "https://x.com/user/status/123" --json

   # 通用网页
   curl "https://r.jina.ai/https://example.com"
   ```

3. **失败时降级**
   - 使用 MCP 服务器
   - 最后使用内置工具

## 📝 示例

### 读取 URL
```yaml
# Twitter/X
- exec("xreach tweet \"https://x.com/user/status/123\" --json")

# 通用网页
- exec("curl \"https://r.jina.ai/https://example.com\"")

# GitHub (github-mcp)
- mcp__github__get_file_contents

# 最后
- web_fetch("url")
```

### 搜索
```yaml
# Twitter 搜索
- exec("xreach search \"AI tools\" --json")

# 网络搜索 (Exa MCP)
- mcp__exa__web_search_exa

# 最后
- web_search("AI tools")
```

## 🧠 记忆学习

本技能会根据使用情况更新工具优先级：
- 记录哪些工具最有效
- 调整优先级顺序
- 在 `~/claude-code-workspace/shared/memory/user-profile.md` 中记录发现
