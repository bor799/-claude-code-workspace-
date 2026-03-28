---
name: manage-info-sources
description: |
  信息源管理 Skill v2.0.0 - 清理和整理 Obsidian 信息源、兴趣领域、职业发展目录。
  支持多目录类型：信息源（标准分类）、知识库（主题分类+元数据）。
  工作流：先清理 → 再整理 → 生成看板。
allowed-tools:
  - Read
  - Bash
metadata:
  trigger: 信息源管理、清理重复、整理分类、生成看板
  version: 2.0.0
  author: Murphy
---

# 信息源管理 v2.0.0

管理 Obsidian 知识库，支持信息源和知识库两种模式。

## 支持的目录

| 目录 | 类型 | 说明 |
|------|------|------|
| **信息源** | info_source | 标准分类（商业、技术、投资等），移动文件到分类目录 |
| **兴趣领域** | knowledge_base | 主题分类，保留现有结构，自动添加元数据 |
| **职业发展** | knowledge_base | 主题分类，保留现有结构，自动添加元数据 |

## 工作流程

### 阶段一：清理
1. 删除测试文件（无标题、空文件）
2. 清理重复内容（按 url/title）
3. 备份机制（删除前自动备份）

### 阶段二：整理

**信息源模式**:
4. 统一元数据（`rating` → `score`）
5. 智能分类（根据 tags/title 推断）
6. 移动文件到正确目录

**知识库模式**:
4. 自动添加元数据（title, category, subcategory, type, created）
5. 保留现有目录结构

### 阶段三：看板
- 信息源：分类看板 + 周看板 + 总看板
- 知识库：主题看板 + 总看板

## 智能分类模式（仅信息源）

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

## 知识库元数据

自动推断并添加标准元数据：

```yaml
---
title: 文档标题
category: 一级分类
subcategory: 二级分类
type: 文档类型
created: 2026-03-07
tags: []
status: 进行中
---
```

### 类型识别规则

| 文件/目录特征 | 推断 type |
|---------------|-----------|
| README.md | 文档 |
| 设计文档/架构/方案 | 设计 |
| 分析/报告 | 报告 |
| 实践项目/项目案例 | 项目 |
| 基础概念/笔记 | 笔记 |
| 配置/config | 配置 |

## 使用

**触发方式**:
- "清理信息源"
- "整理兴趣领域"
- "生成看板"
- "/manage-info-sources"

**执行脚本**:
```bash
~/claude-code-workspace/skills/manage-info-sources/manage.sh [选项]
```

**选项**:
- `--cleanup-only` - 仅执行清理
- `--organize-only` - 仅执行整理
- `--dashboard-only` - 仅生成看板
- `--full` - 完整流程（默认）
- `--dir <name>` - 指定目录（信息源/兴趣领域/职业发展）
- `--mode-auto` - 自动提取分类（仅信息源）
- `--mode-structure` - 现有结构优先（仅信息源）
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

## 目录配置

配置文件：`config/directories.yaml`

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

---

**版本**: 2.0.0 | **更新**: 2026-03-07 | 支持多目录和知识库模式
