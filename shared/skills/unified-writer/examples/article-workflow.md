# 文章创作完整流程示例

## 场景：从零到发布

### 第一步：创建草稿

```
用户: /write 写一篇关于 AI Agent 的文章

AI: 正在创建文章草稿...
    请提供以下信息：
    - 目标读者：技术人员 / 普通读者
    - 文章风格：技术 / 通俗 / 故事
    - 预期字数：500 / 1000 / 2000+
```

### 第二步：完善内容

```
用户: 技术人员，风格通俗，2000字

AI: 正在生成草稿...
    ✅ 草稿已创建: ai-agent-draft.md

    下一步建议：
    1. 检查并编辑内容
    2. 添加配图
    3. 生成封面

    需要现在执行吗？(y/n)

用户: y

AI: 执行中...
    ✅ 格式化完成
    ✅ 生成 3 张配图：
       - AI 架构图
       - 工作流程图
       - 应用场景图
    ✅ 生成封面图

    输出文件：
    - ai-agent-formatted.md
    - img/cover.png
    - img/architecture.png
    - img/workflow.png
    - img/scenarios.png
```

### 第三步：预览和调整

```
用户: 我想调整架构图的风格

AI: 可选风格：
    1. minimal - 极简风格
    2. technical - 技术蓝图
    3. elegant - 优雅风格
    4. warm - 温暖风格

    选择风格: technical

AI: 重新生成架构图...
    ✅ 已更新: img/architecture.png (technical 风格)
```

### 第四步：转换格式

```
用户: 转换成 HTML

AI: 转换中...
    ✅ HTML 生成完成
    📁 输出: ai-agent.html

    可用主题：
    - github (默认)
    - wechat
    - custom

    需要切换主题吗？(n)

AI: 完成！使用 GitHub 主题
```

### 第五步：发布

```
用户: 发布

AI: 选择发布平台：
    1. X/Twitter
    2. 微信公众号
    3. 小红书

    选择: 1, 2

AI: 准备发布...
    [X/Twitter]
    预览内容：
    [文章摘要 + 链接]
    标签: #AI #Agent #Tech

    [微信公众号]
    预览内容：
    [格式化后的文章]

    确认发布？(y)

AI: 发布中...
    ✅ X/Twitter: https://x.com/user/status/123456
    ✅ 微信公众号: 已发送草稿

    发布完成！总耗时: 2m 15s
```

---

## 完整对话示例

```
用户: /write 写一篇关于 AI Agent 的文章，目标读者是技术人员

AI: 正在生成文章...
    ✅ 草稿已创建: ai-agent-draft.md (2200 字)

    文章结构：
    - 引言: 什么是 AI Agent
    - 核心组件
    - 工作原理
    - 应用场景
    - 未来展望

    下一步建议：
    1. 格式化并美化
    2. 添加技术配图
    3. 生成架构流程图

    需要现在执行吗？(y/n)

用户: y，配图用技术风格

AI: 执行中...
    ✅ 格式化完成
    ✅ 生成配图 (technical 风格):
       - Agent 架构图
       - 决策流程图
       - 应用场景图

    输出文件：
    - ai-agent-formatted.md
    - img/architecture.png
    - img/decision-flow.png
    - img/applications.png

    需要发布吗？(y/n)

用户: 先转成 HTML

AI: 转换中...
    ✅ HTML 生成完成: ai-agent.html

    预览链接: file:///path/to/ai-agent.html

    现在发布吗？(y/n)

用户: 发布到微信

AI: 准备发布到微信公众号...
    文章已格式化为微信样式
    代码高亮: ✅
    数学公式: ✅
    图片: ✅

    确认发布？(y)

用户: y

AI: 发布中...
    ✅ 已发送到微信公众号草稿箱
    📝 请在后台查看并正式发布

    完整工作流耗时: 3m 45s
```

---

## 快捷操作

### 一键完成

```
用户: /write ai-agent-draft.md 全部

AI: 执行完整流程...
    ✅ 格式化
    ✅ 生成配图 (4 张)
    ✅ 转换 HTML
    ✅ 准备发布

    所有文件已就绪！
```

### 选择性执行

```
用户: /write ai-agent-draft.md 配图+封面

AI: 执行中...
    ✅ 生成 3 张配图
    ✅ 生成封面图

    输出: img/
```

---

## 时间参考

| 操作 | 预计耗时 |
|------|----------|
| 格式化 | 5-10s |
| 生成配图 (每张) | 10-15s |
| 生成封面 | 8-12s |
| 转换 HTML | 3-5s |
| 发布 | 5-10s |
| **完整流程** | **2-4 分钟** |
