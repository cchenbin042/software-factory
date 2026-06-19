# Feature Factory — 项目级 CLAUDE.md

此项目是 Feature Factory Agent Teams 的可共享 Skill 包。它包含 7 个 Agent 定义、编排 Skill、入口命令和 Builder 共享规则。

## 项目用途

这不是一个应用程序代码库。它是一个 **Claude Code Skill 包**——可以被复制到任何项目中，为该项目的开发提供结构化的多 Agent 协作流水线。

## 组件架构

```
SKILL.md (ModelScope 入口) → .claude/ (Skill 包)
/software-factory (Command) → feature-factory (Skill) → 7 Agents
/debug (Command) → debugger (Agent)
```

## 目录布局

```
feature-factory/
├── SKILL.md                     ← ★ ModelScope / Skill 入口（根目录仅此 1 个 SKILL.md）
├── .claude/                     ← 部署到目标项目的 Skill 包
│   ├── agents/                  ← 从 references/agents/ 镜像
│   ├── skills/domain-modeling/  ← 领域建模 Skill
│   ├── commands/                ← /software-factory, /debug
│   ├── rules/                   ← Builder 规则、Git 工作流、失败恢复
│   ├── tests/                   ← smoke.sh
│   ├── FAQ.md
│   └── CLAUDE.md.template
├── references/                  ← ★ 规范源（捆绑资源）
│   ├── agents/                  ← 7 Agent 定义
│   ├── rules/                   ← 3 规则文件
│   ├── prompts/                 ← 20 Prompt 模板
│   ├── commands/                ← 2 入口命令
│   ├── domain-modeling/         ← 领域建模 Skill
│   └── docs/                    ← FAQ、CLAUDE.md 模板
├── scripts/                     ← 安装脚本 + smoke test
└── assets/                      ← 图标
```

- 向魔搭社区上传时，`SKILL.md` 是唯一入口，`references/`、`scripts/`、`assets/` 为捆绑资源
- 在本仓库中，`.claude/` 是 `references/` 中文件的拷贝副本，确保本项目自身可通过 `/software-factory` 使用

## 关键文件

- `SKILL.md` — ★ ModelScope/Skill 入口，完整编排 Skill 定义
- `references/agents/*.md` — 7 个 Agent 定义（YAML frontmatter + body）
- `references/prompts/` — 20 个 Prompt 模板（三种模式 + 共享）
- `references/commands/software-factory.md` — `/software-factory` 入口命令
- `references/commands/debug.md` — `/debug` 独立调试命令
- `references/rules/builder-rules.md` — Builder 共享的 13 条质量准则
- `references/rules/git-workflow.md` — Git 工作流集成（分支命名、提交策略、冲突预防）
- `references/rules/failure-recovery.md` — 失败恢复与 5 个反馈闭环流程
- `references/domain-modeling/SKILL.md` — 领域建模 Skill
- `scripts/smoke.sh` — Pipeline 完整性验证脚本（62 项检查）
- `references/docs/FAQ.md` — 常见问题和排查指南

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
- SKILL.md 是 ModelScope 规范的 Skill 入口（根目录仅此 1 个 SKILL.md）
- 绑定资源在 `references/`（Agent、Prompt、规则）、`scripts/`（安装/测试脚本）和 `assets/`（图标）目录下
- 每个目标项目需要自己的 CLAUDE.md（从 `references/docs/CLAUDE.md.template` 创建）

## 已知依赖

- Planner Agent 依赖 [Superpowers](https://github.com/anthropics/superpowers) 插件的 `brainstorming` Skill
- 如果 Superpowers 不可用，Planner 仍然可以工作——brainstorming 调用会优雅降级为内部分析
