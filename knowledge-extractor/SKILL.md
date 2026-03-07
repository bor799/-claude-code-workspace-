---
name: knowledge-extractor
description: 智能知识萃取 v3.0。深度分析长文、推文、视频等内容，提取洞见和高价值信息，生成结构化情报报告。支持长文分析、短消息评估、视频内容分析、知识归档到 Obsidian/Notion、情报收集等场景。
trigger:
  - 知识萃取
  - extract knowledge
  - analyze content
  - 情报收集
  - 萃取
  - 分析文章
---

# Knowledge Extractor

智能知识萃取 Agent（保留原始 Agent 格式）。

详见 AGENT.md 获取完整配置和使用说明。

## 使用方式

```bash
# 定时执行（每天 05:00 自动抓取）
cd "/Users/murphy/Documents/Obsidian Vault/职业发展/项目案例/100X_知识萃取系统/knowledge-extractor" && python src/main.py

# 手动执行
cd "/Users/murphy/Documents/Obsidian Vault/职业发展/项目案例/100X_知识萃取系统/knowledge-extractor" && python src/main.py --dry-run --verbose
```
