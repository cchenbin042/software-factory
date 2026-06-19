# Full Mode — Step 5: Test Verifier Prompt

Copy the content below into the `prompt` field of the Agent() call:

---

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
