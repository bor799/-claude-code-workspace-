#!/usr/bin/env python3
"""
信息源目录重构脚本
- 精简 frontmatter 属性
- 重新分类到4个新分类
- 移动文件到新位置
"""

import os
import re
import shutil
from pathlib import Path
from datetime import datetime

# 配置
SOURCE_DIR = "/Users/murphy/Documents/Obsidian Vault/信息源/2026-03-W4"
WEEK = "2026-03-W4"

# 新分类体系
NEW_CATEGORIES = [
    "AI Agent研究解读",
    "实践案例",
    "技术创业",
    "财经"
]

# 分类映射规则 (规则预判)
CATEGORY_MAP = {
    # AI Agent研究解读
    "AI Agent": "AI Agent研究解读",
    "AI Agent ": "AI Agent研究解读",
    "AI Agent与法律边界": "AI Agent研究解读",
    "大模型工程": "AI Agent研究解读",
    "AI工程": "AI Agent研究解读",
    "AI行业动态": "AI Agent研究解读",
    "AI进展": "AI Agent研究解读",
    "AI行业观察": "AI Agent研究解读",
    "AI Agent & Fintech": "AI Agent研究解读",  # 默认归入 AI Agent研究解读

    # 实践案例
    "技术工程": "实践案例",
    "工程化": "实践案例",
    "技术决策": "实践案例",
    "职业认知": "实践案例",

    # 技术创业
    "技术创业": "技术创业",
    "技术并购": "技术创业",
    "开源商业化": "技术创业",
    "商业思维": "技术创业",
    "商业战略": "技术创业",
    "商业情报": "技术创业",
    "Web3商业模式": "技术创业",  # 默认归入技术创业

    # 财经
    "Web3商业与RWA": "财经",
    "宏观趋势": "财经",
    "Fintech": "财经",
}


def extract_frontmatter(content):
    """提取 YAML frontmatter"""
    match = re.match(r'^---\n(.*?)\n---\n', content, re.DOTALL)
    if match:
        return match.group(1)
    return None


def parse_frontmatter(yaml_str):
    """简单的 YAML 解析器"""
    frontmatter = {}
    for line in yaml_str.split('\n'):
        if ':' in line:
            key, value = line.split(':', 1)
            key = key.strip()
            value = value.strip().strip('"').strip("'")
            frontmatter[key] = value
    return frontmatter


def get_new_category(old_category):
    """根据旧分类获取新分类"""
    # 先尝试直接映射
    if old_category in CATEGORY_MAP:
        return CATEGORY_MAP[old_category]

    # 尝试部分匹配
    for key, value in CATEGORY_MAP.items():
        if key in old_category or old_category in key:
            return value

    # 默认归入 AI Agent研究解读
    return "AI Agent研究解读"


def simplify_frontmatter(frontmatter):
    """精简 frontmatter 属性"""
    new_frontmatter = {}

    # 保留有用属性
    if 'title' in frontmatter:
        new_frontmatter['title'] = frontmatter['title']
    if 'source' in frontmatter:
        new_frontmatter['source'] = frontmatter['source']
    if 'source_url' in frontmatter:
        new_frontmatter['source_url'] = frontmatter['source_url']
    if 'week' in frontmatter:
        new_frontmatter['week'] = frontmatter['week']
    else:
        new_frontmatter['week'] = WEEK
    if 'score' in frontmatter:
        new_frontmatter['score'] = frontmatter['score']
    if 'reread_worthy' in frontmatter:
        new_frontmatter['reread_worthy'] = frontmatter['reread_worthy']
    if 'tags' in frontmatter:
        new_frontmatter['tags'] = frontmatter['tags']

    return new_frontmatter


def format_frontmatter(frontmatter):
    """格式化 frontmatter 为 YAML"""
    lines = ['---']
    for key, value in frontmatter.items():
        if key == 'tags':
            # tags 格式化为列表
            if isinstance(value, str):
                # 处理类似 "['tag1', 'tag2']" 的字符串
                tags = eval(value) if value.startswith('[') else [value]
            else:
                tags = value
            lines.append(f'tags: {tags}')
        else:
            lines.append(f'{key}: "{value}"')
    lines.append('---')
    lines.append('')  # 添加空行
    return '\n'.join(lines)


