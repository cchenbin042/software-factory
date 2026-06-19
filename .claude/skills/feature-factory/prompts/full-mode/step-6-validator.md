# Full Mode — Step 6: Implementation Validator Prompt

Copy the content below into the `prompt` field of the Agent() call:

---

Agent(
  subagent_type="implementation-validator",
  description="Validate the implementation",
  prompt="Validate the implementation against the approved story and brief. Check every item on your checklist: acceptance criteria, failure paths, security, migrations, scope, patterns, duplicates, missed concerns. Fix Minor issues directly. Report Important and Critical issues with file paths and line numbers.

Approved User Story:
[PLANNER'S OUTPUT (user story section)]

Approved Technical Brief:
[PLANNER'S OUTPUT (technical brief section)]

Backend Builder Summary:
[BACKEND BUILDER'S OUTPUT]

Frontend Builder Summary:
[FRONTEND BUILDER'S OUTPUT]

Test Verifier Report:
[TEST VERIFIER'S OUTPUT]"
)
