---
# paths 限制规则生效的文件类型。按项目技术栈定制——删除不相关的扩展名，添加项目使用的。
paths:
  - "**/*.ts"
  - "**/*.tsx"
  - "**/*.js"
  - "**/*.jsx"
  - "**/*.py"
  - "**/*.go"
  - "**/*.rs"
---

# Failure Recovery & Degradation

## Agent Timeout or Hang

If an agent exceeds its `maxTurns` or produces no output for an extended period:

1. **Report to the user**: which agent, what step, what was expected
2. **Offer options**:
   - Retry with a narrower scope (split the task)
   - Retry with a higher `maxTurns` value
   - Skip the agent and proceed manually (only if the user accepts the risk)
   - Abort the pipeline
3. **Never silently retry** — a hung agent often indicates the task is too large for a single agent instance

## maxTurns Exhaustion

If an agent hits `maxTurns` without completing its output:

1. Read what the agent produced so far
2. If the output is substantially complete (>80%), ask the user whether to accept it as-is or split the remaining work
3. If the output is incomplete, launch a NEW instance with a narrower prompt scoped to the unfinished portion only
4. If a second instance also hits maxTurns, the task is too large — ask the user to break the feature into smaller pieces

## Parallel Builder Failure (One Succeeds, One Fails)

When both Builders are launched in parallel and only one succeeds:

1. **Preserve the successful Builder's work** — do not discard it
2. **Report to the user**: which Builder failed, what the failure was
3. **Offer options**:
   - Retry the failed Builder with the same prompt
   - Retry with a narrowed scope
   - Continue with only the successful Builder's work (only if the failing side was optional)
   - Abort and revert both
4. If the user chooses to retry only the failed Builder, use the successful Builder's output as additional context for the Verifier

## Incomplete Agent Output

If an agent returns output that is truncated, missing required sections, or clearly cut off:

1. **Check which sections are present**: compare against the agent's defined output format
2. **If only the summary section is missing**: the agent likely ran out of turns at the very end. Ask the user whether to accept the output or request the missing section from a fresh instance.
3. **If core sections are missing**: relaunch the agent with the prompt `"Your previous output was truncated — you were [N]% complete. Continue from where you left off: [last complete section + content]. Produce ONLY the remaining sections: [list missing sections]."`
4. **If relaunch also fails**: the task is too large. Split and re-run.

## Downstream Propagation Rule

When an earlier agent's output has known issues, downstream agents MUST be told. Add a caveat to their prompt:

```
NOTE: The [agent name] output had [specific issue]. Specifically:
- [What's wrong or missing]
- [What to watch for]
Proceed with awareness of this gap.
```

Never hide upstream issues from downstream agents — they will produce wrong results and the Validator catch will be the first indication of a problem.

## Feedback Loop Procedures

### Loop 1: Planner Revision (Blueprint Rejected)

When the user rejects the Planner's blueprint:

1. **Capture exactly what's wrong**: wrong story, missing acceptance criteria, bad technical design, scope too large/small
2. **Feed back to Planner**:
   ```
   Agent(
     subagent_type="planner",
     description="Revise blueprint per user feedback",
     prompt="Revise your User Story and Technical Brief. The user rejected the previous version.

   What to change:
   [USER'S SPECIFIC FEEDBACK — be precise, not general]

   What to keep:
   [PARTS THE USER LIKED — if any]

   Previous output for reference:
   [PLANNER'S FULL PREVIOUS OUTPUT]

   Produce the FULL revised blueprint — do not reference 'changes from previous version' or explain what you changed. Output the complete User Story + Technical Brief as if it were the first draft."
   )
   ```
3. **Present the revised blueprint** with a clear summary of what changed
4. **Maximum 3 revision cycles.** If the user rejects the blueprint 3 times, the feature is too ambiguous. Pause and ask the user to clarify the core requirements in writing before continuing. More Planner cycles won't fix unclear requirements.

### Loop 2: Builder Test Failure

When a Builder reports test failures:

1. **Read the test failure output carefully** — is it a real bug in the new code, or did an existing test break?
2. **If new tests fail**: the Builder's code has bugs. Feed the failure output back:
   ```
   Agent(
     subagent_type="backend-builder",  // or frontend-builder
     description="Fix test failures",
     prompt="Your previous implementation has test failures. Fix the code so all tests pass. Do NOT weaken the tests — fix the code.

   Test failures:
   [FAILURE OUTPUT]

   Your previous summary:
   [BUILDER'S OUTPUT]

   Fix the implementation, re-run the tests, and produce a revised summary."
   )
   ```
3. **If existing tests break**: the Builder introduced a regression. This is more serious — the Builder must fix it before proceeding. Use the same retry pattern but emphasize: "You broke existing tests. Find what your changes broke and fix it. The existing tests are correct."
4. **Maximum 2 fix cycles per Builder.** If tests still fail after 2 fix attempts, surface to the user with the full failure output. Do not let the Verifier act as a second Builder — it only reports, it doesn't fix.

### Loop 3: Validator BLOCKED — Rollback to Builder

When the Validator returns BLOCKED (Critical issues exist):

1. **Present every Critical issue** to the user with file paths and line numbers
2. **Categorize by owner**:
   - Security, data integrity, API logic → Backend Builder
   - UI/data leaks, accessibility, client-side state → Frontend Builder
   - Both → both Builders (sequentially — Backend first, then Frontend)
3. **User decides**: fix all Critical issues, fix some, or adjust the acceptance criteria (if the Validator was too strict)
4. **If fixing**: feed only the Critical (and user-selected Important) issues back to the relevant Builder:
   ```
   Agent(
     subagent_type="backend-builder",
     description="Fix critical validation issues",
     prompt="Fix the following Critical issues found during implementation validation. Change ONLY the lines specified — do not refactor unrelated code.

   Issues to fix:
   [LIST OF ISSUES WITH FILE:PATH:LINE:RECOMMENDATION]

   Your previous implementation summary:
   [BUILDER'S OUTPUT]

   After fixing, re-run typecheck, lint, and tests. Produce a summary of ONLY what you changed."
   )
   ```
5. **After fixes**: re-run Verifier → re-run Validator
6. **Maximum 2 rollback cycles.** If BLOCKED again after 2 fix cycles, the Technical Brief and User Story may need adjustment — escalate to the user for a design-level decision.

### Loop 4: Verifier Finds Untestable Criteria

When the Test Verifier reports criteria that can't be tested cleanly:

1. **Distinguish the cause**:
   - **Implementation gap**: the code doesn't expose a way to verify the criterion → flag as a Builder issue
   - **Test infrastructure gap**: the project lacks the test tooling needed (e.g., no E2E framework, no email capture) → note as a tooling limitation
   - **Ambiguous criterion**: the acceptance criterion itself is vague ("the system should be fast") → flag as a Planner issue
2. **If it's an implementation gap**: feed back to the relevant Builder
3. **If it's a test infrastructure gap**: note in the Validator's input — this is a known constraint, not an oversight
4. **If it's an ambiguous criterion**: surface to the user — the criterion needs rewriting

### Loop 5: Researcher Raises Blocking Questions

When the Researcher's report contains open questions that block the Planner:

1. **Surface blocking questions to the user immediately** — do not launch the Planner
2. **User answers** → feed answers to the Planner as additional context
3. **User can't answer** → the Planner must treat these as explicit "Open Questions" in the blueprint and make reasonable assumptions (documented as assumptions, not silently baked in)
4. **If too many blocking questions (>5)**: the feature request is too vague. Ask the user to rewrite with more detail rather than playing 20 questions.