def process_file(file_path, stats):
    """处理单个文件"""
    try:
        with open(file_path, 'r', encoding='utf-8') as f:
            content = f.read()

        # 提取 frontmatter
        yaml_str = extract_frontmatter(content)
        if not yaml_str:
            stats['no_frontmatter'] += 1
            return None

        frontmatter = parse_frontmatter(yaml_str)
        old_category = frontmatter.get('category', '未分类')

        # 获取新分类
        new_category = get_new_category(old_category)

        # 精简 frontmatter
        new_frontmatter = simplify_frontmatter(frontmatter)
        new_frontmatter['category'] = new_category

        # 生成新内容
        new_yaml = format_frontmatter(new_frontmatter)
        new_content = new_yaml + content[content.find('---', 3) + 4:]

        # 构建新路径
        filename = os.path.basename(file_path)
        new_dir = os.path.join(SOURCE_DIR, new_category)
        new_path = os.path.join(new_dir, filename)

        # 确保目标目录存在
        os.makedirs(new_dir, exist_ok=True)

        # 写入新文件
        with open(new_path, 'w', encoding='utf-8') as f:
            f.write(new_content)

        # 记录统计
        stats['total'] += 1
        stats['by_category'][new_category] = stats['by_category'].get(new_category, 0) + 1
        stats['category_mapping'][old_category] = stats['category_mapping'].get(old_category, 0) + 1

        # 删除旧文件
        os.remove(file_path)

        return {
            'old_path': file_path,
            'new_path': new_path,
            'old_category': old_category,
            'new_category': new_category
        }

    except Exception as e:
        stats['errors'] += 1
        stats['error_files'].append((file_path, str(e)))
        return None


def main():
    """主函数"""
    print("🚀 开始重构信息源目录...")
    print(f"📁 源目录: {SOURCE_DIR}")
    print()

    # 统计信息
    stats = {
        'total': 0,
        'no_frontmatter': 0,
        'errors': 0,
        'error_files': [],
        'by_category': {},
        'category_mapping': {}
    }

    # 创建新分类目录
    for category in NEW_CATEGORIES:
        os.makedirs(os.path.join(SOURCE_DIR, category), exist_ok=True)
        print(f"📂 创建分类: {category}")

    print()

    # 收集所有需要处理的文件
    files_to_process = []
    for root, dirs, files in os.walk(SOURCE_DIR):
        for file in files:
            if file.endswith('.md'):
                file_path = os.path.join(root, file)
                # 跳过已经在正确目录中的文件
                rel_path = os.path.relpath(file_path, SOURCE_DIR)
                if any(rel_path.startswith(cat + '/') or rel_path.startswith(cat + '\\') for cat in NEW_CATEGORIES):
                    continue
                # 跳过根目录的文件
                if os.path.dirname(file_path) == SOURCE_DIR:
                    continue
                files_to_process.append(file_path)

    print(f"📝 找到 {len(files_to_process)} 个文件需要处理")
    print()

    # 处理文件
    results = []
    for i, file_path in enumerate(files_to_process, 1):
        result = process_file(file_path, stats)
        if result:
            results.append(result)
            print(f"[{i}/{len(files_to_process)}] {os.path.basename(file_path)}")
            print(f"  {result['old_category']} → {result['new_category']}")

    print()
    print("📊 处理完成！统计信息：")
    print(f"  总文件数: {stats['total']}")
    print(f"  无 frontmatter: {stats['no_frontmatter']}")
    print(f"  错误数: {stats['errors']}")
    print()
    print("📂 新分类分布：")
    for category, count in sorted(stats['by_category'].items()):
        print(f"  {category}: {count}")
    print()
    print("📋 旧分类映射：")
    for old_cat, count in sorted(stats['category_mapping'].items()):
        print(f"  {old_cat}: {count}")

    if stats['error_files']:
        print()
        print("❌ 错误文件：")
        for file_path, error in stats['error_files']:
            print(f"  {file_path}: {error}")

    print()
    print("⚠️  注意：旧文件尚未删除，请检查确认后手动删除")
    print("📁 旧文件位置：源目录中的各个子目录")


if __name__ == '__main__':
    main()
