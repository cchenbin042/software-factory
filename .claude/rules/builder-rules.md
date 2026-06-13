---
# paths 限制规则生效的文件类型。按项目技术栈定制——删除不相关的扩展名，添加项目使用的。
paths:
  - "**/*.ts"
  - "**/*.tsx"
  - "**/*.js"
  - "**/*.jsx"
  - "**/*.py"
  - "**/*.go"
  - "**/*.rs"
---

# Builder Shared Rules

These rules apply to both the Backend Builder and Frontend Builder. They define the minimum quality bar for any code that enters the codebase.

## Before Writing Code

1. **Read first, write second.** Understand the existing patterns before making changes. Read at least:
   - The project's CLAUDE.md
   - The files the Researcher identified as relevant
   - At least one similar feature for reference
2. **Reuse, don't reinvent.** If a helper function, component, hook, or utility already exists, use it. Only write new ones when the existing ones genuinely don't fit.
3. **Match the surroundings.** New code should look like it was written by the same person who wrote the adjacent code. Same naming. Same error handling. Same folder structure. Same import style.

## While Writing Code

4. **Tests are not optional.** Write tests alongside code, not after. Every new function gets a unit test. Every new component gets a render test. Every new API endpoint gets an integration test.
5. **Handle the unhappy path.** Every network call gets an error state. Every data fetch gets a loading state. Every list gets an empty state. Every form gets validation errors.
6. **Keep it simple.** Prefer readable code over clever code. If a junior developer wouldn't understand it, rewrite it.
7. **No dead code.** No commented-out blocks. No unused imports. No unreachable branches. If it doesn't serve a purpose, delete it.

## After Writing Code

8. **Typecheck must pass.** Zero errors. No `as any` escapes without a comment explaining why.
9. **Lint must pass.** Zero warnings. If a rule is wrong, fix the rule — don't suppress it inline.
10. **Tests must pass.** All existing tests must still pass. All new tests must pass. If something is flaky, fix the test — don't skip it.
11. **Self-review the diff.** Before reporting done, read your own diff. Ask: would I approve this PR? If not, fix the issues first.

## When Stuck or Uncertain

12. **Surface, don't guess.** If a business rule is unclear, flag it. If an API contract is ambiguous, flag it. If a migration might be destructive, flag it. Guessing is how bugs enter the codebase.
13. **Ask for clarification.** It's better to ask one question now than to fix ten files later.

## What Never To Do

- Never skip tests because "it's simple" — simple things break too
- Never leave `console.log` or `print` statements in production code — use the project's logger
- Never hardcode values that should be configuration — use env vars or config files
- Never expose internal error details to API clients — log the detail, return a clean message
- Never commit secrets, keys, tokens, or credentials — use env vars
- Never add a dependency without explicit approval in the Technical Brief
