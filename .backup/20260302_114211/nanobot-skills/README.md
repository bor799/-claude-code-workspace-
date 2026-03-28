# Nanobot Skills - Claude Code Integration

## Overview
This directory contains skills from Claude Code that have been migrated/linked for use with nanobot.

## Skills Status

### ✅ Currently Available in Nanobot

| Skill | Location | Status | Source |
|-------|----------|--------|--------|
| research-specialist | `/skills/research-specialist/` | ✅ Active | Native |
| invest-research | `/skills/invest-research/` | ✅ Active (4 sub-skills) | Native |
| humanizer-zh | `/skills/humanizer-zh/` | ✅ Linked | 🔗 Claude Code |
| doc-manager | `/skills/doc-manager/` | ✅ Linked | 🔗 Claude Code |
| plan-feature | `/skills/plan-feature/` | ✅ Linked | 🔗 Claude Code |
| systematic-debugging | `/skills/systematic-debugging/` | ✅ Linked | 🔗 Claude Code |
| brainstorming | `/skills/brainstorming/` | ✅ Linked | 🔗 Claude Code |
| youtube-transcript | `/skills/youtube-transcript/` | ✅ Linked | 🔗 Claude Code |
| opennews-mcp | `/skills/opennews-mcp/` | ✅ Active | 6551 API |
| opentwitter-mcp | `/skills/opentwitter-mcp/` | ✅ Active | 6551 API |

### 📦 Available in Claude Code (not yet in nanobot)

| Skill | Location | Description |
|-------|----------|-------------|
| humanizer-zh | `~/.claude/skills/humanizer-zh/` | Chinese text humanizer |
| doc-manager | `~/.claude/skills/doc-manager/` | Document management |
| plan-feature | `~/.claude/skills/plan-feature/` | Feature planning |
| test-driven-development | `~/.claude/skills/test-driven-development/` | TDD workflow |
| systematic-debugging | `~/.claude/skills/systematic-debugging/` | Debugging methodology |
| executing-plans | `~/.claude/skills/executing-plans/` | Plan execution |
| writing-plans | `~/.claude/skills/writing-plans/` | Plan writing |
| code-review | `~/.claude/skills/code-review/` | Code review |
| receiving-code-review | `~/.claude/skills/receiving-code-review/` | Receiving reviews |
| requesting-code-review | `~/.claude/skills/requesting-code-review/` | Requesting reviews |
| finishing-a-development-branch | `~/.claude/skills/finishing-a-development-branch/` | Branch management |
| writing-skills | `~/.claude/skills/writing-skills/` | Skill authoring |
| subagent-driven-development | `~/.claude/skills/subagent-driven-development/` | Subagent orchestration |
| dispatching-parallel-agents | `~/.claude/skills/dispatching-parallel-agents/` | Parallel agent execution |
| verification-before-completion | `~/.claude/skills/verification-before-completion/` | Task verification |
| using-superpowers | `~/.claude/skills/using-superpowers/` | Superpower usage |
| using-git-worktrees | `~/.claude/skills/using-git-worktrees/` | Git worktrees |
| evaluate-session | `~/.claude/skills/evaluate-session/` | Session evaluation |
| ui-ux-pro-max | `~/.claude/skills/ui-ux-pro-max/` | UI/UX guidance |
| brainstorming | `~/.claude/skills/brainstorming/` | Brainstorming |
| lets-go-rss | `~/.claude/skills/lets-go-rss/` | RSS handling |
| reading-note-publisher | `~/.claude/skills/reading-note-publisher/` | Publishing notes |
| youtube-transcript | `~/.claude/skills/youtube-transcript/` | YouTube transcription |
| agent-architecture-learning | `~/.claude/skills/agent-architecture-learning/` | Agent architecture |

### 🔌 MCP Servers (Claude Code)

| MCP | Status | Tools |
|-----|--------|-------|
| github | ✅ Enabled | mcp__github__*, mcp__github-mcp__* |
| web-reader | ✅ Available | mcp__web-reader__webReader |
| web-search-prime | ✅ Available | mcp__web-search-prime__webSearchPrime |
| exa | ✅ Available | mcp__exa__web_search_exa |
| ai-builders-coach | ✅ Available | mcp__ai-builders-coach__* |
| zread | ✅ Available | mcp__zread__read_file, mcp__zread__get_repo_structure |

## Migration Notes

### How to migrate Claude Code skills to nanobot:

1. Claude Code skills are stored in `~/.claude/skills/` as `.skill` files (ZIP archives)
2. Extract the skill: `unzip ~/.claude/skills/[skill-name].skill -d /tmp/`
3. Copy to nanobot: `cp -r /tmp/[skill-name]/ ~/.nanobot/workspace/skills/`
4. Create SKILL.md in the skill directory following nanobot's format

### Direct Linking (Alternative)

Create a symlink from nanobot skills to Claude Code skills:
```bash
ln -s ~/.claude/skills/[skill-name] ~/.nanobot/workspace/skills/[skill-name]
```

## MCP Integration

Claude Code MCP servers can be used by nanobot if they provide compatible APIs. Check:
- Server configuration in `~/.claude/settings.local.json`
- Available MCP tools under `mcp__*` permissions

### Available MCP Tools (from Claude Code)

| MCP Server | Tools | Status |
|-----------|-------|--------|
| github | create_repository, get_file_contents, list_issues, list_commits, list_pull_requests, search_repositories | ✅ Enabled |
| web-reader | webReader | ✅ Available |
| web-search-prime | webSearchPrime | ✅ Available |
| exa | web_search_exa | ✅ Available |
| ai-builders-coach | get_deployment_guide, get_base_url, get_auth_token, get_api_specification | ✅ Available |
| zread | read_file, get_repo_structure | ✅ Available |

### How to use MCP tools

The MCP tools are accessible via their full names, e.g.:
- `mcp__github__search_repositories`
- `mcp__web-reader__webReader`
- `mcp__exa__web_search_exa`

## Configuration Files

- Claude: `~/.claude/settings.json` and `~/.claude/settings.local.json`
- Nanobot: `/Users/murphy/.nanobot/workspace/skills/*/config.json`
