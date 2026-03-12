# Telegram 代理配置修复技能

## 概述

修复 Telegram Bot 在国内网络环境下的连接问题，通过自动检测和配置代理解决 `api.telegram.org` 无法访问的问题。

## 适用场景

- Telegram Bot 推送失败
- 网络超时或连接被拒绝
- 国内网络环境下使用 Telegram API

## 诊断步骤

### 1. 检查代理环境变量

```bash
echo "HTTP_PROXY: $HTTP_PROXY"
echo "HTTPS_PROXY: $HTTPS_PROXY"
echo "ALL_PROXY: $ALL_PROXY"
```

### 2. 测试代理连接

```bash
# 测试代理能否访问 Telegram
curl -s -x http://127.0.0.1:7897 -o /dev/null -w "%{http_code}" "https://api.telegram.org"
# 返回 200/302/401/404 都表示能连接上
```

### 3. 查找代理端口

```bash
# 查看常见代理软件端口
lsof -iTCP -sTCP:LISTEN -P | grep -E ':(7890|7891|7897|10809|1087|6152|6153)'

# 或查看系统代理设置
scutil --proxy  # macOS
```

## 配置方法

### 临时配置（当前终端会话）

```bash
export HTTPS_PROXY=http://127.0.0.1:你的端口
export HTTP_PROXY=http://127.0.0.1:你的端口

# 例如 Clash Verge
export HTTPS_PROXY=http://127.0.0.1:7897
```

### 永久配置（推荐）

#### macOS / Linux

```bash
# 编辑 shell 配置文件
echo 'export HTTPS_PROXY=http://127.0.0.1:你的端口' >> ~/.zshrc
echo 'export HTTP_PROXY=http://127.0.0.1:你的端口' >> ~/.zshrc

# 重新加载配置
source ~/.zshrc
```

#### Windows

```powershell
# PowerShell
setx HTTPS_PROXY http://127.0.0.1:你的端口
setx HTTP_PROXY http://127.0.0.1:你的端口
```

## 验证配置

### 测试 Bot API 连接

```bash
# 替换 YOUR_BOT_TOKEN 为你的实际 token
curl -s -x $HTTPS_PROXY -X POST \
  "https://api.telegram.org/botYOUR_BOT_TOKEN/getMe" \
  -H "Content-Type: application/json" | python3 -m json.tool
```

### 发送测试消息

```bash
# 替换 YOUR_BOT_TOKEN 和 YOUR_CHAT_ID
curl -s -x $HTTPS_PROXY -X POST \
  "https://api.telegram.org/botYOUR_BOT_TOKEN/sendMessage" \
  -H "Content-Type: application/json" \
  -d '{"chat_id": "YOUR_CHAT_ID", "text": "测试消息"}'
```

## 常见问题

### Q1: 代理端口是多少？

A: 取决于你的代理软件：
- **Clash Verge**: 默认 7897（可在设置中查看）
- **ClashX**: 默认 7890
- **V2RayN**: 默认 10809
- **Surge**: 查看 macOS 系统代理设置

### Q2: 仍然连接失败？

A: 检查以下几点：
1. 代理软件是否正在运行
2. 端口号是否正确
3. 代理是否允许局域网连接
4. 尝试使用系统代理模式而非 TUN 模式

### Q3: 如何获取 Chat ID？

A: 发送消息给你的 Bot，然后访问：
```
https://api.telegram.org/botYOUR_BOT_TOKEN/getUpdates
```

## 相关资源

- [Telegram Bot API 文档](https://core.telegram.org/bots/api)
- [CodePilot Issue #210](https://github.com/op7418/CodePilot/issues/210)
- [undici ProxyAgent](https://undici.nodejs.org/#/docs/api/ProxyAgent)
