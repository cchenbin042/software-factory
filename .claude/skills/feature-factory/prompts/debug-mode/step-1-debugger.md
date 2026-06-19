# Debug Mode — Step 1: Debugger Prompt

Copy the content below into the `prompt` field of the Agent() call:

---

Agent(
  subagent_type="debugger",
  description="Analyze bug root cause",
  prompt="Analyze the following bug report. Find the root cause, provide reproducible steps, and recommend a fix.

Bug Report:
[USER'S BUG DESCRIPTION]"
)
