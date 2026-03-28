# OpenAI Codex CLI -- 架构学习指南

> 基于 agent-architecture-learning 框架 | 2026-03-28

---

## 一、30 秒定位

**Codex 是什么**：OpenAI 出品的终端 AI 编程 Agent，开源（Apache 2.0），用 Rust 写了 80+ 个 crate。

**核心卖点**：生产级沙箱（macOS Seatbelt / Linux 三层隔离），同类产品里唯一做到 OS 级沙箱的 CLI Agent。

**属于 Agent 四阶模型的哪一阶**：

| 阶阶 | 能力 | Codex 对应 |
|-----|------|-----------|
| 第一阶 | 大脑（LLM 调用） | o3/o4-mini 模型推理 |
| 第二阶 | 手脚（工具体系） | shell、文件读写、补丁、代码搜索 |
| 第三阶 | 经验+自主性 | Agentic 循环、上下文压缩、Memory |
| **第四阶** | **协作能力** | **审批系统（人工/Guardian 子 Agent）、Hooks、中断控制** |

**定位：完整的第四阶 Agent**。不只是"帮你写代码"，而是"和你一起写代码"——你能观察、打断、审批、纠偏。

---

## 二、架构全景

```
用户输入 (CLI / IDE / Web)
    │
    ▼
┌─────────────┐
│  Codex CLI   │  ← 入口，事件处理（human output / JSONL）
└──────┬──────┘
       │
       ▼
┌──────────────────────────────────────────┐
│            CodexThread                   │
│  (会话管理：一个 Thread = 一次工作上下文)    │
├──────────────────────────────────────────┤
│  ContextManager                          │
│  ├─ 系统指令组装（AGENTS.md + Skills）      │
│  ├─ 消息历史 + token 计数                  │
│  └─ 自动压缩 / 摘要                        │
└──────────────┬───────────────────────────┘
               │
               ▼
┌──────────────────────────────────────────┐
│         Agent Loop (ReAct)               │
│                                          │
│  模型推理 → 工具调用 → [审批] → 沙箱执行    │
│       ↑        │                         │
│       └────────┘  (循环直到最终回复)        │
│                                          │
│  工具调用链：                               │
│  PreToolUse Hook → 审批 → 沙箱包装 → 执行  │
│  → PostToolUse Hook → 结果回传模型         │
└──────────────┬───────────────────────────┘
               │
               ▼
┌──────────────────────────────────────────┐
│          SandboxManager                  │
│  macOS: sandbox-exec (Seatbelt/SBPL)     │
│  Linux: bubblewrap + Landlock + seccomp  │
│  Windows: Restricted Token               │
│                                          │
│  模式：ReadOnly / WorkspaceWrite / Full   │
└──────────────────────────────────────────┘
```

**关键设计决策**：

1. **为什么用 Rust 写 80+ crate？** 模块化到极致——沙箱、工具、协议、配置、MCP 各自独立编译。代价是复杂度高，好处是每个部分可以独立测试和替换。

2. **为什么同时做 MCP Client 和 MCP Server？** Codex 既能"使用别人的工具"（Client），也能"把自己变成工具给别人用"（Server）。这是一个双向的 Agent 互操作设计。

3. **为什么搞 OS 级沙箱而不是 Docker？** Docker 太重了。Codex 需要在用户本地快速启动、轻量执行命令。OS 原生沙箱零依赖、毫秒级启动。

---

## 三、核心概念速查

| 概念 | 一句话解释 | 判断标准 |
|------|-----------|---------|
| **ReAct 循环** | 推理→行动→观察，循环往复直到任务完成 | 任何 Agent 都有这个循环，区别在循环里放什么 |
| **沙箱** | 限制 Agent 能碰什么文件、能访问什么网络 | 副作用越大，沙箱越重要 |
| **审批系统** | Agent 要做危险操作时，先问人（或 Guardian 子 Agent） | "有副作用的工具"比例越高，审批越关键 |
| **AGENTS.md** | 项目级指令文件，告诉 Agent 这个项目的规则 | 等同于 Claude Code 的 CLAUDE.md |
| **MCP** | Agent 工具的"USB 接口"——统一协议，即插即用 | 需要连接外部工具时才需要 |
| **App Server** | JSON-RPC 协议，让 IDE（VS Code 等）能驱动 Codex | CLI 之外的第二个交互入口 |
| **ContextManager** | 管理对话历史的"编辑"，控制 token 预算 | 对话越长，压缩策略越重要 |

---

## 四、与竞品对比（选型参考）

| 维度 | Codex CLI | Claude Code | Cursor | Aider |
|------|-----------|-------------|--------|-------|
| 语言 | Rust (80+ crates) | TypeScript | TypeScript | Python |
| 沙箱 | OS 级（最强） | 无原生沙箱 | 无 | 无 |
| 模型 | OpenAI (o3, o4-mini) | Claude | 多供应商 | 多供应商 |
| IDE 集成 | App Server (JSON-RPC) | VS Code 扩展 | 内置 (VS Code fork) | 终端 |
| MCP | Client + Server | Client only | 无 | 无 |
| Hooks | 完整生命周期 | 工具前后 | 无 | 无 |
| 开源 | Apache 2.0 | 闭源 | 闭源 | Apache 2.0 |
| 适合场景 | 安全敏感 / 需要深度定制 | 通用开发 | GUI 交互 | 轻量终端 |

**选型判断**：
- 要最强的安全隔离 → Codex
- 要最好的通用开发体验 → Claude Code
- 要 GUI 交互 → Cursor
- 要最轻量 → Aider

---

## 五、渐进式学习问题

