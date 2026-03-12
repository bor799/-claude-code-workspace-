# Claude Code 配置文件

## 关于我

我是一个追求**极致效率**的开发者，专注于：
- **功能开发**：快速交付高质量的功能实现
- **代码审查与重构**：保持代码库的健康和可维护性
- **性能分析与优化**：识别和解决性能瓶颈
- **文档与知识管理**：构建系统化的知识体系

## 工作理念

### 核心原则
1. **自动化优先**：将重复性任务转化为可复用的 AI skills
2. **系统化思维**：建立评估体系，持续改进工作流程
3. **知识复用**：通过文档和技能库积累经验
4. **质量与效率并重**：不牺牲代码质量的快速交付

### 工作风格
- **直接务实**：用最简单直接的方案解决问题
- **主动思考**：在执行前理解上下文，避免无效工作
- **持续优化**：每次会话后评估性能，识别改进点

## 评估框架

我使用基于以下标准的性能评估体系（详见 evaluation prompt）：

### 评估维度
1. **Spec Stability (25%)** - 需求稳定性
2. **First-Attempt Accuracy (25%)** - 首次执行准确性
3. **Feedback Sentiment (20%)** - 反馈情感倾向
4. **Autonomy Level (15%)** - 自主工作能力
5. **Completion Quality (15%)** - 完成质量

### 红旗警示（扣分项）
- "Wrong path" 纠正：-10分/次
- 重复相同错误：-15分/次
- 用户重复解释同一事项：-10分/次
- 忽略明确指令：-20分/次
- 需要重做大量工作：-25分/次

## 交互偏好

### 我希望你做的事
- ✅ **主动规划**：复杂任务前先规划，用 TodoWrite 展示步骤
- ✅ **并行工作**：独立操作使用并行工具调用提升效率
- ✅ **精准编辑**：使用 Edit 工具而非重写整个文件
- ✅ **及时汇报**：用简洁的语言说明进展和关键发现
- ✅ **遵循模式**：识别项目中的现有模式，保持一致性
- ✅ **智能 URL 处理**：收到 URL 时严格按照工具优先级处理
  - **LEVEL 0**: agent-reach CLI（最高优先级）
  - **LEVEL 1**: MCP 服务器（如 agent-reach 不可用）
  - **LEVEL 2**: 内置工具（最后手段）
  - **内容类型判断**：
    - **文章/长内容** → 使用 100X 知识萃取系统深度分析
    - **推文/短内容** → 询问用户意图（转换/萃取/两者都要）
    - **代码仓库** → 使用 github-mcp 或代码搜索
    - **其他网页** → 先用 agent-reach 读取，再判断处理方式

### 我不希望你做的事
- ❌ **过度工程**：避免为未来可能的需求添加复杂性
- ❌ **假设推测**：不确定时主动询问，不要猜测
- ❌ **忽略上下文**：先阅读相关文件再提出修改建议
- ❌ **冗余注释**：不自添加显而易见的注释或文档
- ❌ **批量完成**：及时标记任务完成，不要批量更新状态

## 技能系统

### 可用技能
1. **/evaluate** - 会话性能评估
   - 基于五维度评估框架分析会话质量
   - 识别红旗问题和改进机会
   - 生成绩效报告和优化建议

2. **/review** - 代码审查
   - 检查代码质量、安全性、性能
   - 识别重构机会
   - 提供具体改进建议

3. **/plan-feature** - 功能规划
   - 分析需求并拆解任务
   - 识别依赖关系和风险
   - 提供实现策略建议

4. **/refactor** - 重构指导
   - 评估代码复杂度
   - 提供重构路径
   - 保持功能不变的前提下优化结构

## Agent 工具设计原则

> 基于 Claude Code 团队的实践经验：构建 Agent 工具系统的核心矛盾——如何在保持模型能力与工具复杂度之间找到平衡。

### 核心理念

1. **工具越少越好**：每个新工具都增加模型认知负担，降低决策质量
2. **匹配模型能力**：工具必须匹配模型当前能力水平，而非人类直觉
3. **渐进式披露**：通过文件引用链让 Agent 递进式发现上下文
4. **观察驱动迭代**：通过观察模型输出、实验、迭代来理解模型边界

### 四大设计模式

