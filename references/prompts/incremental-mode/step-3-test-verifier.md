# Incremental Mode — Step 3: Test Verifier Prompt

Copy the content below into the `prompt` field of the Agent() call:

---

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
