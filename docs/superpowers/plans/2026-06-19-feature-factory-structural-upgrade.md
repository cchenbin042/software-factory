# Feature Factory v1.5.0–v1.5.2 Structural Upgrade — Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Elevate Feature Factory from "well-designed" to "production-grade infrastructure" — split the monolithic SKILL.md, decouple Superpowers dependency, establish CI quality gates, and complete the documentation suite.

**Architecture:** Three-sprint layered delivery — Sprint 1 restructures the skeleton (SKILL.md split + Superpowers decoupling), Sprint 2 adds automated quality protection (CI + dependency declarations + deprecation policy), Sprint 3 polishes the experience (cost reference + FAQ cases + demo video).

**Tech Stack:** Bash 4.0+, GNU sed/grep, Git, GitHub Actions, OBS Studio (for recording)

## Global Constraints

- **Cross-project portable (distributed content):** All files under `.claude/` must use relative paths, zero frontmatter parsing dependencies, pure Markdown readable; must work directly after copying to any target project
- **Maintainer tools don't ship:** `.github/` directory used only in source repo, not copied with `.claude/`
- **Never delete content:** All original content preserved — only moved and slimmed; deprecated items marked `# LEGACY`
- **Never change Agent responsibilities:** No agent count changes, no orchestration logic changes, no pipeline topology changes
- **Smoke test is the final arbiter:** After each sprint, `bash .claude/tests/smoke.sh` must produce 0 warnings and 0 errors
- **Commit granularity:** One commit per task, Conventional Commits format, Co-Authored-By trailer

---

## Sprint 1: Structural Layer (v1.5.0) — Tasks 1–10

### Task 1: Scaffold prompt template directory structure

**Files:**
- Create: `.claude/skills/feature-factory/prompts/` and all subdirectories

**Interfaces:**
- Consumes: nothing
- Produces: directory skeleton consumed by Tasks 2–5

- [ ] **Step 1: Create directory tree**

```bash
mkdir -p .claude/skills/feature-factory/prompts/{full-mode,debug-mode,incremental-mode,shared}
```

- [ ] **Step 2: Verify structure**

```bash
find .claude/skills/feature-factory/prompts -type d
```

Expected: 4 directories (full-mode, debug-mode, incremental-mode, shared)

- [ ] **Step 3: Add .gitkeep placeholders**

```bash
for dir in full-mode debug-mode incremental-mode shared; do
  touch .claude/skills/feature-factory/prompts/$dir/.gitkeep
done
```

- [ ] **Step 4: Commit**

```bash
git add .claude/skills/feature-factory/prompts/
git commit -m "chore: scaffold prompt template directory structure"
```

---

### Task 2: Create Full Mode prompt templates (6 files)

**Files:**
- Create: `prompts/full-mode/step-1-researcher.md`, `step-2-planner.md`, `step-4-backend-builder.md`, `step-4-frontend-builder.md`, `step-5-test-verifier.md`, `step-6-validator.md`

**Interfaces:**
- Consumes: nothing
- Produces: prompt templates referenced by Task 8 (SKILL.md slim-down)
- Source: current `SKILL.md` lines 38–153 (Full Mode Agent invocation templates)

- [ ] **Step 1: Create `step-1-researcher.md`**

```markdown
# Full Mode — Step 1: Researcher Prompt

Copy the content below into the `prompt` field of the Agent() call:

---

Agent(
  subagent_type="researcher",
  description="Research codebase for feature",
  prompt="Research the codebase for the following feature request. Map relevant files, identify existing patterns, find similar features, flag risks, and list tests that will need updates.

Feature: [USER'S FEATURE DESCRIPTION]"
)
```

- [ ] **Step 2: Create `step-2-planner.md`** — extract from SKILL.md lines 56–73 (Planner invocation with domain-modeling instructions)
- [ ] **Step 3: Create `step-4-backend-builder.md`** — extract from SKILL.md lines 109–128 (Backend Builder with TDD instructions)
- [ ] **Step 4: Create `step-4-frontend-builder.md`** — extract from SKILL.md lines 130–152 (Frontend Builder with TDD + a11y instructions)
- [ ] **Step 5: Create `step-5-test-verifier.md`** — extract from SKILL.md lines 163–182 (Test Verifier invocation)
- [ ] **Step 6: Create `step-6-validator.md`** — extract from SKILL.md lines 196–214 (Validator invocation)
- [ ] **Step 7: Verify — each file contains correct subagent_type**

