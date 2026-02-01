# Claude Code 自动化定时同步 - 完整使用指南

## ✅ 系统状态

**当前状态**: 所有组件已安装并测试通过 ✅

- ✅ 自动同步脚本已创建
- ✅ Git 凭证已配置
- ✅ Launchd 定时任务已加载
- ✅ 所有测试用例通过（19/19）
- ✅ VPN 连接正常

---

## 🎯 系统功能

### 自动化功能

1. **每周自动同步**: 每周一上午 10:00 自动执行
2. **版本管理**: 每次同步创建 Git Tag（vYYYY-MM-DD）
3. **VPN 检查**: 自动检测 VPN 连接状态
4. **智能跳过**: 无更新或 VPN 未连接时自动跳过
5. **完整日志**: 记录所有同步历史

### 版本历史

每次同步会在 GitHub 上创建一个 Tag，例如：
```
v2026-02-02
v2026-02-09
v2026-02-16
```

你可以随时回滚到任何历史版本。

---

## 📋 日常使用

### 自动同步（推荐）

**无需任何操作！** 系统会在每周一上午 10:00 自动同步。

**前提条件**:
- ✅ VPN 已连接
- ✅ 电脑已开机

### 手动同步

如果需要立即同步：

```bash
cd ~/claude-code-workspace/scripts
./auto-sync.sh sync
```

### 查看状态

```bash
cd ~/claude-code-workspace/scripts
./auto-sync.sh status
```

输出示例：
```
=========================================
同步状态
=========================================
VPN: ✅ 已连接

仓库状态:
  未推送的提交: 0
  未提交的更改: 有

最近的 Tags:
v2026-02-02
v2026-01-26
v2026-01-19
```

### 查看同步历史

```bash
# 查看日志
cat ~/claude-code-workspace/sync.log

# 查看所有 Tags
cd ~/claude-code-workspace/scripts
./auto-sync.sh tags
```

---

## 🧪 测试系统

### 运行测试

```bash
cd ~/claude-code-workspace/scripts
./test-auto-sync.sh all
```

### 测试覆盖

测试套件包含 19 个测试用例：

1. ✅ 脚本文件存在性
2. ✅ Launchd 配置文件
3. ✅ Git 配置
4. ✅ 脚本帮助功能
5. ✅ 脚本状态功能
6. ✅ VPN 检测
7. ✅ Git 仓库状态
8. ✅ 日志文件创建
9. ✅ 测试模式
10. ✅ Tag 列表
11. ✅ 权限检查
12. ✅ 环境变量
13-19. ✅ 其他验证测试

### 快速测试

```bash
./test-auto-sync.sh quick
```

---

## 🔄 版本管理

### 查看所有版本

```bash
cd ~/claude-code-workspace
git tag -l
```

### 查看特定版本

```bash
# 查看版本详情
git show v2026-02-02

# 查看版本之间的差异
git diff v2026-02-02 v2026-02-09
```

### 回滚到旧版本

```bash
# 查看某个版本的内容
git checkout v2026-02-02

# 恢复到最新版本
git checkout main
```

### 删除标签（谨慎操作）

```bash
# 删除本地标签
git tag -d v2026-02-02

# 删除远程标签
git push origin :refs/tags/v2026-02-02
```

---

## ⚙️ 高级配置

### 修改同步时间

编辑 Launchd 配置文件：

```bash
vim ~/Library/LaunchAgents/com.claudecode.sync.plist
```

修改 `StartCalendarInterval` 部分：

```xml
<key>StartCalendarInterval</key>
<dict>
    <key>Weekday</key>
    <integer>1</integer>  <!-- 0=周日, 1=周一, ..., 6=周六 -->
    <key>Hour</key>
    <integer>10</integer>  <!-- 0-23 小时 -->
    <key>Minute</key>
    <integer>0</integer>   <!-- 0-59 分钟 -->
</dict>
```

修改后重新加载：

```bash
launchctl unload ~/Library/LaunchAgents/com.claudecode.sync.plist
launchctl load ~/Library/LaunchAgents/com.claudecode.sync.plist
```

### 查看定时任务日志

```bash
# 标准输出日志
tail -f /tmp/claudecode-sync.out.log

# 错误日志
tail -f /tmp/claudecode-sync.err.log
```

### 启用/禁用定时任务

```bash
# 禁用
launchctl unload ~/Library/LaunchAgents/com.claudecode.sync.plist

# 启用
launchctl load ~/Library/LaunchAgents/com.claudecode.sync.plist

# 手动触发测试
launchctl start com.claudecode.sync
```

