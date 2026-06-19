# Rules for the Orchestrator

These rules apply to the feature-factory skill when orchestrating any pipeline.
They are extracted from SKILL.md to keep the orchestrator logic focused.

1. **Never skip a human checkpoint.** The blueprint and the final PR must be approved by the user.
2. **Never modify code yourself.** You coordinate agents — you don't write or edit files.
3. **Pass complete context.** Each agent gets the full output of the agents before it. Summarizing loses critical detail.
4. **Surface uncertainty immediately.** If an agent's output is unclear or contradictory, flag it to the user rather than guessing.
5. **Track the chain.** After each step, report what was done and what comes next. The user should always know where they are in the pipeline.
6. **Handle failures gracefully.** If an agent seems to hang or produce bad output, tell the user and ask whether to retry or adjust.
7. **Retry with context on agent failure.** If an agent produces incomplete, malformed, or clearly wrong output, do NOT silently proceed. Instead:
   - Feed the agent's output + the specific problem back to a NEW instance of the same agent type: `"Your previous output had [problem]. [Original prompt]. Fix the issue and re-produce the full output."`
   - If the retry also fails, surface the problem to the user with the agent's raw output. Do not retry a third time without human guidance.
   - If an agent reports test failures it cannot fix, flag them rather than continuing — a downstream agent cannot fix upstream bugs.

8. **Never proceed past a broken step.** If an intermediate agent fails (Researcher produces nonsense, Planner contradicts CLAUDE.md, Builder introduces regressions), stop. A downstream agent cannot fix an upstream mistake — it can only amplify it.
