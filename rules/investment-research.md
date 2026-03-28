---
name: investment-research
preamble-tier: 3
version: 0.1.0
description: |
  投资研究工作流：宏观分析 → 市场情绪 → 财报深度 → 价值评估 → 综合决策。
  Use when asked to: "分析这只股票", "该不该买", "财报分析", "宏观分析",
  "市场情绪", "估值", "投资决策", "/analyze", "/fa", "/vi"。
  Proactively suggest when: 用户提到某只股票、财报季、市场波动，
  或需要做出投资决策。
allowed-tools:
  - Bash
  - Read
  - Grep
  - Glob
  - AskUserQuestion
  - WebSearch
benefits-from: [information-processing]
workflow:
  upstream: [information-processing]
  suggest: [information-processing]
---

# 投资研究专家

## 触发器

**一旦**出现以下信号，**务必**激活此专家：

| 信号 | 示例 |
|------|------|
| 投资分析 | "分析这只股票", "该不该买", "投资建议" |
| 财报分析 | "财报", "earnings", "业绩" |
| 宏观分析 | "宏观", "流动性", "利率" |
| 市场情绪 | "市场情绪", "恐慌指数", "看多看空" |
| 价值评估 | "估值", "PE", "DCF", "内在价值" |

## 工作流

### Step 1: 识别分析类型

```
用户请求
    │
    ├── 综合分析 → /comprehensive-analysis（一键全流程）
    ├── 单模块分析 → 具体模块
    │   ├── macro-liquidity → 宏观流动性
    │   ├── us-market-sentiment → 市场情绪
    │   ├── tech-earnings-deepdive → 科技股财报
    │   └── us-value-investing → 价值投资
    └── 信息搜集 → information-processing（先搜资料再分析）
```

### Step 2: 执行分析

**综合分析模式** (`/comprehensive-analysis`)：
- 整合四个模块的输出
- 长期视角：企业文化、商业模式、竞争壁垒
- 短期视角：定价、市场情绪、流动性环境
- 输出：明确的买入/不买入建议 + 市场信号

**单模块模式**：
- 根据用户指定的模块深入分析
- 可独立使用，也可配合综合分析

### Step 3: 输出格式

```
## 分析结论
- 建议：买入 / 观望 / 不买入
- 置信度：高 / 中 / 低
- 关键信号：[列出]

## 详细分析
[按模块输出]
```

## 管辖的技能

| 技能 | 用途 | 触发 |
|------|------|------|
| /comprehensive-analysis | 综合投资分析（主入口） | "分析公司", "/analyze" |
| invest-research | 投资研究框架 | "投资研究", "深度分析" |

**子模块**（由 invest-research 编排）：
- us-value-investing — 价值投资评估
- macro-liquidity — 宏观流动性分析
- us-market-sentiment — 市场情绪追踪
- tech-earnings-deepdive — 科技股财报深度分析

## 常见错误

| 错误 | 正确做法 |
|------|----------|
| 跳过信息搜集直接分析 | 先用 information-processing 获取最新数据 |
| 只看单一维度 | 至少考虑长短期两个视角 |
| 给出模糊建议 | 必须明确：买入/观望/不买入 + 置信度 |
| 忽略市场环境 | 宏观和情绪是投资决策的重要背景 |

## 与其他专家的关系

| 关系 | 专家 |
|------|------|
| **上游** | information-processing（获取公司最新资讯、财报数据） |
| **下游** | 无（投资决策是终端输出） |
| **协作** | content-creation（投资研究报告写作时） |
