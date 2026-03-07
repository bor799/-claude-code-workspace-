#!/bin/bash
# Update last Chat ID wrapper script

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
python3 "$SCRIPT_DIR/update-last-chat-id.py" "$@"
