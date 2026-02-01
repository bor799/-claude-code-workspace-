# Claude Code 工作区同步脚本 (Windows 版本)
# 用法: .\sync-windows.ps1 [push|pull|status]

param(
    [Parameter(Position=0)]
    [ValidateSet('push', 'pull', 'status', 'help')]
    [string]$Command = 'help'
)

# 配置
$REPO_DIR = "$env:USERPROFILE\claude-code-workspace"
$SKILLS_SOURCE = "$REPO_DIR\skills"
$SKILLS_TARGET_AGENT = "$env:USERPROFILE\.agents\skills"
$SKILLS_TARGET_CLAUDE = "$env:USERPROFILE\.claude\skills"
$CLAUDE_MD_SOURCE = "$REPO_DIR\CLAUDE.md"
$CLAUDE_MD_TARGET = "$env:USERPROFILE\CLAUDE.md"

# 日志函数
function Log-Info {
    param([string]$Message)
    Write-Host "[INFO] $Message" -ForegroundColor Green
}

function Log-Warn {
    param([string]$Message)
    Write-Host "[WARN] $Message" -ForegroundColor Yellow
}

function Log-Error {
    param([string]$Message)
    Write-Host "[ERROR] $Message" -ForegroundColor Red
}

# 显示用法
function Show-Usage {
    Write-Host "用法: .\sync-windows.ps1 [push|pull|status|help]"
    Write-Host ""
    Write-Host "命令:"
    Write-Host "  push    - 推送本地更改到 GitHub"
    Write-Host "  pull    - 从 GitHub 拉取更新并安装"
    Write-Host "  status  - 查看同步状态"
    Write-Host "  help    - 显示此帮助信息"
    Write-Host ""
    Write-Host "示例:"
    Write-Host "  .\sync-windows.ps1 push   # 推送到 GitHub"
    Write-Host "  .\sync-windows.ps1 pull   # 拉取更新"
}

# Git 操作
function Git-Push {
    Log-Info "推送到 GitHub..."

    Set-Location $REPO_DIR

    # 检查是否有更改
    $status = git status --porcelain
    if (-not $status) {
        Log-Warn "没有需要推送的更改"
        return
    }

    # 添加所有更改
    git add .

    # 提交
    Write-Host ""
    $commitMsg = Read-Host "请输入提交信息 (默认: Update workspace)"
    if (-not $commitMsg) { $commitMsg = "Update workspace" }

    git commit -m $commitMsg

    # 推送
    git push

    Log-Info "✅ 推送成功！"
}

function Git-Pull {
    Log-Info "从 GitHub 拉取更新..."

    Set-Location $REPO_DIR

    # 拉取更新
    git pull origin main

    Log-Info "✅ 拉取成功！"

    # 安装更新
    Install-ToSystem
}

function Git-Status {
    Log-Info "查看同步状态..."

    Set-Location $REPO_DIR

    Write-Host ""
    git status
    Write-Host ""

    # 显示最近提交
    Write-Host "最近的提交:"
    git log --oneline -5
}

# 安装到系统
function Install-ToSystem {
    Log-Info "安装更新到系统..."

    # 备份现有配置
    $backupDir = "$env:USERPROFILE\.claude-backup-$(Get-Date -Format 'yyyyMMdd-HHmmss')"
    New-Item -ItemType Directory -Path $backupDir -Force | Out-Null

    if (Test-Path $CLAUDE_MD_TARGET) {
        Copy-Item $CLAUDE_MD_TARGET $backupDir
        Log-Info "已备份现有 CLAUDE.md"
    }

    if (Test-Path $SKILLS_TARGET_AGENT) {
        Copy-Item $SKILLS_TARGET_AGENT $backupDir -Recurse
        Log-Info "已备份现有技能"
    }

    # 安装 CLAUDE.md
    Copy-Item $CLAUDE_MD_SOURCE $CLAUDE_MD_TARGET -Force
    Log-Info "✅ 已更新 CLAUDE.md"

    # 安装技能
    New-Item -ItemType Directory -Path $SKILLS_TARGET_AGENT -Force | Out-Null
    Copy-Item "$SKILLS_SOURCE\*" $SKILLS_TARGET_AGENT -Recurse -Force

    # 创建符号链接（需要管理员权限或开发者模式）
    # Windows 符号链接需要特殊权限，这里使用复制代替
    New-Item -ItemType Directory -Path $SKILLS_TARGET_CLAUDE -Force | Out-Null

    # 复制技能文件（Windows 下用复制代替符号链接）
    Copy-Item "$SKILLS_SOURCE\*" $SKILLS_TARGET_CLAUDE -Recurse -Force

    Log-Info "✅ 已更新技能"

    # 验证安装
    Write-Host ""
    Log-Info "验证安装:"
    Get-ChildItem $SKILLS_TARGET_CLAUDE | Where-Object {
        $_.Name -match 'code-review|evaluate-session|plan-feature|doc-manager'
    } | ForEach-Object { Write-Host "  → $($_.Name)" }

    Write-Host ""
    Log-Info "✅ 安装完成！"
    Log-Info "备份位置: $backupDir"
}

# 主函数
switch ($Command) {
    'push' {
        Git-Push
    }
    'pull' {
        Git-Pull
    }
    'status' {
        Git-Status
    }
    'help' {
        Show-Usage
    }
}
