---
name: infrastructure
preamble-tier: 2
version: 0.1.0
description: |
  基础设施工作流：GitHub 同步、部署管理、知识管理、信息源整理。
  Use when asked to: "同步", "push", "pull", "部署", "文档管理",
  "知识管理", "整理信息源", "git", "commit", "PR"。
  Proactively suggest when: 用户准备提交代码、需要同步到另一台电脑、
  或信息源积累需要整理时。
allowed-tools:
  - Bash
  - Read
  - Write
  - Edit
  - Glob
  - Grep
  - AskUserQuestion
benefits-from: [development, information-processing]
workflow:
  suggest: [cleanup-info-sources, knowledge-extractor]
---

# 基础设施专家

## 触发器

**一旦**出现以下信号，**务必**激活此专家：

| 信号 | 示例 |
|------|------|
| Git 操作 | "commit", "push", "pull", "PR", "同步" |
| 部署 | "部署", "deploy", "发布" |
| 文档管理 | "更新文档", "管理知识库", "README" |
| 知识管理 | "萃取", "整理信息源", "去重" |
| 同步 | "同步配置", "推送到 GitHub" |

## GitHub 配置

### 仓库信息
- **用户名**: bor799
- **邮箱**: 2822887579@qq.com
- **工作区仓库**: `-claude-code-workspace-`（前后都有横杠！）
- **工作区位置**: `~/claude-code-workspace`

### 同步机制

**macOS (A电脑)**:
```bash
cd ~/claude-code-workspace/scripts
./sync-mac.sh push   # 推送到 GitHub
./sync-mac.sh pull   # 从 GitHub 拉取
./sync-mac.sh status # 查看状态
```

**Windows (B电脑)**:
```powershell
cd $env:USERPROFILE\claude-code-workspace\scripts
.\sync-windows.ps1 push
.\sync-windows.ps1 pull
.\sync-windows.ps1 status
```

### 认证预检

**在调用任何 GitHub 操作之前**，先检查认证状态：
```bash
gh auth status 2>&1 | grep "Logged in" && echo "OK" || echo "NOT_AUTH"
```

- **已认证**：直接使用
- **未认证**：立即提供手动方案，不要尝试需要 token 的操作
- Token 名称：`claude-code-sync`，权限：repo

## 信息源管理

### Obsidian 信息源结构

```
信息源/YYYY-MM-WN/
├── AI Agent研究解读/    # 学术研究、技术解读
├── 实践案例/            # 技术落地、踩坑记录
├── 技术创业/            # 商业化案例、创业故事
├── 财经/                # 投资分析、宏观财经
└── 归档/
```

### 清理规则（固化）

- **一级分类**（4个，固定不变）
- **二级分类**：≥10 个文件时触发，目标密度 5-10 个/子类目
- **备份优先**：删除前先备份
- **保守策略**：不确定时保留
- **用户确认**：清理前展示方案

## 知识萃取系统

**路径**: `~/Documents/Obsidian Vault/职业发展/项目案例/100X_知识萃取系统/knowledge-extractor`

**AI 角色（生产者）**：只负责推送链接到队列
```bash
cd "<萃取路径>" && python add-link.py "<链接>"
# 推送后立即退出，不要等待
```

**❌ 不要**：等待进程完成、终止正在运行的进程、自己跑 main.py

## 管辖的技能

| 技能 | 用途 | 触发 |
|------|------|------|
| /doc-manager | 文档管理 | 文档编写、知识沉淀 |
| cleanup-info-sources | 信息源清理 | 去重、分类、备份 |
| knowledge-extractor | 知识萃取 | 深度分析、信号提取 |
| lets-go-rss | RSS 订阅 | 内容聚合、增量更新 |
| ai-builder-deploy | AI Builder 部署 | 一键部署到 ai-builders.space |

## 共享配置

以下配置与 Nanobot 共享，修改后两边同时生效：

- **共享技能**: `~/claude-code-workspace/shared/skills/`
- **工具优先级**: `~/claude-code-workspace/shared/preferences/tool-priorities.md`
- **用户画像**: `~/claude-code-workspace/shared/memory/user-profile.md`
- **学习风格**: `~/claude-code-workspace/shared/preferences/learning-style.md`

同步检查：`cd ~/claude-code-workspace/shared/sync && ./sync-all.sh --help`

## 常见错误

| 错误 | 正确做法 |
|------|----------|
| 未检查认证就调 GitHub API | 先 `gh auth status` |
| 自己跑 100X 的 main.py | 只用 add-link.py 推送链接 |
| 等待 100X 处理完成 | 推送后立即退出 |
| 删除信息源前不备份 | 先备份再操作 |
| 忽略仓库的横杠命名 | 仓库名是 `-claude-code-workspace-` |

## 与其他专家的关系

| 关系 | 专家 |
|------|------|
| **协作** | development（开发后需要 commit/push） |
| **上游** | information-processing（获取内容后存入信息源） |
| **下游** | information-processing（信息源整理后可搜索） |
| **参考** | gstack 的 /ship + /land-and-deploy（发布工作流） |
