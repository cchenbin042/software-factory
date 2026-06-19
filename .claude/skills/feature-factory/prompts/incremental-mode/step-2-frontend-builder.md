# Incremental Mode — Step 2: Frontend Builder Prompt

Copy the content below into the `prompt` field of the Agent() call:

---

Agent(
  subagent_type="frontend-builder",
  description="Implement frontend incremental change",
  prompt="Implement the following incremental change. There is no Technical Brief — the user's description IS the spec. Read the relevant existing code before you write anything. Surface any assumptions you make.

Change:
[USER'S DESCRIPTION]

Researcher Quick Scan:
[RESEARCHER'S OUTPUT]

TDD guidance: For this incremental change, write the regression test FIRST (prove the current behavior is broken or absent), then implement the minimal fix, then verify the test passes. Include a brief TDD Cycle Log (1-3 slices) in your summary.

Rules:
1. Read the files the Researcher identified BEFORE writing any code
2. Match existing patterns exactly — this is a small change, not a refactor
3. Handle all states: loading, error, empty, success — even for small UI changes
4. If the change implies a bigger refactor or touches files the Researcher didn't flag, STOP and report it — do not proceed
5. Write component tests for what you change
6. Run typecheck, lint, and tests before reporting. All must pass.
7. If you cannot complete the change without touching files outside scope, report what you need and why — do not extend scope silently"
)
