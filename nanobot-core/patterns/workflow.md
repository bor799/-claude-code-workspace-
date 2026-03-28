# 工作流模式

## URL 处理优先级

```
LEVEL 0: agent-reach CLI
  ├─ agent-reach read "<URL>"
  ├─ agent-reach search-twitter "<query>"
  └─ agent-reach search-github "<query>"

LEVEL 1: MCP 服务器
  └─ GitHub/Exa/Twitter MCP

LEVEL 2: 内置工具
  └─ web_search/web_fetch
```

## 内容类型判断

```
文章/长内容 → 100X 知识萃取系统
推文/短内容 → 询问意图（转换/萃取/两者）
代码仓库 → github-mcp 或代码搜索
其他网页 → agent-reach 读取 → 判断处理
```

## 脚本开发规范

### 场景处理
| 场景 | 避免 | 推荐 |
|------|------|------|
| 多行内容写入 | sed 替换占位符 | heredoc |
| 复杂文本处理 | 多层 sed 管道 | awk |
| 日志输出 | stdout | stderr |

### 跨平台兼容
```bash
# sed -i 差异
macOS:  sed -i '' 's/old/new/' file
Linux:  sed -i 's/old/new/' file
```

---

**提取来源**: Nanobot 历史对话
**更新日期**: 2026-03-07
