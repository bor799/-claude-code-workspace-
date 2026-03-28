---
name: telegram-proxy-fix
version: 1.0.0
description: |
  Telegram Bot API 代理连接修复工具。自动检测和修复国内网络环境下 Telegram API 无法访问的问题。

  支持自动检测系统代理（Clash、V2Ray、Surge 等）、环境变量、常见代理端口。
  为 Python/Node.js 项目提供代理集成代码。

  触发条件：Telegram Bot 无法发送消息、Connection refused/Timeout 错误。
trigger:
  - Telegram
  - 代理
  - proxy
  - Connection refused
  - Timeout
  - 无法访问
  - 国内网络
allowed-tools:
  - Bash
  - Read
  - Write
metadata:
  author: Murphy
  category: 网络工具
  related_issue: https://github.com/op7418/CodePilot/issues/210
---

# Telegram Proxy Fix

## 描述

自动检测和修复 Telegram Bot API 的代理连接问题。解决国内网络环境下 Telegram API 无法访问的问题。

## 功能

- 自动检测系统代理配置（Clash、V2Ray、Surge 等）
- 支持环境变量 `HTTPS_PROXY` / `HTTP_PROXY` / `ALL_PROXY`
- 自动测试常见代理端口 (7890, 7891, 7897, 7899, 10808, 10809)
- 为 Python/Node.js 项目提供代理集成代码

## 使用场景

当以下情况时使用此技能：

1. Telegram Bot 无法发送消息
2. "Connection refused" 或 "Timeout" 错误
3. 需要在国内网络环境使用 Telegram API
4. 需要为项目添加代理支持

## 快速开始

### 1. 检测代理状态

```bash
# 检查环境变量
echo $HTTPS_PROXY

# 检查 Clash Verge 端口
lsof -iTCP -sTCP:LISTEN -P | grep clash

# 检查系统代理设置
scutil --proxy
```

### 2. 设置代理

```bash
# 临时设置
export HTTPS_PROXY=http://127.0.0.1:7897

# 永久设置（写入 ~/.zshrc）
echo 'export HTTPS_PROXY=http://127.0.0.1:7897' >> ~/.zshrc
source ~/.zshrc
```

### 3. 测试连接

```bash
# 测试 Telegram API
curl -x $HTTPS_PROXY -s -o /dev/null -w "%{http_code}" https://api.telegram.org
```

## Python 集成

将以下代码添加到你的项目中：

```python
from typing import Optional
import os
import subprocess

class TelegramNotifier:
    def __init__(self, config: dict):
        self.bot_token = config.get('telegram_bot_token')
        self.chat_id = config.get('telegram_chat_id')
        self.proxy = self._detect_proxy()

    def _detect_proxy(self) -> Optional[str]:
        """自动检测代理配置"""
        # 1. 配置文件
        if config_proxy := self.config.get('telegram_proxy_url'):
            return config_proxy

        # 2. 环境变量
        for var in ['HTTPS_PROXY', 'HTTP_PROXY', 'ALL_PROXY']:
            if proxy := os.getenv(var):
                return proxy

        # 3. 自动检测常见端口
        for port in [7890, 7891, 7897, 7899, 10808, 10809]:
            if self._check_proxy_available(f'http://127.0.0.1:{port}'):
                return f'http://127.0.0.1:{port}'

        return None

    def _check_proxy_available(self, proxy_url: str) -> bool:
        """检查代理是否可用"""
        try:
            cmd = ['curl', '-s', '-o', '/dev/null', '-w', '%{http_code}',
                   '-x', proxy_url, '--connect-timeout', '3',
                   'https://api.telegram.org']
            result = subprocess.run(cmd, capture_output=True, text=True, timeout=5)
            return result.stdout in ['200', '401', '404']
        except Exception:
            return False

    def send_message(self, message: str) -> bool:
        """发送消息（自动使用代理）"""
        import json
        import urllib.request

        url = f"https://api.telegram.org/bot{self.bot_token}/sendMessage"
        data = json.dumps({
            'chat_id': self.chat_id,
            'text': message,
            'parse_mode': 'HTML'
        }).encode('utf-8')

        req = urllib.request.Request(url, data=data, headers={'Content-Type': 'application/json'})

        # 使用代理
        if self.proxy:
            req.set_proxy(self.proxy.replace('http://', ''), 'https')

        try:
            with urllib.request.urlopen(req, timeout=30) as response:
                return json.loads(response.read().decode()).get('ok', False)
        except Exception as e:
            print(f"发送失败: {e}")
            return False
```

## Node.js 集成

```javascript
import axios from 'axios';
import { HttpsProxyAgent } from 'https-proxy-agent';

class TelegramNotifier {
  constructor(config) {
    this.botToken = config.telegram_bot_token;
    this.chatId = config.telegram_chat_id;
    this.proxy = this.detectProxy();
  }

  detectProxy() {
    // 环境变量
    return process.env.HTTPS_PROXY ||
           process.env.HTTP_PROXY ||
           process.env.ALL_PROXY ||
           config.telegram_proxy_url ||
           null;
  }

  async sendMessage(message) {
    const url = `https://api.telegram.org/bot${this.botToken}/sendMessage`;

    try {
      const response = await axios.post(url, {
        chat_id: this.chatId,
        text: message,
        parse_mode: 'HTML'
      }, {
        httpsAgent: this.proxy ? new HttpsProxyAgent(this.proxy) : undefined,
        timeout: 30000
      });

      return response.data.ok;
    } catch (error) {
      console.error('发送失败:', error.message);
      return false;
    }
  }
}
```

## 代理软件端口参考

| 软件 | HTTP 端口 | SOCKS5 端口 |
|------|-----------|-------------|
| Clash Verge | 7890/7899 | 7897 |
| Clash X | 7890 | 7890 |
| V2RayN | 10809 | 10808 |
| Surge | 6153 | 6152 |
| Shadowsocks | - | 1080 |

## 故障排查

### 问题：端口测试全部失败

**原因**：代理软件未运行或端口配置错误

**解决**：
1. 确认代理软件正在运行
2. 检查代理软件的端口设置
3. 尝试开启 TUN 模式（某些软件需要）

### 问题：设置环境变量后仍然无效

**原因**：当前 shell 未重新加载配置

**解决**：
```bash
source ~/.zshrc
# 或重新打开终端
```

### 问题：curl 测试成功但程序仍然失败

**原因**：程序没有正确读取环境变量

**解决**：确保程序在启动后能读取到 `HTTPS_PROXY` 环境变量

## 相关链接

- [CodePilot Issue #210](https://github.com/op7418/CodePilot/issues/210) - 原始问题报告
- [Telegram Bot API](https://core.telegram.org/bots/api) - 官方文档
