# Incremental Mode — Step 1: Researcher Prompt

Copy the content below into the `prompt` field of the Agent() call:

---

Agent(
  subagent_type="researcher",
  description="Quick scan for incremental change",
  prompt="Quick scan — under 10 turns. For the following change, identify: (1) Which files will be touched, (2) Any existing patterns those files follow, (3) Any tests that will need updates, (4) Any files that import or depend on the files being changed.

Change: [USER'S DESCRIPTION]"
)
