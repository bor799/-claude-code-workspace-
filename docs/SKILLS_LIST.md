# Claude Code 技能清单

> 自动生成的技能列表，最后更新时间: 2026-03-05 21:42:25

---

## 📁 目录结构

```
~/.claude/skills/          # 个人技能目录
|-- [个人技能...]

~/claude-code-workspace/shared/skills/  # 共享技能目录
|-- [共享技能...]
```

---

## 👤 个人技能 (Skills)

**位置**: `/Users/murphy/.claude/skills`

#### agent-reach-auto-call

allowed-tools: - Bash metadata: priority: LEVEL_1 version: 1.2.0 platforms: [twitter, reddit, github, youtube, bilibili, xhs, instagram, linkedin, bosszhipin]

#### unified-writer

统一写作工具 - 智能路由到最佳子工具。整合 14 个 baoyu skills 为单一入口，AI 自主决策使用哪个工具。
支持：内容获取、格式化、转换、视觉生成、图片处理、发布。
使用场景：文章创作、内容格式化、视觉生成、跨平台发布。
触发词：/write, 写作, 格式化, 配图, 转换, 发布, 处理文章, 生成图片。
allowed-tools: - Bash - Read - Write - Edit - Skill - AskUserQuestion
metadata: version: 1.0.0 author: Murphy category: 写作工具

#### code-review

系统化的代码审查，检查代码质量、安全性、性能和可维护性。 识别重构机会，提供具体改进建议。 适用于审查 PR、重构代码、提升代码质量。 allowed-tools: - Read - Grep - Glob - AskUserQuestion metadata: trigger: 代码审查、代码质量检查、重构建议 version: 1.0.0 author: Murphy

#### doc-manager

系统化的文档管理与知识沉淀，生成技术文档、API 文档、架构文档。 维护 README、CLAUDE.md、项目知识库。 适用于文档编写、知识管理、项目维护。 allowed-tools: - Read - Write - Edit - Glob - Grep metadata: trigger: 文档编写、知识管理、README 生成、API 文档 version: 1.0.0 author: Murphy

#### evaluate-session

评估 Claude Code 会话的性能，基于五维度框架计算得分。 识别红旗问题和改进机会，生成优化建议。 适用于总结会话、识别可自动化任务、持续改进工作流。 allowed-tools: - Read - AskUserQuestion metadata: trigger: 评估会话性能、分析工作流程、识别改进点 version: 1.0.0 author: Murphy

#### frontend-slides

Create stunning, animation-rich HTML presentations from scratch or by converting PowerPoint files. Use when the user wants to build a presentation, convert a PPT/PPTX to web, or create slides for a talk/pitch. Helps non-designers discover their aesthetic through visual exploration rather than abstract choices.

#### humanizer-zh

去除文本中的 AI 生成痕迹。适用于编辑或审阅文本，使其听起来更自然、更像人类书写。 基于维基百科的"AI 写作特征"综合指南。检测并修复以下模式：夸大的象征意义、 宣传性语言、以 -ing 结尾的肤浅分析、模糊的归因、破折号过度使用、三段式法则、 AI 词汇、否定式排比、过多的连接性短语。 allowed-tools: - Read - Write - Edit - AskUserQuestion metadata: trigger: 编辑或审阅文本，去除 AI 写作痕迹 source: 翻译自 blader/humanizer，参考 hardikpandya/stop-slop

#### lets-go-rss

轻量级全平台 RSS 订阅管理器。一键聚合 YouTube、Vimeo、Behance、B站、微博、抖音、小红书的内容更新，支持增量去重和 AI 智能分类。

#### plan-feature

系统化的功能开发规划，分析需求、拆解任务、识别依赖和风险。 提供清晰的实现路径和策略建议。 适用于新功能开发、复杂任务规划、技术方案设计。 allowed-tools: - Read - Glob - Grep - AskUserQuestion metadata: trigger: 功能规划、需求分析、任务拆解、技术设计 version: 1.0.0 author: Murphy

#### ui-ux-pro-max

UI/UX design intelligence. 67 styles, 96 palettes, 57 font pairings, 25 charts, 13 stacks (React, Next.js, Vue, Svelte, SwiftUI, React Native, Flutter, Tailwind, shadcn/ui). Actions


---

## 🤝 共享技能 (Shared Skills)

**位置**: `/Users/murphy/claude-code-workspace/shared/skills`

#### baoyu-article-illustrator

Analyzes article structure, identifies positions requiring visual aids, generates illustrations with Type × Style two-dimension approach. Use when user asks to illustrate article, add images, generate images for article, or 为文章配图.

#### baoyu-comic

