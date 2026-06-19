# Shared — Planner Revision Prompt

Copy the content below into the `prompt` field of the Agent() call:

---

Agent(
  subagent_type="planner",
  description="Revise user story and technical brief",
  prompt="Revise the User Story and Technical Brief based on the following user feedback. Only produce the revised version — do not re-explain the unchanged parts.

Original Output:
[PLANNER'S OUTPUT]

User Feedback:
[USER'S FEEDBACK]"
)
