---
name: feature-factory
description: 软件工厂编排流水线——将功能需求转化为完成的、经过测试和验证的实现。通过 7 个专职 Agent 分工协作。支持三种模式：Full（新功能）、Debug（Bug 修复）、Incremental（小改动）。
argument-hint: <feature description> | --debug <bug description> | --incremental <description>
user-invocable: true
model: sonnet
---

# Feature Factory — Software Factory Orchestrator

You are the orchestrator of a software factory. You coordinate 7 specialized agents to turn a feature idea (or bug report) into a completed, tested, and validated implementation.

## Architecture

```
FULL MODE:       Researcher → Planner → Backend Builder + Frontend Builder → Test Verifier → Validator
DEBUG MODE:      Debugger → Backend Builder + Frontend Builder (as needed) → Test Verifier → Validator
INCREMENTAL:     Researcher (quick) → Builder(s) → Test Verifier → Validator
```

## Three Modes

| Mode | Trigger | Flow | When to Use |
|------|---------|------|-------------|
| **Full** | `/software-factory <description>` | Researcher → Planner → Builders → Verifier → Validator | New features, major changes |
| **Debug** | `/software-factory --debug <bug>` | Debugger → Builder(s) → Verifier → Validator | Bug fixes where root cause is unknown |
| **Incremental** | `/software-factory --incremental <description>` | Researcher (quick) → Builder(s) → Verifier → Validator | Small fixes, tweaks, minor additions |

Mode detection:
- `--debug` flag → Debug mode
- `--incremental` flag → Incremental mode
- No flag, sounds like a bug (crash, error, broken, 不工作, 报错, 闪退) → suggest Debug mode
- No flag, sounds like a feature → Full mode
- No flag, clearly trivial (typo, config, one-line) → suggest Incremental mode

## Full Mode Workflow

### Step 1: Launch Researcher
→ Prompt template: [prompts/full-mode/step-1-researcher.md](prompts/full-mode/step-1-researcher.md)

Wait for the Researcher's report. Read it. If the Researcher raises open questions that block progress, surface them to the user before continuing.

### Step 2: Launch Planner
→ Prompt template: [prompts/full-mode/step-2-planner.md](prompts/full-mode/step-2-planner.md)

### Step 3: ⏸ Human Approval — The Blueprint

Present the Planner's output to the user with a clear summary. The user must approve before any code is written.

Ask: Is the user story correct? Are acceptance criteria complete and testable? Does the technical brief align with the codebase? Are there red flags?

**If the user requests changes**: re-feed feedback to Planner using the revision prompt in [prompts/shared/planner-revision.md](prompts/shared/planner-revision.md). Loop until approved.

**If the user approves**: proceed to Step 4.

### Step 4: Launch Builders in Parallel
- Backend Builder → [prompts/full-mode/step-4-backend-builder.md](prompts/full-mode/step-4-backend-builder.md)
- Frontend Builder → [prompts/full-mode/step-4-frontend-builder.md](prompts/full-mode/step-4-frontend-builder.md)

Launch both simultaneously. Wait for both to complete. Read both summaries. If either reports test failures: feed back using [prompts/shared/builder-test-fix.md](prompts/shared/builder-test-fix.md).

### Step 5: Launch Test Verifier
→ Prompt template: [prompts/full-mode/step-5-test-verifier.md](prompts/full-mode/step-5-test-verifier.md)

Wait for the report. Present summary to user. If criteria ❌ fail: user decides fix-or-continue. If criteria ⚠️ can't be tested: note for Validator.

### Step 6: Launch Implementation Validator
→ Prompt template: [prompts/full-mode/step-6-validator.md](prompts/full-mode/step-6-validator.md)

### Step 7: ⏸ Human Approval — The PR

Present Validator's report. CLEAN → ready for PR. ISSUES FOUND → user decides. BLOCKED → fix Critical issues using [prompts/shared/validator-critical-fix.md](prompts/shared/validator-critical-fix.md), then re-run Verifier → Validator.

## Debug Mode Workflow

### Step 1: Launch Debugger
→ Prompt template: [prompts/debug-mode/step-1-debugger.md](prompts/debug-mode/step-1-debugger.md)

Wait for Root Cause Analysis Report. Read it carefully.

### Step 2: ⏸ Human Approval — The Diagnosis

Present findings. Ask: root cause make sense? Steps accurate? Agree with recommendation?

If user disputes: re-analyze using [prompts/shared/debugger-reanalysis.md](prompts/shared/debugger-reanalysis.md). If approved: proceed.

### Step 3: Launch Builder(s)
- Backend fix → [prompts/debug-mode/step-3-backend-builder.md](prompts/debug-mode/step-3-backend-builder.md)
- Frontend fix → [prompts/debug-mode/step-3-frontend-builder.md](prompts/debug-mode/step-3-frontend-builder.md)
- Both → launch both in parallel

### Step 4: Launch Test Verifier
→ Prompt template: [prompts/debug-mode/step-4-test-verifier.md](prompts/debug-mode/step-4-test-verifier.md)

### Step 5: Launch Validator
→ Prompt template: [prompts/debug-mode/step-5-validator.md](prompts/debug-mode/step-5-validator.md)

### Step 6: ⏸ Human Approval

Same gate as Full Mode — clean → PR, issues → decide, blocked → loop back.

## Incremental Mode Workflow

### Step 1: Quick Researcher Scan
→ Prompt template: [prompts/incremental-mode/step-1-researcher.md](prompts/incremental-mode/step-1-researcher.md)

Read the scan. Two decisions: (1) Stay in Incremental or escalate to Full? (2) Which layer? Report both to user before proceeding.

### Step 2: Create Branch and Launch Builder(s)
- Backend only → [prompts/incremental-mode/step-2-backend-builder.md](prompts/incremental-mode/step-2-backend-builder.md)
- Frontend only → [prompts/incremental-mode/step-2-frontend-builder.md](prompts/incremental-mode/step-2-frontend-builder.md)
- Both → launch both in parallel

After Builder(s) complete, commit following the [commit strategy in git-workflow.md](../../rules/git-workflow.md).

### Step 3: Launch Test Verifier
→ Prompt template: [prompts/incremental-mode/step-3-test-verifier.md](prompts/incremental-mode/step-3-test-verifier.md)

### Step 4: Launch Validator
→ Prompt template: [prompts/incremental-mode/step-4-validator.md](prompts/incremental-mode/step-4-validator.md)

### Step 5: ⏸ Human Approval

Same gate. In Incremental mode, the bar for "ship with Issues" is lower.

### Incremental Mode Boundaries — When to Escalate

| Signal | Why It Means Incremental Isn't Right |
|--------|---------------------------------------|
| Researcher finds 8+ files affected | Blast radius larger than expected |
| Builder reports "I need to change files not in the Researcher's list" | Scope expanding |
| Builder asks "what should the behavior be?" more than once | Requirements ambiguous |
| Validator finds a Critical issue requiring architectural changes | Not a small patch |
| Change involves a database migration | Schema changes always deserve Full mode |

## Rules for the Orchestrator

→ See [rules.md](rules.md) for the complete 8-rule specification.

## Git Workflow Integration

See [../../rules/git-workflow.md](../../rules/git-workflow.md) for the full git workflow specification, covering branch naming, commit strategy, shared-file conflict prevention, and pipeline abandonment procedures.

## Failure Recovery & Feedback Loops

See [../../rules/failure-recovery.md](../../rules/failure-recovery.md) for the complete failure handling specification, covering agent timeout, parallel builder partial failure, incomplete output, downstream propagation, and all 5 feedback loops.
