---
name: unified-writer
description: >
  统一写作工具 - 智能路由到最佳子工具。支持：内容获取、格式化、转换、视觉生成、图片处理、发布。
  AI 自主决策使用哪个工具，无需手动指定。使用场景：文章创作、内容格式化、视觉生成、跨平台发布。
  触发词：/write, 写作, 格式化, 配图, 转换, 发布, 处理文章, 生成图片。
allowed-tools:
  - Bash
  - Read
  - Write
  - Edit
  - Skill
  - AskUserQuestion
metadata:
  version: 1.0.0
  author: Murphy
  category: 写作工具
  config_file: CONFIG.md
---

# 统一写作工具 (Unified Writer)

**一个入口，AI 自主路由到最佳工具**。

不再需要记忆 14 个独立的 baoyu skills。告诉 AI 你想做什么，它会自动选择合适的工具。

---

## 🎯 核心理念

### 问题
- 太多独立 skills，不知道用哪个
- 功能重叠，选择困难
- 配置分散，管理麻烦

### 解决方案
- **单一入口**: `/write` 处理所有写作需求
- **智能路由**: AI 分析上下文，自动选择工具
- **统一配置**: 一个 `CONFIG.md` 管理所有偏好

---

## 📊 工具映射

| 意图 | 子技能 | 触发词 |
|------|--------|--------|
| **获取内容** | url-to-markdown, x-to-markdown | URL, twitter.com, x.com |
| **格式化** | format-markdown | 格式化, 美化, 整理 |
| **转换格式** | markdown-to-html | 转HTML, 转换格式 |
| **文章配图** | article-illustrator | 配图, 插图, 文章图片 |
| **信息图** | infographic | 信息图, 可视化, 摘要图 |
| **封面图** | cover-image | 封面, 首图 |
| **幻灯片** | slide-deck | PPT, 幻灯片, 演示 |
| **小红书** | xhs-images | 小红书, 种草图 |
| **知识漫画** | comic | 漫画, 连环画 |
| **图片生成** | image-gen | 生成图片, AI作画 |
| **图片压缩** | compress-image | 压缩, 优化图片 |
| **发布到 X** | post-to-x | 发推特, 发布X, tweet |
| **发布微信** | post-to-wechat | 发公众号, 发布微信 |
| **Gemini API** | danger-gemini-web | Gemini, 谷歌AI |

---

## 🚀 使用方式

### 模式 1：自然语言（推荐）

```
用户: 帮我格式化这篇文章并配图

AI: 正在处理...
    ✅ 格式化完成 (format-markdown)
    ✅ 生成 3 张配图 (article-illustrator)
    📁 输出: article-formatted.md, img/
```

### 模式 2：文件处理

```
用户: /write article.md

AI: 分析 article.md...
    这是纯文本 Markdown，建议：
    1. 格式化（添加标题、摘要、格式）
    2. 生成配图
    3. 转换为 HTML

    是否全部执行？(y/n)
```

### 模式 3：URL 处理

```
用户: /write https://twitter.com/user/status/123

AI: 检测到 Twitter URL...
    ✅ 获取推文内容 (x-to-markdown)
    📝 推文: [内容摘要]

    可以执行：
    1. 保存为 Markdown
    2. 生成信息图分享
    3. 深度萃取关键信息
```

### 模式 4：明确指令

```
用户: 把这篇文章转换成 HTML 并发布到微信

AI: 执行流程：
    ✅ Markdown → HTML (markdown-to-html)
    ✅ 格式化为微信样式 (wechat theme)
    ⏳ 准备发布到微信公众号...
    请确认内容后继续
```

---

## 🧠 智能路由逻辑

### 决策流程

```
用户输入
   ↓
1. 分析输入类型
   ├─ 文件路径 → 读取并分析内容
   ├─ URL → 获取内容并分析
   └─ 自然语言 → 提取意图
   ↓
2. 提取用户意图
   ├─ 明确指令 → 直接执行
   └─ 模糊意图 → 推荐操作
   ↓
3. 匹配工具
   ├─ 单一意图 → 调用一个工具
   └─ 复合意图 → 组合多个工具
   ↓
4. 执行并返回结果
```

### 意图检测示例

| 用户输入 | 检测到的意图 | 路由到 |
|----------|--------------|--------|
| "格式化这篇文章" | format | format-markdown |
| "配图" | visual | article-illustrator |
| "做成信息图" | infographic | infographic |
| "发推特" | publish | post-to-x |
| "转换成HTML" | convert | markdown-to-html |
| "压缩图片" | image | compress-image |

