# Debug Mode — Step 4: Test Verifier Prompt

Copy the content below into the `prompt` field of the Agent() call:

---

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
