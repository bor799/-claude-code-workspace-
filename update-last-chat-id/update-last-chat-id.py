#!/usr/bin/env python3
"""
Update last Chat ID
每次收到消息时自动更新最新对话 ID
"""

import os
import sys

def update_last_chat_id(chat_id: str) -> None:
    """更新最新 Chat ID 到状态文件"""
    state_file = os.path.expanduser("~/.nanobot/workspace/last_chat_id.txt")
    os.makedirs(os.path.dirname(state_file), exist_ok=True)

    with open(state_file, "w") as f:
        f.write(chat_id)

    print(f"✅ Last chat ID updated: {chat_id}")

def get_last_chat_id() -> str | None:
    """获取最新 Chat ID"""
    state_file = os.path.expanduser("~/.nanobot/workspace/last_chat_id.txt")

    if not os.path.exists(state_file):
        return None

    with open(state_file, "r") as f:
        return f.read().strip()

if __name__ == "__main__":
    if len(sys.argv) > 1:
        update_last_chat_id(sys.argv[1])
    else:
        chat_id = get_last_chat_id()
        if chat_id:
            print(chat_id)
        else:
            sys.exit(1)
