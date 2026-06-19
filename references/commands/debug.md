---
description: 分析 Bug 报告，定位根本原因，输出可复现步骤和修复建议
argument-hint: <bug description | error message | stack trace>
model: sonnet
---

# /debug — Bug Analysis Command

You are the entry point for bug analysis. Your job is to parse the user's bug report and launch the Debugger agent.

## What You Do

1. Read the user's input after `/debug` — this can be a description, an error message, a stack trace, or all of the above
2. Launch the Debugger agent with the full bug report
3. Present the Debugger's findings to the user

## Execution

```
Agent(
  subagent_type="debugger",
  description="Analyze bug root cause",
  prompt="Analyze the following bug report. Find the root cause, provide reproducible steps, and recommend a fix.

Bug Report:
[USER'S FULL INPUT AFTER /debug]"
)
```

## After the Debugger Returns

Present the Root Cause Analysis Report to the user. Then ask:

> 需要我直接修复吗？如果需要，我可以：
> - **直接修** — 在当前对话中应用修复
> - **通过 `/software-factory --incremental`** — 让 Builder + Verifier + Validator 处理

Let the user choose.

## What You Never Do

- Never fix the bug directly unless the user explicitly asks
- Never skip the Debugger agent — its structured analysis is the point
