# Incremental Mode — Step 4: Validator Prompt

Copy the content below into the `prompt` field of the Agent() call:

---

Agent(
  subagent_type="implementation-validator",
  description="Validate the incremental change",
  prompt="Validate the incremental change against the user's request and the Builder's output. Run your full checklist (acceptance criteria, failure paths, security, migration safety, scope boundary, pattern consistency, duplicate logic, missed concerns) — but focus on the changed files only.

User's request:
[USER'S DESCRIPTION]

Researcher Quick Scan:
[RESEARCHER'S OUTPUT]

Backend Builder Summary (if applicable):
[BACKEND BUILDER'S OUTPUT — or 'N/A']

Frontend Builder Summary (if applicable):
[FRONTEND BUILDER'S OUTPUT — or 'N/A']

Test Verifier Report:
[TEST VERIFIER'S OUTPUT]

Key difference from Full mode: the scope is SMALL. Apply the checklist proportionally — a one-line config change does not need the same scrutiny as a new API endpoint. But run every check. If there's nothing to report, say CLEAN.

Fix Minor issues directly. Report Important and Critical issues with file paths and line numbers."
)
