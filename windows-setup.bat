@echo off
echo ===============================================
echo    Claude Code Workspace - Windows 快速配置
echo ===============================================
echo.
echo 此脚本将:
echo 1. 检查 Git 安装
echo 2. 克隆/更新工作空间仓库
echo 3. 配置 Claude Code
echo 4. 检查开发工具
echo.
pause
echo.
echo 启动 PowerShell 配置脚本...
echo.

REM 以管理员权限运行 PowerShell
powershell -ExecutionPolicy Bypass -Command "Start-Process powershell -ArgumentList '-ExecutionPolicy Bypass -File \"%~dp0windows-setup.ps1\"' -Verb RunAs"

if %ERRORLEVEL% NEQ 0 (
    echo.
    echo ❌ 无法启动管理员权限的 PowerShell
    echo 尝试以普通用户权限运行...
    echo.
    powershell -ExecutionPolicy Bypass -File "%~dp0windows-setup.ps1"
)

echo.
echo 配置完成！
pause