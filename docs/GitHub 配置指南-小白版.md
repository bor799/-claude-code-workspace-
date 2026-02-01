# GitHub 配置指南 - 小白版

## 🎯 目标

将你的 Claude Code 工作区推送到 GitHub，实现多电脑同步。

---

## 📋 准备工作

### 你需要的信息

- **GitHub 账号**: 2822887579@qq.com
- **GitHub 主页**: https://github.com/bor799
- **GitHub 密码**: (你自己的密码)

### 好消息！

**你不需要设置 Token 或 SSH 密钥！**

Claude Code 有内置的 GitHub 代理，会自动处理所有认证问题。你只需要：
1. 登录 GitHub
2. 创建仓库
3. 运行推送命令

---

## 🚀 第一步：在 GitHub 创建仓库

### 1. 登录 GitHub

打开浏览器，访问: https://github.com

登录你的账号（2822887579@qq.com）

### 2. 创建新仓库

1. 点击右上角的 **+** 号
2. 选择 **New repository** (新建仓库)

### 3. 填写仓库信息

**Repository name (仓库名称)**:
```
claude-code-workspace
```

**Description (描述)**:
```
Claude Code 技能体系和配置文件
```

**Public/Private (公开/私有)**:
- 推荐: **Private** (私有) - 只有你能看到
- 或者: **Public** (公开) - 所有人都能看到

### 4. 其他设置

**⚠️ 重要**: 不要勾选以下选项:
- ❌ Add a README file (添加 README 文件)
- ❌ Add .gitignore (添加 .gitignore)
- ❌ Choose a license (选择许可证)

(我们已经有这些文件了)

### 5. 创建仓库

点击绿色的 **Create repository** 按钮

### 6. 保存仓库地址

创建后，GitHub 会显示一个地址，类似：
```
https://github.com/bor799/claude-code-workspace.git
```

**复制这个地址**，后面会用到！

---

## 📤 第二步：推送代码到 GitHub

打开 **终端** (Terminal)，运行以下命令：

### 1. 进入工作区目录

```bash
cd ~/claude-code-workspace
```

### 2. 添加 GitHub 远程仓库

```bash
git remote add origin https://github.com/bor799/claude-code-workspace.git
```

**注意**: 将 `bor799` 替换为你的用户名（如果不是 bor799）

### 3. 推送到 GitHub

```bash
git push -u origin main
```

**重要**: 运行这个命令时，Claude Code 的 GitHub 代理会弹出登录窗口：

1. 输入你的 GitHub 账号: `2822887579@qq.com`
2. 输入你的 GitHub 密码
3. 如果有 2FA (双因素认证)，输入验证码

### 4. 等待完成

上传可能需要几分钟，取决于文件大小和网络速度。

看到类似这样的信息就成功了：
```
To https://github.com/bor799/claude-code-workspace.git
 * [new branch]      main -> main
```

---

## ✅ 第三步：验证成功

### 1. 检查 GitHub 仓库

回到浏览器，刷新 GitHub 仓库页面：

你应该看到:
- ✅ README.md 文件
- ✅ skills/ 目录
- ✅ docs/ 目录
- ✅ scripts/ 目录
- ✅ CLAUDE.md 文件

### 2. 测试同步脚本

```bash
cd ~/claude-code-workspace/scripts
./sync-mac.sh status
```

应该显示 Git 状态信息。

---

## 🔄 如何使用

### 日常推送更新

当你修改了文件后（比如更新了 CLAUDE.md）:

```bash
cd ~/claude-code-workspace/scripts
./sync-mac.sh push
```

按提示输入提交信息，比如:
```
更新了工作偏好配置
```

### 拉取更新

当你在另一台电脑上需要同步时:

```bash
cd ~/claude-code-workspace/scripts
./sync-mac.sh pull
```

这会:
1. 从 GitHub 拉取最新代码
2. 自动安装到系统
3. 备份旧配置

---

## 📝 在 B 电脑（Windows）上使用

### 第一次设置

1. **克隆仓库**:
   ```powershell
   git clone https://github.com/bor799/claude-code-workspace.git $env:USERPROFILE\claude-code-workspace
   ```

2. **安装配置**:
   ```powershell
   cd $env:USERPROFILE\claude-code-workspace\scripts
   .\sync-windows.ps1 pull
   ```

3. **验证**:
   打开 Claude Code，测试技能是否可用:
   ```
   /evaluate-session
   ```

### 日常使用

**拉取更新**:
```powershell
cd $env:USERPROFILE\claude-code-workspace\scripts
.\sync-windows.ps1 pull
```

**推送更新**:
```powershell
cd $env:USERPROFILE\claude-code-workspace\scripts
.\sync-windows.ps1 push
```

---

## 🎯 快速参考卡片

### macOS (A 电脑)

| 操作 | 命令 |
|------|------|
| 推送到 GitHub | `cd ~/claude-code-workspace/scripts && ./sync-mac.sh push` |
| 从 GitHub 拉取 | `cd ~/claude-code-workspace/scripts && ./sync-mac.sh pull` |
| 查看状态 | `cd ~/claude-code-workspace/scripts && ./sync-mac.sh status` |

### Windows (B 电脑)

| 操作 | 命令 |
|------|------|
| 推送到 GitHub | `cd $env:USERPROFILE\claude-code-workspace\scripts; .\sync-windows.ps1 push` |
| 从 GitHub 拉取 | `cd $env:USERPROFILE\claude-code-workspace\scripts; .\sync-windows.ps1 pull` |
| 查看状态 | `cd $env:USERPROFILE\claude-code-workspace\scripts; .\sync-windows.ps1 status` |

---

## ❓ 常见问题

### Q1: 推送时提示 "Authentication failed" (认证失败)

**解决**:
1. 检查 GitHub 账号密码是否正确
2. 确认仓库地址是否正确
3. 重新运行 `git push -u origin main`

### Q2: 提示 "Permission denied" (权限被拒绝)

**解决**:
1. 确认仓库是你的
2. 确认账号有推送权限

### Q3: 推送很慢或失败

**解决**:
1. 检查网络连接
2. 尝试使用 VPN (如果需要)
3. 稍后再试

### Q4: Windows 脚本无法执行

**解决**:
```powershell
# 设置 PowerShell 执行策略
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
```

---

## 📞 需要帮助？

如果遇到问题:

1. **查看错误信息**: 仔细阅读终端显示的错误
2. **检查 GitHub 仓库**: 确认仓库地址正确
3. **重新尝试**: 有时只是网络问题

---

## 🎉 完成！

现在你已经:
- ✅ 创建了 GitHub 仓库
- ✅ 推送了工作区代码
- ✅ 设置好了同步机制

**下一步**: 在 Windows 电脑上克隆仓库并测试同步！

---

**创建日期**: 2026-02-02
**作者**: Murphy
**版本**: 1.0.0
