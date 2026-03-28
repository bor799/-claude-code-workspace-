---
name: youtube-transcript
description: |
  下载 YouTube 视频的字幕（支持中英文）。
  可以获取带或不带时间戳的字幕，保存为文本文件。
allowed-tools:
  - Bash
  - Write
  - Read
metadata:
  trigger: YouTube字幕下载、视频文字稿、字幕提取
  version: 1.0.0
  author: Murphy
---

# YouTube 字幕下载

你是一个 YouTube 字幕下载专家，能够从 YouTube 视频中提取字幕并保存为文本文件。

## 工作流程

当用户要求下载 YouTube 视频字幕时：

1. **解析视频 URL** - 从用户提供的 URL 中提取视频 ID
2. **尝试获取字幕** - 使用以下方法（按优先级）：
   - 优先获取中文简体字幕 (zh-Hans)
   - 其次获取中文繁体字幕 (zh-Hant)
   - 最后获取英文字幕 (en)
3. **保存字幕** - 将字幕保存到桌面或指定位置
4. **报告结果** - 告知用户字幕已保存的位置和条目数

## 使用工具

### 方法 1: 使用 Python 和 youtube-transcript-api

```python
from youtube_transcript_api import YouTubeTranscriptApi
import re

# 提取视频 ID
video_id = re.findall(r'(?:v=|\/)([0-9A-Za-z_-]{11}).*', url)[0]

# 获取字幕（优先中文）
transcript = YouTubeTranscriptApi.get_transcript(
    video_id, 
    languages=['zh-Hans', 'zh-Hant', 'zh', 'en']
)

# 保存字幕
with open('transcript.txt', 'w', encoding='utf-8') as f:
    for entry in transcript:
        f.write(entry['text'] + '\n')
```

### 方法 2: 使用 yt-dlp

如果 Python API 失败，使用 yt-dlp：

```bash
yt-dlp --write-subs --sub-langs zh-Hans,zh-Hant,en \
  --skip-download --cookies-from-browser chrome \
  --output "transcript" "VIDEO_URL"
```

## 输出格式

默认保存两个文件：
- `youtube_transcript.txt` - 纯文本字幕
- `youtube_transcript_formatted.txt` - 带时间戳的字幕（可选）

## 注意事项

- 如果遇到 IP 封禁，尝试使用浏览器 cookies
- 自动生成字幕（asr）可能不如人工字幕准确
- 某些视频可能没有字幕
