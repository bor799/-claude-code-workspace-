---
name: agent-reach
version: 1.0.0
description: |
  互联网工具路由：自动选择最佳工具处理 URL 和搜索请求。
  支持 13+ 平台：Twitter/X、Reddit、YouTube、GitHub、Bilibili、小红书、抖音、
  微信文章、LinkedIn、Boss直聘、RSS、Exa 搜索及任意网页。
trigger:
  - URL
  - 链接
  - 搜索
  - 读取
allowed-tools:
  - Bash
  - Read
  - Skill
metadata:
  author: Murphy
  category: 信息获取
  health-check: agent-reach doctor
  upstream: https://github.com/Panniantong/agent-reach
  platforms: 13+
---

# 快速开始

**检查状态**：`agent-reach doctor`
**使用下方表格**：根据平台类型选择对应的命令

---

# 工具路由决策表

## URL 处理

| 类型 | 首选命令 |
|------|----------|
| 任意网页 | `curl "https://r.jina.ai/<url>"` |
| Twitter/X | `xreach tweet <url> --json` |
| 微信文章 | `wechat-read <url>` 或 `python3 ~/.agent-reach/tools/wechat-article-for-ai/main.py "<url>"` |
| GitHub | `gh api /repos/owner/repo` |
| YouTube/B站 | `yt-dlp --dump-json "<url>"` |

## 搜索

| 平台 | 首选命令 |
|------|------|
| 通用搜索 | `mcp__exa__web_search_exa` |
| Twitter | `xreach search "<query>" --json` |
| GitHub | `gh search repos "<query>"` |
| Reddit | Exa MCP 或 `curl "https://r.jina.ai/http://reddit.com/r/xxx"` |

## 常用命令速查

### 读取内容
```bash
# 网页文章（自动提取正文）
curl "https://r.jina.ai/https://example.com/article"

# Twitter 推文
xreach tweet "https://x.com/user/status/123" --json

# 微信文章（需专用工具）
wechat-read "https://mp.weixin.qq.com/s/xxx"

# GitHub 仓库
gh repo view owner/repo
gh issue view 123 -R owner/repo
```

### 搜索信息
```bash
# 通用网络搜索
mcp__exa__web_search_exa

# Twitter 搜索
xreach search "关键词" -n 10 --json

# GitHub 搜索
gh search repos "关键词" --limit 10
gh search code "关键词" --language python
```

### 获取视频信息
```bash
# YouTube / Bilibili 元数据
yt-dlp --dump-json "视频URL"

# 下载字幕（翻译用）
yt-dlp --write-sub --write-auto-sub --sub-lang "zh-Hans,zh,en" \
  --skip-download -o "/tmp/%(id)s" "视频URL"
```

## ⚠️ 重要注意事项

**工作区规则**：
- ❌ 不要在 agent 工作区创建文件
- ✅ 临时文件使用 `/tmp/`
- ✅ 持久数据使用 `~/.agent-reach/`

**平台限制**：
- **Bilibili**：可能遇到 412 错误 → 使用 `--cookies-from-browser chrome` 或配置代理
- **微信文章**：必须使用专用工具，无法用 curl/Jina 直接读取
- **Reddit**：服务器 IP 可能被 403 → 优先使用 Exa 搜索
- **小红书**：需要登录（使用 Cookie-Editor 导入 cookies）

## 故障排查

```bash
agent-reach doctor              # 检查可用通道
agent-reach configure proxy URL # 配置代理
```

**常见问题**：
- Twitter 请求失败 → 配置代理
- 微信文章无法读取 → 确保使用 `wechat-read` 命令
- B站 412 错误 → 添加浏览器 cookies

---

> 📖 **完整文档与所有平台示例**：https://github.com/Panniantong/agent-reach
> 📋 **详细版本**：`shared/skills/agent-reach/SKILL.md`
