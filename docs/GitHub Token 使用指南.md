# GitHub Personal Access Token 使用指南

## 什么是 Personal Access Token (PAT)?

Personal Access Token 是 GitHub 提供的一种安全认证方式，用于代替密码进行 API 和 Git 操作。

---

## 📋 创建 Personal Access Token

### Step 1: 登录 GitHub

访问: https://github.com

使用你的账号登录:
- **账号**: 2822887579@qq.com
- **主页**: https://github.com/bor799

### Step 2: 进入 Settings

1. 点击右上角头像
2. 选择 **Settings** (设置)

### Step 3: 创建 Token

1. 在左侧菜单，滚动到底部
2. 点击 **Developer settings**
3. 点击 **Personal access tokens** → **Tokens (classic)**
4. 点击 **Generate new token** → **Generate new token (classic)**

### Step 4: 配置 Token

**Note (备注)**: 输入 `Claude Code Workspace`

**Expiration (过期时间)**: 选择 `No expiration` (永不过期) 或选择合适的时间

**Select scopes (选择权限)**: 勾选以下权限:
- ✅ **repo** (完整仓库访问权限)
  - repo:status
  - repo_deployment
  - public_repo
  - repo:invite
  - security_events

### Step 5: 生成并保存

1. 点击底部的 **Generate token**
2. **重要**: 立即复制 token（只显示一次！）
3. 保存到安全的地方

---

## 🔧 配置 Claude Code 工作区

### 方式 1: 存储 Token 到系统环境变量 (推荐)

**macOS / Linux**:
```bash
# 添加到 ~/.zshrc 或 ~/.bash_profile
export GITHUB_TOKEN="你的token"

# 重新加载配置
source ~/.zshrc
```

**Windows**:
```powershell
# 设置用户环境变量
[System.Environment]::SetEnvironmentVariable('GITHUB_TOKEN', '你的token', 'User')
```

### 方式 2: 存储 Token 到 Git Credential Helper

```bash
# macOS
git config --global credential.helper osxkeychain

# Windows
git config --global credential.helper manager-core

# Linux
git config --global credential.helper store
```

### 方式 3: 在 URL 中使用 Token (临时)

```bash
# 克隆仓库时
git clone https://<token>@github.com/bor799/claude-code-workspace.git

# 或添加远程仓库
git remote add origin https://<token>@github.com/bor799/claude-code-workspace.git
```

---

## 📝 更新 CLAUDE.md

将以下信息添加到你的 `~/CLAUDE.md`:

```markdown
## GitHub 配置

- **用户名**: bor799
- **邮箱**: 2822887579@qq.com
- **主页**: https://github.com/bor799
- **Token**: 已设置到环境变量 GITHUB_TOKEN

**注意**: 不要在文档中明文存储 token！
```

---

## 🚀 推送工作区到 GitHub

### 创建新仓库

1. 访问: https://github.com/new
2. **Repository name**: `claude-code-workspace`
3. **Description**: `Claude Code 技能体系和配置文件`
4. **Public/Private**: 选择你的偏好
5. **不要**勾选 "Add a README file" (我们已经有了)
6. 点击 **Create repository**

### 推送代码

```bash
cd ~/claude-code-workspace

# 添加远程仓库 (使用 token)
git remote add origin https://<token>@github.com/bor799/claude-code-workspace.git

# 推送到 GitHub
git push -u origin main
```

---

## 🔒 安全最佳实践

### ✅ 做什么

1. **定期更新 token**: 每 6-12 个月更新一次
2. **限制 token 权限**: 只授予必要的权限
3. **使用环境变量**: 不要在代码或文档中硬编码
4. **启用 2FA**: 在 GitHub 上启用双因素认证

### ❌ 不要做什么

1. **不要分享 token**: 像对待密码一样保护它
2. **不要提交到 git**: 确保 .gitignore 包含敏感文件
3. **不要在公开地方暴露**: 包括截图、日志、错误信息

---

## 🔄 更新 Token

如果 token 泄露或需要更新:

1. 撤销旧 token:
   - GitHub → Settings → Developer settings → Personal access tokens
   - 找到 token 并点击 **Delete**

2. 创建新 token (重复上面的步骤)

3. 更新系统配置:
   ```bash
   # 更新环境变量
   export GITHUB_TOKEN="新token"

   # 或更新 git credential
   git credential reject <<EOF
   protocol=https
   host=github.com
   EOF
   ```

---

## 📞 获取帮助

如果遇到问题:

- **GitHub 官方文档**: https://docs.github.com/en/authentication/keeping-your-account-and-data-secure/creating-a-personal-access-token
- **Token 权限说明**: https://docs.github.com/en/authentication/keeping-your-account-and-data-secure/creating-a-personal-access-token#creating-a-personal-access-token

---

**最后更新**: 2026-02-02
**作者**: Murphy
