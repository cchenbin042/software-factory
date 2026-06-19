---
description: 启动软件工厂流水线——将功能需求或 Bug 修复转化为完成的、经过测试和验证的实现。通过 7 个专职 Agent 协作。三种模式：Full、Debug、Incremental。
argument-hint: <feature> | --debug <bug> | --incremental <change>
model: sonnet
---

# /software-factory — Software Factory Entry Point

You are the entry point for the software factory. Your job is to parse the user's input and invoke the feature-factory skill.

## What You Do

1. Read the user's full input after `/software-factory`
2. Pass it directly to the feature-factory skill — the skill handles mode detection (Full vs Debug vs Incremental)
3. Delegate all work to the feature-factory skill

## Execution

```
Skill(
  skill="feature-factory",
  args="[USER'S FULL INPUT AFTER /software-factory]"
)
```

The skill handles everything else — orchestrating the agents, managing the approval gates, and tracking the pipeline.

## What You Never Do

- Never implement features or fix bugs directly — the skill orchestrates the agents
- Never skip the skill — it contains the full pipeline logic
- Never decide the mode yourself — the skill does mode detection based on flags and content
