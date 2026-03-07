# 统一写作工具 - 架构设计

> **日期**: 2026-03-07
> **目标**: 整合所有 baoyu skills 为单一智能写作工具
> **核心理念**: 一个入口，AI 自主路由到合适工具

---

## 🎯 设计目标

### 当前问题
- **14 个独立 skills**，需要手动选择
- **功能重叠**：多个 skill 都能处理类似任务
- **配置分散**：每个 skill 有独立的 EXTEND.md
- **认知负担**：用户需要记住每个 skill 的用途

### 解决方案
- **单一入口**：`/write` 命令处理所有写作需求
- **智能路由**：AI 分析上下文，自动选择工具
- **统一配置**：一个 `WRITER_CONFIG.md` 管理所有偏好
- **渐进增强**：高级用户仍可直接调用子技能

---

## 📊 Skills 整合分析

### 功能分类

| 类别 | Skills | 统一接口 |
|------|--------|----------|
| **内容获取** | url-to-markdown, x-to-markdown | `import:` 从 URL/Twitter 获取内容 |
| **内容格式化** | format-markdown | `format:` 格式化 Markdown |
| **内容转换** | markdown-to-html | `convert:` 转换格式 |
| **视觉生成** | article-illustrator, infographic, cover-image, comic, slide-deck, xhs-images | `visual:` 生成视觉内容 |
| **图片处理** | image-gen, compress-image | `image:` 处理图片 |
| **内容发布** | post-to-x, post-to-wechat | `publish:` 发布到平台 |
| **辅助工具** | danger-gemini-web | `assist:` 辅助功能 |

### 决策路由逻辑

```
用户输入 → 分析意图 → 路由到工具
   ↓          ↓            ↓
"格式化"  → 格式化检测 → format-markdown
"配图"    → 视觉需求   → article-illustrator
"转换"    → 格式转换   → markdown-to-html
"发布"    → 平台检测   → post-to-x/wechat
```

---

## 🏗️ 架构设计

### 目录结构

```
claude-code-workspace/shared/skills/unified-writer/
├── SKILL.md                    # 主入口（智能路由）
├── CONFIG.md                   # 默认配置模板
├── DESIGN.md                   # 本文档
├── tools/                      # 子工具映射
│   ├── content-import.md      # 内容获取工具
│   ├── content-format.md      # 格式化工具
│   ├── content-convert.md     # 转换工具
│   ├── visual-gen.md          # 视觉生成工具
│   ├── image-process.md       # 图片处理工具
│   ├── publish-platform.md    # 发布工具
│   └── assist-tools.md        # 辅助工具
└── examples/                   # 使用示例
    ├── article-workflow.md    # 文章创作流程
    ├── social-post.md         # 社交媒体发布
    └── visual-content.md      # 视觉内容生成
```

### 核心组件

#### 1. SKILL.md - 智能路由器

```yaml
name: unified-writer
description: >
  统一写作工具 - 智能路由到最佳子工具。
  支持：内容获取、格式化、转换、视觉生成、图片处理、发布。
  AI 自主决策使用哪个工具，无需手动指定。
```

**路由逻辑**：
1. 分析用户输入意图
2. 匹配最佳工具
3. 调用子 skill 或直接执行
4. 返回结果

#### 2. CONFIG.md - 统一配置

```yaml
# 写作偏好
preferences:
  # 格式化
  format:
    auto_summary: true
    summary_length: medium
    cjk_spacing: true

  # 视觉生成
  visual:
    default_style: minimal
    default_type: infographic
    aspect_ratio: landscape

  # 发布
  publish:
    default_platforms: [x, wechat]
    auto_tag: true

# 工具配置
tools:
  image_gen:
    provider: openai  # openai, google, replicate
    model: dall-e-3

  x_post:
    account: personal  # personal, work
```

#### 3. tools/ 目录 - 工具映射

每个文件描述：
- 工具用途
- 触发条件
- 参数映射
- 调用方式

---

## 🔄 工作流示例

### 场景 1：文章创作完整流程

```bash
# 用户请求
/write "帮我写一篇关于 AI 的文章，包括配图和发布"

# AI 路由决策
1. 检测：需要创作新文章 → 调用 content-format
2. 检测：需要配图 → 调用 article-illustrator
3. 检测：需要发布 → 调用 post-to-x

# 执行流程
→ 生成内容
→ 格式化 Markdown
→ 生成配图
→ 发布到平台
→ 返回完整报告
```

