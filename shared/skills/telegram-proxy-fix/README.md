# Telegram Proxy Fix

自动检测和修复 Telegram Bot API 代理连接问题。

## 快速使用

### 一键诊断

```bash
bash ~/claude-code-workspace/shared/skills/telegram-proxy-fix/telegram-proxy-fix.sh
```

### 交互式修复

脚本会自动：
1. 检查环境变量 `HTTPS_PROXY`
2. 检测代理软件（Clash、V2Ray、Surge 等）
3. 扫描常见代理端口
4. 测试 Telegram API 连接
5. 提供一键修复选项

## 技能内容

- **SKILL.md** - 完整的技能文档，包含 Python/Node.js 集成代码
- **telegram-proxy-fix.sh** - 一键诊断和修复脚本
- **README.md** - 本文件

## 集成到项目

### Python 项目

参考 `SKILL.md` 中的代码片段，添加 `TelegramNotifier` 类。

### Node.js 项目

使用 `https-proxy-agent` 库集成代理支持。

### 已集成的项目

- 100X 知识萃取系统（已自动应用此修复）

## 故障排查

| 问题 | 解决方案 |
|------|----------|
| 所有端口测试失败 | 确认代理软件正在运行 |
| 环境变量无效 | 运行 `source ~/.zshrc` 重新加载 |
| curl 成功但程序失败 | 检查程序是否正确读取环境变量 |

## 常见代理端口

| 软件 | 端口 |
|------|------|
| Clash Verge | 7897 (混合), 7899 (HTTP) |
| Clash X | 7890 |
| V2RayN | 10808 (HTTP), 10809 (SOCKS) |
| Surge | 6152 (HTTP), 6153 (SOCKS) |

## 更新日志

- **2026-03-12** - 初始版本
  - 自动检测环境变量
  - 端口扫描功能
  - Python/Node.js 集成代码
  - 一键诊断脚本