```bash
grep -l 'subagent_type=' .claude/skills/feature-factory/prompts/full-mode/*.md | wc -l
```

Expected: `6`

- [ ] **Step 8: Commit**

```bash
git add .claude/skills/feature-factory/prompts/full-mode/
git commit -m "feat: extract Full Mode agent prompts into standalone templates"
```

---

### Task 3: Create Debug Mode prompt templates (5 files)

**Files:**
- Create: `prompts/debug-mode/step-1-debugger.md`, `step-3-backend-builder.md`, `step-3-frontend-builder.md`, `step-4-test-verifier.md`, `step-5-validator.md`

**Interfaces:**
- Consumes: nothing
- Produces: prompt templates referenced by Task 8
- Source: current `SKILL.md` lines 235–343 (Debug Mode Agent invocation templates)

- [ ] **Step 1–5: Create all 5 files** — same format as Task 2: Markdown heading + Agent() invocation verbatim
- [ ] **Step 6: Verify**

```bash
grep -l 'subagent_type=' .claude/skills/feature-factory/prompts/debug-mode/*.md | wc -l
```

Expected: `5`

- [ ] **Step 7: Commit**

```bash
git add .claude/skills/feature-factory/prompts/debug-mode/
git commit -m "feat: extract Debug Mode agent prompts into standalone templates"
```

---

### Task 4: Create Incremental Mode prompt templates (5 files)

**Files:**
- Create: `prompts/incremental-mode/step-1-researcher.md`, `step-2-backend-builder.md`, `step-2-frontend-builder.md`, `step-3-test-verifier.md`, `step-4-validator.md`

**Interfaces:**
- Consumes: nothing
- Produces: prompt templates referenced by Task 8
- Source: current `SKILL.md` lines 349–538 (Incremental Mode — all self-contained Agent invocation templates)

> **Important:** Incremental Mode prompts must be fully self-contained — cannot use "Same as Full Mode Step N" references.

- [ ] **Step 1–5: Create all 5 files**
- [ ] **Step 6: Verify**

```bash
grep -l 'subagent_type=' .claude/skills/feature-factory/prompts/incremental-mode/*.md | wc -l
```

Expected: `5`

- [ ] **Step 7: Commit**

```bash
git add .claude/skills/feature-factory/prompts/incremental-mode/
git commit -m "feat: extract Incremental Mode agent prompts into standalone templates"
```

---

### Task 5: Create Shared retry/recovery prompt templates (4 files)

**Files:**
- Create: `prompts/shared/planner-revision.md`, `builder-test-fix.md`, `validator-critical-fix.md`, `debugger-reanalysis.md`

**Interfaces:**
- Consumes: nothing
- Produces: retry prompt templates referenced by orchestrator rules and failure-recovery feedback loops
- Source: `SKILL.md` lines 86–99, 257–269; `.claude/rules/failure-recovery.md` lines 79–96, 105–119, 135–149

- [ ] **Step 1: Create `planner-revision.md`** — blueprint rejection retry template
- [ ] **Step 2: Create `builder-test-fix.md`** — test failure retry template
- [ ] **Step 3: Create `validator-critical-fix.md`** — Critical issue fix retry template
- [ ] **Step 4: Create `debugger-reanalysis.md`** — disputed diagnosis reanalysis template
- [ ] **Step 5: Verify**

```bash
grep -l 'subagent_type=' .claude/skills/feature-factory/prompts/shared/*.md | wc -l
```

Expected: `4`

- [ ] **Step 6: Commit**

```bash
git add .claude/skills/feature-factory/prompts/shared/
git commit -m "feat: extract shared retry/recovery prompt templates"
```

---

### Task 6: Create rules.md (8 orchestrator rules)

**Files:**
- Create: `.claude/skills/feature-factory/rules.md`

**Interfaces:**
- Consumes: nothing
- Produces: standalone rule file referenced by slimmed SKILL.md
- Source: current `SKILL.md` lines 553–564

- [ ] **Step 1: Write rules.md**