### Tier 1：理解定位（5 分钟）

> 目标：搞清楚 Codex 是什么、解决什么问题、属于 Agent 哪一阶

**Q1**: Codex 是一个 CLI 工具。如果要把它的能力从终端搬到网页上（Codex Web），架构上最大的变化是什么？

> 提示：想想"用户实时交互控制"在终端和网页里分别怎么实现。

**Q2**: Codex 同时支持 `suggest`（建议模式）和 `full-auto`（全自动模式）。从 Agent 四阶模型的角度，这两种模式分别对应第几阶？为什么？

> 提示：想想"用户在不在决策循环里"。

**Q3**: 如果你要做一个"AI 帮用户修 Excel"的产品，你会选 Codex 的架构还是 Claude Code 的架构？为什么？

> 提示：想想你的产品里"有副作用的操作"多不多。

---

### Tier 2：理解架构（15 分钟）

> 目标：看懂架构图，理解各组件之间的关系

**Q4**: Codex 的沙箱有三种模式：ReadOnly、WorkspaceWrite、FullAccess。如果你是产品架构师，你会给"代码审查"任务设什么模式？给"部署上线"任务设什么模式？为什么？

> 提示：三步推理——这个任务涉及哪些操作 → 这些操作有什么副作用 → 需要多大的隔离？

**Q5**: Codex 既是 MCP Client 又是 MCP Server。用业务类比解释一下"双向互操作"的价值。

> 提示：想想"员工能调用外部服务"和"员工本身也能被其他部门调用"。

**Q6**: `ContextManager` 的自动压缩策略，在什么场景下会成为瓶颈？如果你要设计一个更好的策略，你会怎么改？

> 提示：想想"长对话"和"需要回忆之前细节"之间的矛盾。

---

### Tier 3：深度理解（30 分钟）

> 目标：能预判设计决策的后果，能类比到自己的产品

**Q7**: Codex 用 80+ Rust crate 实现了极高的模块化。如果你要做一个类似产品但团队只有 3 个人，你会保留这种架构吗？哪些模块必须拆，哪些可以合？

> 提示：拆的收益是独立测试/替换，代价是协作成本。小团队要平衡。

**Q8**: Guardian 子 Agent（用另一个 AI 来审批操作）这个设计，在你自己的产品场景里适用吗？什么条件下你会用人工审批，什么条件下用 Guardian？

> 提示：人工审批慢但准确，Guardian 快但可能出错。想想你的产品对"出错"的容忍度。

**Q9**: 如果 Codex 要支持"多个 Agent 协同完成一个任务"（比如一个写前端、一个写后端），架构上需要改什么？参考 Codex 现有的 `codex-app-server` 的 Thread/Turn 模型来思考。

> 提示：现有的 Thread 是单 Agent 的。多 Agent 需要什么？共享状态？通信机制？冲突解决？

---

### Tier 4：架构决策模拟（思考题）

> 目标：能把学到的框架用到自己的产品决策中

**Q10**: 假设你要基于 Codex 的架构做一个"AI 投研助手"（读财报、分析数据、生成报告），你会保留 Codex 的哪些组件？哪些不需要？哪些需要改造？

> 提示：逐个过——沙箱需要吗（你的 Agent 不写代码）？审批系统需要吗（报告可能有误导）？MCP 呢（要接外部数据源）？

---

## 六、学习路线建议

### 如果你有 Python 基础（你的情况）

```
第 1 步：用起来（1 小时）
├─ npm i -g @openai/codex
├─ 跑几个简单任务感受一下
└─ 体验 suggest / auto-edit / full-auto 三种模式

第 2 步：看 AGENTS.md（30 分钟）
├─ 它是 Codex 的"项目规则文件"
├─ 对比你项目的 CLAUDE.md
└─ 思考：为什么这个文件如此重要？

第 3 步：理解 Agent Loop（1 小时）
├─ 读 codex-rs/core/src/codex.rs（核心循环）
├─ 不需要逐行懂 Rust，看流程即可
└─ 对比你的 agent-architecture-learning 四阶模型

第 4 步：理解沙箱（1 小时）
├─ 读 sandboxing/src/manager.rs
├─ 理解三种模式的设计意图
└─ 思考：你的产品需要这种隔离吗？

第 5 步：回答 Tier 1-3 的问题（1-2 小时）
└─ 不查资料，先凭理解回答，再对照验证

第 6 步：Tier 4 思考题（选做）
└─ 把 Codex 的设计决策迁移到你的产品场景
```

### 关键文件清单（按阅读优先级）

| 优先级 | 文件 | 看什么 |
|-------|------|-------|
| P0 | `AGENTS.md` | 项目规则模板，Codex 自己如何指导 AI |
| P1 | `codex-rs/core/src/codex.rs` | Agent 核心循环 |
| P1 | `codex-rs/sandboxing/src/manager.rs` | 沙箱架构 |
| P2 | `codex-rs/protocol/src/` | 共享类型定义 |
| P2 | `codex-rs/tools/src/` | 工具系统 |
| P3 | `codex-rs/app-server/src/` | IDE 集成协议 |
| P3 | `codex-rs/hooks/src/` | 生命周期钩子 |

---

## 七、一句话总结

**Codex 的核心创新不在于"AI 能写代码"（这所有产品都能做），而在于两点**：
1. **OS 级沙箱**——让 AI 的"手"被物理约束，这是安全的基础设施
2. **完整的第四阶交互**——审批、中断、Hooks，让人类真正在决策循环里

学 Codex 不是学 Rust，而是学"当一个 Agent 产品需要生产级安全性和人类协作时，架构该怎么设计"。
