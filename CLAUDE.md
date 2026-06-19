# Feature Factory — 项目级 CLAUDE.md

此项目是 Feature Factory Agent Teams 的可共享 Skill 包。它包含 7 个 Agent 定义、编排 Skill、入口命令和 Builder 共享规则。

## 项目用途

这不是一个应用程序代码库。它是一个 **Claude Code Skill 包**——可以被复制到任何项目中，为该项目的开发提供结构化的多 Agent 协作流水线。

## 组件架构

```
/software-factory (Command) → feature-factory (Skill) → 7 Agents
/debug (Command) → debugger (Agent)
```

## 关键文件

- `.claude/agents/*.md` — 7 个 Agent 定义（YAML frontmatter + body）
- `.claude/skills/feature-factory/SKILL.md` — 编排 Skill，定义三种模式的完整流水线
- `.claude/commands/software-factory.md` — `/software-factory` 入口命令
- `.claude/commands/debug.md` — `/debug` 独立调试命令
- `.claude/rules/builder-rules.md` — Builder 共享的 13 条质量准则
- `.claude/rules/git-workflow.md` — Git 工作流集成（分支命名、提交策略、冲突预防）
- `.claude/rules/failure-recovery.md` — 失败恢复与 5 个反馈闭环流程
- `.claude/tests/smoke.sh` — Pipeline 完整性验证脚本（43 项检查）
- `.claude/FAQ.md` — 常见问题和排查指南

## Agent 定义规范

每个 Agent 文件使用 YAML frontmatter：

```yaml
---
name: agent-name
description: 触发条件描述。PROACTIVELY invoke when...
tools: Read, Grep, Glob
model: sonnet
permissionMode: acceptEdits
maxTurns: 15
skills:  # 可选——预加载到 Agent 上下文的 Skill 列表
  - brainstorming
---
```

## 跨项目共享

此 Skill 包设计为跨项目可移植：
- Agent 定义不包含项目特定代码引用
- Builder 共享规则是通用的质量准则
- 每个目标项目需要自己的 CLAUDE.md（从模板创建）

## 已知依赖

- Planner Agent 依赖 [Superpowers](https://github.com/anthropics/superpowers) 插件的 `brainstorming` Skill
- 如果 Superpowers 不可用，Planner 仍然可以工作——brainstorming 调用会优雅降级为内部分析
