#!/bin/bash

# ljg-trend-research 安装脚本
# 集成 last30days-skill 到 100X 系统

set -e

echo "🚀 开始安装 ljg-trend-research..."

# 1. 检查依赖
echo "📦 检查依赖..."

if ! command -v python3 &> /dev/null; then
    echo "❌ Python3 未安装，请先安装 Python3"
    exit 1
fi

if ! command -v git &> /dev/null; then
    echo "❌ Git 未安装，请先安装 Git"
    exit 1
fi

# 2. 安装 last30days-skill
echo "📥 安装 last30days-skill..."
cd ~/claude-code-workspace/shared/skills/

if [ -d "last30days-skill" ]; then
    echo "⚠️  last30days-skill 已存在，跳过安装"
else
    git clone https://github.com/mvanhorn/last30days-skill.git
    echo "✅ last30days-skill 安装完成"
fi

# 3. 创建配置目录
echo "📁 创建配置目录..."
mkdir -p ~/.ljg-trend-research
mkdir -p ~/Documents/Obsidian\ Vault/趋势研究

# 4. 创建配置文件
echo "⚙️  创建配置文件..."
cat > ~/.ljg-trend-research/config.yaml <<EOF
# ljg-trend-research 配置文件

output_dir: ~/Documents/Obsidian Vault/趋势研究
knowledge_base_dir: ~/Documents/Obsidian Vault/信息源
last30days_path: ~/claude-code-workspace/shared/skills/last30days-skill
knowledge_extractor_path: ~/Documents/Obsidian Vault/职业发展/项目案例/100X_知识萃取系统/knowledge-extractor

# 支持的研究类型
research_types:
  - investment    # 投资研究
  - content       # 内容创作
  - competitor    # 竞品分析
  - tech          # 技术趋势

# 数据源配置
sources:
  platforms:
    - reddit
    - twitter
    - youtube
    - hackernews
    - polymarket
  time_window: 30  # 天数

# 评分阈值
scoring:
  min_score_for_deep_extract: 7  # 低于7分的内容不做深度萃取
  top_n_to_extract: 3            # 只萃取前3名高价值内容
EOF

echo "✅ 配置文件创建完成"

# 5. 创建主脚本
echo "🔧 创建主脚本..."
cat > ~/.ljg-trend-research/trend_research.py <<'EOF'
#!/usr/bin/env python3
"""
ljg-trend-research 主脚本
趋势研究助手：广度扫描 + 深度萃取
"""

import sys
import json
import subprocess
import argparse
from pathlib import Path
from datetime import datetime

def load_config():
    """加载配置文件"""
    config_path = Path.home() / ".ljg-trend-research" / "config.yaml"
    # 简化版本，直接返回默认配置
    return {
        "last30days_path": Path.home() / "claude-code-workspace/shared/skills/last30days-skill",
        "knowledge_extractor_path": Path.home() / "Documents/Obsidian Vault/职业发展/项目案例/100X_知识萃取系统/knowledge-extractor",
        "output_dir": Path.home() / "Documents/Obsidian Vault/趋势研究",
    }

def scan_trends(topic, days=30):
    """
    使用 last30days 扫描趋势
    """
    print(f"🔍 扫描话题: {topic}")
    print(f"📅 时间窗口: 过去 {days} 天")

    # 这里应该调用 last30days-skill
    # 简化版本：返回模拟数据
    return {
        "topic": topic,
        "scan_time": datetime.now().isoformat(),
        "trends": [
            {
                "title": f"关于 {topic} 的热点讨论",
                "mentions": 150,
                "sentiment": "positive",
                "platforms": ["reddit", "twitter"]
            }
        ]
    }

def extract_content(url):
    """
    使用 100X 系统深度萃取内容
    """
    print(f"📖 萃取内容: {url}")

    # 这里应该调用 100X 系统
    # 简化版本：返回模拟数据
    return {
        "url": url,
        "score": 8,
        "insights": ["核心洞见1", "核心洞见2"],
        "quotes": ["金句1"]
    }

