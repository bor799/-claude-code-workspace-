# FractalFlow 分形文档架构改造计划

> 基于用户提供的 NBO 工作流设计文档
>
> 创建时间: 2026-03-21

---

## 一、架构原则

### 三层结构

```
┌─────────────────────────────────────────────────────────────┐
│  层级一：根目录主控文档（CLAUDE.md）                         │
│  地位：系统的"灵魂"与强制法典                               │
├─────────────────────────────────────────────────────────────┤
│  层级二：文件夹级架构说明（/.folder.md）                     │
│  地位：局部地图，让 Claude 在子目录下重建局部世界观         │
├─────────────────────────────────────────────────────────────┤
│  层级三：文件头部协议（In/Out/Pos）                         │
│  地位：细胞核信息，描述文件职责和依赖                       │
└─────────────────────────────────────────────────────────────┘
```

### 更新协议

1. **原子更新规则**：代码变更 → 立即更新对应文档
2. **递归触发**：文件变更 → Header 更新 → 文件夹 MD 更新 → （若影响全局）主 MD 更新
3. **分形自治**：确保任何子目录下，Claude 都能通过该目录的 MD 重建局部世界观

---

## 二、目录分类

### 核心系统（优先级：P0）

| 目录 | 职责 | 复杂度 |
|------|------|--------|
| `nanobot-core` | 独立工作区·核心原则 | 高 |
| `nanobot-principles` | 核心原则与模式 | 高 |
| `knowledge-extractor` | CLI 网关（路由到 100X 系统） | 中 |
| `agent-reach` | 互联网访问与平台交互 | 高 |
| `shared` | 共享配置与工具库 | 中 |

> **说明**: `knowledge-extractor` 是 CLI 网关层，真正的 100X 知识萃取系统位于 Obsidian Vault。

### 技能系统（优先级：P1）

| 目录 | 职责 | 复杂度 |
|------|------|--------|
| `comprehensive-analysis` | 综合投资分析（含 5 个 Agent） | 高 |
| `ui-ux-pro-max` | UI/UX 设计系统 | 中 |
| `unified-writer` | 统一写作工具 | 中 |
| `code-review` | 代码审查 | 低 |
| `evaluate-session` | 会话评估 | 低 |
| `plan-feature` | 功能规划 | 低 |
| `doc-manager` | 文档管理 | 低 |

> **说明**: `invest-research` 已合并到 `comprehensive-analysis`。

### 代理系统（优先级：P1）

| 目录 | 职责 | 复杂度 |
|------|------|--------|
| `subagents` | 子代理定义 | 中 |
| `skills` | 技能库（与 shared/skills 共享） | 中 |
| `agent-reach-auto-call` | URL 处理优先级指南 | 低 |

### 工具与支持（优先级：P2）

| 目录 | 职责 | 复杂度 |
|------|------|--------|
| `tools` | 通用工具集 | 低 |
| `frontend-slides` | 前端演示生成 | 低 |
| `lets-go-rss` | RSS 订阅管理 | 低 |
| `cleanup-info-sources` | 信息源清理 | 低 |
| `humanizer-zh` | 中文文本人性化 | 低 |

### 学习与临时（优先级：P3）

| 目录 | 职责 | 复杂度 |
|------|------|--------|
| `agent-architecture-learning` | 架构学习笔记 | 低 |
| `agent-architecture-learning-skill` | 架构学习技能 | 低 |
| `docs` | 文档归档 | 低 |
| `get-last-chat-id` | 临时工具 | 低 |
| `update-last-chat-id` | 临时工具 | 低 |
| `release-skills` | 发布工具 | 低 |
| `process-content` | 内容处理 | 低 |

---

## 三、.folder.md 模板

### 基础模板

```markdown
# <目录名>

## 职责
一句话描述这个目录的核心功能

## 输入
- 输入类型 A
- 输入类型 B

## 输出
- 输出类型 A
- 输出类型 B

## 核心文件
| 文件 | 职责 |
|------|------|
| `file.ts` | 描述 |
| `config/` | 描述 |

## 依赖
- 依赖项 A
- 依赖项 B

## 注意事项
- 重要提醒
- 常见陷阱

## 更新日志
- 2026-03-21: 创建 .folder.md
```

### 高级模板（复杂系统）

```markdown
# <目录名>

> **状态**: <Active/Experimental/Deprecated>
> **维护者**: <Owner>
> **最后更新**: 2026-03-21

## 职责
核心功能描述，系统定位

## 架构

```
<目录名>/
├── core/          # 核心逻辑
├── config/        # 配置文件
├── utils/         # 工具函数
└── tests/         # 测试文件
```

## 数据流

```
输入 → 处理步骤 A → 处理步骤 B → 输出
```

## 输入
| 类型 | 格式 | 来源 |
|------|------|------|
| 输入A | 格式 | 来源 |

## 输出
| 类型 | 格式 | 目标 |
|------|------|------|
| 输出A | 格式 | 目标 |

## 核心文件
| 文件/目录 | 职责 | 依赖 |
|-----------|------|------|
| `main.py` | 主入口 | config.py |
| `utils/` | 工具函数 | - |

## 外部依赖
- Python 3.9+
- OpenAI API
- Telegram Bot Token

## 配置要求
- 环境变量: `API_KEY`, `BOT_TOKEN`
- 配置文件: `config/settings.json`

## 注意事项
1. 需要代理配置
2. 链接通过 NBO 推送
3. 日志自动轮转

## 相关目录
- `../shared/` - 共享工具
- `../nanobot-core/` - 核心原则

## 更新日志
- 2026-03-21: 创建 .folder.md
```

