# Full Mode — Step 1: Researcher Prompt

Copy the content below into the `prompt` field of the Agent() call:

---

Agent(
  subagent_type="researcher",
  description="Research codebase for feature",
  prompt="Research the codebase for the following feature request. Map relevant files, identify existing patterns, find similar features, flag risks, and list tests that will need updates.

Feature: [USER'S FEATURE DESCRIPTION]"
)
