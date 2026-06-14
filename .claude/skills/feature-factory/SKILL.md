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
| **Full** | `/feature-factory <description>` | Researcher → Planner → Builders → Verifier → Validator | New features, major changes |
| **Debug** | `/feature-factory --debug <bug>` | Debugger → Builder(s) → Verifier → Validator | Bug fixes where root cause is unknown |
| **Incremental** | `/feature-factory --incremental <description>` | Researcher (quick) → Builder(s) → Verifier → Validator | Small fixes, tweaks, minor additions |

Mode detection:
- `--debug` flag → Debug mode
- `--incremental` flag → Incremental mode
- No flag, sounds like a bug (crash, error, broken, 不工作, 报错, 闪退) → suggest Debug mode
- No flag, sounds like a feature → Full mode
- No flag, clearly trivial (typo, config, one-line) → suggest Incremental mode

## Full Mode Workflow

### Step 1: Launch Researcher

```
Agent(
  subagent_type="researcher",
  description="Research codebase for feature",
  prompt="Research the codebase for the following feature request. Map relevant files, identify existing patterns, find similar features, flag risks, and list tests that will need updates.

Feature: [USER'S FEATURE DESCRIPTION]"
)
```

Wait for the Researcher's report. Read it. If the Researcher raises open questions that block progress, surface them to the user before continuing.

### Step 2: Launch Planner

Pass the Researcher's findings to the Planner:

```
Agent(
  subagent_type="planner",
  description="Write user story and technical brief",
  prompt="Based on the following Researcher findings and the user's feature request, produce a User Story and Technical Brief. Include both in a single response.

Feature Request: [USER'S FEATURE DESCRIPTION]

Researcher Findings:
[RESEARCHER'S FULL OUTPUT]"
)
```

### Step 3: ⏸ Human Approval — The Blueprint

Present the Planner's output to the user with a clear summary. The user must approve before any code is written.

Ask:
- Is the user story correct? Does it capture the real problem?
- Are the acceptance criteria complete and testable?
- Does the technical brief align with how the codebase actually works?
- Are there red flags in the design? (wrong assumptions, over-engineering, missing edge cases)

**If the user requests changes**: feed the feedback back to the Planner:
```
Agent(
  subagent_type="planner",
  description="Revise user story and technical brief",
  prompt="Revise the User Story and Technical Brief based on the following user feedback. Only produce the revised version — do not re-explain the unchanged parts.

Original Output:
[PLANNER'S OUTPUT]

User Feedback:
[USER'S FEEDBACK]"
)
```

Loop until the user approves.

**If the user approves**: proceed to Step 4.

### Step 4: Launch Builders in Parallel

Launch both builders simultaneously — they share the same Technical Brief and can work independently.

```
// Launch Backend Builder
Agent(
  subagent_type="backend-builder",
  description="Build backend for feature",
  prompt="Implement the backend for the following approved Technical Brief. Build API routes, services, database migrations, and background jobs. Write unit tests. Run typecheck, lint, and tests before reporting.

Approved Technical Brief:
[PLANNER'S OUTPUT (technical brief section)]

Researcher Findings:
[RESEARCHER'S OUTPUT]"
)

// Launch Frontend Builder in parallel
Agent(
  subagent_type="frontend-builder",
  description="Build frontend for feature",
  prompt="Implement the frontend for the following approved Technical Brief. Build components, pages, hooks, and states. Write component tests. Run typecheck, lint, and tests before reporting.

Approved Technical Brief:
[PLANNER'S OUTPUT (technical brief section)]

Researcher Findings:
[RESEARCHER'S OUTPUT]

IMPORTANT: Use the API shapes from the Technical Brief as your contract. If the Backend Builder is running in parallel, the actual API may diverge later — the Validator will catch mismatches."
)
```

Wait for both to complete. Read both summaries.

**If either Builder reports test failures**: that Builder is not done. Ask the user whether to feed the failure back to the Builder for a fix, or continue and let the Validator catch it.

### Step 5: Launch Test Verifier

Pass all outputs to the Test Verifier:

