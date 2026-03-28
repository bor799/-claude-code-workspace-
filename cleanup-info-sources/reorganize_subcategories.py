#!/usr/bin/env python3
"""
二级分类重构脚本
将 AI Agent研究解读 下的文件按二级分类重新组织
"""

import os
import re
from pathlib import Path

# 配置
SOURCE_DIR = "/Users/murphy/Documents/Obsidian Vault/信息源/2026-03-W4/AI Agent研究解读"

# 二级分类定义（基于文件名匹配规则）
SUBCATEGORIES = {
    "大模型工程": [
        "Qwen", "GPT-5.4", "Attention残差", "AI推理成本"
    ],
    "Agent工程": [
        "Agent工程", "Agent交互", "Agent重构", "Agent长上下文",
        "编码Agent", "AI Agent实时文档", "智能体工程",
        "Agentic Engineering", "AI代码交付", "Showboat"
    ],
    "AI基础设施": [
        "沙箱", "WASM", "OpenAI收购Astral"
    ],
    "开发模式": [
        "Vibe Coding", "软件工厂", "代码成本归零"
    ],
    "行业与法律": [
        "OpenAI 使命", "Circle转型", "开源许可", "净室设计",
        "Deep Blue", "职业"
    ]
}


def get_subcategory(filename):
    """根据文件名判断应该属于哪个二级分类"""
    for category, keywords in SUBCATEGORIES.items():
        for keyword in keywords:
            if keyword in filename:
                return category
    return "Agent工程"  # 默认


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


def format_frontmatter(frontmatter):
    """格式化 frontmatter 为 YAML"""
    lines = ['---']
    for key, value in frontmatter.items():
        if key == 'tags':
            if isinstance(value, str):
                tags = eval(value) if value.startswith('[') else [value]
            else:
                tags = value
            lines.append(f'tags: {tags}')
        else:
            lines.append(f'{key}: "{value}"')
    lines.append('---')
    lines.append('')
    return '\n'.join(lines)


def update_category_in_frontmatter(content, new_category):
    """更新 frontmatter 中的 category 字段"""
    yaml_str = extract_frontmatter(content)
    if not yaml_str:
        return content

    frontmatter = parse_frontmatter(yaml_str)
    frontmatter['category'] = new_category

    new_yaml = format_frontmatter(frontmatter)
    body_start = content.find('---', 3) + 4
    return new_yaml + content[body_start:]


def main():
    print("🚀 开始二级分类重构...")
    print(f"📁 源目录: {SOURCE_DIR}")
    print()

    # 创建二级分类目录
    for category in SUBCATEGORIES.keys():
        os.makedirs(os.path.join(SOURCE_DIR, category), exist_ok=True)
        print(f"📂 创建分类: {category}")

    print()

    # 统计信息
    stats = {cat: 0 for cat in SUBCATEGORIES.keys()}

    # 获取所有 md 文件
    files = [f for f in os.listdir(SOURCE_DIR) if f.endswith('.md')]

    print(f"📝 找到 {len(files)} 个文件需要处理")
    print()

    # 处理每个文件
    for i, filename in enumerate(files, 1):
        file_path = os.path.join(SOURCE_DIR, filename)

        # 判断二级分类
        subcategory = get_subcategory(filename)

        # 读取文件内容
        with open(file_path, 'r', encoding='utf-8') as f:
            content = f.read()

        # 更新 frontmatter 中的 category
        new_category = f"AI Agent研究解读/{subcategory}"
        new_content = update_category_in_frontmatter(content, new_category)

        # 写入新位置
        new_path = os.path.join(SOURCE_DIR, subcategory, filename)
        with open(new_path, 'w', encoding='utf-8') as f:
            f.write(new_content)

        # 删除旧文件
        os.remove(file_path)

        stats[subcategory] += 1

        print(f"[{i}/{len(files)}] {filename} → {subcategory}")

    print()
    print("📊 处理完成！统计信息：")
    for category, count in stats.items():
        if count > 0:
            print(f"  {category}: {count}")

    print()
    print("✅ 二级分类重构完成！")


if __name__ == '__main__':
    main()
