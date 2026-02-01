#!/bin/bash

# Claude Code 工作区 GitHub 初始化脚本
# 在 A 电脑（macOS）上运行一次即可

set -e

REPO_DIR="$HOME/claude-code-workspace"

echo "🚀 初始化 GitHub 仓库..."
echo ""

# 检查是否在正确的目录
if [ ! -d "$REPO_DIR" ]; then
    echo "❌ 错误: 工作区目录不存在: $REPO_DIR"
    echo "请先运行准备步骤创建目录结构"
    exit 1
fi

cd "$REPO_DIR"

# 初始化 Git 仓库
if [ ! -d ".git" ]; then
    echo "📝 初始化 Git 仓库..."
    git init
    git branch -M main
else
    echo "⚠️  Git 仓库已存在"
fi

# 创建 .gitignore
echo "📝 创建 .gitignore..."
cat > .gitignore << 'EOF'
# macOS
.DS_Store

# Windows
Thumbs.db
desktop.ini

# 备份文件
*.backup
*.bak

# 临时文件
*.tmp
*.temp

# 编辑器
.vscode/
.idea/
*.swp
*.swo
*~

# Claude Code 特定
.claude-backup-*/
EOF

# 创建 README.md
echo "📝 创建 README.md..."
cat > README.md << 'EOF'
# Claude Code 工作区

这是我的 Claude Code 技能体系和配置文件，通过在多台电脑间同步。

## 📦 内容

- **CLAUDE.md**: Claude Code 全局配置
- **skills/**: 自定义技能
  - evaluate-session: 会话性能评估
  - code-review: 代码审查
  - plan-feature: 功能规划
  - doc-manager: 文档管理
- **docs/**: 相关文档

## 🚀 快速开始

### macOS

```bash
# 克隆仓库
git clone <your-repo-url> ~/claude-code-workspace

# 安装
cd ~/claude-code-workspace/scripts
chmod +x sync-mac.sh
./sync-mac.sh pull
```

### Windows

```powershell
# 克隆仓库
git clone <your-repo-url> $env:USERPROFILE\claude-code-workspace

# 安装
cd $env:USERPROFILE\claude-code-workspace\scripts
.\sync-windows.ps1 pull
```

## 🔄 同步

### 推送更改到 GitHub

**macOS**:
```bash
cd ~/claude-code-workspace/scripts
./sync-mac.sh push
```

**Windows**:
```powershell
cd $env:USERPROFILE\claude-code-workspace\scripts
.\sync-windows.ps1 push
```

### 从 GitHub 拉取更新

**macOS**:
```bash
cd ~/claude-code-workspace/scripts
./sync-mac.sh pull
```

**Windows**:
```powershell
cd $env:USERPROFILE\claude-code-workspace\scripts
.\sync-windows.ps1 pull
```

## 📝 更新工作流

1. 修改本地文件（CLAUDE.md、技能、文档）
2. 运行同步脚本推送: `./sync-mac.sh push` 或 `.\sync-windows.ps1 push`
3. 在另一台电脑运行: `./sync-mac.sh pull` 或 `.\sync-windows.ps1 pull`

## 📚 更多信息

查看 `docs/` 目录了解详细使用说明。

---

**版本**: 1.0.0
**最后更新**: 2026-02-02
EOF

# 创建 VERSION.md
echo "📝 创建 VERSION.md..."
cat > VERSION.md << EOF
# Claude Code 工作区版本信息

## 当前版本

- **版本号**: 1.0.0
- **创建日期**: 2026-02-02
- **创建者**: Murphy
- **系统**: macOS

## 版本历史

### v1.0.0 (2026-02-02)

**初始版本**
- 创建基础工作区结构
- 添加 4 个核心技能
- 创建同步脚本（macOS + Windows）
- 初始化 GitHub 仓库

**包含内容**:
- CLAUDE.md 全局配置
- evaluate-session 技能
- code-review 技能
- plan-feature 技能
- doc-manager 技能
- 完整文档体系
- 跨平台同步脚本

---

## 更新日志

请在此记录每次重要更新:

- **YYYY-MM-DD**: [描述更新内容]
EOF

# 添加文件到 Git
echo "📝 添加文件到 Git..."
git add .
git commit -m "Initial commit: Claude Code workspace v1.0.0"

# 询问是否添加远程仓库
echo ""
read -p "是否添加 GitHub 远程仓库？(y/n) " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    read -p "请输入 GitHub 仓库 URL: " repo_url

    if [ -n "$repo_url" ]; then
        git remote add origin "$repo_url"
        echo "📝 远程仓库已添加: $repo_url"

        read -p "是否现在推送到 GitHub？(y/n) " -n 1 -r
        echo
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            git push -u origin main
            echo "✅ 已推送到 GitHub！"
        fi
    fi
fi

echo ""
echo "✅ 初始化完成！"
echo ""
echo "📋 下一步:"
echo "  1. 如果还未推送到 GitHub，手动运行:"
echo "     cd $REPO_DIR"
echo "     git remote add origin <your-repo-url>"
echo "     git push -u origin main"
echo ""
echo "  2. 在 B 电脑（Windows）上克隆仓库:"
echo "     git clone <your-repo-url> %USERPROFILE%\\claude-code-workspace"
echo ""
echo "  3. 在 B 电脑上运行同步脚本:"
echo "     cd %USERPROFILE%\\claude-code-workspace\\scripts"
echo "     .\\sync-windows.ps1 pull"
