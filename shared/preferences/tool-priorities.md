# 工具调用优先级

> 最后更新: 2026-03-27
> 详细工作流: `~/claude-code-workspace/rules/information-processing.md`

## 优先级规则

```
LEVEL 0 (本地工具) → LEVEL 1 (MCP) → LEVEL 2 (内置工具)
```

## LEVEL 0 — 本地工具（最高优先级）

| 平台 | 工具 | 命令 |
|------|------|------|
| Twitter/X | xreach | `xreach tweet "<url>" --json` |
| 微信公众号 | 本地工具 | `wechat-read "<url>"` |
| 通用网页 | Jina Reader | `curl "https://r.jina.ai/<url>"` |
| GitHub | gh CLI | `gh search repos "query"` |

## LEVEL 1 — MCP 服务

| 平台 | 工具 | 前置检查 |
|------|------|----------|
| GitHub | github-mcp | `gh auth status` |
| 搜索 | Exa MCP | - |

## LEVEL 2 — 内置工具（最后手段）

| 工具 | 用途 |
|------|------|
| web_search | 搜索 |
| web_fetch | 网页读取 |

## 外部依赖预检

```bash
gh auth status 2>&1 | grep "Logged in" && echo "OK" || echo "NOT_AUTH"
```

## 100X 知识萃取系统

**消费者路径**: `~/Documents/Obsidian Vault/职业发展/项目案例/100X_知识萃取系统/knowledge-extractor/v2`

**消费者是7×24小时运行的，不要停止它！**

### 启动消费者
```bash
~/.100x/start_consumer.sh
# 或手动：
cd ~/Documents/Obsidian\ Vault/职业发展/项目案例/100X_知识萃取系统/knowledge-extractor/v2
source .venv/bin/activate
python -m src.main --queue
```

### 检查状态
```bash
# 进程状态
ps aux | grep "src.main.*--queue"

# 队列状态
sqlite3 ~/.100x/queue.db "SELECT status, COUNT(*) FROM link_queue GROUP BY status"

# 日志
tail -f ~/.100x/consumer.log
```

### AI 使用方式
AI 只负责推送链接到队列：
```bash
cd ~/Documents/Obsidian\ Vault/职业发展/项目案例/100X_知识萃取系统/knowledge-extractor/v2
python -m src.main --add-url "<链接>"
```
