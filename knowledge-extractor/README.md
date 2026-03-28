# Knowledge Extractor

[English](#english) | [中文](#chinese)

---

<a id="english"></a>
## English

### Overview

**Knowledge Extractor v3.0** is an intelligent knowledge extraction skill for Claude Code that analyzes any content (articles, tweets, documents) and extracts high-value insights using AI.

**New in v3.0**: Intelligence Analyst persona, underwater insights extraction, golden quotes, methodology modeling, and universal taxonomy.

### Features

- **Intelligence Analyst Persona**: 10-year experienced analyst & cognitive scientist
- **Core Output Structure**: Reconstructed title, one-sentence summary, underwater insights, golden quotes, methodology modeling
- **Content-Aware Analysis**: Automatically adapts strategy for short messages vs long-form content
- **Universal Taxonomy**: Covers business, technology, cognitive growth, and industry insights
- **Multiple Output Formats**: Markdown, JSON, HTML, Notion
- **Smart Scoring**: Enhanced with counter-intuitive insights, pitfall lessons, and insider information

### Installation

1. Copy the `knowledge-extractor.md` file to your Claude Code skills directory:

```bash
# macOS/Linux
cp knowledge-extractor.md ~/.claude/skills/

# Windows
copy knowledge-extractor.md %USERPROFILE%\.claude\skills\
```

2. Restart Claude Code

### Usage

```
# Analyze an article (default universal taxonomy)
Use knowledge-extractor to analyze: https://example.com/article

# Analyze a tweet
Use knowledge-extractor with content_type=twitter to analyze this tweet

# Use v2.0 data science taxonomy
Use knowledge-extractor with taxonomy=v2.0 to analyze

# Custom taxonomy
Use knowledge-extractor with taxonomy={Investment:[Strategy,Macro,Stocks]} to analyze

# Output as Notion format
Use knowledge-extractor with output_format=notion to analyze: [content]

# Filter low-quality content
Use knowledge-extractor with min_score=7 to keep only high-scoring content
```

### Parameters

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `content` | text/url | Required | Content to analyze |
| `content_type` | string | "auto" | Content type: auto/long/short/twitter |
| `taxonomy` | object | Universal | Custom classification system |
| `min_score` | number | 0 | Minimum score threshold (0-10) |
| `output_format` | string | "markdown" | Output: markdown/json/html/notion |

### Output Format

#### Short Content (< 300 chars)

```json
{
  "content_type": "short",
  "category_l1": "Technology & Product",
  "category_l2": "AI/LLM",
  "score": 7,
  "scoring_rationale": "High density insights (+2), specific examples (+1)",
  "information_density": "high",
  "key_points": ["Insight 1", "Insight 2"],
  "information_gain": "New discovery about X",
  "entities": ["OpenAI", "GPT-4"],
  "verdict": "Worth saving"
}
```

#### Long Content (>= 300 chars) - v3.0

```json
{
  "content_type": "long",
  "category_l1": "Technology & Product",
  "category_l2": "AI/LLM",
  "score": 8.5,
  "scoring_rationale": "Counter-intuitive (+3), pitfall lessons (+1), actionable (+1)",
  "reconstructed_title": "Prompt Engineering Hallucination Traps & Chain Validation",
  "one_sentence_summary": "Background: Prompt engineering is core to AI applications. Conflict: Most prompts have hallucination issues. Solution: Use chain validation and structured output design.",
  "entities": ["OpenAI", "Anthropic", "LangChain"],
  "underwater_insights": [
    {"type": "Counter-intuitive", "content": "Longer complex prompts perform worse"},
    {"type": "Pitfall", "content": "Temperature >0.7 causes structured output format errors"},
    {"type": "Insider", "content": "Top AI companies use code generation, not natural language prompts"},
    {"type": "Data", "content": "Few-Shot + CoT improves accuracy from 65% to 92%"}
  ],
  "golden_sentences": [
    "Good prompts ask the right questions, not more questions",
    "AI certainty comes from constraints, not freedom"
  ],
  "scenarios_logic": {
    "problem_solved": "How to design reliable AI application prompts",
    "applicable_scenarios": "Agent development, RAG systems, automation workflows",
    "limitations": "Not suitable for creative generation and open conversations",
    "logic_deduction": "Structured input → Chain validation → Constrained output → Result verification"
  },
  "actionable_framework": {
    "tech_stack": ["LangChain", "Pydantic", "OpenAI SDK"],
    "sop": [
      "1. Define structured output schema",
      "2. Design few-shot examples",
      "3. Add validation rules",
      "4. Implement chain validation",
      "5. Monitor and iterate"
    ]
  }
}
```

### Scoring Criteria (v3.0 Enhanced)

#### Plus Factors (All Content)

| Score | Criteria |
|-------|----------|
| +3 | **Exclusive**: First-hand data, insider information, post-mortem |
| +3 | **Counter-intuitive**: Paradigm-shifting conclusions with evidence |
| +2 | **Deep Derivation**: Complete Why-How-What chain |
| +2 | **Concrete Data**: ROI, conversion rates, specific numbers |
| +1 | **Actionable**: Clear execution steps, code, or SOP |
| +1 | **Balanced View**: Shows both pros and cons |
| +1 | **Pitfall Lessons**: Real failure cases and lessons |
| +1 | **Insider Info**: Industry secrets and insider information |

#### Short Content Specific

| Score | Criteria |
|-------|----------|
| +2 | **High Density**: 2+ valuable insights in <100 chars |
| +1 | **Accurate Prediction**: Later verified judgment |
| +1 | **Resource Links**: Points to quality resources |

#### Minus Factors

| Score | Criteria |
|-------|----------|
| -3 | **Buzzword Pile**: Jargon without substance |
| -2 | **Promotional**: Obvious marketing language |
| -2 | **Echo Chamber**: No unique viewpoint |
| -1 | **Pure Emotion**: Complaints with no information |
| -1 | **Tool List**: Just lists tools without analysis |

### Default Taxonomy (v3.0 Universal)

#### Option A: Universal Classification (Default)

```yaml
Business & Finance:
  - Business Model
  - Investment Strategy
  - Macroeconomics

Technology & Product:
  - AI/LLM
  - Engineering Practice
  - Product Methodology

Cognitive & Growth:
  - Mental Models
  - Learning Methods
  - Health Management

Industry Insights:
  - Trend Analysis
  - Competitive Landscape
  - Unspoken Rules
```

#### Option B: Data Science Classification (v2.0 Preserved)

```yaml
Data Science:
  - Product Thinking
  - Statistical Principles
  - Code Engineering

AI:
  - Applications and Principles
  - Evaluation and Safety
  - Marketing and Growth

Health and Growth:
  - Physical Fitness
  - Mental Cognition
  - Personal Development

Investment and Finance:
  - Investment Strategy
  - Macroeconomics
  - Financial Knowledge

Product and Business:
  - Product Methodology
  - Business Model
  - Growth Strategy
```

### Version History

#### v3.0 (2026-02-26)
- New Intelligence Analyst & Cognitive Scientist persona
- New core output: reconstructed title, one-sentence summary, underwater insights, golden quotes, methodology modeling
- New universal taxonomy covering business, technology, cognitive growth, industry insights
- Enhanced scoring with counter-intuitive, pitfall lessons, and insider info dimensions
- Backward compatible with v2.0 all parameters and features

#### v2.0 (2026-02-26)
- Content type adaptation (short messages vs long-form)
- Refactored scoring criteria focusing on information gain
- New short-content specific scoring items
- New HTML/Notion output formats

### License

MIT License - see [LICENSE](LICENSE) file.

---

<a id="chinese"></a>
## 中文

### 简介

**Knowledge Extractor v3.0** 是 Claude Code 的智能知识萃取 skill，使用 AI 分析任何内容（文章、推文、文档），提取高价值洞察。

**v3.0 新特性**：情报分析师角色、水下信息萃取、金句提取、方法论建模、通用分类体系。

### 核心特性

- **情报分析师角色**：10年经验的首席情报分析师 + 认知科学家
- **核心输出结构**：重构标题、一句话归纳、水下信息、金句萃取、方法论建模
- **内容自适应分析**：自动识别短消息和长文，采用不同策略
- **通用分类体系**：覆盖商业、技术、认知成长、行业洞察
- **多格式输出**：Markdown、JSON、HTML、Notion
- **智能评分**：新增反常识、踩坑经验、内幕揭露维度

### 安装

1. 将 `knowledge-extractor.md` 复制到 Claude Code skills 目录：

```bash
# macOS/Linux
cp knowledge-extractor.md ~/.claude/skills/

# Windows
copy knowledge-extractor.md %USERPROFILE%\.claude\skills\
```

2. 重启 Claude Code

### 使用示例

```
# 分析文章（默认通用分类）
使用 knowledge-extractor 分析：https://example.com/article

# 分析推文
使用 knowledge-extractor，content_type=twitter，分析这条推文

# 使用 v2.0 数据科学分类
使用 knowledge-extractor，taxonomy=v2.0，分析内容

# 自定义分类
使用 knowledge-extractor，taxonomy={投资:[策略,宏观,个股]}，分析内容

# 输出 Notion 格式
使用 knowledge-extractor，output_format=notion，分析：[内容]

# 过滤低质量内容
使用 knowledge-extractor，min_score=7，只保留高分内容
```

### 参数说明

| 参数 | 类型 | 默认值 | 说明 |
|------|------|--------|------|
| `content` | text/url | 必填 | 要分析的内容 |
| `content_type` | string | "auto" | 内容类型: auto/long/short/twitter |
| `taxonomy` | object | 通用体系 | 自定义分类体系 |
| `min_score` | number | 0 | 最低评分阈值（0-10） |
| `output_format` | string | "markdown" | 输出: markdown/json/html/notion |

### 评分标准（v3.0 增强）

#### 通用加分项

| 分值 | 标准 |
|------|------|
| +3 | **独家信息**：一手数据、内幕、复盘 |
| +3 | **反常识**：颠覆常识结论，有证据 |
| +2 | **深度推导**：完整 Why-How-What 链条 |
| +2 | **具体数据**：ROI、转化率、具体数字 |
| +1 | **可操作**：明确执行步骤、代码、SOP |
| +1 | **辩证视角**：展示正反两面 |
| +1 | **踩坑经验**：真实失败案例和教训 |
| +1 | **内幕揭露**：行业潜规则、内幕信息 |

#### 减分项

| 分值 | 标准 |
|------|------|
| -3 | **概念堆砌**：术语无实质内容 |
| -2 | **软文/公关**：明显营销话术 |
| -2 | **复读机**：无独特观点 |
| -1 | **纯情绪宣泄**：抱怨无信息量 |
| -1 | **工具清单**：只罗列工具无分析 |

### 默认分类体系（v3.0 通用版）

#### 方案 A：通用分类（默认）

```yaml
商业与财经:
  - 商业模式
  - 投资策略
  - 宏观经济

技术与产品:
  - AI/LLM
  - 工程实践
  - 产品方法论

认知与成长:
  - 思维模型
  - 学习方法
  - 健康管理

行业洞察:
  - 趋势分析
  - 竞争格局
  - 潜规则
```

#### 方案 B：数据科学分类（v2.0 保留）

```yaml
数据科学:
  - 产品思维
  - 统计原理
  - 代码工程

AI:
  - 应用和原理
  - 评估和安全
  - 营销增长

健康与成长:
  - 身体机能
  - 心理认知
  - 个人精进

投资与理财:
  - 投资策略
  - 宏观经济
  - 理财知识

产品与商业:
  - 产品方法论
  - 商业模式
  - 增长策略
```

### 版本历史

#### v3.0 (2026-02-26)
- 全新情报分析师 + 认知科学家角色定义
- 新增核心输出结构：重构标题、一句话归纳、水下信息、金句萃取、方法论建模
- 新增通用分类体系：覆盖商业、技术、认知、行业洞察
- 增强评分标准：新增反常识、踩坑经验、内幕揭露维度
- 保留向后兼容：v2.0 所有参数和功能完整保留

#### v2.0 (2026-02-26)
- 新增内容类型自适应（短消息/长文）
- 重构评分标准，降低长度权重，关注信息增量
- 新增短消息专属评分项
- 新增 HTML/Notion 输出格式

### 许可证

MIT License - 详见 [LICENSE](LICENSE) 文件。
