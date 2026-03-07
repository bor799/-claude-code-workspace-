# 统一写作工具 - 配置文件

> **优先级**: 项目级 > 用户级 > 默认级
> **项目级**: `.baoyu-skills/unified-writer/CONFIG.md`
> **用户级**: `~/.baoyu-skills/unified-writer/CONFIG.md`
> **默认级**: `shared/skills/unified-writer/CONFIG.md`

---

## 📝 写作偏好

### 内容格式化

```yaml
format:
  # 自动生成摘要
  auto_summary: true

  # 摘要长度: short, medium, long
  summary_length: medium

  # 中英文自动间距
  cjk_spacing: true

  # 标题层级规范
  heading_style: atx  # atx (#) or setext (===)

  # 列表符号
  list_style: consistent  # consistent, minus, plus, star
```

### 视觉生成

```yaml
visual:
  # 默认风格
  default_style: minimal  # minimal, elegant, technical, warm, blueprint

  # 默认类型
  default_type: infographic  # infographic, scene, flowchart, comparison

  # 默认比例
  aspect_ratio: landscape  # landscape (16:9), portrait (9:16), square (1:1)

  # 每篇文章配图数量
  images_per_article: 3

  # 自动生成封面图
  auto_cover: true
```

### 图片处理

```yaml
image:
  # 图片生成服务
  provider: openai  # openai, google, replicate

  # 默认模型
  model: dall-e-3

  # 图片压缩格式
  compress_format: webp  # webp, png

  # 压缩质量
  compress_quality: 85

  # 输出目录
  output_dir: img
```

### 内容发布

```yaml
publish:
  # 默认发布平台
  default_platforms:
    - x  # Twitter/X
    - wechat  # 微信公众号

  # 自动添加标签
  auto_tag: true

  # 默认标签
  default_tags:
    - AI
    - 技术

  # 发布前确认
  require_confirmation: true
```

### 内容转换

```yaml
convert:
  # HTML 主题
  html_theme: github  # github, wechat, custom

  # 代码高亮
  code_highlight: true

  # 数学公式
  math_rendering: katex  # katex, mathjax

  # 脚注
  footnotes: true
```

---

## 🎨 工具配置

### 内容获取

```yaml
content_import:
  # URL 内容提取
  url_reader: jina  # jina, browser

  # Twitter 内容提取
  twitter_reader: xreach  # xreach, api

  # 微信公众号
  wechat_reader: jina  # jina, custom
```

### 视觉生成

```yaml
visual_gen:
  # 信息图
  infographic:
    default_layout: bento-grid
    default_style: craft-handmade

  # 文章配图
  article_illustrator:
    auto_positions: true
    style_consistency: true

  # 封面图
  cover_image:
    default_palette: vibrant
    default_mood: professional
```

### 发布平台

```yaml
platforms:
  x:
    account: personal  # personal, work
    default_hashtags: ["#AI", "#Tech"]

  wechat:
    account: default
    auto_format: true

  xiaohongshu:
    account: default
    image_style: cartoon
```

---

## 🔧 高级设置

### 工作流

```yaml
workflows:
  # 文章创作流程
  article_creation:
    - format
    - visual
    - convert

  # 社交媒体发布
  social_post:
    - format
    - image
    - publish

  # 内容再利用
  content_repurpose:
    - import
    - format
    - visual
    - publish
```

### 智能推荐

```yaml
recommendations:
  # 基于内容类型推荐工具
  content_based: true

  # 基于历史选择推荐
  history_based: true

  # 显示推荐理由
  show_reasoning: true
```

### 性能

```yaml
performance:
  # 并行处理
  parallel: true

  # 缓存结果
  cache: true

  # 超时时间（秒）
  timeout: 120
```

---

## 📋 示例配置

### 极简配置

```yaml
# ~/.baoyu-skills/unified-writer/CONFIG.md
format:
  auto_summary: true

visual:
  default_style: minimal

publish:
  default_platforms: [x]
```

### 专业配置

```yaml
# .baoyu-skills/unified-writer/CONFIG.md
format:
  auto_summary: true
  summary_length: long
  cjk_spacing: true

visual:
  default_style: elegant
  default_type: framework
  images_per_article: 5
  auto_cover: true

image:
  provider: replicate
  model: sdxl
  compress_format: webp
  compress_quality: 90

publish:
  default_platforms: [x, wechat, xiaohongshu]
  auto_tag: true
  default_tags: [AI, LLM, 技术分享]

workflows:
  article_creation:
    - import
    - format
    - visual
    - convert
    - publish
```

---

**版本**: 1.0.0
**最后更新**: 2026-03-07
