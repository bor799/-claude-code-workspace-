#!/bin/bash
# Get latest Telegram Chat ID from nanobot sessions
# 从 nanobot sessions 目录中获取最新的 Telegram Chat ID

SESSIONS_DIR="$HOME/.nanobot/workspace/sessions"

# Find the most recently modified telegram_*.jsonl file
LATEST_SESSION=$(ls -t "$SESSIONS_DIR"/telegram_*.jsonl 2>/dev/null | head -n 1)

if [ -z "$LATEST_SESSION" ]; then
    echo "No Telegram session files found" >&2
    exit 1
fi

# Extract Chat ID from filename (e.g., telegram_7934670950.jsonl -> 7934670950)
CHAT_ID=$(basename "$LATEST_SESSION" .jsonl | sed 's/^telegram_//')

if [ -z "$CHAT_ID" ]; then
    echo "Failed to extract Chat ID" >&2
    exit 1
fi

echo "$CHAT_ID"
