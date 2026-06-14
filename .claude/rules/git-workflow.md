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

# Git Workflow Integration

The orchestrator manages git state throughout the pipeline. These conventions ensure every change is traceable, recoverable, and safe.

## Branch Naming

| Mode | Branch Pattern | Example |
|------|---------------|---------|
| Full | `feature/<slug>` | `feature/invoice-reminder` |
| Debug | `fix/<slug>` | `fix/duplicate-invoice-emails` |
| Incremental | `chore/<slug>` | `chore/update-error-message` |

Derive `<slug>` from the user's description: lowercase, dashes, max 4 words. Strip special characters.

## Branch Creation Timing

Create the branch at the **start of Step 4** (Builder phase) in Full mode, or at the **start of Step 3** in Debug mode, or at the **start of Step 3** in Incremental mode. Never create a branch during research or planning — those phases are read-only.

Before creating the branch:
1. Run `git status --porcelain` — if there are uncommitted changes, warn the user. Do not create a branch from a dirty working tree unless the user explicitly approves.
2. Run `git branch --list <branch-name>` — if the branch already exists, append `-2`, `-3`, etc. Warn the user.
3. Run `git checkout -b <branch-name>`

## Commit Strategy: Orchestrator Commits, Builders Write

**Builders do NOT commit themselves.** A Builder's maxTurns is for writing code and tests — not for git operations. The orchestrator handles all git commits.

### After Each Builder Completes

As soon as a Builder returns its summary (with test results all green):

1. Run `git add <all files the Builder created or modified>` — use the Builder's summary to identify files. Never `git add -A` blindly.
2. Run `git commit -m "<type>: <description>"` using Conventional Commits format:
   - `feat:` — new feature code
   - `fix:` — bug fixes
   - `test:` — test files only
   - `chore:` — config, dependencies, non-functional changes
3. If the Builder created nothing (no-op), don't force a commit.

### Commit Granularity

Aim for one commit per Builder. If the Builder touched many files across distinct concerns, split into 2-3 focused commits:
- **Migration commit**: `feat: add migration for <thing>`
- **Implementation commit**: `feat: implement <backend or frontend piece>`
- **Test commit**: `test: add tests for <thing>`

Never commit with `--allow-empty`. Never force-push. Never amend commits after pushing.

## Shared-File Conflict Prevention (Parallel Builders)

When Backend and Frontend Builders run in parallel, they may both modify shared files (package.json, tsconfig, routing registrations, etc.). This is the highest-risk scenario in the git workflow.

### Prevention: Before Builders Start

1. **Identify shared-risk files** — files that both Builders might reasonably need to touch based on the Technical Brief. Common candidates:
   - Package manifests (`package.json`, `requirements.txt`, `go.mod`, `Cargo.toml`)
   - Config files (`tsconfig.json`, `.env.example`)
   - Route/app registrations (`app.ts`, `main.ts`, `urls.py`)
   - Shared types or constants files

2. **Assign ownership BEFORE builders launch**:
   - If Backend Builder needs to add a dependency → Backend Builder owns `package.json`
   - If Frontend Builder needs to add a dependency → tell Backend Builder "do NOT add dependencies; Frontend Builder will handle that"
   - For shared config files → designate ONE builder as the owner, tell the other to leave it alone

3. **Add explicit scope boundaries to Builder prompts**:
   ```
   Backend Builder prompt addendum:
   "FILE OWNERSHIP: You own [list of backend files]. Do NOT modify [list of shared files owned by Frontend Builder]. If you need a change in a Frontend-owned file, note it in your summary under 'Cross-Cut Requests'."

   Frontend Builder prompt addendum:
   "FILE OWNERSHIP: You own [list of frontend files]. Do NOT modify [list of shared files owned by Backend Builder]. If you need a change in a Backend-owned file, note it in your summary under 'Cross-Cut Requests'."
   ```

### Detection: After Both Builders Complete

After both Builders return and the orchestrator has committed their changes:

1. Run `git log --oneline -2` to see the two Builder commits
2. Run `git diff HEAD~2..HEAD --name-only | sort | uniq -d` to check for files that appear in BOTH commits
3. If duplicates exist → those files were modified by both Builders. Check if git merge already handled it (unlikely on a linear branch) or if the second commit overwrote the first.

### Resolution: When Conflicts Are Detected

1. **Report to the user** with the conflicting file paths and which Builder modified each
2. **Offer**:
   - Let the Validator detect and report the issue (lightweight, but may leave a broken intermediate state)
   - Re-run the second Builder with the first Builder's changes as additional context (costs time, but produces a clean result)
   - Manual resolution (user inspects the conflicting files themselves)
3. If the conflict is in a low-risk file (README, docs), flag it and continue — the Validator won't be blocked by cosmetic issues
4. If the conflict is in a high-risk file (API contract, shared types, business logic), pause — do not proceed to Verifier until resolved

## After Validator Passes

When the Validator returns CLEAN or the user approves ISSUES FOUND:

1. Run `git status --porcelain` to confirm nothing is left uncommitted
2. Run `git log --oneline <base-branch>..HEAD` to verify the commit history is clean and conventional
3. Tell the user:
   ```
   Ready for PR. Branch: <name>. Commits:
   - <commit 1>
   - <commit 2>
   ...

   Create PR: gh pr create --title "<conventional commit title>" --body "<summary>"
   ```
4. Never create the PR yourself — the final PR is the user's gate

## If the Pipeline is Abandoned

If the user decides not to proceed after code has been written:

### Step 1: Preserve the Work

The user may abandon the pipeline but want to keep the code for later. ALWAYS preserve before cleaning up:

```
# Stash uncommitted changes with a descriptive name
git stash push -u -m "feature-factory: [feature name] — abandoned pipeline"

# Create a backup tag so the work is findable even if the branch is deleted
git tag "ff-abandoned/$(date +%Y%m%d-%H%M%S)-<slug>"

# Push the tag (optional — ask the user)
```

### Step 2: Offer Cleanup Options

Present three options:
1. **Keep everything**: Stay on the feature branch, keep the stash. User can resume later with `git stash pop`.
2. **Keep the branch, clean the stash**: `git checkout <original-branch>` — uncommitted changes are safe in the stash.
3. **Full cleanup**: `git checkout <original-branch> && git stash drop && git branch -D <feature-branch>` — everything is gone, no recovery possible. Warn before doing this.

**Golden rule for pipeline abandonment**: never silently discard work. The user invested time in the pipeline — the code may be partially correct. Always offer to preserve before cleaning up.

### Step 3: Verify Clean Exit

After cleanup (whichever option the user chose):
```
git branch --show-current   # Verify we're back on the original branch
git stash list              # Confirm stash state
```