---

## ⚙️ 配置系统

### 配置优先级

```
项目级 > 用户级 > 默认级

.baoyu-skills/unified-writer/CONFIG.md  (项目优先)
~/.baoyu-skills/unified-writer/CONFIG.md (用户次之)
shared/skills/unified-writer/CONFIG.md   (默认配置)
```

### 检查配置

```bash
# 检查项目级配置
test -f .baoyu-skills/unified-writer/CONFIG.md && echo "project"

# 检查用户级配置
test -f "$HOME/.baoyu-skills/unified-writer/CONFIG.md" && echo "user"

# 读取配置（按优先级）
CONFIG=$(test -f .baoyu-skills/unified-writer/CONFIG.md && cat .baoyu-skills/unified-writer/CONFIG.md || (test -f "$HOME/.baoyu-skills/unified-writer/CONFIG.md" && cat "$HOME/.baoyu-skills/unified-writer/CONFIG.md" || cat shared/skills/unified-writer/CONFIG.md))
```

### 配置示例

```yaml
# ~/.baoyu-skills/unified-writer/CONFIG.md
format:
  auto_summary: true
  cjk_spacing: true

visual:
  default_style: minimal
  images_per_article: 3

publish:
  default_platforms: [x, wechat]
  auto_tag: true
```

---

## 🔧 工具调用方式

### 方式 1：调用 Skill

```yaml
# 调用子技能
tool: Skill
skill: format-markdown
params: { file: "article.md" }
```

### 方式 2：执行脚本

```yaml
# 直接执行脚本
tool: Bash
command: "npx tsx scripts/format.ts article.md"
```

### 方式 3：组合工作流

```yaml
# 多步骤组合
tools:
  - format-markdown
  - article-illustrator
  - markdown-to-html
```

---

## 📋 完整工作流示例

### 场景：文章创作到发布

```
用户: 我有一篇关于 AI 的草稿，帮我完善并发布

AI: 分析中...
    检测到草稿文件: ai-draft.md
    状态: 纯文本 Markdown

    推荐流程：
    1. ✅ 格式化（添加标题、摘要、格式）
    2. ✅ 生成配图（3 张插图 + 封面）
    3. ✅ 转换为 HTML
    4. ⏳ 发布到平台

    是否执行？(y/n)

用户: y

AI: 执行中...
    [1/4] 格式化... ✅
    [2/4] 生成配图... ✅
       - 封面图: img/cover.png
       - 插图1: img/section-1.png
       - 插图2: img/section-2.png
       - 插图3: img/section-3.png
    [3/4] 转换 HTML... ✅
    [4/4] 准备发布...

    发布平台：
    [ ] X/Twitter
    [ ] 微信公众号
    [ ] 小红书

    选择平台: x, wechat

AI: 发布中...
    ✅ X/Twitter: https://x.com/user/status/123
    ✅ 微信公众号: 已发送草稿

    完成时间: 45s
    输出文件:
    - ai-draft-formatted.md
    - ai-draft.html
    - img/
```

---

## 🎨 高级功能

### 自定义工作流

用户可以定义自己的工作流程：

```yaml
# ~/.baoyu-skills/unified-writer/CONFIG.md
workflows:
  daily_article:
    - format
    - cover
    - publish

  deep_dive:
    - format
    - visual
    - infographic
    - convert
    - publish
```

### 智能推荐

基于历史使用习惯，AI 会主动推荐操作：

```
AI: 检测到这是一篇技术文章...
    基于你的习惯，建议：
    1. 生成流程图 (flowchart)
    2. 添加代码高亮
    3. 发布到 GitHub

    是否采用建议？(y/n)
```

---

## 📚 设计文档

详细架构设计请参考：
- `DESIGN.md` - 完整架构设计
- `CONFIG.md` - 配置文件说明
- `examples/` - 使用示例

---

## 🔄 迁移指南

### 从旧 skills 迁移

| 旧用法 | 新用法 |
|--------|--------|
| `/baoyu-format-markdown article.md` | `/write article.md` |
| `/baoyu-article-illustrator article.md` | `/write article.md 配图` |
| `/baoyu-post-to-x article.md` | `/write article.md 发到X` |

### 兼容性

- 旧的 skills 仍然可用
- 推荐使用统一入口
- 高级用户可直接调用子技能

---

**版本**: 1.0.0
**更新**: 2026-03-07
**作者**: Murphy
**设计原则**: 简化操作，AI 自主决策
