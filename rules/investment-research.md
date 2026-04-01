---
name: investment-research
preamble-tier: 3
version: 0.2.0
description: |
  投资研究专家 v2：双轨并行分析（一级市场 VC + 二级市场），综合决策交付。
  一家公司同时从两个视角看，交叉验证。
  Use when asked to: "分析这只股票", "该不该买", "财报分析", "宏观分析",
  "市场情绪", "估值", "投资决策", "投资报告", "分析这个项目", "/analyze", "/fa", "/vi"。
  Proactively suggest when: 用户提到某只股票、财报季、市场波动、创业项目，
  或需要做出投资决策。
allowed-tools:
  - Bash
  - Read
  - Grep
  - Glob
  - AskUserQuestion
  - WebSearch
benefits-from: [information-processing, ljg-invest]
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
| 创业项目分析 | "投资报告", "分析这个项目", "BP 分析" |

## 核心架构：双轨并行

触发一家公司名 → **同时**从两个视角分析 → 交叉验证 → 综合决策

```
用户输入：公司名 / 项目名
    │
    ├── 轨道 A：一级市场 / VC 视角
    │     └── /ljg-invest
    │         ├─ 秩序创造机器判定
    │         ├─ 创生公式
    │         ├─ 市场认知差
    │         └─ 投资建议（换不换）
    │         （独立 sub-agent 执行）
    │
    ├── 轨道 B：二级市场视角
    │     └── 现有分析模块
    │         ├─ tech-earnings-deepdive（科技股财报）
    │         ├─ us-value-investing（价值投资）
    │         ├─ macro-liquidity（宏观流动性）
    │         ├─ us-market-sentiment（市场情绪）
    │         └─ crypto-bottom（加密底部信号）
    │         （独立 sub-agent 执行）
    │
    └── 综合决策
          ├─ 两个视角的交叉验证
          ├─ 认知差分析（一级 vs 二级市场的定价差异）
          ├─ 买入 / 观望 / 卖出
          ├─ 置信度
          └─ 退出信号
```

## 工作流

### Step 1: 识别分析类型

```
用户请求
    │
    ├── 综合分析 → 双轨并行（推荐）
    │     同时启动轨道 A + 轨道 B
    │
    ├── 纯一级市场 → /ljg-invest
    │     适合：创业项目、BP 分析、早期投资
    │
    ├── 纯二级市场 → 单模块分析
    │     ├─ macro-liquidity → 宏观流动性
    │     ├─ us-market-sentiment → 市场情绪
    │     ├─ tech-earnings-deepdive → 科技股财报
    │     └─ us-value-investing → 价值投资
    │
    └── 信息搜集 → information-processing（先搜资料再分析）
```

### Step 1.5: 市场情绪扫描（新增）

**在深度分析前，先用 last30days 扫描市场情绪：**

```bash
# 安装 last30days-skill
cd ~/claude-code-workspace/shared/skills/
git clone https://github.com/mvanhorn/last30days-skill.git

# 使用场景：
# 1. 投资标的情绪扫描
last30days "市场对 [公司名] 的看法" "people are saying about [公司名]"

# 2. 行业情绪扫描
last30days "[行业] 未来30天趋势" "[行业] outlook"

# 3. 预测市场信号（如果有 Polymarket 数据）
last30days "[公司/事件] 预测市场" "[公司/事件] prediction market"
```

**输出解读：**
- 社区讨论热度：关注度指标
- 主导观点：看多/看空比例
- 预测市场赔率：真金白银押注的概率
- 时间趋势：情绪是在升温还是降温

### Step 2: 执行分析

**双轨并行模式**（默认推荐）：
- 轨道 A 和轨道 B **同时启动**，各自独立 sub-agent
- 轨道 A 用 /ljg-invest 的秩序创造机器框架
- 轨道 B 用现有四模块（可选择性启动所需模块）
- 两条轨道完成后进入综合决策

**轨道 A（一级市场）核心框架**：
- 秩序创造机器：项目是否在创造新秩序？
- 创生公式：从 0 到 1 的路径是否清晰？
- 市场认知差：市场是否低估了什么？
- 换不换：投资建议

**轨道 B（二级市场）核心框架**：
- 长期视角：企业文化、商业模式、竞争壁垒
- 短期视角：定价、市场情绪、流动性环境
- 财报深度：收入、利润、现金流、指引

### Step 3: 综合决策

```
## 投资决策

### 交叉验证
- 一级市场视角：[结论]
- 二级市场视角：[结论]
- 认知差分析：[一级和二级市场的定价差异在哪里]

### 结论
- 建议：买入 / 观望 / 卖出
- 置信度：高 / 中 / 低
- 关键信号：[列出]
- 退出信号：[什么情况该撤]

### 详细分析
[按轨道输出]
```

## 管辖的技能

| 技能 | 用途 | 触发 |
|------|------|------|
| /ljg-invest | VC/早期投资分析 | "投资报告", "分析这个项目", "BP 分析" |
| invest-research | 投资研究框架 | "投资研究", "深度分析" |

**子模块**（轨道 B，由 invest-research 编排）：
- us-value-investing — 价值投资评估
- macro-liquidity — 宏观流动性分析
- us-market-sentiment — 市场情绪追踪
- tech-earnings-deepdive — 科技股财报深度分析

## 常见错误

| 错误 | 正确做法 |
|------|----------|
| 跳过信息搜集直接分析 | 先用 information-processing 获取最新数据 |
| 只看单一维度 | 至少考虑长短期两个视角 |
| 只看二级市场忽略一级 | 默认双轨并行，交叉验证 |
| 给出模糊建议 | 必须明确：买入/观望/卖出 + 置信度 |
| 忽略市场环境 | 宏观和情绪是投资决策的重要背景 |

## 与其他专家的关系

| 关系 | 专家 | 说明 |
|------|------|------|
| **上游** | information-processing | 获取公司最新资讯、财报数据 |
| **下游** | 无 | 投资决策是终端输出 |
| **协作** | content-creation | 投资研究报告写作时 |