---

## 📊 监控和维护

### 检查系统状态

```bash
# 运行完整测试
~/claude-code-workspace/scripts/test-auto-sync.sh all

# 查看定时任务状态
launchctl list | grep claudecode

# 查看最近同步
tail -20 ~/claude-code-workspace/sync.log
```

### 故障排除

#### 问题 1: 定时任务未执行

**检查**:
```bash
# 查看任务状态
launchctl list | grep claudecode

# 查看错误日志
cat /tmp/claudecode-sync.err.log
```

**解决**:
```bash
# 重新加载任务
launchctl unload ~/Library/LaunchAgents/com.claudecode.sync.plist
launchctl load ~/Library/LaunchAgents/com.claudecode.sync.plist
```

#### 问题 2: VPN 检测失败

**检查**:
```bash
ping -c 3 github.com
```

**解决**:
- 确保 VPN 已连接
- 检查 VPN 配置
- 尝试重启 VPN

#### 问题 3: Git 推送失败

**检查**:
```bash
cd ~/claude-code-workspace
git remote -v
git status
```

**解决**:
```bash
# 重新配置凭证
git config --global credential.helper osxkeychain

# 手动测试推送
git push origin main
```

---

## 🎓 最佳实践

### 1. 定期检查

建议每周手动运行一次测试：

```bash
~/claude-code-workspace/scripts/test-auto-sync.sh quick
```

### 2. 查看日志

定期查看同步日志，确保系统正常运行：

```bash
tail -50 ~/claude-code-workspace/sync.log
```

### 3. 版本管理

- 重要修改后，可以手动创建 Tag
- 定期清理旧的 Tags（保留最近 3-6 个月）
- 为重要的版本添加详细的 Tag 消息

### 4. 备份策略

- GitHub 作为主要备份
- 本地保留最近 7 天的同步日志
- 重要修改建议额外备份到其他位置

---

## 📝 命令速查

### 日常命令

| 操作 | 命令 |
|------|------|
| 手动同步 | `~/claude-code-workspace/scripts/auto-sync.sh sync` |
| 查看状态 | `~/claude-code-workspace/scripts/auto-sync.sh status` |
| 查看日志 | `cat ~/claude-code-workspace/sync.log` |
| 查看版本 | `~/claude-code-workspace/scripts/auto-sync.sh tags` |
| 运行测试 | `~/claude-code-workspace/scripts/test-auto-sync.sh all` |

### 管理命令

| 操作 | 命令 |
|------|------|
| 查看定时任务 | `launchctl list \| grep claudecode` |
| 禁用定时任务 | `launchctl unload ~/Library/LaunchAgents/com.claudecode.sync.plist` |
| 启用定时任务 | `launchctl load ~/Library/LaunchAgents/com.claudecode.sync.plist` |
| 手动触发 | `launchctl start com.claudecode.sync` |

---

## 🔒 安全建议

### 1. Git 凭证

- ✅ 使用 Git Credential Helper（已配置）
- ✅ 凭证存储在 macOS Keychain 中
- ❌ 不要在脚本中硬编码密码

### 2. 日志文件

- 日志文件包含同步历史
- 不包含敏感信息（密码、Token）
- 定期清理旧日志

### 3. VPN 安全

- 使用可靠的 VPN 服务
- 确保 VPN 连接稳定
- 定期更新 VPN 配置

---

## 🎉 总结

你现在拥有一个**完全自动化的备份系统**：

✅ **每周自动备份** - 无需手动操作
✅ **版本历史管理** - 所有历史版本可追溯
✅ **智能检测** - VPN 和更新状态自动检查
✅ **完整测试** - 19 个测试用例确保可靠性
✅ **详细日志** - 所有操作都有记录
✅ **灵活控制** - 随时手动同步或查看状态

---

## 📞 获取帮助

### 查看帮助

```bash
# 同步脚本帮助
~/claude-code-workspace/scripts/auto-sync.sh help

# 测试脚本帮助
~/claude-code-workspace/scripts/test-auto-sync.sh help
```

### 相关文档

- `~/claude-code-workspace/README.md` - 项目说明
- `~/claude-code-workspace/docs/GitHub 配置指南-小白版.md` - GitHub 配置
- `~/claude-code-workspace/scripts/auto-sync.sh` - 同步脚本（带详细注释）
- `~/claude-code-workspace/scripts/test-auto-sync.sh` - 测试脚本（带详细注释）

---

**创建日期**: 2026-02-02
**版本**: 1.0.0
**作者**: Murphy
**状态**: ✅ 已安装并测试通过
