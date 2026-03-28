---
name: content-creation
preamble-tier: 2
version: 0.1.0
description: |
  统一内容创作工作流：写作 → 格式化 → 去 AI 痕迹 → 配图 → 转换 → 发布。
  Use when asked to: "写", "写文章", "配图", "做PPT", "做幻灯片", "发布",
  "转换", "排版", "去AI痕迹", "humanize", "润色", "/write".
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
benefits-from: [information-processing, humanizer-zh, frontend-slides, frontend-design, ui-ux-pro-max]
workflow:
  upstream: [information-processing]
  next: [information-processing]
  suggest: [humanizer-zh]
---

# 内容创作专家

## 触发器

**一旦**出现以下信号，**务必**激活此专家：

| 信号 | 示例 |
|------|------|
| 写作请求 | "帮我写", "写一篇文章", "起草" |
| 格式化/转换 | "转成HTML", "格式化Markdown", "排版" |
| 去AI痕迹 | "润色", "humanize", "读起来太AI了" |
| 视觉生成 | "配图", "封面图", "信息图", "幻灯片" |
| 跨平台发布 | "发到微信", "发到X", "发布" |

## 工作流

### Step 1: 识别创作意图

```
用户请求
    │
    ├── 纯写作 → unified-writer
    ├── 去AI痕迹 → humanizer-zh
    ├── 幻灯片/PPT → frontend-slides
    ├── UI/前端设计 → frontend-design / ui-ux-pro-max
    └── 跨平台发布 → unified-writer (路由到子工具)
```

### Step 2: 选择执行路径

**统一入口**：`/write` 或 `unified-writer`
- AI 分析上下文，自动路由到最佳子工具
- 无需用户手动指定子工具
- 配置优先级：项目 > 用户 > 默认

### Step 3: 后处理

| 场景 | 后处理 |
|------|--------|
| 生成中文内容 | **自动**经过 humanizer-zh 处理 |
| 生成幻灯片 | 检查 viewport 适配（100vh/100dvh，不可滚动） |
| 发布前 | 确认目标平台格式要求 |

## 管辖的技能

| 技能 | 用途 | 触发 |
|------|------|------|
| `/write` (unified-writer) | 统一写作入口 | 任何写作/格式化/发布请求 |
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

## 与其他专家的关系

| 关系 | 专家 |
|------|------|
| **上游** | information-processing（获取素材后创作） |
| **下游** | information-processing（发布后可能需要推广） |
| **协作** | development（技术文档写作时） |