| 模式 | 场景 | 方法 | 案例 |
|------|------|------|------|
| **工具拆分** | 多功能工具导致认知冲突 | 拆分为独立、单一职责工具 | ExitPlan → AskUserQuestion |
| **约束解除** | 模型能力进化，工具成为束缚 | 移除过度保护机制 | TodoWrite → Task |
| **自主构建** | 系统被动提供上下文 | 提供搜索工具，让模型自主构建 | RAG → Grep + 渐进式披露 |
| **Subagent 委托** | 低频但复杂的专业任务 | 创建专门 Subagent 按需处理 | Claude Code Guide |

### 工具设计检查清单

**新增工具前**：
- [ ] 是否能通过修改现有工具解决？
- [ ] 是否能用渐进式披露实现？
- [ ] 模型是否理解工具的正确用法？
- [ ] 是否会增加不必要的认知负担？
- [ ] 新工具的使用频率是否足够高？

**现有工具审查**：
- [ ] 模型是否主动规避此工具？
- [ ] 此工具是否限制了模型新能力的发挥？
- [ ] 工具职责是否过于复杂需要拆分？

## 信息搜寻系统

### 工具优先级（严格遵循）

| 优先级 | 工具 | 用途 | 命令 |
|--------|------|------|------|
| **LEVEL 0** | xreach | Twitter/X 内容 | `xreach tweet <url> --json` |
| **LEVEL 0** | Jina Reader | 通用网页读取 | `https://r.jina.ai/<url>` |
| **LEVEL 0** | 100X 知识萃取 | 深度分析文章 | `python src/main.py` |
| **LEVEL 1** | agent-reach | 平台搜索 | `agent-reach search-twitter <query>` |
| **LEVEL 2** | 内置工具 | 最后手段 | `web_search`, `web_fetch` |

### URL 处理流程

```
收到 URL → 判断类型 → 选择工具 → 提取内容 → 判断处理方式
   ↓           ↓           ↓          ↓           ↓
Twitter/X  →  xreach   →  推文内容  →  询问用户意图
微信文章  →  Jina Reader → 长文章    →  100X 深度分析
其他网页  →  Jina Reader → 网页内容   →  根据 URL 类型判断
代码仓库  →  github-mcp → 代码内容  →  分析或阅读
```

### xread (Twitter 专用)

**路径**: `/Users/murphy/.npm-global/bin/xreach`

**读推文**:
```bash
xreach tweet "<url>" --json
```

**特点**:
- 使用 Twitter API 读取完整推文
- 支持认证信息配置
- 输出 JSON 格式

### Jina Reader (通用网页)

**使用方式**:
```bash
curl "https://r.jina.ai/<url>"
```

**特点**:
- 无需认证，直接使用
- 自动提取标题和正文
- 输出 Markdown 格式
- 支持微信公众号等复杂页面

### 100X 知识萃取系统

**路径**: `/Users/murphy/Documents/Obsidian Vault/职业发展/项目案例/100X_知识萃取系统/knowledge-extractor`

**NBO 调用方式**:
```bash
# 写入链接到输入文件
echo "<URL>" >> ~/.nanobot/workspace/wechat_inbox.txt

# 执行分析
cd "/Users/murphy/Documents/Obsidian Vault/职业发展/项目案例/100X_知识萃取系统/knowledge-extractor" && /opt/miniconda3/bin/python3 src/main.py --verbose
```

**功能**:
- 读取用户发送的链接（Twitter、微信、网页等）
- AI 分析内容质量（评分 1-10 分）
- 提取核心洞察、方法论、金句
- 推送到 Telegram（所有评分）
- 存储高分内容到 Obsidian（>6 分）

**输出**:
- Telegram 推送（所有评分）
- Obsidian 存储（>6 分）
- 每日简报 (`~/.nanobot/workspace/daily_digest.md`)

## 项目上下文

### 当前工作重点
- 构建 AI 辅助开发的标准化工作流
- 识别和自动化重复性任务
- 建立可复用的技能库

### 优先级判断
- **高优先级**：影响核心功能的 Bug、性能瓶颈、安全漏洞
- **中优先级**：代码质量改进、重构优化、文档完善
- **低优先级**：边缘功能、非关键优化、探索性实验

### 技术栈偏好
- 优先使用项目现有技术栈
- 避免引入不必要的依赖
- 选择成熟、稳定的解决方案

## 沟通协议

### 报告格式
使用简洁的 Markdown 格式：
- **进展**：当前正在做什么
- **发现**：关键信息或问题
- **下一步**：接下来的计划

