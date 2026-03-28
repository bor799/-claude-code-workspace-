# 信息源管理 Skill v2.0.0

自动清理和整理 Obsidian 知识库，支持信息源和知识库两种模式，生成 Dataview 看板。

## 新增功能 (v2.0.0)

### 多目录支持

| 目录 | 类型 | 处理方式 |
|------|------|----------|
| **信息源** | info_source | 标准分类，移动文件到分类目录 |
| **兴趣领域** | knowledge_base | 主题分类，保留结构，添加元数据 |
| **职业发展** | knowledge_base | 主题分类，保留结构，添加元数据 |

### 知识库元数据自动推断

自动为知识库文件添加标准元数据：

```yaml
---
title: 文档标题
category: 一级分类（从目录名推断）
subcategory: 二级分类（从子目录名推断）
type: 文档类型（从文件名/目录名推断）
created: 2026-03-07（从文件创建时间获取）
tags: []
status: 进行中
---
```

### 知识库看板

- 主题统计：按一级分类统计文档数
- 类型分类：按文档类型分类统计
- 最新文档：最近创建/修改的文档列表
- 主题看板：每个主题独立看板

## 功能

### 阶段一：清理
- 删除测试文件（无标题、空文件）
- 清理重复内容（按 url/title）
- 备份机制（删除前自动备份）

### 阶段二：整理

**信息源模式**:
- 统一元数据（`rating` → `score`）
- 智能分类（两种模式可选）
- 移动文件到正确目录

**知识库模式**:
- 自动添加元数据
- 保留现有目录结构

### 阶段三：看板

**信息源**:
- 分类看板（每个分类一个）
- 本周总看板
- 知识库总看板

**知识库**:
- 知识库总看板
- 主题看板（每个主题一个）

## 使用

### 通过 Claude Code 触发

```
清理信息源
整理兴趣领域
生成职业发展看板
/manage-info-sources
```

### 直接运行脚本

```bash
~/claude-code-workspace/skills/manage-info-sources/manage.sh [选项]
```

**选项**:
- `--cleanup-only` - 仅执行清理
- `--organize-only` - 仅执行整理
- `--dashboard-only` - 仅生成看板
- `--full` - 完整流程（默认）
- `--dir <name>` - 指定目录（信息源/兴趣领域/职业发展）
- `--mode-auto` - 自动提取分类模式（仅信息源）
- `--mode-structure` - 现有结构优先模式（仅信息源）
- `-h, --help` - 显示帮助

**示例**:
```bash
# 默认：信息源目录，完整流程
./manage.sh

# 兴趣领域：仅添加元数据
./manage.sh --dir 兴趣领域 --organize-only

# 职业发展：生成看板
./manage.sh --dir 职业发展 --dashboard-only

# 信息源：完整流程 + 自动分类
./manage.sh --dir 信息源 --mode-auto
```

## 配置文件

`config/directories.yaml` - 目录配置

```yaml
directories:
  - name: 信息源
    path: "/Users/murphy/Documents/Obsidian Vault/信息源"
    type: info_source
    has_metadata: true
    preserve_structure: false
    add_metadata: false
    categories: [商业, 技术, 投资, 推特, 播客, 文章, 访谈]

  - name: 兴趣领域
    path: "/Users/murphy/Documents/Obsidian Vault/兴趣领域"
    type: knowledge_base
    has_metadata: false
    preserve_structure: true
    add_metadata: true
```

## 智能分类模式（仅信息源）

执行时会询问选择分类模式（或通过 `--mode-*` 指定）：

| 模式 | 说明 | 适用场景 |
|------|------|----------|
| **自动提取** | 根据文章的 tags 和 title 关键词自动推断分类 | 首次整理，或需要重新分类 |
| **现有结构** | 优先保留现有目录结构，未分类的才自动推断 | 已有手动分类，只想补充缺失 |

### 自动提取分类规则

| 关键词 | 分类 |
|--------|------|
| AI, Claude, 编程, Agent, 工程 | 技术 |
| 股票, 投资, 财报, 港股 | 投资 |
| 产品, 商业, 创业 | 商业 |
| podcast, 播客, 对话 | 播客 |
| twitter.com, x.com | 推特 |
| article, 微信文章 | 文章 |
| interview, 访谈 | 访谈 |

## 目录结构

### 信息源目录

```
~/Documents/Obsidian Vault/信息源/
├── 2026-03-W1/
│   ├── 商业/
│   │   └── 📊 商业看板.md
│   ├── 技术/
│   │   └── 📊 技术看板.md
│   ├── 投资/
│   │   └── 📊 投资看板.md
│   ├── 推特/
│   │   └── 📊 推特看板.md
│   ├── 播客/
│   │   └── 📊 播客看板.md
│   ├── 文章/
│   │   └── 📊 文章看板.md
│   ├── 访谈/
│   │   └── 📊 访谈看板.md
│   └── 📊 本周概览.md
├── 📊 知识库看板.md
└── 归档/
    └── 清理备份_YYYYMMDD_HHMMSS/
```

### 知识库目录

```
~/Documents/Obsidian Vault/兴趣领域/
├── AI 进展/
│   ├── 实践项目/
│   ├── 思考沉淀/
│   └── 📊 AI 进展看板.md
├── Crypto/
│   ├── 基础概念/
│   ├── 实践项目/
│   └── 📊 Crypto看板.md
└── 📊 兴趣领域看板.md
```

## 依赖

- Obsidian
- Dataview 插件

## 版本

- v2.0.0 - 2026-03-07: 支持多目录和知识库模式
- v1.1.0 - 2026-03-07: 支持两种分类模式
- v1.0.0 - 2026-03-07: 初始版本