```markdown
# Rules for the Orchestrator

These rules apply to the feature-factory skill when orchestrating any pipeline.

1. **Never skip a human checkpoint.** The blueprint and the final PR must be approved by the user.
2. **Never modify code yourself.** You coordinate agents — you don't write or edit files.
3. **Pass complete context.** Each agent gets the full output of the agents before it.
4. **Surface uncertainty immediately.** If an agent's output is unclear, flag it to the user.
5. **Track the chain.** After each step, report what was done and what comes next.
6. **Handle failures gracefully.** Tell the user and ask whether to retry or adjust.
7. **Retry with context on agent failure.** Feed the problem back to a NEW instance. Maximum 2 retries without human guidance.
8. **Never proceed past a broken step.** A downstream agent cannot fix an upstream mistake.
```

- [ ] **Step 2: Commit**

```bash
git add .claude/skills/feature-factory/rules.md
git commit -m "refactor: extract orchestrator rules into standalone file"
```

---

### Task 7: Decouple Superpowers — rewrite planner.md Phase 0

**Files:**
- Modify: `.claude/agents/planner.md:21–48` (Phase 0 and Phase 0b sections)

**Interfaces:**
- Consumes: nothing (standalone edit)
- Produces: Planner that works with or without Superpowers plugin; consumed by Task 8 (SKILL.md references Planner as agent)

- [ ] **Step 1: Read current planner.md baseline**

```bash
sed -n '21,48p' .claude/agents/planner.md
```

- [ ] **Step 2: Replace Phase 0 (lines 21–37)** with conditional branch + inline brainstorming process (full content from design doc Sprint 1 §1.2)

Key elements:
- (a) "If Superpowers is available → `Skill(skill="brainstorming")`"
- (b) "If NOT available → inline 4-step process: Explore → Ask → Propose → Present"
- (c) Hard gate preserved: "Do NOT write User Story or Technical Brief until this process is complete"

- [ ] **Step 3: Verify Phase 0b (Domain Modeling) is untouched**

```bash
grep -A5 'Phase 0b' .claude/agents/planner.md
```

Expected: Phase 0b still present and unmodified

- [ ] **Step 4: Run smoke.sh — planner frontmatter must still be valid**

```bash
bash .claude/tests/smoke.sh
```

Expected: All planner checks PASS

- [ ] **Step 5: Commit**

```bash
git add .claude/agents/planner.md
git commit -m "feat(planner): add inline brainstorming fallback when Superpowers is unavailable"
```

---

### Task 8: Slim SKILL.md to index file ⚠️ CRITICAL

**Files:**
- Modify: `.claude/skills/feature-factory/SKILL.md` (~580 → ~120 lines)

**Interfaces:**
- Consumes: all prompt templates from Tasks 2–5, rules.md from Task 6, planner.md from Task 7
- Produces: slim orchestrator entry point — the single file that launches all pipelines

> ⚠️ **This is the most critical task in Sprint 1.** SKILL.md is the single entry point. After slimming, all prompt content must remain reachable via links, smoke.sh subagent_type checks must pass, and the orchestrator reading experience must not degrade.

- [ ] **Step 1: Backup current SKILL.md**

```bash
cp .claude/skills/feature-factory/SKILL.md .claude/skills/feature-factory/SKILL.md.bak
```

- [ ] **Step 2: Write slimmed SKILL.md**

Preserve: frontmatter + Architecture ASCII diagram + Three Modes table + step summaries (one line + link each) + orchestrator rules reference + external Git/Recovery rule references.

Remove: all inline `prompt="..."` content from Agent() calls (now in prompt files).

Full slimmed content per design doc Sprint 1 §1.1.

- [ ] **Step 3: Verify — all links resolve to real files**

```bash
grep -oP '\[.*?\]\(\.\..*?\.md\)' .claude/skills/feature-factory/SKILL.md | \
  sed 's/.*(//;s/)//' | while read link; do
    target=$(echo "$link" | sed 's|../../|.claude/|')
    if [ -f "$target" ]; then echo "OK: $link"; else echo "MISSING: $link"; fi
  done
```

Expected: All links output `OK`

- [ ] **Step 4: Verify — all subagent_type references still valid**

```bash
grep -o 'subagent_type="[^"]*"' .claude/skills/feature-factory/prompts/**/*.md | sed 's/.*"//;s/"//' | sort -u
```

Expected: 7 agent names listed, each agent file exists

- [ ] **Step 5: Run smoke.sh**

```bash
bash .claude/tests/smoke.sh
```

Expected: PASS across the board · WARN: 0 · FAIL: 0

- [ ] **Step 6: Remove backup**

```bash
rm .claude/skills/feature-factory/SKILL.md.bak
```

- [ ] **Step 7: Commit**