```
Agent(
  subagent_type="test-verifier",
  description="Write acceptance tests",
  prompt="Write acceptance tests for the following feature. Cover every acceptance criterion from the user story. Report exactly which criteria pass and which fail.

User Story and Acceptance Criteria:
[PLANNER'S OUTPUT (user story section)]

Technical Brief:
[PLANNER'S OUTPUT (technical brief section)]

Backend Builder Summary:
[BACKEND BUILDER'S OUTPUT]

Frontend Builder Summary:
[FRONTEND BUILDER'S OUTPUT]"
)
```

Wait for the report. Present the summary to the user.

- If all criteria ✅ pass → proceed to Step 6.
- If some criteria ❌ fail → report to the user. The user decides whether to:
  - Send back to the relevant Builder for a fix → then re-run Verifier
  - Continue to Validator (Validator will also catch these)
- If some criteria ⚠️ can't be tested → note them. This is useful information for the Validator.

### Step 6: Launch Implementation Validator

```
Agent(
  subagent_type="implementation-validator",
  description="Validate the implementation",
  prompt="Validate the implementation against the approved story and brief. Check every item on your checklist: acceptance criteria, failure paths, security, migrations, scope, patterns, duplicates, missed concerns. Fix Minor issues directly. Report Important and Critical issues with file paths and line numbers.

Approved User Story:
[PLANNER'S OUTPUT (user story section)]

Approved Technical Brief:
[PLANNER'S OUTPUT (technical brief section)]

Backend Builder Summary:
[BACKEND BUILDER'S OUTPUT]

Frontend Builder Summary:
[FRONTEND BUILDER'S OUTPUT]

Test Verifier Report:
[TEST VERIFIER'S OUTPUT]"
)
```

### Step 7: ⏸ Human Approval — The PR

Present the Validator's report to the user.

- **If CLEAN**: tell the user the feature is ready for PR. Summarize what was built and the key test results.
- **If ISSUES FOUND**: present the Important/Minor issues. Let the user decide which to fix before PR.
- **If BLOCKED**: present the Critical issues. The user must decide next steps — send back to a Builder, fix manually, or adjust the brief.

If there are Critical issues and the user wants to fix them, loop back:
- Security/logic issues → Backend Builder
- UI/state issues → Frontend Builder
- Then re-run Verifier → re-run Validator

## Debug Mode Workflow

For bug fixes where the root cause is unknown. The Debugger finds it first, then builders apply the fix.

### Step 1: Launch Debugger

```
Agent(
  subagent_type="debugger",
  description="Analyze bug root cause",
  prompt="Analyze the following bug report. Find the root cause, provide reproducible steps, and recommend a fix.

Bug Report:
[USER'S BUG DESCRIPTION]"
)
```

Wait for the Debugger's Root Cause Analysis Report. Read it carefully.

### Step 2: ⏸ Human Approval — The Diagnosis

Present the Debugger's findings to the user. Ask:

- Does the root cause make sense?
- Are the reproducible steps accurate?
- Do you agree with the fix recommendation?

**If the user disputes the diagnosis**: feed their feedback back to the Debugger for deeper analysis.
```
Agent(
  subagent_type="debugger",
  description="Re-analyze bug with user feedback",
  prompt="Re-analyze the bug. Your previous analysis was:

[DEBUGGER'S PREVIOUS OUTPUT]

The user says: [USER'S FEEDBACK]

Re-examine the code with this feedback in mind. Revise or strengthen your root cause analysis."
)
```

**If the user approves**: proceed to Step 3.

### Step 3: Launch Builder(s)

Determine which layer the fix touches based on the Debugger's report:
- Backend only → Backend Builder
- Frontend only → Frontend Builder
- Both → both Builders in parallel

```
Agent(
  subagent_type="backend-builder",  // or frontend-builder, or both
  description="Apply bug fix",
  prompt="Apply the following fix based on the Debugger's root cause analysis. Write tests that prove the bug is fixed and prevent regression. Run typecheck, lint, and tests before reporting.

Debugger's Root Cause Analysis:
[DEBUGGER'S FULL OUTPUT]

Fix to apply:
- File: [path from debugger]
- Change: [specific change from debugger]
- Regression risk: [risk level from debugger]"
)
```

