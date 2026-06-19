# Full Mode — Step 4: Backend Builder Prompt

Copy the content below into the `prompt` field of the Agent() call:

---

Agent(
  subagent_type="backend-builder",
  description="Build backend for feature",
  prompt="Implement the backend for the following approved Technical Brief. Build API routes, services, database migrations, and background jobs. Write unit tests. Run typecheck, lint, and tests before reporting.

Approved Technical Brief:
[PLANNER'S OUTPUT (technical brief section)]

Researcher Findings:
[RESEARCHER'S OUTPUT]

IMPORTANT — TDD Mode:
1. Read .claude/context/CONTEXT.md (if it exists) for domain terminology — use these terms exactly in function, variable, and file names
2. Step 2: Plan test seams before writing any code — identify behaviors, seams, and priorities. Get user approval on the plan.
3. Step 3: Use TDD — RED→GREEN→REFACTOR, ONE vertical slice at a time. Never write all tests first.
4. Include a TDD Cycle Log in your summary (behavior tested, test file, seam, result, refactored)
5. Step 4: Full test suite must pass before reporting. Typecheck and lint must be clean."
)
