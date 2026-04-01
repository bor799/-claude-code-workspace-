# Claude Code Workspace

完整的 Claude Code 开发专家工作空间，包含开发规则、技能集和子代理系统。

## 🎯 核心功能

这个工作空间专门为**开发专家**和**技术文档撰写**设计，包含：

- **开发专家规则系统** (`rules/development.md`)
- **信息处理工作流** (`rules/information-processing.md`)
- **内容创作规范** (`rules/content-creation.md`)
- **投资研究框架** (`rules/investment-research.md`)
- **完整的技能集** (`skills/`, `shared/skills/`)
- **子代理系统** (`subagents/`)

## 📦 快速开始 (Windows)

### 1. 安装依赖

```powershell
# 确保 Git 已安装
git --version

# 克隆仓库
git clone https://github.com/bor799/-claude-code-workspace-.git %USERPROFILE%\claude-code-workspace
cd %USERPROFILE%\claude-code-workspace
```

### 2. 配置 Claude Code

在你的主目录创建或编辑 `CLAUDE.md` 文件：

```markdown
# Claude Code 配置

## 核心规则

- 直接务实，用最简单的方案
- 不确定就问，别猜
- 用 Edit 工具精准编辑
- 不要过度工程

## 专家规则

| 任务类型 | 规则文件 |
|----------|----------|
| 信息获取/搜索/理解/消化 | `rules/information-processing.md` |
| 写作/配图/发布 | `rules/content-creation.md` |
| 代码/调试/评估 | `rules/development.md` |
| 股票/投资决策 | `rules/investment-research.md` |

位置：`~/claude-code-workspace/rules/`
```

### 3. Windows 特定配置

某些脚本需要 Windows 特定处理：

```powershell
# 安装 Windows 构建工具 (可选，用于编译原生模块)
npm install --global windows-build-tools
```

## 🛠️ 开发专家工作流

### 触发器

当你遇到以下情况时，开发专家会自动激活：

| 信号 | 示例 |
|------|------|
| 功能规划 | "帮我规划", "怎么设计", "技术方案" |
| 代码实现 | "写代码", "实现这个", "开发" |
| 代码审查 | "review", "代码审查", "检查代码" |
| 调试 | "debug", "报错了", "fix" |
| 会话评估 | "评估", "这次做得怎么样" |

### 脚本开发规则

**必须遵循**：

- ✅ 使用 heredoc 直接写入多行内容
- ✅ 复杂文本处理使用 `awk`
- ✅ 日志输出到 stderr (`>&2`)
- ❌ 避免多层 `sed` 管道
- ❌ 避免日志输出到 stdout

## 📁 项目结构

```
claude-code-workspace/
├── rules/                    # 专家规则文件
│   ├── development.md        # 开发专家规则 ⭐
│   ├── information-processing.md
│   ├── content-creation.md
│   └── investment-research.md
├── skills/                   # 本地技能
├── shared/skills/           # 共享技能
├── subagents/               # 子代理系统
├── nanobot-core/           # 核心 nanobot 组件
├── CLAUDE.md               # 全局配置 (需在主目录)
└── README.md              # 本文件
```

## 🚀 可用技能

### 开发相关
- `/plan-feature` - 功能规划
- `/code-review` - 代码审查
- `/evaluate-session` - 会话评估
- `agent-architecture-learning` - 架构学习

### 分析相关
- `/investigate` - 系统性调试 (gstack)
- `/comprehensive-analysis` - 综合分析
- `knowledge-extractor` - 知识萃取

### 内容创作
- `unified-writer` - 统一写作引擎
- `doc-manager` - 文档管理器

## 🔧 常见问题

### Windows 路径问题
Windows 使用反斜杠 `\`，但在大多数现代工具中正斜杠 `/` 也能正常工作。

### 权限问题
某些脚本可能需要执行权限：
```powershell
# Git Bash 或 WSL
chmod +x script.sh
```

### 编码问题
确保终端使用 UTF-8 编码：
```powershell
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
```

## 📚 更多信息

- **GitHub**: https://github.com/bor799/-claude-code-workspace-
- **Issue Tracker**: 在 GitHub 仓库报告问题

## 🤝 贡献

欢迎提交 Pull Request 或 Issue！

## 📄 许可

本项目采用 MIT 许可证。