### Step 4: Launch Test Verifier

```
Agent(
  subagent_type="test-verifier",
  description="Verify bug fix",
  prompt="Write acceptance tests to verify the following bug is fixed. The acceptance criteria are:
1. The bug no longer reproduces (use the Debugger's reproducible steps)
2. The fix doesn't break existing functionality
3. Related paths that might have the same bug are also tested

Debugger's Root Cause Analysis:
[DEBUGGER'S FULL OUTPUT]

Builder Summary:
[BUILDER'S OUTPUT]"
)
```

### Step 5: Launch Validator

```
Agent(
  subagent_type="implementation-validator",
  description="Validate the bug fix",
  prompt="Validate the bug fix implementation. Focus on:
1. Was the root cause actually addressed? (not just the symptom)
2. Are there similar patterns elsewhere that should also be fixed?
3. Does the test actually reproduce the original bug?
4. Security and regression checks

Debugger's Root Cause Analysis:
[DEBUGGER'S FULL OUTPUT]

Builder Summary:
[BUILDER'S OUTPUT]

Test Verifier Report:
[TEST VERIFIER'S OUTPUT]"
)
```

### Step 6: ⏸ Human Approval

Present the Validator's report. Same approval gate — clean → PR, issues → decide, blocked → loop back.

## Incremental Mode Workflow

For small changes—typo fixes, config updates, minor UI tweaks, one-line patches. A lightweight scan replaces full research and planning. But every step is self-contained: the orchestrator never needs to cross-reference Full mode.

### Step 1: Quick Researcher Scan

Even small changes can have unexpected side effects. Launch a quick Researcher to map the affected area:

```
Agent(
  subagent_type="researcher",
  description="Quick scan for incremental change",
  prompt="Quick scan — under 10 turns. For the following change, identify: (1) Which files will be touched, (2) Any existing patterns those files follow, (3) Any tests that will need updates, (4) Any files that import or depend on the files being changed.

Change: [USER'S DESCRIPTION]"
)
```

Read the Researcher's scan carefully. Two decisions to make:

**Decision 1 — Stay in Incremental or escalate?**
- If the Researcher finds **cross-cutting concerns** (changes touching 3+ modules, database schema changes, auth/permission changes) → surface this to the user and offer to switch to Full mode
- If the Researcher finds **only the expected files** with no surprises → stay in Incremental
- If the Researcher finds **nothing** (change is purely cosmetic in one file) → stay in Incremental, proceed

**Decision 2 — Which layer?**
- Backend files only → Backend Builder only
- Frontend files only → Frontend Builder only
- Both layers → both Builders in parallel

Report both decisions to the user before proceeding: "This is a [backend/frontend/full-stack] change affecting [N] files. Staying in Incremental mode."

### Step 2: Create Branch and Launch Builder(s)

First, create the git branch (see [.claude/rules/git-workflow.md](../../rules/git-workflow.md) for branch naming and safety checks).

Then launch the appropriate Builder(s). Unlike Full mode, there is no Planner blueprint. The Builder works from the user's description plus the Researcher's scan.

#### If Backend Builder Only

```
Agent(
  subagent_type="backend-builder",
  description="Implement backend incremental change",
  prompt="Implement the following incremental change. There is no Technical Brief — the user's description IS the spec. Read the relevant existing code before you write anything. Surface any assumptions you make.

Change:
[USER'S DESCRIPTION]

Researcher Quick Scan:
[RESEARCHER'S OUTPUT]

Rules:
1. Read the files the Researcher identified BEFORE writing any code
2. Match existing patterns exactly — this is a small change, not a refactor
3. If the change implies a bigger refactor or touches files the Researcher didn't flag, STOP and report it — do not proceed
4. Write unit tests for what you change
5. Run typecheck, lint, and tests before reporting. All must pass.
6. If you cannot complete the change without touching files outside scope, report what you need and why — do not extend scope silently"
)
```

#### If Frontend Builder Only