```bash
git add .claude/skills/feature-factory/SKILL.md
git commit -m "refactor: slim SKILL.md to ~120-line index; prompts live in standalone files"
```

---

### Task 9: Update install scripts — add Superpowers prompt

**Files:**
- Modify: `install.sh` (append to end), `install.ps1` (append to end)

- [ ] **Step 1: Append to install.sh**

```bash
cat >> install.sh << 'ENDOFFILE'

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "  Recommended: Superpowers Plugin"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "Feature Factory's Planner uses Superpowers for interactive"
echo "brainstorming. Without it, Planner falls back to an inline"
echo "process that works but is less polished."
echo ""
echo "Install it for the full experience:"
echo "  claude plugins install anthropics/superpowers"
echo ""
read -p "Install Superpowers now? [Y/n] " answer
if [ "$answer" != "n" ] && [ "$answer" != "N" ]; then
  claude plugins install anthropics/superpowers 2>/dev/null || \
    echo "  → Skipped (claude CLI not available in this environment)"
fi
ENDOFFILE
```

- [ ] **Step 2: Append PowerShell equivalent to install.ps1**

```powershell
Write-Host "Recommended: Superpowers Plugin" 
Write-Host "  claude plugins install anthropics/superpowers"
$answer = Read-Host "Install Superpowers now? [Y/n]"
if ($answer -ne 'n' -and $answer -ne 'N') {
  claude plugins install anthropics/superpowers 2>$null
}
```

- [ ] **Step 3: Commit**

```bash
git add install.sh install.ps1
git commit -m "feat(install): add Superpowers plugin installation prompt"
```

---

### Task 10: Update smoke.sh — add prompt template integrity checks

**Files:**
- Modify: `.claude/tests/smoke.sh` (insert new check category before Summary section)

