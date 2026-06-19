# Debug Mode — Step 3: Backend Builder Prompt

Copy the content below into the `prompt` field of the Agent() call:

---

Agent(
  subagent_type="backend-builder",
  description="Apply bug fix",
  prompt="Apply the following fix based on the Debugger's root cause analysis. Write tests that prove the bug is fixed and prevent regression. Run typecheck, lint, and tests before reporting.

Debugger's Root Cause Analysis:
[DEBUGGER'S FULL OUTPUT]

Fix to apply:
- File: [path from debugger]
- Change: [specific change from debugger]
- Regression risk: [risk level from debugger]

IMPORTANT — TDD Mode:
1. Read .claude/context/CONTEXT.md (if it exists) for domain terminology — use these terms exactly in function, variable, and file names
2. Step 2: Plan test seams before writing any code — identify behaviors, seams, and priorities. Get user approval on the plan.
3. Step 3: Use TDD — RED→GREEN→REFACTOR, ONE vertical slice at a time. Never write all tests first.
4. Include a TDD Cycle Log in your summary (behavior tested, test file, seam, result, refactored)
5. Step 4: Full test suite must pass before reporting. Typecheck and lint must be clean."
)