```
Agent(
  subagent_type="frontend-builder",
  description="Implement frontend incremental change",
  prompt="Implement the following incremental change. There is no Technical Brief — the user's description IS the spec. Read the relevant existing code before you write anything. Surface any assumptions you make.

Change:
[USER'S DESCRIPTION]

Researcher Quick Scan:
[RESEARCHER'S OUTPUT]

Rules:
1. Read the files the Researcher identified BEFORE writing any code
2. Match existing patterns exactly — this is a small change, not a refactor
3. Handle all states: loading, error, empty, success — even for small UI changes
4. If the change implies a bigger refactor or touches files the Researcher didn't flag, STOP and report it — do not proceed
5. Write component tests for what you change
6. Run typecheck, lint, and tests before reporting. All must pass.
7. If you cannot complete the change without touching files outside scope, report what you need and why — do not extend scope silently"
)
```

#### If Both Builders (Parallel)

Launch both simultaneously. Apply the shared-file conflict prevention rules from [.claude/rules/git-workflow.md](../../rules/git-workflow.md) before launching. Use the same prompts as above, adding file ownership boundaries as needed.

After the Builder(s) complete, commit their work following the [commit strategy in git-workflow.md](../../rules/git-workflow.md).

**If a Builder reports test failures**: follow the [Builder Test Failure feedback loop](../../rules/failure-recovery.md#loop-2-builder-test-failure). Do not proceed to Step 3 until tests pass or the user explicitly overrides.

**If a Builder reports scope creep** (needs to touch files outside the Researcher's list): pause and report to the user. This is a sign that Incremental mode may be the wrong choice — offer to escalate to Full mode.

### Step 3: Launch Test Verifier

In Incremental mode, there is no Planner-written user story. The Test Verifier extracts acceptance criteria from the user's description and the Builder's output:

```
Agent(
  subagent_type="test-verifier",
  description="Write acceptance tests for incremental change",
  prompt="Write acceptance tests for the following incremental change. Since there is no formal User Story, your acceptance criteria come from two sources:

Source 1 — The user's original request:
[USER'S DESCRIPTION]

Source 2 — What the Builder actually implemented:
[BUILDER'S OUTPUT / BOTH BUILDERS' OUTPUTS]

Extract verifiable acceptance criteria from these sources. Each criterion must be something a test can directly confirm. Then write and run the tests.

Your report must follow the standard format:

## Acceptance Test Report: [Change Name]

### Test File
`path/to/__tests__/acceptance/[change-slug].test.ts`

### Results by Acceptance Criterion

| # | Criterion | Test | Result | Notes |
|---|-----------|------|--------|-------|
| 1 | [Derived from user description or Builder output] | `test('...')` | ✅/❌/⚠️ | |

### Summary
- ✅ Passing: N
- ❌ Failing: N
- ⚠️ Cannot cover cleanly: N

### Failing Criteria Detail
[If any — same format as Full mode]

### Untestable Criteria Detail
[If any — same format as Full mode]"
)
```

Present the Test Verifier's summary to the user.

- If all criteria ✅ pass → proceed to Step 4.
- If some criteria ❌ fail → follow the [Verifier Finds Untestable Criteria feedback loop](../../rules/failure-recovery.md#loop-4-verifier-finds-untestable-criteria). The user decides whether to fix or continue.
- If some criteria ⚠️ can't be tested → note them and proceed. The Validator will see them.

### Step 4: Launch Validator

The Validator's scope in Incremental mode is narrower — only the changed files, not the full codebase. But the checklist is the same:

```
Agent(
  subagent_type="implementation-validator",
  description="Validate the incremental change",
  prompt="Validate the incremental change against the user's request and the Builder's output. Run your full checklist (acceptance criteria, failure paths, security, migration safety, scope boundary, pattern consistency, duplicate logic, missed concerns) — but focus on the changed files only.

User's request:
[USER'S DESCRIPTION]

Researcher Quick Scan:
[RESEARCHER'S OUTPUT]

Backend Builder Summary (if applicable):
[BACKEND BUILDER'S OUTPUT — or 'N/A']

Frontend Builder Summary (if applicable):
[FRONTEND BUILDER'S OUTPUT — or 'N/A']

Test Verifier Report:
[TEST VERIFIER'S OUTPUT]

Key difference from Full mode: the scope is SMALL. Apply the checklist proportionally — a one-line config change does not need the same scrutiny as a new API endpoint. But run every check. If there's nothing to report, say CLEAN.

Fix Minor issues directly. Report Important and Critical issues with file paths and line numbers."
)
```

### Step 5: ⏸ Human Approval

Present the Validator's report to the user.

- **If CLEAN**: tell the user the change is ready for PR. Summarize what was changed and the test results. Same PR flow as Full mode — orchestrator does not create the PR.
- **If ISSUES FOUND**: present the Important/Minor issues. Let the user decide which to fix before PR. In Incremental mode, the bar for "ship with Issues" is lower than Full mode — a minor lint inconsistency in a hotfix is acceptable.
- **If BLOCKED**: present the Critical issues. Follow the [Validator BLOCKED feedback loop](../../rules/failure-recovery.md#loop-3-validator-blocked--rollback-to-builder). If the fix requires touching files outside the Researcher's original scope, strongly consider escalating to Full mode — the "incremental" premise has broken.

### Incremental Mode Boundaries — When to Escalate

Incremental mode works for changes that are **small and predictable**. If any of these happen during execution, pause and offer to switch to Full mode:

| Signal | Why It Means Incremental Isn't Right |
|--------|---------------------------------------|
| Researcher finds 8+ files affected | The blast radius is larger than expected — needs proper planning |
| Builder reports "I need to change files not in the Researcher's list" | Scope is expanding — the Researcher missed important dependencies |
| Builder asks "what should the behavior be?" more than once | Requirements are ambiguous — needs a Planner to resolve |
| Validator finds a Critical issue that requires architectural changes | The fix isn't a small patch — needs design work |
| Change involves a database migration | Schema changes always deserve Full mode planning with `up`/`down` review |

## Rules for the Orchestrator

1. **Never skip a human checkpoint.** The blueprint and the final PR must be approved by the user.
2. **Never modify code yourself.** You coordinate agents — you don't write or edit files.
3. **Pass complete context.** Each agent gets the full output of the agents before it. Summarizing loses critical detail.
4. **Surface uncertainty immediately.** If an agent's output is unclear or contradictory, flag it to the user rather than guessing.
5. **Track the chain.** After each step, report what was done and what comes next. The user should always know where they are in the pipeline.
6. **Handle failures gracefully.** If an agent seems to hang or produce bad output, tell the user and ask whether to retry or adjust.
7. **Retry with context on agent failure.** If an agent produces incomplete, malformed, or clearly wrong output, do NOT silently proceed. Instead:
   - Feed the agent's output + the specific problem back to a NEW instance of the same agent type: `"Your previous output had [problem]. [Original prompt]. Fix the issue and re-produce the full output."`
   - If the retry also fails, surface the problem to the user with the agent's raw output. Do not retry a third time without human guidance.
   - If an agent reports test failures it cannot fix, flag them rather than continuing — a downstream agent cannot fix upstream bugs.

8. **Never proceed past a broken step.** If an intermediate agent fails (Researcher produces nonsense, Planner contradicts CLAUDE.md, Builder introduces regressions), stop. A downstream agent cannot fix an upstream mistake — it can only amplify it.

## Git Workflow Integration

See [.claude/rules/git-workflow.md](../../rules/git-workflow.md) for the full git workflow specification, covering:
- Branch naming conventions and creation timing
- Commit strategy (orchestrator commits, builders write)
- Shared-file conflict prevention for parallel builders
- Pipeline abandonment preservation procedures

## Failure Recovery & Feedback Loops

See [.claude/rules/failure-recovery.md](../../rules/failure-recovery.md) for the complete failure handling specification, covering:
- Agent timeout, hang, and maxTurns exhaustion recovery
- Parallel builder partial failure (one succeeds, one fails)
- Incomplete agent output recovery
- All 5 feedback loops (Planner revision, Builder test failure, Validator BLOCKED, Verifier untestable criteria, Researcher blocking questions)
- Downstream propagation rule for known upstream issues