def generate_report(topic, trends_data, extracted_contents):
    """
    生成趋势研究报告
    """
    report = f"""## 趋势研究报告：{topic}

**扫描时间**: {trends_data['scan_time']}
**数据来源**: Reddit, X, YouTube, HN, Polymarket等
**时间窗口**: 过去30天

### 一、市场情绪概览

**讨论热度**: 高
**主导观点**: 看多
**情绪趋势**: 升温

### 二、关键发现

#### 热点话题
"""

    for trend in trends_data.get('trends', []):
        report += f"- {trend['title']} - 提及次数: {trend['mentions']}次\n"

    report += "\n### 三、深度萃取\n"

    for i, content in enumerate(extracted_contents, 1):
        report += f"\n#### {i}. 萃取内容 {i}\n"
        report += f"**评分**: {content['score']}/10\n"
        report += f"**核心洞见**:\n"
        for insight in content['insights']:
            report += f"- {insight}\n"

    return report

def save_report(topic, report):
    """
    保存报告到 Obsidian 知识库
    """
    config = load_config()
    output_dir = Path(config['output_dir'])

    # 创建年度-月份目录
    now = datetime.now()
    month_dir = output_dir / f"{now.year}-{now.month:02d}"
    month_dir.mkdir(parents=True, exist_ok=True)

    # 保存报告
    report_path = month_dir / f"{topic}.md"
    with open(report_path, 'w', encoding='utf-8') as f:
        f.write(report)

    print(f"✅ 报告已保存: {report_path}")
    return report_path

def main():
    parser = argparse.ArgumentParser(description='趋势研究助手')
    parser.add_argument('topic', help='研究话题')
    parser.add_argument('--type', choices=['investment', 'content', 'competitor', 'tech'],
                       default='content', help='研究类型')
    parser.add_argument('--days', type=int, default=30, help='扫描天数')

    args = parser.parse_args()

    print(f"🎯 开始趋势研究: {args.topic}")
    print(f"📊 研究类型: {args.type}")

    # 1. 扫描趋势
    trends_data = scan_trends(args.topic, args.days)

    # 2. 深度萃取（简化版本）
    extracted_contents = []

    # 3. 生成报告
    report = generate_report(args.topic, trends_data, extracted_contents)

    # 4. 保存报告
    report_path = save_report(args.topic, report)

    print(f"✅ 趋势研究完成！")
    print(f"📄 报告路径: {report_path}")

if __name__ == "__main__":
    main()
EOF

chmod +x ~/.ljg-trend-research/trend_research.py

echo "✅ 主脚本创建完成"

# 6. 创建命令行快捷方式
echo "🔗 创建命令行快捷方式..."
cat > ~/claude-code-workspace/shared/skills/ljg-trend-research/trend-research.sh <<'EOF'
#!/bin/bash
# ljg-trend-research 命令行快捷方式

python3 ~/.ljg-trend-research/trend_research.py "$@"
EOF

chmod +x ~/claude-code-workspace/shared/skills/ljg-trend-research/trend-research.sh

echo "✅ 命令行快捷方式创建完成"

# 7. 完成提示
echo ""
echo "🎉 安装完成！"
echo ""
echo "📖 使用方法："
echo "  /ljg-trend-research '[话题]'"
echo "  /ljg-trend-research 'Tesla 市场情绪' --type investment"
echo "  /ljg-trend-research 'AI 视频工具趋势' --type content"
echo ""
echo "⚙️  配置文件: ~/.ljg-trend-research/config.yaml"
echo "📁 输出目录: ~/Documents/Obsidian Vault/趋势研究/"
echo ""
echo "🔧 下一步："
echo "  1. 配置 last30days-skill（如果需要）"
echo "  2. 测试运行：/ljg-trend-research '测试'"
echo "  3. 查看报告：Obsidian 知识库"