- [ ] **Step 1: Insert "Prompt Templates" check category** after Domain-Modeling checks (check #8), before Summary

```bash
# ─── 9. Prompt Template Integrity ──────────────────────────────

echo ""
echo "── Prompt Templates ──"

PROMPTS_DIR="$ROOT/.claude/skills/feature-factory/prompts"

# Full Mode: 6 files
FULL_EXPECTED=6
FULL_COUNT=$(ls "$PROMPTS_DIR/full-mode/"*.md 2>/dev/null | grep -v .gitkeep | wc -l)
if [ "$FULL_COUNT" -eq "$FULL_EXPECTED" ]; then
  pass "prompts/full-mode/: $FULL_COUNT/$FULL_EXPECTED prompt files"
else
  fail "prompts/full-mode/: $FULL_COUNT/$FULL_EXPECTED prompt files (expected $FULL_EXPECTED)"
fi

# Debug Mode: 5 files
DEBUG_EXPECTED=5
DEBUG_COUNT=$(ls "$PROMPTS_DIR/debug-mode/"*.md 2>/dev/null | grep -v .gitkeep | wc -l)
if [ "$DEBUG_COUNT" -eq "$DEBUG_EXPECTED" ]; then
  pass "prompts/debug-mode/: $DEBUG_COUNT/$DEBUG_EXPECTED prompt files"
else
  fail "prompts/debug-mode/: $DEBUG_COUNT/$DEBUG_EXPECTED prompt files (expected $DEBUG_EXPECTED)"
fi

# Incremental Mode: 5 files
INCR_EXPECTED=5
INCR_COUNT=$(ls "$PROMPTS_DIR/incremental-mode/"*.md 2>/dev/null | grep -v .gitkeep | wc -l)
if [ "$INCR_COUNT" -eq "$INCR_EXPECTED" ]; then
  pass "prompts/incremental-mode/: $INCR_COUNT/$INCR_EXPECTED prompt files"
else
  fail "prompts/incremental-mode/: $INCR_COUNT/$INCR_EXPECTED prompt files (expected $INCR_EXPECTED)"
fi

# Shared: 4 files
SHARED_EXPECTED=4
SHARED_COUNT=$(ls "$PROMPTS_DIR/shared/"*.md 2>/dev/null | grep -v .gitkeep | wc -l)
if [ "$SHARED_COUNT" -eq "$SHARED_EXPECTED" ]; then
  pass "prompts/shared/: $SHARED_COUNT/$SHARED_EXPECTED prompt files"
else
  fail "prompts/shared/: $SHARED_COUNT/$SHARED_EXPECTED prompt files (expected $SHARED_EXPECTED)"
fi

# Every prompt file must contain a subagent_type
for f in "$PROMPTS_DIR"/full-mode/*.md "$PROMPTS_DIR"/debug-mode/*.md "$PROMPTS_DIR"/incremental-mode/*.md; do
  [ "$(basename "$f")" = ".gitkeep" ] && continue
  if grep -q 'subagent_type=' "$f"; then
    pass "  $(basename "$f"): contains subagent_type"
  else
    fail "  $(basename "$f"): missing subagent_type reference"
  fi
done
```

- [ ] **Step 2: Run smoke.sh to verify**

```bash
bash .claude/tests/smoke.sh
```

Expected: "Prompt Templates" category appears, all checks PASS

- [ ] **Step 3: Commit**

```bash
git add .claude/tests/smoke.sh
git commit -m "test: add prompt template integrity checks to smoke test"
```

---

### Sprint 1 Completion Checklist

- [ ] `bash .claude/tests/smoke.sh` → 0 FAIL, 0 WARN
- [ ] `git log --oneline -10` → one commit per task
- [ ] New SKILL.md < 150 lines
- [ ] `find .claude/skills/feature-factory/prompts -name '*.md' ! -name '.gitkeep' | wc -l` → 20
- [ ] Planner works in environments without Superpowers

---

## Sprint 2: Quality Layer (v1.5.1) — Tasks 11–16

### Task 11: Create GitHub Actions CI workflow

**Files:**
- Create: `.github/workflows/smoke.yml`

**Classification:** Maintainer tool — does NOT ship with `.claude/` distribution

- [ ] **Step 1: Create .github/workflows directory**

```bash
mkdir -p .github/workflows
```

- [ ] **Step 2: Write smoke.yml**

```yaml
name: Pipeline Smoke Test

on:
  push:
    paths:
      - '.claude/agents/**'
      - '.claude/commands/**'
      - '.claude/context/**'
      - '.claude/rules/**'
      - '.claude/skills/**'
      - '.claude/tests/**'
  pull_request:
    paths:
      - '.claude/agents/**'
      - '.claude/commands/**'
      - '.claude/context/**'
      - '.claude/rules/**'
      - '.claude/skills/**'
      - '.claude/tests/**'

jobs:
  smoke:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4

      - name: Ensure smoke test is executable
        run: test -x .claude/tests/smoke.sh || chmod +x .claude/tests/smoke.sh

      - name: Run pipeline smoke test
        run: bash .claude/tests/smoke.sh --ci
```

- [ ] **Step 3: Validate YAML syntax locally**

```bash
python3 -c "import yaml; yaml.safe_load(open('.github/workflows/smoke.yml'))" 2>/dev/null || \
  echo "WARNING: PyYAML not available — GitHub will validate on push"
```

- [ ] **Step 4: Commit**

```bash
git add .github/workflows/smoke.yml
git commit -m "ci: add GitHub Actions smoke test workflow"
```

---

### Task 12: Add dependency declarations to smoke.sh

**Files:**
- Modify: `.claude/tests/smoke.sh` (insert after `set -euo pipefail`, before `PASS=0`)

- [ ] **Step 1: Locate insertion point**

```bash
grep -n 'set -euo pipefail' .claude/tests/smoke.sh
grep -n 'PASS=0' .claude/tests/smoke.sh
```

- [ ] **Step 2: Insert dependency check block between them**

```bash
# Dependency check
REQUIRED_CMDS=("bash" "sed" "grep")
MISSING_CMDS=()

for cmd in "${REQUIRED_CMDS[@]}"; do
  if ! command -v "$cmd" &>/dev/null; then
    MISSING_CMDS+=("$cmd")
  fi
done

if [ ${#MISSING_CMDS[@]} -gt 0 ]; then
  echo "ERROR: Required commands not found: ${MISSING_CMDS[*]}" >&2
  echo "Install them before running this script." >&2
  exit 3
fi

# bash >= 4.0
if [ "${BASH_VERSINFO[0]}" -lt 4 ]; then
  echo "ERROR: bash >= 4.0 required, found $BASH_VERSION" >&2
  exit 3
fi
```

- [ ] **Step 3: Test on current environment**

```bash
bash .claude/tests/smoke.sh
```

Expected: Script runs without dependency errors

- [ ] **Step 4: Commit**

```bash
git add .claude/tests/smoke.sh
git commit -m "test: add dependency declarations to smoke.sh (bash >= 4.0, GNU sed/grep)"
```

---

### Task 13: Add --ci flag to smoke.sh

**Files:**
- Modify: `.claude/tests/smoke.sh` (2 locations: variable declaration + verdict logic)

- [ ] **Step 1: Add CI_MODE variable** after dependency check, before first check category

```bash
# ─── CI Mode ─────────────────────────────────────────────────────
CI_MODE=false
if [ "${1:-}" = "--ci" ]; then
  CI_MODE=true
fi
```

- [ ] **Step 2: Modify verdict logic** — CI mode suppresses warning exit code

Change:
```bash
elif [ "$WARN" -gt 0 ]; then
  ...
  exit 1
```

To:
```bash
elif [ "$WARN" -gt 0 ] && [ "$CI_MODE" = false ]; then
  ...
  exit 1
else
  if [ "$CI_MODE" = true ] && [ "$WARN" -gt 0 ]; then
    echo "Verdict: CLEAN (${WARN} warning(s) suppressed in CI mode)"
  fi
  exit 0
fi
```

- [ ] **Step 3: Test --ci flag**

```bash
bash .claude/tests/smoke.sh --ci; echo "Exit: $?"
```

Expected: exit 0 (not 1) even if warnings exist

- [ ] **Step 4: Commit**

```bash
git add .claude/tests/smoke.sh
git commit -m "test: add --ci flag to suppress warnings in CI environments"
```

---

### Task 14: Verify prompt checks are compatible with Sprint 1 structure

**Files:**
- Possibly modify: `.claude/tests/smoke.sh`

> If Task 10 already added prompt template checks and they remain valid after Sprint 1, this task is a no-op verification.

- [ ] **Step 1: Confirm Task 10 prompt checks pass in Sprint 2 context**

```bash
bash .claude/tests/smoke.sh --ci
```

Expected: "Prompt Templates" category all PASS

---

### Task 15: Verify .gitignore doesn't exclude new files

**Files:**
- Possibly modify: `.gitignore`

- [ ] **Step 1: Check new files aren't ignored**

```bash
git check-ignore .claude/skills/feature-factory/prompts/full-mode/step-1-researcher.md \
  .github/workflows/smoke.yml \
  docs/demo-script.md
```

Expected: no output (none ignored)

- [ ] **Step 2: Commit only if changes needed**

```bash
git add .gitignore && git commit -m "chore: verify .gitignore does not exclude new prompt/CI/doc files" || echo "No changes needed"
```

---

### Task 16: Add deprecation policy to CHANGELOG

**Files:**
- Modify: `CHANGELOG.md` (insert new section after version strategy)

- [ ] **Step 1: Locate insertion point**

```bash
grep -n 'Semantic Versioning' CHANGELOG.md
```

- [ ] **Step 2: Insert deprecation policy** (full content from design doc Sprint 2 §2.3)

Includes:
- 6-component strategy table
- Version bump trigger rules table
- Deprecation announcement template
- User compatibility check instructions (run `smoke.sh`)

- [ ] **Step 3: Verify Markdown table alignment**

```bash
head -80 CHANGELOG.md
```

- [ ] **Step 4: Commit**

```bash
git add CHANGELOG.md
git commit -m "docs: add deprecation policy and version compatibility guarantees"
```

---

### Sprint 2 Completion Checklist

- [ ] `bash .claude/tests/smoke.sh --ci` → exit 0
- [ ] `bash .claude/tests/smoke.sh` (human mode) → exit 1 if warnings, exit 0 if clean
- [ ] Push to GitHub → Actions tab shows smoke.yml run result
- [ ] CHANGELOG contains complete deprecation policy section

---

## Sprint 3: Documentation Layer (v1.5.2) — Tasks 17–23

### Task 17: Add token cost reference table to README

**Files:**
- Modify: `README.md` (insert between "前置依赖" and "端到端示例")

- [ ] **Step 1: Locate insertion point**

```bash
grep -n '前置依赖' README.md
grep -n '端到端示例' README.md
```

- [ ] **Step 2: Insert token cost reference** (full content from design doc Sprint 3 §3.1)

Includes: 3-mode token estimate table, influencing factors table, cost-saving tips

- [ ] **Step 3: Verify table renders correctly**

```bash
grep -c '^|' README.md
```

- [ ] **Step 4: Commit**

```bash
git add README.md
git commit -m "docs: add token cost reference table for all three modes"
```

---

### Task 18: Add real-world case to FAQ Q1

**Files:**
- Modify: `.claude/FAQ.md` (append to Q1)

- [ ] **Step 1: Locate Q1/Q2 boundary**

```bash
grep -n '### Q1:' .claude/FAQ.md
grep -n '### Q2:' .claude/FAQ.md
```

- [ ] **Step 2: Insert case between Q1 end and Q2 start**

Case: NestJS project — `typecheck` command in CLAUDE.md doesn't match project's actual `package.json`.

Format: Scenario → Investigation → Fix → Lesson

- [ ] **Step 3: Commit**

```bash
git add .claude/FAQ.md
git commit -m "docs: add real-world troubleshooting case to FAQ Q1"
```

---

### Task 19: Add real-world case to FAQ Q6

**Files:**
- Modify: `.claude/FAQ.md` (append to Q6)

- [ ] **Step 1: Locate Q6/Q7 boundary**

```bash
grep -n '### Q6:' .claude/FAQ.md
grep -n '### Q7:' .claude/FAQ.md
```

- [ ] **Step 2: Insert case**

Case: User thought "change error messages" was Incremental — Quick Researcher found 12 files across 3 modules → escalated to Full.

- [ ] **Step 3: Commit**

```bash
git add .claude/FAQ.md
git commit -m "docs: add real-world mode selection case to FAQ Q6"
```

---

### Task 20: Add real-world case to FAQ Q8

**Files:**
- Modify: `.claude/FAQ.md` (append to Q8, before "快速诊断" section)

- [ ] **Step 1: Locate Q8/diagnostic boundary**

```bash
grep -n '### Q8:' .claude/FAQ.md
grep -n '快速诊断' .claude/FAQ.md
```

- [ ] **Step 2: Insert case**

Case: Go project — copied `.claude/` unchanged → `paths` in builder-rules.md didn't include `.go` files, CLAUDE.md commands were for Node.js.

- [ ] **Step 3: Commit**

```bash
git add .claude/FAQ.md
git commit -m "docs: add cross-project installation troubleshooting case to FAQ Q8"
```

---

### Task 21: Create demo recording script

**Files:**
- Create: `docs/demo-script.md`

- [ ] **Step 1: Ensure docs/ exists**

```bash
mkdir -p docs
```

- [ ] **Step 2: Write demo-script.md** — 3-minute script with 14 time-segments, each with visual/audio columns (full content from design doc Sprint 3 §3.3)

- [ ] **Step 3: Commit**

```bash
git add docs/demo-script.md
git commit -m "docs: add 3-minute demo recording script"
```

---

### Task 22: Record demo video and link in README

**Files:**
- Modify: `README.md` (add video link line below "快速开始" heading)

- [ ] **Step 1: Record terminal session** per demo-script.md

Tools: OBS Studio (free, cross-platform). Capture terminal window at 1920×1080. Keep it real — no heavy editing.

- [ ] **Step 2: Upload to YouTube (unlisted), copy share link**
- [ ] **Step 3: Add link to README**

```markdown
> 🎬 **3 分钟演示**：[观看 Feature Factory 完整流水线](https://youtu.be/XXXXX)
```

- [ ] **Step 4: Commit**

```bash
git add README.md
git commit -m "docs: add demo video link to README"
```

---

### Task 23: Final verification — full smoke test

**Files:**
- No modifications — verification only

- [ ] **Step 1: Run full smoke test**

```bash
bash .claude/tests/smoke.sh
```

Expected: PASS all · WARN: 0 · FAIL: 0 · Verdict: CLEAN

- [ ] **Step 2: Review complete commit history**

```bash
git log --oneline master..HEAD
```

Expected: ~23 commits, Conventional Commits format

- [ ] **Step 3: Confirm clean working tree**

```bash
git status --porcelain
```

Expected: empty output

- [ ] **Step 4: Structural integrity verification**

```bash
echo "=== SKILL.md lines ===" && wc -l .claude/skills/feature-factory/SKILL.md
echo "=== Prompt templates ===" && find .claude/skills/feature-factory/prompts -name '*.md' ! -name '.gitkeep' | wc -l
echo "=== CI workflow ===" && test -f .github/workflows/smoke.yml && echo "EXISTS"
echo "=== Deprecation policy ===" && grep -c 'Deprecation 策略' CHANGELOG.md
echo "=== Cost table ===" && grep -c 'Token' README.md
echo "=== FAQ cases ===" && grep -c '真实案例' .claude/FAQ.md
echo "=== Demo script ===" && test -f docs/demo-script.md && echo "EXISTS"
```

- [ ] **Step 5: Final commit (if any stray changes)**

```bash
git add -A
git diff --cached --stat
# If stragglers: git commit -m "chore: final cleanup for v1.5.2"
# If clean: git reset HEAD -- .
```

---

### Sprint 3 Completion Checklist

- [ ] README has token cost reference table (human-readable, order-of-magnitude accurate)
- [ ] FAQ has 3 real-world cases (scenario → investigation → fix → lesson)
- [ ] `docs/demo-script.md` exists and is complete
- [ ] YouTube link in README is active (if recording done)
- [ ] Full smoke test → CLEAN

---

## Appendix A: File Change Summary

| File | Sprint | Task | Operation | Classification |
|------|--------|------|-----------|----------------|
| `.claude/skills/feature-factory/prompts/` tree | S1 | T1 | Create | Distributed |
| `prompts/full-mode/*.md` (6) | S1 | T2 | Create | Distributed |
| `prompts/debug-mode/*.md` (5) | S1 | T3 | Create | Distributed |
| `prompts/incremental-mode/*.md` (5) | S1 | T4 | Create | Distributed |
| `prompts/shared/*.md` (4) | S1 | T5 | Create | Distributed |
| `.claude/skills/feature-factory/rules.md` | S1 | T6 | Create | Distributed |
| `.claude/agents/planner.md` | S1 | T7 | Modify | Distributed |
| `.claude/skills/feature-factory/SKILL.md` | S1 | T8 | Modify | Distributed |
| `install.sh` | S1 | T9 | Modify | Distributed |
| `install.ps1` | S1 | T9 | Modify | Distributed |
| `.claude/tests/smoke.sh` | S1+S2 | T10,T12,T13,T14 | Modify | Distributed |
| `.github/workflows/smoke.yml` | S2 | T11 | Create | Maintainer |
| `.gitignore` | S2 | T15 | Possibly modify | Both |
| `CHANGELOG.md` | S2 | T16 | Modify | Distributed |
| `README.md` | S3 | T17,T22 | Modify | Distributed |
| `.claude/FAQ.md` | S3 | T18,T19,T20 | Modify | Distributed |
| `docs/demo-script.md` | S3 | T21 | Create | Distributed |

## Appendix B: Expected Commit Sequence

```
# Sprint 1
chore: scaffold prompt template directory structure
feat: extract Full Mode agent prompts into standalone templates
feat: extract Debug Mode agent prompts into standalone templates
feat: extract Incremental Mode agent prompts into standalone templates
feat: extract shared retry/recovery prompt templates
refactor: extract orchestrator rules into standalone file
feat(planner): add inline brainstorming fallback when Superpowers is unavailable
refactor: slim SKILL.md to ~120-line index; prompts live in standalone files
feat(install): add Superpowers plugin installation prompt
test: add prompt template integrity checks to smoke test

# Sprint 2
ci: add GitHub Actions smoke test workflow
test: add dependency declarations to smoke.sh (bash >= 4.0, GNU sed/grep)
test: add --ci flag to suppress warnings in CI environments
chore: verify .gitignore does not exclude new prompt/CI/doc files
docs: add deprecation policy and version compatibility guarantees

# Sprint 3
docs: add token cost reference table for all three modes
docs: add real-world troubleshooting case to FAQ Q1
docs: add real-world mode selection case to FAQ Q6
docs: add cross-project installation troubleshooting case to FAQ Q8
docs: add 3-minute demo recording script
docs: add demo video link to README
chore: final cleanup for v1.5.2
```

## Appendix C: Verification Command Reference

| Scenario | Command |
|----------|---------|
| Human smoke test | `bash .claude/tests/smoke.sh` |
| CI smoke test | `bash .claude/tests/smoke.sh --ci` |
| Prompt template count | `find .claude/skills/feature-factory/prompts -name '*.md' ! -name '.gitkeep' \| wc -l` |
| SKILL.md line count | `wc -l .claude/skills/feature-factory/SKILL.md` |
| Link integrity | `grep -oP '\[.*?\]\(\.\..*?\.md\)' .claude/skills/feature-factory/SKILL.md` |
| Clean working tree | `git status --porcelain` |
| Commit history | `git log --oneline master..HEAD` |