---

## 四、文件头部协议

### Python 文件

```python
"""
文件名: main.py
职责: 知识萃取主入口

输入:
- URL (str): 文章链接
- content (dict): 预处理内容

输出:
- report (dict): 萃取报告
  - score (int): 质量评分
  - insights (list): 核心洞察

依赖:
- openai
- config.settings

位置: knowledge-extractor/src/
"""
```

### TypeScript 文件

```typescript
/**
 * 文件名: client.ts
 * 职责: Gemini Web API 客户端
 *
 * 输入:
 * - prompt: string - 用户提示
 *
 * 输出:
 * - Promise<string> - API 响应
 *
 * 依赖:
 * - @types/node
 * - ./types
 *
 * 位置: gemini-webapi/
 */
```

### Shell 脚本

```bash
#!/bin/bash
# 文件名: sync-mac.sh
# 职责: macOS 同步脚本
#
# 输入: 无
# 输出: 推送到 GitHub
# 依赖: git, gh
# 位置: scripts/

set -euo pipefail
```

### Markdown 文档

```markdown
<!--
文件名: SKILL.md
职责: 技能定义文档

输入: 用户触发词
输出: 技能执行上下文
依赖: ../shared/preferences/
位置: skills/code-review/
-->
```

---

## 五、实施计划

### 第一阶段：核心系统（1-2周）

| 目录 | 状态 | 负责人 |
|------|------|--------|
| `nanobot-core` | ✅ 完成 | - |
| `nanobot-principles` | ✅ 完成 | - |
| `knowledge-extractor` | ✅ 完成 (CLI 网关) | - |
| `agent-reach` | ✅ 完成 | - |
| `shared` | ✅ 完成 | - |

> **P0 核心系统已全部完成！**

### 第二阶段：技能系统（1周）

| 目录 | 状态 | 负责人 |
|------|------|--------|
| `comprehensive-analysis` | ✅ 完成 | - |
| `ui-ux-pro-max` | ✅ 完成 | - |
| `unified-writer` | ✅ 完成 | - |
| `code-review` | ✅ 完成 | - |
| `evaluate-session` | ✅ 完成 | - |
| `plan-feature` | ✅ 完成 | - |
| `doc-manager` | ✅ 完成 | - |

> **P1 技能系统已全部完成！**

### 第三阶段：代理系统（1周）

| 目录 | 状态 | 负责人 |
|------|------|--------|
| `subagents` | ✅ 完成 | - |
| `skills` | ✅ 完成 | - |
| `agent-reach-auto-call` | ✅ 完成 | - |

> **P1 代理系统已全部完成！**

### 第四阶段：工具与支持（按需）

| 目录 | 优先级 |
|------|--------|
| `tools` | P2 |
| `frontend-slides` | P2 |
| `lets-go-rss` | P2 |
| `cleanup-info-sources` | P2 |
| `humanizer-zh` | P2 |

---

## 六、检查清单

### 目录级检查

- [ ] `.folder.md` 文件存在
- [ ] 职责描述清晰
- [ ] 输入输出明确
- [ ] 核心文件列表完整
- [ ] 依赖关系注明
- [ ] 注意事项齐全

### 文件级检查

- [ ] 头部协议存在
- [ ] 职责描述准确
- [ ] 输入输出类型明确
- [ ] 依赖列出
- [ ] 位置注明

---

## 七、维护协议

### 代码变更时

1. 修改代码
2. 更新文件头部协议（如有变化）
3. 更新 `.folder.md`（如有影响）
4. 更新 `CLAUDE.md`（如影响全局）

### 定期审查

- **每周**: 检查新增文件是否有协议
- **每月**: 审查 .folder.md 准确性
- **每季度**: 全局架构审查

---

## 八、快速参考

### 创建新目录时

```bash
# 1. 创建目录
mkdir new-directory

# 2. 创建 .folder.md
cat > new-directory/.folder.md << 'EOF'
# new-directory

## 职责
...

EOF

# 3. 创建核心文件
cat > new-directory/main.ts << 'EOF'
/**
 * 文件名: main.ts
 * 职责: ...
 */
EOF
```

### 检查覆盖率

```bash
# 检查 .folder.md 覆盖率
find . -maxdepth 1 -type d ! -name ".*" | while read dir; do
  name=$(basename "$dir")
  if [ -f "$dir/.folder.md" ]; then
    echo "✅ $name"
  else
    echo "❌ $name"
  fi
done
```

---

**文档版本**: 1.1.0
**最后更新**: 2026-03-21

## 九、更新日志

| 日期 | 版本 | 变更 |
|------|------|------|
| 2026-03-21 | 1.1.0 | 删除 invest-research（已合并到 comprehensive-analysis）；更新 knowledge-extractor 为 CLI 网关描述 |
| 2026-03-21 | 1.0.0 | 创建改造计划 |
