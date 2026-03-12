# agent-reach 命令参考

> ⚠️ **重要**: agent-reach 是一个脚手架工具，不是直接的读取/搜索工具。
> 它用于安装和配置上游工具，实际执行读取和搜索的是上游工具。

## 架构说明

```
agent-reach (安装器 + 配置工具)
  ├── setup          # 初始化环境
  ├── install        # 安装上游工具
  ├── configure      # 配置工具参数
  ├── doctor         # 检查工具状态
  └── uninstall      # 卸载工具

上游工具 (实际执行读取和搜索)
  ├── xreach         # Twitter/X 内容
  ├── Jina Reader    # 通用网页
  ├── yt-dlp         # 视频/字幕
  ├── gh             # GitHub
  ├── mcporter       # 小红书/抖音/LinkedIn
  └── miku_ai        # 微信公众号搜索
```

## 安装检查

```bash
which agent-reach
# 或
agent-reach --help
```

## 诊断工具

```bash
# 检查所有渠道状态
agent-reach doctor
```

输出示例：
```
[✓] xreach - Twitter/X
[✓] yt-dlp - YouTube
[✓] Jina Reader - Web
[?] gh - GitHub (需要认证)
[?] mcporter - MCP 工具
```

## 上游工具使用

### Twitter/X (优先级选择)

#### LEVEL 0: xreach CLI (推荐)

```bash
# 读取推文
xreach tweet "https://x.com/user/status/123" --json

# 搜索推文
xreach search "AI tools" --json

# 获取用户推文
xreach tweets @username -n 20 --json

# 获取完整推文串
xreach thread "https://x.com/user/status/123" --json
```

#### LEVEL 1: twitter-6551 MCP (备用)

当 xreach 不可用时，使用 twitter-6551 MCP：

**配置方式**:

1. **获取 API Token**: 访问 https://6551.io/mcp 获取 Token
2. **配置 Token**:

```bash
# 方式 1: 配置文件
vi ~/claude-code-workspace/shared/skills/opentwitter-mcp/config.json
# 添加: "api_token": "<your-token>"

# 方式 2: 环境变量
export TWITTER_TOKEN="<your-token>"
```

3. **启用 MCP**:

在 `~/.claude/settings.local.json` 中添加:
```json
"enabledMcpjsonServers": ["github", "exa", "twitter-6551"]
```

**可用工具**:
- `mcp__twitter-6551__search_twitter` - 搜索推文
- `mcp__twitter-6551__get_twitter_user` - 获取用户信息
- `mcp__twitter-6551__get_twitter_user_tweets` - 获取用户推文
- `mcp__twitter-6551__get_twitter_follower_events` - 获取关注事件
- `mcp__twitter-6551__get_twitter_kol_followers` - 获取 KOL 关注者

#### LEVEL 2: Jina Reader (最后手段)

```bash
curl "https://r.jina.ai/https://x.com/user/status/123"
```

### 通用网页 (Jina Reader)

```bash
# 读取推文
xreach tweet "https://x.com/user/status/123" --json

# 搜索推文
xreach search "AI tools" --json

# 获取用户推文
xreach tweets @username -n 20 --json

# 获取完整推文串
xreach thread "https://x.com/user/status/123" --json
```

### 通用网页 (Jina Reader)

```bash
# 读取任意网页
curl "https://r.jina.ai/https://example.com/article"

# 读取微信公众号
curl "https://r.jina.ai/https://mp.weixin.qq.com/s/xxx"

# 读取 GitHub 仓库页面
curl "https://r.jina.ai/https://github.com/user/repo"
```

**特点**:
- 无需认证
- 自动提取 Markdown
- 支持复杂页面

### 视频 (yt-dlp)

```bash
# 获取视频元数据
yt-dlp --dump-json "https://youtube.com/watch?v=xxx"

# 下载字幕
yt-dlp --write-sub --write-auto-sub --sub-lang "zh-Hans,zh,en" \
  --skip-download -o "/tmp/%(id)s" "URL"

# 搜索视频
yt-dlp --dump-json "ytsearch5:query"
```

### GitHub (gh)

```bash
# 先认证
gh auth login

# 搜索仓库
gh search repos "llm framework" --limit 10

# 查看仓库
gh repo view openai/openai

# 搜索代码
gh search code "prompt" --language python
```

### 小红书/抖音 (mcporter)

```bash
# 小红书搜索
mcporter call 'xiaohongshu.search_feeds(keyword: "query")'

# 抖音解析
mcporter call 'douyin.parse_douyin_video_info(share_link: "https://v.douyin.com/xxx/")'
```

## 配置工具

```bash
# 配置代理
agent-reach configure proxy http://127.0.0.1:7890

# 配置 Twitter Cookie
agent-reach configure twitter

# 配置其他渠道
agent-reach configure <channel>
```

## 故障排查

### 找不到命令

```bash
# 重新安装
pip install -U agent-reach-cli

# 或使用 npm
npm install -g agent-reach-cli
```

### 权限问题

```bash
chmod +x $(which agent-reach)
```

### 上游工具不可用

```bash
# 运行诊断
agent-reach doctor

# 查看修复建议
agent-reach doctor --fix
```

### MCP Inspector Proxy 连接错误

**问题**: "Error Connecting to MCP Inspector Proxy"

**原因**: MCP Inspector 是调试工具，需要正确配置代理

**解决方案**:

1. **检查 MCP 配置**:
```bash
# 查看当前 MCP 配置
cat ~/.claude.json | grep -A 20 "mcpServers"
```

2. **验证 API Token**:
```bash
# 检查 Token 是否配置
cat ~/claude-code-workspace/shared/skills/opentwitter-mcp/config.json
```

3. **测试 MCP 连接**:
```bash
# 使用 uv 直接测试
cd ~/claude-code-workspace/shared/skills/opentwitter-mcp
uv run opentwitter-mcp
```

4. **查看日志**:
```bash
# Claude Code MCP 日志位置
tail -f ~/.claude/debug/mcp-*.log
```

**正常使用不需要 MCP Inspector**:
- MCP Inspector 仅用于调试 MCP 服务器
- 正常使用时，Claude Code 会自动连接到配置的 MCP 服务器
- 如果只是想使用 Twitter 功能，确保 `settings.local.json` 中 `enabledMcpjsonServers` 包含 `"twitter-6551"`

## 完整文档

详细的上游工具文档请参考:
- `~/claude-code-workspace/shared/skills/agent-reach/SKILL.md`
- https://github.com/Panniantong/Agent-Reach

---

**最后更新**: 2026-03-07
**版本**: 2.0.0
