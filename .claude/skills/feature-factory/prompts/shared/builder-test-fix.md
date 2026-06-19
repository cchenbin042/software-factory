# Shared — Builder Test Fix Prompt

Copy the content below into the `prompt` field of the Agent() call:

---

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