### 错误处理
遇到问题时：
1. 清晰描述问题现象
2. 提供可能的根本原因
3. 给出2-3个解决方案及权衡
4. 推荐最优方案并说明理由

### 决策咨询
需要我做选择时：
- 使用 AskUserQuestion 工具
- 提供清晰的选项和影响说明
- 包含推荐的选项及理由

## 持续改进

每次会话结束后，我会：
1. 评估本次会话的性能得分
2. 识别可以自动化的重复任务
3. 更新技能库和配置文件
4. 记录有价值的经验和模式

---

## GitHub 配置

### 仓库信息

- **用户名**: bor799
- **邮箱**: 2822887579@qq.com
- **主页**: https://github.com/bor799
- **工作区仓库**: https://github.com/bor799/-claude-code-workspace-
- ⚠️ **注意**: 仓库名称前后都有横杠

### GitHub 认证

- **Token 已创建**: ✅ 是
- **Token 位置**: 已配置到 Git 远程仓库
- **Token 名称**: claude-code-sync
- **Token 权限**: repo (完整仓库访问)
- **Token 创建日期**: 2026-02-02

**重要**: Token 已保存在 Git 配置中，无需每次输入。如需更换，请访问 https://github.com/settings/tokens

### 同步机制

**工作区位置**: `~/claude-code-workspace`

**A 电脑 (macOS)**:
- 推送: `cd ~/claude-code-workspace/scripts && ./sync-mac.sh push`
- 拉取: `cd ~/claude-code-workspace/scripts && ./sync-mac.sh pull`
- 状态: `cd ~/claude-code-workspace/scripts && ./sync-mac.sh status`

**B 电脑 (Windows 11)**:
- 推送: `cd $env:USERPROFILE\claude-code-workspace\scripts; .\sync-windows.ps1 push`
- 拉取: `cd $env:USERPROFILE\claude-code-workspace\scripts; .\sync-windows.ps1 pull`
- 状态: `cd $env:USERPROFILE\claude-code-workspace\scripts; .\sync-windows.ps1 status`

### 更新流程

1. 修改本地文件（CLAUDE.md、技能、文档）
2. 运行同步脚本推送到 GitHub
3. 在另一台电脑运行拉取脚本
4. 自动安装到系统，立即可用

### 认证方式

使用 Claude Code 内置的 GitHub 代理进行认证，无需手动配置 Token 或 SSH 密钥。

**详细配置指南**: 查看 `~/claude-code-workspace/docs/GitHub 配置指南-小白版.md`

---

**最后更新**: 2026-03-06
**目标**: 通过 AI 辅助实现 10x 开发效率提升

---

## 共享配置

本系统使用共享配置库，与 Nanobot 保持一致：

- **共享技能**: `~/claude-code-workspace/shared/skills/`
- **工具优先级**: `~/claude-code-workspace/shared/preferences/tool-priorities.md`
- **学习风格**: `~/claude-code-workspace/shared/preferences/learning-style.md`
- **用户画像**: `~/claude-code-workspace/shared/memory/user-profile.md`

### 同步更新

修改共享配置后，无需额外操作，两边同时生效。

查看配置状态: `cd ~/claude-code-workspace/shared/sync && ./sync-all.sh --help`

---

## 经验教训（来自 100X 系统集成）

### 避免的错误

1. **过度自主实现**：遇到 URL 处理时，应该优先使用现有工具（agent-reach、xreach、Jina），而不是自己实现
2. **忽略用户明确指令**：用户说"持续测试"时，应该使用 `dangerouslyDisableSandbox: true` 而非反复询问
3. **错误假设**：假设系统架构而非询问或查看文档

### 关键学习

1. **系统边界**：100X 由 NBO 调用，不是独立运行
2. **网络依赖**：Telegram API 需要代理才能访问
3. **回退机制**：API 失败时应该有备用方案（模拟模式）
4. **工具优先级**：严格遵循 LEVEL 0 → LEVEL 1 → LEVEL 2 的顺序

### 记录的模式

- macOS 扩展属性会阻止脚本执行：`xattr -cr <file>`
- Python fcntl 文件锁：用于防止多实例竞争
- 统一提取器模式：主工具 + fallback 工具处理不同场景
- 代理配置：所有外部 API 调用都需要考虑代理
