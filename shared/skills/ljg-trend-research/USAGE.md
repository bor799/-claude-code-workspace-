# ljg-trend-research 深度集成版 - 使用指南

## 🎯 系统概述

这是一个深度集成的趋势研究系统，结合了：
- **last30days-skill**: 扫描 Reddit, X, YouTube, HN, Polymarket 等 10+ 平台
- **100X 知识萃取系统**: 深度分析和知识管理
- **自动化定时任务**: 每天凌晨 4 点自动运行

## 📦 已安装组件

✅ last30days-skill (~/claude-code-workspace/shared/skills/last30days-skill)
✅ 100X 知识萃取系统 (~/Documents/Obsidian Vault/职业发展/项目案例/100X_知识萃取系统/knowledge-extractor)
✅ 定时任务 (launchd)
✅ 管理脚本 (~/claude-code-workspace/shared/skills/ljg-trend-research/schedule.sh)

## 🚀 快速开始

### 1. 快速测试（推荐先运行）

```bash
# 测试单个话题（约 1-3 分钟）
python3 ~/.ljg-trend-research/quick_test.py
```

### 2. 完整测试

```bash
# 测试所有配置的话题（约 10-30 分钟）
cd ~/claude-code-workspace/shared/skills/ljg-trend-research
./schedule.sh test
```

### 3. 查看结果

```bash
# 打开 Obsidian 查看生成的日报
open ~/Documents/Obsidian\ Vault/趋势研究/日报/
```

## 📋 监控的话题

当前配置了 9 个话题：

**AI & 技术:**
- AI 行业趋势
- AI 应用
- AI 信息处理

**投资标的:**
- 加密货币稳定币
- 泡泡玛特
- 名创优品
- Lemonade (LMND)
- BitGo
- 紫金矿业

## ⚙️ 管理命令

```bash
cd ~/claude-code-workspace/shared/skills/ljg-trend-research

# 查看定时任务状态
./schedule.sh status

# 手动运行测试
./schedule.sh test

# 查看日志
./schedule.sh logs

# 编辑话题配置
./schedule.sh edit

# 重新安装定时任务
./schedule.sh uninstall
./schedule.sh install
```

## 📝 输出格式

### 日报结构

```
📊 趋势日报 - YYYY年MM月DD日
├── 📈 今日概览
│   └── 🔥 热度 TOP 3
├── 🤖 AI & 技术趋势
│   ├── AI 行业趋势
│   ├── AI 应用
│   └── AI 信息处理
├── 💰 投资标的情绪
│   ├── 加密货币稳定币
│   ├── 泡泡玛特
│   ├── 名创优品
│   ├── Lemonade
│   ├── BitGo
│   └── 紫金矿业
└── 🎯 今日观察与行动建议
```

### 数据文件

- **日报**: `~/Documents/Obsidian Vault/趋势研究/日报/日报-YYYY-MM-DD.md`
- **原始数据**: `~/.ljg-trend-research/logs/data_YYYYMMDD_HHMMSS.json`
- **运行日志**: `~/.ljg-trend-research/logs/daily_report.log`

## 🔧 配置修改

### 添加/删除话题

```bash
# 编辑话题配置
vi ~/.ljg-trend-research/topics.yaml

# 配置格式：
topics:
  - topic: "新话题"
    keywords: ["关键词1", "关键词2"]
    type: "tech"  # tech | investment
    priority: "high"  # high | medium | low
```

### 修改运行时间

```bash
# 编辑 plist 文件
vi ~/Library/LaunchAgents/com.ljg.trendresearch.plist

# 修改 Hour 和 Minute
<key>StartCalendarInterval</key>
<dict>
    <key>Hour</key>
    <integer>4</integer>  # 改成你想要的时间
    <key>Minute</key>
    <integer>0</integer>
</dict>

# 重新加载
launchctl unload ~/Library/LaunchAgents/com.ljg.trendresearch.plist
launchctl load ~/Library/LaunchAgents/com.ljg.trendresearch.plist
```

## ⚠️ 注意事项

### 运行时间

- **单个话题**: 1-3 分钟
- **完整扫描**: 10-30 分钟（9 个话题）
- **定时任务**: 凌晨 4 点运行，不会影响白天使用

### 依赖要求

- Python 3
- last30days-skill（已安装）
- 100X 系统（已安装）
- 网络连接

### 故障排查

```bash
# 查看日志
./schedule.sh logs

# 检查 last30days 配置
cd ~/claude-code-workspace/shared/skills/last30days-skill
python3 scripts/last30days.py setup

# 手动测试 last30days
cd ~/claude-code-workspace/shared/skills/last30days-skill
python3 scripts/last30days.py "AI 应用" --quick
```

## 📊 性能优化建议

### 如果觉得太慢

1. **减少话题数量**: 编辑 `topics.yaml`，只保留最重要的
2. **使用快速模式**: 已经默认使用 `--quick` 参数
3. **调整扫描时间**: 改成凌晨 3 点或 5 点

### 如果想要更详细

1. **移除 --quick 参数**: 编辑 `integrated_daily_report.py`，去掉 `--quick`
2. **增加 100X 深度萃取**: 对高热度话题自动触发深度分析
3. **增加数据源**: 配置更多 last30days 数据源

## 🎯 使用场景

### 每日例行

1. **早上起床**: 打开 Obsidian 查看自动生成的日报
2. **通勤路上**: 阅读热点和趋势
3. **工作中**: 根据趋势做决策
4. **写作时**: 参考热度排序选择话题

### 投资决策

1. 查看投资标的的市场情绪
2. 关注热度异常的标的
3. 结合预测市场数据做判断

### 内容创作

1. 看什么话题最火
2. 了解社区在讨论什么
3. 找到内容灵感

## 🔮 未来改进

- [ ] 自动 Telegram 推送
- [ ] 100X 深度萃取集成
- [ ] 趋势图表生成
- [ ] 自定义评分系统
- [ ] 多语言支持

## 📞 支持

遇到问题：
1. 查看日志: `./schedule.sh logs`
2. 检查配置: 确保所有依赖都正确安装
3. 重新安装: `./schedule.sh uninstall && ./schedule.sh install`

---

**系统版本**: v1.0.0
**最后更新**: 2026-04-01
**维护者**: Murphy
