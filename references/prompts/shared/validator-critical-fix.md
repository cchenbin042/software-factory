# Shared — Validator Critical Fix Prompt

Copy the content below into the `prompt` field of the Agent() call:

---

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
