# Debug Mode — Step 5: Validator Prompt

Copy the content below into the `prompt` field of the Agent() call:

---

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
