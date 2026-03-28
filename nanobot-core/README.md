# Nanobot Core

**独立工作区 · 核心原则项目**

## 启动

```bash
cd ~/claude-code-workspace/nanobot-core && ./.system/loader.sh
```

## 结构

```
nanobot-core/
├── .system/
│   ├── manifest.json       # 项目配置
│   ├── principles.md       # 核心原则（入口）
│   ├── QUICKREF.md         # 快速参考
│   └── loader.sh           # 加载器
├── context/
│   └── session.md          # 会话上下文
├── rules/
│   ├── core-principles/    # 核心原则
│   └── extracted-rules/    # 提取规则
├── patterns/               # 行为模式
└── skills/                 # 技能库
```

## 执行模式

- **直接执行**: 输入 → 处理 → 结果
- **静默模式**: 无过程阐述
- **最大权限**: 无需审批

## 使用

**在对话开始时**：
1. 运行 `loader.sh` 加载工作区
2. 读取 `principles.md` 核心原则
3. 按原则执行，直接返回结果

---

**版本**: 1.0.0
**更新**: 2026-03-07
