# Windows 开发环境配置脚本
# 使用方法: powershell -ExecutionPolicy Bypass -File windows-setup.ps1

Write-Host "🚀 Claude Code Workspace - Windows 开发环境配置" -ForegroundColor Green
Write-Host "================================================" -ForegroundColor Yellow

# 检查管理员权限
$isAdmin = ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
if (-not $isAdmin) {
    Write-Host "⚠️  建议以管理员身份运行此脚本" -ForegroundColor Yellow
    $continue = Read-Host "是否继续? (y/n)"
    if ($continue -ne "y") {
        exit
    }
}

# 1. 检查 Git
Write-Host "`n📦 检查 Git 安装..." -ForegroundColor Cyan
try {
    $gitVersion = git --version
    Write-Host "✅ Git 已安装: $gitVersion" -ForegroundColor Green
} catch {
    Write-Host "❌ Git 未安装，请先安装 Git: https://git-scm.com/download/win" -ForegroundColor Red
    exit 1
}

# 2. 设置工作空间目录
$workspacePath = "$env:USERPROFILE\claude-code-workspace"
Write-Host "`n📁 工作空间目录: $workspacePath" -ForegroundColor Cyan

if (Test-Path $workspacePath) {
    Write-Host "✅ 目录已存在" -ForegroundColor Green
} else {
    Write-Host "📥 创建工作空间目录..." -ForegroundColor Yellow
    New-Item -ItemType Directory -Path $workspacePath -Force | Out-Null
}

# 3. 检查是否为 git 仓库
if (Test-Path "$workspacePath\.git") {
    Write-Host "✅ 已是 Git 仓库，尝试更新..." -ForegroundColor Green
    Set-Location $workspacePath
    git pull origin main
} else {
    Write-Host "📥 克隆仓库..." -ForegroundColor Yellow
    Set-Location $env:USERPROFILE
    git clone https://github.com/bor799/-claude-code-workspace-.git $workspacePath
    Set-Location $workspacePath
}

# 4. 配置 Claude Code
Write-Host "`n⚙️  配置 Claude Code..." -ForegroundColor Cyan
$claudeMdPath = "$env:USERPROFILE\CLAUDE.md"

if (Test-Path $claudeMdPath) {
    $backup = "$claudeMdPath.backup_$(Get-Date -Format 'yyyyMMdd_HHmmss')"
    Write-Host "📋 备份现有 CLAUDE.md 到: $backup" -ForegroundColor Yellow
    Copy-Item $claudeMdPath $backup
}

$claudeConfig = @'
# Claude Code 配置

## 核心规则

- 直接务实，用最简单的方案
- 不确定就问，别猜
- 用 Edit 工具精准编辑
- 不要过度工程
- 不要停止/杀掉用户的后台守护进程，除非用户明确要求

## 专家规则（按需读取）

| 任务类型 | 规则文件 |
|----------|----------|
| 信息获取/搜索/理解/消化 | `rules/information-processing.md` |
| 写作/配图/发布 | `rules/content-creation.md` |
| 代码/调试/评估 | `rules/development.md` |
| 股票/投资决策 | `rules/investment-research.md` |

位置：`~/claude-code-workspace/rules/`

## 通用技能（按需触发，不绑专家）

| 触发信号 | 技能 | 说明 |
|----------|------|------|
| 关系/人际/心理 | /ljg-relationship | 关系结构分析 |
| 旅行/城市/文化 | /ljg-travel | 旅行深度研究 |
| 单词/英语/词根 | /ljg-word | 单词深度拆解 |
| 下载推文媒体 | /ljg-x-download | X 媒体下载 |
| 技能总览 | /ljg-skill-map | 查看已安装技能 |

## Windows 特定配置

- 路径分隔符: 支持正斜杠 `/` 和反斜杠 `\`
- 编码: UTF-8
- Shell: PowerShell / Git Bash
'@

Write-Host "📝 写入 CLAUDE.md 配置..." -ForegroundColor Yellow
$claudeConfig | Out-File -FilePath $claudeMdPath -Encoding UTF8
Write-Host "✅ CLAUDE.md 配置完成" -ForegroundColor Green

# 5. 设置 UTF-8 编码
Write-Host "`n🔧 配置系统编码..." -ForegroundColor Cyan
Write-Host "建议在 PowerShell 配置文件中添加:" -ForegroundColor Yellow
Write-Host "[Console]::OutputEncoding = [System.Text.Encoding]::UTF8" -ForegroundColor White

# 6. 检查开发工具
Write-Host "`n🛠️  检查推荐开发工具..." -ForegroundColor Cyan

$tools = @{
    "Node.js" = "node --version"
    "Python" = "python --version"
    "GitHub CLI" = "gh --version"
}

foreach ($tool in $tools.Keys) {
    try {
        $version = Invoke-Expression $tools[$tool] 2>&1
        if ($LASTEXITCODE -eq 0) {
            Write-Host "✅ $tool : $version" -ForegroundColor Green
        } else {
            Write-Host "⚠️  $tool 未安装" -ForegroundColor Yellow
        }
    } catch {
        Write-Host "⚠️  $tool 未安装" -ForegroundColor Yellow
    }
}

# 7. 完成
Write-Host "`n🎉 配置完成！" -ForegroundColor Green
Write-Host "================================================" -ForegroundColor Yellow
Write-Host "📚 工作空间位置: $workspacePath" -ForegroundColor Cyan
Write-Host "📝 配置文件位置: $claudeMdPath" -ForegroundColor Cyan
Write-Host "`n🚀 下一步:" -ForegroundColor Yellow
Write-Host "1. 重启 Claude Code" -ForegroundColor White
Write-Host "2. 尝试使用开发专家功能" -ForegroundColor White
Write-Host "3. 查看 README.md 了解更多功能" -ForegroundColor White

# 8. 询问是否打开工作空间
$openExplorer = Read-Host "`n是否在资源管理器中打开工作空间? (y/n)"
if ($openExplorer -eq "y") {
    explorer.exe $workspacePath
}

Write-Host "`n✨ 祝你使用愉快！" -ForegroundColor Green