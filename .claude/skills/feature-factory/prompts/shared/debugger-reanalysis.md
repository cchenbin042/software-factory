# Shared — Debugger Re-analysis Prompt

Copy the content below into the `prompt` field of the Agent() call:

---

Agent(
  subagent_type="debugger",
  description="Re-analyze bug with user feedback",
  prompt="Re-analyze the bug. Your previous analysis was:

[DEBUGGER'S PREVIOUS OUTPUT]

The user says: [USER'S FEEDBACK]

Re-examine the code with this feedback in mind. Revise or strengthen your root cause analysis."
)
