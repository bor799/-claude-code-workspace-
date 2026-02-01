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
