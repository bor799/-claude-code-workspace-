---
name: content-creation
preamble-tier: 2
version: 0.2.0
description: |
  内容创作专家 v2：输入模块 + 输出模块，完整创作闭环。
  先读透素材，再写透交付。
  Use when asked to: "写", "写文章", "配图", "做PPT", "做幻灯片", "发布",
  "转换", "排版", "去AI痕迹", "humanize", "润色", "/write", "铸卡",
  "做成图", "做成卡片", "信息图"。
  Proactively suggest when: 用户完成了信息获取后需要产出内容，或需要将内容适配到特定平台。
allowed-tools:
  - Bash
  - Read
  - Write
  - Edit
  - Glob
  - Grep
  - AskUserQuestion
  - WebSearch
benefits-from: [information-processing, humanizer-zh, frontend-slides, frontend-design, ui-ux-pro-max, ljg-writes, ljg-card, ljg-paper-flow, ljg-word-flow, ljg-learn, ljg-plain]
workflow:
  upstream: [information-processing]
  next: [information-processing]
  suggest: [humanizer-zh, ljg-writes]
---

# 内容创作专家

## 触发器

**一旦**出现以下信号，**务必**激活此专家：

| 信号 | 示例 |
|------|------|
| 写作请求 | "帮我写", "写一篇文章", "起草" |
| 深度写作 | "带着观点写", "写一篇深度文章" |
| 去 AI 痕迹 | "润色", "humanize", "读起来太AI了" |
| 视觉生成 | "配图", "封面图", "信息图", "铸卡", "做成图" |
| 幻灯片 | "PPT", "幻灯片", "演讲稿" |
| 跨平台发布 | "发到微信", "发到X", "发布" |
| 格式化/转换 | "转成HTML", "格式化Markdown", "排版" |

## 工作流

### 输入模块：读透素材（写作前的准备）

写作不是凭空输出。写之前先确保素材被深度消化：

| 素材类型 | 技能 | 说明 |
|----------|------|------|
| 技术论文 | /ljg-paper | 先读透论文核心思想再动笔 |
| 技术概念 | /ljg-learn | 先八维解剖概念再解释 |
| 背景资料 | /ljg-plain | 先白话消化再创作 |

这些是写作的**前置步骤**，不是独立的研究环节。目的是为输出准备素材。

### 输出模块：写透交付

### Step 1: 识别创作意图

```
创作请求
    │
    ├── 深度观点文 → /ljg-writes（找核→攻核→展开→磨）
    ├── 平台内容 → /write（统一写作入口）
    ├── 去 AI 痕迹 → humanizer-zh
    ├── 视觉输出 → /ljg-card（6种模具）
    ├── 幻灯片/PPT → frontend-slides
    ├── UI/前端设计 → frontend-design / ui-ux-pro-max
    └── 跨平台发布 → /write（路由到子工具）
```

### Step 2: 选择执行路径

**统一入口**：`/write` 或 `unified-writer`
- AI 分析上下文，自动路由到最佳子工具
- 无需用户手动指定子工具
- 配置优先级：项目 > 用户 > 默认

**深度写作入口**：`/ljg-writes`
- 适合：带观点的深度文章
- 流程：找核 → 攻核 → 展开 → 磨

**视觉输出入口**：`/ljg-card`
- 6种模具：长图(-l)、信息图(-i)、多卡片(-m)、视觉笔记(-v)、漫画(-c)、白板(-w)
- 替代多个 baoyu-* 视觉技能

### Step 3: 后处理

| 场景 | 后处理 |
|------|--------|
| 生成中文内容 | **自动**经过 humanizer-zh 处理 |
| 生成幻灯片 | 检查 viewport 适配（100vh/100dvh，不可滚动） |
| 发布前 | 确认目标平台格式要求 |

### Step 4: 发布

| 平台 | 工具 |
|------|------|
| 微信 | baoyu-post-to-wechat |
| X | baoyu-post-to-x |
| 幻灯片 | frontend-slides |

## 工作流快捷方式

| 工作流 | 技能链 | 说明 |
|--------|--------|------|
| /ljg-paper-flow | ljg-paper → ljg-card | 读论文 + 做卡片一气呵成 |
| /ljg-word-flow | ljg-word → ljg-card -i | 单词分析 + 信息图卡片一气呵成 |

## 管辖的技能

| 技能 | 用途 | 触发 |
|------|------|------|
| `/write` (unified-writer) | 统一写作入口 | 任何写作/格式化/发布请求 |
| /ljg-writes | 深度写作引擎 | "写一篇深度文章"、"带着观点写" |
| /ljg-card | 内容铸卡 | "做成图"、"信息图"、"长图"、"铸卡" |
| /ljg-paper-flow | 论文+卡片 | "读论文并做卡片" |
| /ljg-word-flow | 单词+卡片 | "词卡"、"word card" |
| humanizer-zh | 去 AI 痕迹 | 中文文本润色、humanize |
| frontend-slides | 幻灯片生成 | PPT 转换、演讲稿 |
| frontend-design | 前端界面 | 网页组件、页面 |
| ui-ux-pro-max | UI/UX 设计 | 设计系统、风格选择 |

## 写作偏好

- 中文内容优先使用自然流畅的表达
- 避免过度使用连接词（因此、从而、进而）
- 避免 AI 典型模式：三段式、排比、破折号滥用、空洞总结
- 技术文档保持简洁，不做过度解释
- 内容要有信息增量，不要水字数

## 常见错误

| 错误 | 正确做法 |
|------|----------|
| 手动选择子工具 | 让 AI 自动路由 |
| 跳过 humanizer-zh | 中文内容自动后处理 |
| 幻灯片超过 viewport | 强制 100vh/100dvh |
| 忽略目标平台格式 | 发布前确认格式要求 |
| 不读素材直接写 | 先用输入模块消化素材再动笔 |

## 与其他专家的关系

| 关系 | 专家 | 说明 |
|------|------|------|
| **上游** | information-processing | 素材和信息由信息处理专家提供 |
| **协作** | development | 技术文档写作时 |