Knowledge comic creator supporting multiple art styles and tones. Creates original educational comics with detailed panel layouts and sequential image generation. Use when user asks to create 知识漫画, 教育漫画, biography comic, tutorial comic, or Logicomix-style comic.

#### baoyu-compress-image

Compresses images to WebP (default) or PNG with automatic tool selection. Use when user asks to compress image, optimize image, convert to webp, or reduce image file size.

#### baoyu-cover-image

Generates article cover images with 5 dimensions (type, palette, rendering, text, mood) combining 9 color palettes and 6 rendering styles. Supports cinematic (2.35:1), widescreen (16:9), and square (1:1) aspects. Use when user asks to generate cover image, create article cover, or make cover.

#### baoyu-danger-gemini-web

Generates images and text via reverse-engineered Gemini Web API. Supports text generation, image generation from prompts, reference images for vision input, and multi-turn conversations. Use when other skills need image generation backend, or when user requests generate image with Gemini, Gemini text generation, or needs vision-capable AI generation.

#### baoyu-danger-x-to-markdown

Converts X (Twitter) tweets and articles to markdown with YAML front matter. Uses reverse-engineered API requiring user consent. Use when user mentions X to markdown, tweet to markdown, save tweet, or provides x.com/twitter.com URLs for conversion.

#### baoyu-format-markdown

Formats plain text or markdown files with frontmatter, titles, summaries, headings, bold, lists, and code blocks. Use when user asks to format markdown, beautify article, add formatting, or improve article layout. Outputs to {filename}-formatted.md.

#### baoyu-image-gen

AI image generation with OpenAI, Google, DashScope and Replicate APIs. Supports text-to-image, reference images, aspect ratios. Sequential by default; parallel generation available on request. Use when user asks to generate, create, or draw images.

#### baoyu-infographic

Generates professional infographics with 21 layout types and 20 visual styles. Analyzes content, recommends layout×style combinations, and generates publication-ready infographics. Use when user asks to create infographic, 信息图, visual summary, 可视化, or 高密度信息大图.

#### baoyu-markdown-to-html

--- description: Article summary

#### baoyu-post-to-wechat

Posts content to WeChat Official Account (微信公众号) via API or Chrome CDP. Supports article posting (文章) with HTML, markdown, or plain text input, and image-text posting (贴图, formerly 图文) with multiple images. Use when user mentions 发布公众号, post to wechat, 微信公众号, or 贴图/图文/文章.

#### baoyu-post-to-x

Posts content and articles to X (Twitter). Supports regular posts with images/videos and X Articles (long-form Markdown). Uses real Chrome with CDP to bypass anti-automation. Use when user asks to post to X, tweet, publish to Twitter, or share on X.

#### baoyu-slide-deck

Generates professional slide deck images from content. Creates outlines with style instructions, then generates individual slide images. Use when user asks to create slides, make a presentation, generate deck, slide deck, or PPT.

#### baoyu-url-to-markdown

Fetch any URL and convert to markdown using Chrome CDP. Supports two modes - auto-capture on page load, or wait for user signal (for pages requiring login). Use when user wants to save a webpage as markdown.

#### baoyu-xhs-images

Generates Xiaohongshu (Little Red Book) infographic series with 10 visual styles and 8 layouts. Breaks content into 1-10 cartoon-style images optimized for XHS engagement. Use when user mentions 小红书图片, XHS images, RedNote infographics, 小红书种草, or wants social media infographics for Chinese platforms.

#### code-review

version: 1.0

#### release-skills

Universal release workflow. Auto-detects version files and changelogs. Supports Node.js, Python, Rust, Claude Plugin, and generic projects. Use when user says release, 发布, new version, bump version, push, 推送.


---

## 📊 统计信息

| 类别 | 数量 |
|------|------|
| 个人技能 | 13 |
| 共享技能 | 21 |
| **总计** | **34** |

---

## 🔧 技能管理

### 查看技能详情
```bash
# 查看个人技能
cat ~/.claude/skills/[skill-name]/skill.md

# 查看共享技能
cat ~/claude-code-workspace/shared/skills/[skill-name]/skill.md
```

### 添加新技能
```bash
# 创建个人技能
mkdir -p ~/.claude/skills/my-skill
# 编辑 skill.md 文件...

# 创建共享技能（可与其他设备共享）
mkdir -p ~/claude-code-workspace/shared/skills/my-skill
# 编辑 skill.md 文件...
```

### 禁用技能
```bash
# 删除个人技能的符号链接
rm ~/.claude/skills/[skill-name]
```

---

**生成时间**: 2026-03-05 21:42:25
**脚本版本**: 1.0.0
