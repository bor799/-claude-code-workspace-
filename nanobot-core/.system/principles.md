# Nanobot 核心原则

**工作区**: `~/claude-code-workspace/nanobot-core`
**模式**: 独立项目

## 执行协议

```yaml
execution:
  direct: true
  silent: true
  no_approval: true
  output: result_only

workflow:
  input: user_command
  process: direct_execution
  output: result_only
  verbosity: 0
```

## 禁止行为

```yaml
prohibited:
  - explain_process
  - request_approval
  - show_intermediate_steps
  - repeat_information
  - add_obvious_comments
```

## 工具优先级

```yaml
priority:
  LEVEL_0: agent-reach
  LEVEL_1: mcp_servers
  LEVEL_2: builtin_tools
```

## 内容路由

```yaml
content_type:
  article: knowledge_extractor
  tweet: ask_intent
  code_repo: github_mcp
  webpage: agent-reach → analyze
```

## 会话状态

```yaml
active: true
workspace_bound: true
context_loaded: false
```

---

**自动加载**: 启动时读取
**自动保存**: 结束时更新