### 场景 2：处理现有内容

```bash
# 用户请求
/write article.md

# AI 分析 article.md
→ 检测内容状态（草稿/已格式化）
→ 推荐下一步操作
→ 等待用户确认或自动执行

# 示例对话
AI: 检测到 article.md 是纯文本 Markdown。
    建议操作：
    1. 格式化（添加标题、摘要、格式）
    2. 生成配图
    3. 转换为 HTML

User: 全部执行

AI: 执行中...
    ✅ 格式化完成
    ✅ 生成 3 张配图
    ✅ 转换 HTML 完成
    📁 输出文件：article-formatted.md, article.html, img/
```

### 场景 3：智能内容处理

```bash
# 用户请求
/write https://twitter.com/user/status/123

# AI 路由
→ 检测 URL 类型 (Twitter)
→ 调用 x-to-markdown 获取内容
→ 分析内容质量
→ 询问用户意图（保存/分析/转发）

# 示例对话
AI: 已获取推文内容。

    这是一条关于 [主题] 的推文。
    评分：7/10

    可以执行：
    1. 保存为 Markdown
    2. 深度萃取关键信息
    3. 生成信息图分享
    4. 转发到其他平台

User: 2 和 3

AI: 执行中...
    ✅ 知识萃取完成
    ✅ 信息图生成中...
    📁 输出文件：extracted.md, infographic.png
```

---

## 🎨 用户体验设计

### 输入模式

| 模式 | 示例 | 路由到 |
|------|------|--------|
| **文件路径** | `article.md` | 分析文件 → 推荐操作 |
| **URL** | `https://...` | 内容获取 → 后续处理 |
| **自然语言** | "写一篇文章" | 创作模式 |
| **明确指令** | "格式化并配图" | 组合操作 |

### 输出格式

```
✅ 处理完成

**使用工具**: format-markdown, article-illustrator
**耗时**: 45s

**输出文件**:
- article-formatted.md
- img/cover.png
- img/section-1.png

**下一步建议**:
- [ ] 发布到 X/Twitter
- [ ] 转换为 HTML
- [ ] 生成信息图摘要
```

---

## 🔧 实现细节

### 路由决策算法

```python
def route_tool(user_input, context):
    # 1. 分析输入类型
    input_type = detect_input_type(user_input)

    # 2. 提取意图
    intent = extract_intent(user_input)

    # 3. 匹配工具
    tools = match_tools(intent, input_type, context)

    # 4. 排序优先级
    tools = sort_by_priority(tools, context)

    # 5. 返回决策
    return tools
```

### 工具调用方式

```yaml
# 方式 1：直接调用 Skill
tool: format-markdown
action: Skill
params: { file: "article.md" }

# 方式 2：执行脚本
tool: markdown-to-html
action: Bash
params: { command: "npx tsx scripts/convert.ts article.md" }

# 方式 3：组合调用
tool: workflow
actions:
  - format-markdown
  - article-illustrator
  - markdown-to-html
```

---

## 📋 配置优先级

```
项目级配置 > 用户级配置 > 默认配置

.baoyu-skills/unified-writer/CONFIG.md  (项目)
~/.baoyu-skills/unified-writer/CONFIG.md (用户)
shared/skills/unified-writer/CONFIG.md   (默认)
```

---

## 🚀 迁移路径

### 阶段 1：创建统一入口
- 创建 SKILL.md
- 实现基础路由逻辑
- 支持 3-5 个核心 skills

### 阶段 2：完善配置系统
- 实现 CONFIG.md
- 支持多级配置覆盖
- 添加配置验证

### 阶段 3：扩展功能
- 整合所有 baoyu skills
- 支持自定义工作流
- 添加预设模板

### 阶段 4：优化体验
- 学习用户习惯
- 智能推荐操作
- 性能优化

---

## 📚 参考资源

- **Claude Code 工具设计哲学**: `~/claude-code-workspace/shared/preferences/tool-priorities.md`
- **Agent 工具设计模式**: `~/Documents/Obsidian Vault/信息源/2026-03-W1/推特/构建 Agent 工具系统的核心矛盾.md`
- **现有 Skills**: `~/claude-code-workspace/shared/skills/baoyu-*/SKILL.md`

---

**版本**: 1.0.0
**状态**: 设计中
**下一步**: 实现 SKILL.md 主入口
