# Matt Pocock Skills Integration — Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Selectively integrate domain-modeling, TDD, and diagnosing-bugs feedback-loop disciplines from Matt Pocock's skills into Feature Factory's 7-agent pipeline without altering the orchestration topology.

**Architecture:** Four new files (domain-modeling skill + format references + context directory placeholder), seven modified files (5 agent definitions + orchestration SKILL.md + smoke test). Changes are internal to agent workflows — agent-to-agent input/output contracts remain unchanged.

**Tech Stack:** Markdown (YAML frontmatter), Bash (smoke test)

## Global Constraints

- 7-agent pipeline topology (Researcher → Planner → Backend+Frontend Builder → Test Verifier → Validator) unchanged
- 3 modes (Full / Debug / Incremental) unchanged
- 2 human approval gates (blueprint + PR) unchanged
- Hard gates: domain-modeling glossary MUST be produced by Planner; TDD red-green-refactor loop MUST be followed by Builders
- Soft guidance: diagnosing-bugs feedback loop SHOULD be built by Debugger, but skip if env constraints prevent it
- All new files under `.claude/` directory (self-contained, portable)
- Zero external dependencies on Matt Pocock's repo at runtime
- `smoke.sh` must pass 49/49 checks after all tasks complete

---

### Task 1: Create domain-modeling skill frontmatter and body

**Files:**
- Create: `.claude/skills/domain-modeling/SKILL.md`

**Interfaces:**
- Produces: `domain-modeling` skill — loaded by Planner via `skills:` frontmatter. Provides: challenge against glossary, sharpen fuzzy language, stress-test with scenarios, cross-reference with code, update CONTEXT.md inline, offer ADRs sparingly.

- [ ] **Step 1: Write `.claude/skills/domain-modeling/SKILL.md`**

```markdown
---
name: domain-modeling
description: Build and sharpen a project's domain model — challenge terms against the glossary, stress-test with edge-case scenarios, and update CONTEXT.md and ADRs inline.
disable-model-invocation: true
---

# Domain Modeling

Actively build and sharpen the project's domain model as you design. This is the *active* discipline — challenging terms, inventing edge-case scenarios, and writing the glossary and decisions down the moment they crystallise.

Merely *reading* `CONTEXT.md` for vocabulary is not this skill — that's a one-line habit any agent can do. This skill is for when you're changing the model, not just consuming it.

## File structure

For Feature Factory projects, domain artifacts live under `.claude/context/`:

```
.claude/
├── context/
│   ├── CONTEXT.md
│   └── docs/
│       └── adr/
│           ├── 0001-<title>.md
│           └── 0002-<title>.md
└── agents/
```

Create files lazily — only when you have something to write. If no `CONTEXT.md` exists, create one when the first term is resolved. If no `docs/adr/` exists, create it when the first ADR is needed.

## During the session

### Challenge against the glossary

When the user uses a term that conflicts with the existing language in `CONTEXT.md`, call it out immediately. "Your glossary defines 'cancellation' as X, but you seem to mean Y — which is it?"

### Sharpen fuzzy language

When the user uses vague or overloaded terms, propose a precise canonical term. "You're saying 'account' — do you mean the Customer or the User? Those are different things."

### Discuss concrete scenarios

When domain relationships are being discussed, stress-test them with specific scenarios. Invent scenarios that probe edge cases and force the user to be precise about the boundaries between concepts.

### Cross-reference with code

When the user states how something works, check whether the code agrees. If you find a contradiction, surface it: "Your code cancels entire Orders, but you just said partial cancellation is possible — which is right?"

### Update CONTEXT.md inline

When a term is resolved, update `.claude/context/CONTEXT.md` right there. Don't batch these up — capture them as they happen. Use the format in [CONTEXT-FORMAT.md](./CONTEXT-FORMAT.md).

`CONTEXT.md` should be totally devoid of implementation details. Do not treat `CONTEXT.md` as a spec, a scratch pad, or a repository for implementation decisions. It is a glossary and nothing else.

### Offer ADRs sparingly

Only offer to create an ADR when all three are true:

1. **Hard to reverse** — the cost of changing your mind later is meaningful
2. **Surprising without context** — a future reader will wonder "why did they do it this way?"
3. **The result of a real trade-off** — there were genuine alternatives and you picked one for specific reasons

If any of the three is missing, skip the ADR. Use the format in [ADR-FORMAT.md](./ADR-FORMAT.md). Write ADRs to `.claude/context/docs/adr/NNNN-<title>.md`.
```

- [ ] **Step 2: Verify file exists and has correct frontmatter**

Run: `grep "disable-model-invocation" .claude/skills/domain-modeling/SKILL.md`
Expected: `disable-model-invocation: true`

- [ ] **Step 3: Commit**

```bash
git add .claude/skills/domain-modeling/SKILL.md
git commit -m "feat: add domain-modeling skill (SKILL.md)

- Challenge terms against glossary, sharpen fuzzy language
- Stress-test with edge-case scenarios
- Update CONTEXT.md inline, offer ADRs sparingly
- disable-model-invocation: true (loaded by Planner, not auto-invoked)

Co-Authored-By: Claude Opus 4.8 (1M context) <noreply@anthropic.com>"
```

---

### Task 2: Create CONTEXT-FORMAT.md reference

**Files:**
- Create: `.claude/skills/domain-modeling/CONTEXT-FORMAT.md`

**Interfaces:**
- Produces: format spec consumed by the `domain-modeling` skill when writing `.claude/context/CONTEXT.md`
- Referenced by: Task 1's SKILL.md

- [ ] **Step 1: Write `.claude/skills/domain-modeling/CONTEXT-FORMAT.md`**

```markdown
# CONTEXT.md Format

`CONTEXT.md` is a **glossary** — it defines the project's domain terms and nothing else. No implementation details, no specs, no scratch notes.

## Template

```markdown
# Domain Glossary

## <Term Name>
- **Definition**: precise, one sentence
- **Synonyms**: aliases used in code (function names, variable names, file names)
- **Not to be confused with**: similar but distinct terms in this project
- **See also**: related terms in this glossary

## Relationships
- A <Term1> has many <Term2>
- A <Term3> belongs to one <Term4>

## Flagged ambiguities
- "<old-term>" was previously used to mean <X>. Resolved: now means <Y>.
```

## Rules

1. **One term = one `##` section.** Don't group unrelated terms together.
2. **Definitions are one sentence.** If you need more, the term is too broad — split it.
3. **"Not to be confused with" is mandatory.** Every domain has near-misses. Name them.
4. **"Synonyms" lists code identifiers.** Use backticks: `processOrder`, `order.ts`.
5. **Relationships use active verbs**: "has many", "belongs to", "references", "creates".
6. **Flagged ambiguities is a log.** Append to it; never delete entries. It shows how the language evolved.
7. **No implementation details.** This is not where you document API shapes, database schemas, or file paths.
8. **Create lazily.** If no terms have been resolved, don't create an empty file.
```

- [ ] **Step 2: Commit**

```bash
git add .claude/skills/domain-modeling/CONTEXT-FORMAT.md
git commit -m "feat: add CONTEXT-FORMAT.md reference for domain-modeling

Co-Authored-By: Claude Opus 4.8 (1M context) <noreply@anthropic.com>"
```

---

### Task 3: Create ADR-FORMAT.md reference

**Files:**
- Create: `.claude/skills/domain-modeling/ADR-FORMAT.md`

**Interfaces:**
- Produces: format spec consumed by the `domain-modeling` skill when writing `.claude/context/docs/adr/NNNN-<title>.md`
- Referenced by: Task 1's SKILL.md

- [ ] **Step 1: Write `.claude/skills/domain-modeling/ADR-FORMAT.md`**

```markdown
# ADR Format

An Architecture Decision Record (ADR) captures a decision that was **hard to reverse**, **surprising without context**, and the **result of a real trade-off**. If any of the three is missing, skip the ADR.

## Template

```markdown
# ADR-NNNN: <Title — imperative, one line>

## Status
Proposed | Accepted | Deprecated | Superseded by [ADR-NNNN](.)

## Context
What problem are we solving? What constraints are we under?
What alternatives were considered?
Why is this decision hard to reverse?

## Decision
What did we decide? Be specific — exact approach, not a hand-wave.
What was the rejected alternative? Why was it rejected?

## Consequences
What becomes easier because of this decision?
What becomes harder?
What is the migration path if we change our minds later?
```

## Rules

1. **Number sequentially**: 0001, 0002, 0003. Never renumber.
2. **Status starts as "Proposed".** Change to "Accepted" once approved. Use "Deprecated" or "Superseded by ADR-NNNN" when overridden.
3. **Context names the rejected alternative.** Without it, the reader can't see the trade-off.
4. **Decision is precise.** "We'll use Postgres" is too vague. "We'll use Postgres for the write model, with event sourcing via the `events` table using `jsonb` for payloads" is specific.
5. **Consequences are honest.** Every decision makes something harder. Name it.
6. **One decision per ADR.** Don't bundle unrelated choices into one file.
7. **Create sparingly.** Most discussions don't need an ADR. Only create when all three criteria (hard to reverse + surprising + real trade-off) are met.
```

- [ ] **Step 2: Commit**

```bash
git add .claude/skills/domain-modeling/ADR-FORMAT.md
git commit -m "feat: add ADR-FORMAT.md reference for domain-modeling

Co-Authored-By: Claude Opus 4.8 (1M context) <noreply@anthropic.com>"
```

---

### Task 4: Create context directory placeholder

**Files:**
- Create: `.claude/context/.gitkeep`

**Interfaces:**
- Produces: ensures `.claude/context/` directory exists so Planner can write `CONTEXT.md` and `docs/adr/` without checking for directory existence

- [ ] **Step 1: Create directory and placeholder**

```bash
mkdir -p .claude/context/docs/adr
touch .claude/context/.gitkeep
```

- [ ] **Step 2: Verify**

Run: `ls -la .claude/context/`
Expected: `.gitkeep` file exists

Run: `ls -la .claude/context/docs/adr/`
Expected: directory exists (empty)

- [ ] **Step 3: Commit**

```bash
git add .claude/context/.gitkeep
git commit -m "feat: add .claude/context/ directory for domain glossary and ADRs

Co-Authored-By: Claude Opus 4.8 (1M context) <noreply@anthropic.com>"
```

---

### Task 5: Update smoke test — add 6 new checks

**Files:**
- Modify: `.claude/tests/smoke.sh` (add checks 44-49, update summary expectations)

**Interfaces:**
- Consumes: Task 1 (domain-modeling SKILL.md), Task 2 (CONTEXT-FORMAT.md), Task 3 (ADR-FORMAT.md), Task 6-10 (modified agents), Task 11 (modified SKILL.md)
- Produces: 49/49 passing smoke test (was 43/43)

- [ ] **Step 1: Add new checks after the Cross-Reference section (line ~268, before Summary)**

Replace the section:
```
# ─── Summary ───────────────────────────────────────────────────
```

With:
```
# ─── 8. Domain-Modeling Skill Integrity ────────────────────────

echo ""
echo "── Domain-Modeling Skill ──"

DM_DIR="$ROOT/.claude/skills/domain-modeling"

if [ -f "$DM_DIR/SKILL.md" ]; then
  dm_fm=$(sed -n '/^---$/,/^---$/p' "$DM_DIR/SKILL.md" | sed '1d;$d')
  if echo "$dm_fm" | grep -q "disable-model-invocation: true"; then
    pass "domain-modeling/SKILL.md: disable-model-invocation: true"
  else
    fail "domain-modeling/SKILL.md: missing disable-model-invocation: true"
  fi
else
  fail "domain-modeling/SKILL.md: file missing"
fi

if [ -f "$DM_DIR/CONTEXT-FORMAT.md" ]; then
  pass "domain-modeling/CONTEXT-FORMAT.md: exists"
else
  fail "domain-modeling/CONTEXT-FORMAT.md: file missing"
fi

if [ -f "$DM_DIR/ADR-FORMAT.md" ]; then
  pass "domain-modeling/ADR-FORMAT.md: exists"
else
  fail "domain-modeling/ADR-FORMAT.md: file missing"
fi

# Planner must load domain-modeling skill
planner_fm=$(sed -n '/^---$/,/^---$/p' "$AGENT_DIR/planner.md" | sed '1d;$d')
if echo "$planner_fm" | grep -q "domain-modeling"; then
  pass "planner: loads domain-modeling skill"
else
  fail "planner: missing domain-modeling in skills: list"
fi

# Planner maxTurns must be >= 15
planner_mt=$(echo "$planner_fm" | grep "^maxTurns:" | sed 's/maxTurns: *//')
if [ -n "$planner_mt" ] && [ "$planner_mt" -ge 15 ]; then
  pass "planner: maxTurns=$planner_mt (>= 15)"
else
  fail "planner: maxTurns=$planner_mt (expected >= 15)"
fi

# Validator checklist must have >= 10 items
validator_count=$(grep -c '^### [0-9]' "$AGENT_DIR/implementation-validator.md" || true)
if [ "$validator_count" -ge 10 ]; then
  pass "implementation-validator: $validator_count checklist items (>= 10)"
else
  fail "implementation-validator: only $validator_count checklist items (expected >= 10)"
fi

# SKILL.md must reference domain-modeling in Planner invocation
if grep -q 'domain-modeling' "$SKILL_FILE"; then
  pass "SKILL.md: references domain-modeling"
else
  fail "SKILL.md: missing domain-modeling reference"
fi

# ─── Summary ───────────────────────────────────────────────────
```

- [ ] **Step 2: Run smoke test to confirm new checks detect missing work**

Run: `bash .claude/tests/smoke.sh`
Expected: several FAILs — because Tasks 6-11 haven't been done yet. This is expected. At minimum:
- CHECK 44 should PASS (SKILL.md exists from Task 1)
- CHECK 45 should PASS (CONTEXT-FORMAT.md exists from Task 2)
- CHECK 46 should PASS (ADR-FORMAT.md exists from Task 3)
- CHECK 47 should FAIL (planner not updated yet)
- CHECK 48 should FAIL (validator not updated yet)
- CHECK 49 should FAIL (SKILL.md not updated yet)

- [ ] **Step 3: Commit**

```bash
git add .claude/tests/smoke.sh
git commit -m "test: add 6 smoke checks for domain-modeling and TDD integration

New checks:
- 44: domain-modeling/SKILL.md exists with disable-model-invocation
- 45: CONTEXT-FORMAT.md exists
- 46: ADR-FORMAT.md exists
- 47: planner loads domain-modeling skill, maxTurns >= 15
- 48: validator has >= 10 checklist items
- 49: SKILL.md references domain-modeling

Co-Authored-By: Claude Opus 4.8 (1M context) <noreply@anthropic.com>"
```

---

### Task 6: Update Planner agent — domain-modeling + glossary chapter

**Files:**
- Modify: `.claude/agents/planner.md` (3 changes: frontmatter, Phase 0, output format)

**Interfaces:**
- Consumes: Task 1 (domain-modeling skill)
- Produces: Planner now loads domain-modeling skill, executes it during Phase 0, and outputs a Domain Glossary chapter between User Story and Technical Brief
- maxTurns: 12 → 15

- [ ] **Step 1: Change frontmatter — add domain-modeling to skills, bump maxTurns**

Replace:
```yaml
maxTurns: 12
skills:
  - brainstorming
```

With:
```yaml
maxTurns: 15
skills:
  - brainstorming
  - domain-modeling
```

- [ ] **Step 2: Change Phase 0 — add domain-modeling step after brainstorming**

Insert after the line:
```
**Hard gate**: Do NOT write the final User Story or Technical Brief until the brainstorming process is complete and the design is approved.
```

Add:
```markdown

### Phase 0b: Domain Modeling (MANDATORY — run after brainstorming)

Once brainstorming is complete, run the domain-modeling skill to extract the project's language:

1. **Challenge the user's terms** — "You said 'Account' — do you mean Customer or User? Those are different things."
2. **Extract canonical terms** — for every fuzzy concept, propose a precise term. "Let's call it 'Order' — a confirmed purchase request, distinct from 'Cart' which is pre-confirmation."
3. **Stress-test with scenarios** — "If an Order is partially cancelled, does this term still hold?"
4. **Produce the initial glossary** (3-8 terms) and **check for contradictions with existing `.claude/context/CONTEXT.md`**.

**Deliverable**: a Domain Glossary table in the blueprint output, AND an update to `.claude/context/CONTEXT.md` with new terms.
```

- [ ] **Step 3: Insert Domain Glossary chapter in output format**

Replace:
```markdown
## User Story

### Story
As a [role], I want [behavior], so that [outcome].
```

With:
```markdown
## Domain Glossary

> Terms defined during brainstorming + domain-modeling. These terms are the canonical language for ALL downstream agents. Use them exactly in function names, variable names, file names, and test descriptions.

### Terms for this feature

| Term | Definition | In Code As | Not To Be Confused With |
|------|------------|------------|--------------------------|
| <Term> | <Precise, one sentence> | `<functionOrFileName>` | <similar but distinct term> |

### New ADRs (if any)
- `docs/adr/NNNN-<title>.md` — [one-line summary of the decision]

### CONTEXT.md Updated
- `.claude/context/CONTEXT.md` — [terms added or sharpened: ...]
- (If no CONTEXT.md existed, one was created)

---

## User Story

### Story
As a [role], I want [behavior], so that [outcome].
```

- [ ] **Step 4: Add "Glossary" to What You Cannot Do**

Insert after the line:
```markdown
- **NEVER skip tenant isolation or timezone concerns** — if the feature involves data, these must be addressed
```

Add:
```markdown
- **NEVER skip domain modeling** — every feature has domain terms. Extract them. Define them. Write them down. This is the shared language that prevents downstream naming drift.
```

- [ ] **Step 5: Commit**

```bash
git add .claude/agents/planner.md
git commit -m "feat(planner): add domain-modeling phase and Domain Glossary chapter

- Load domain-modeling skill (frontmatter skills: add)
- Phase 0b: extract canonical terms, stress-test with scenarios
- Output: Domain Glossary table between story and brief
- Dual-write: glossary in blueprint + persist to .claude/context/CONTEXT.md
- maxTurns: 12 → 15

Co-Authored-By: Claude Opus 4.8 (1M context) <noreply@anthropic.com>"
```

---

### Task 7: Update Backend Builder agent — TDD workflow

**Files:**
- Modify: `.claude/agents/backend-builder.md` (Step 2 rewritten, Step 3 replaced with TDD loop, output format extended)

**Interfaces:**
- Consumes: Planner's blueprint (now includes Domain Glossary chapter)
- Produces: Backend implementation via RED→GREEN→REFACTOR vertical slices, with TDD Cycle Log in summary

- [ ] **Step 1: Change "Your Input" section — add CONTEXT.md**

Replace:
```markdown
## Your Input

Before you start, you must have:
1. The approved Technical Brief (from Planner)
2. The Researcher's findings
3. The project's CLAUDE.md and `.claude/rules/builder-rules.md`

If any of these are missing, ask for them before writing code.
```

With:
```markdown
## Your Input

Before you start, you must have:
1. The approved Technical Brief (from Planner) — **especially the Domain Glossary chapter for canonical terms**
2. The Researcher's findings
3. The project's CLAUDE.md and `.claude/rules/builder-rules.md`
4. `.claude/context/CONTEXT.md` (if it exists) — use its domain terms for function, variable, and file naming

If any of these are missing, ask for them before writing code. If CONTEXT.md doesn't exist yet, use the Domain Glossary from the Technical Brief — but recommend that Planner initialise CONTEXT.md.
```

- [ ] **Step 2: Rewrite Step 2 — Plan Test Seams**

Replace:
```markdown
### Step 2: Plan Your Implementation
- Identify the exact files you'll touch
- Identify existing helpers and patterns to reuse
- Map the order of implementation (migrations → models → services → routes → jobs)
```

With:
```markdown
### Step 2: Plan Test Seams (MANDATORY — do not write code yet)

Before writing any implementation code, plan the test seams:

1. **Identify behaviors to test** — NOT implementation steps. "User can checkout with valid cart" is a behavior. "OrderService validates cart items" is implementation.
2. **Identify the test seam for each behavior** — the public interface through which the test will exercise the behavior (API endpoint, service method, CLI command).
3. **Confirm seams with the user** — present the list of behaviors to test and their seams. Ask: "Which behaviors are most important? Are these the right seams?"
4. **Map vertical slices** — each slice is ONE behavior, tested through its seam, cutting through ALL layers (route → service → data access → response).

**Output**: a numbered list of behaviors to test, each with:
- Behavior description (what the user can do)
- Test seam (which public interface to test through)
- Priority (must-test first, should-test, nice-to-test)

Do NOT proceed to Step 3 until the user approves this plan.
```

- [ ] **Step 3: Rewrite Step 3 — TDD Loop**

Replace:
```markdown
### Step 3: Implement
- Write migrations first (always include `up` AND `down` methods)
- Write models and types
- Write services with business logic
- Write thin API routes that delegate to services
- Write background jobs if needed
- Write unit tests alongside code (not after)
```

With:
```markdown
### Step 3: TDD Loop — RED → GREEN → REFACTOR (MANDATORY — one vertical slice at a time)

**CRITICAL: DO NOT write all tests first, then all implementation. This is "horizontal slicing" and produces bad tests.** Tests written in bulk test imagined behavior, not actual behavior. They break when behavior is fine, and pass when behavior is broken.

**Correct approach**: vertical slices. One test → one implementation → repeat.

For each behavior from Step 2:

#### RED: Write the failing test
- Write ONE test for ONE behavior through the agreed seam
- The test must exercise the real code path through the public interface
- Tests describe WHAT the system does, not HOW it does it
- Avoid mocking internal collaborators; mock only external services (Stripe, Twilio, etc.)
- Run the test → confirm it FAILS with the expected failure (not a compile error, but an assertion failure)

#### GREEN: Write minimal code to pass
- Write ONLY enough code to make this one test pass
- Migrations first (always include `up` AND `down` methods), then models, then services, then routes
- Do NOT anticipate future tests — no speculative features, no "I'll need this later"
- Keep API routes thin: validate input, call service, return response. Business logic lives in services.
- Run the test → confirm it PASSES
- Run ALL previous tests → confirm they still pass (no regressions)

#### REFACTOR: Clean up while green
- Extract duplication
- Improve names (use the Domain Glossary terms from the Technical Brief or CONTEXT.md)
- Apply SOLID principles where natural
- Run ALL tests after each refactor step → confirm they still pass

**Never refactor while RED.** Get to GREEN first.

#### TDD Cycle Checklist (every slice MUST satisfy)
```
[ ] Test describes behavior, not implementation
[ ] Test uses public interface only — no private method tests, no DB queries past the interface
[ ] Test would survive internal refactor — changing internals without changing behavior would NOT break this test
[ ] Code is minimal for this test — no speculative features
[ ] All tests are GREEN before starting the next slice
```

Repeat RED → GREEN → REFACTOR until all behaviors from Step 2 are covered.
```

- [ ] **Step 4: Update output format — add TDD Cycle Log and Glossary Terms Used**

Insert before the `### Migration Summary` line in the output format:

```markdown
### TDD Cycle Log
| # | Behavior Tested | Test File | Seam | Result | Refactored? |
|---|-----------------|-----------|------|--------|-------------|
| 1 | [behavior from Step 2] | `path/to/test.ts` | [seam] | ✅ RED→GREEN | [what was refactored, or —] |

### Glossary Terms Used
- [Term1], [Term2], [Term3] — from CONTEXT.md / Domain Glossary
- [NewTerm] — NEW (term not in glossary; Planner should review)
```

- [ ] **Step 5: Commit**

```bash
git add .claude/agents/backend-builder.md
git commit -m "feat(backend-builder): replace Step 3 with TDD red-green-refactor loop

- Step 2: Plan Test Seams (identify behaviors + seams before code)
- Step 3: TDD Loop — RED→GREEN→REFACTOR, one vertical slice at a time
- Anti-pattern explicitly banned: horizontal slicing (all tests first)
- Output: TDD Cycle Log + Glossary Terms Used
- Read CONTEXT.md for domain terms when available

Co-Authored-By: Claude Opus 4.8 (1M context) <noreply@anthropic.com>"
```

---

### Task 8: Update Frontend Builder agent — TDD workflow (symmetric to Task 7)

**Files:**
- Modify: `.claude/agents/frontend-builder.md` (same pattern as Task 7: Input, Step 2, Step 3, output format)

**Interfaces:**
- Consumes: Planner's blueprint (now includes Domain Glossary chapter)
- Produces: Frontend implementation via RED→GREEN→REFACTOR vertical slices, with TDD Cycle Log

- [ ] **Step 1: Change "Your Input" section — add CONTEXT.md**

Replace:
```markdown
## Your Input

Before you start, you must have:
1. The approved Technical Brief (from Planner) — **especially the API Changes section**
2. The Researcher's findings
3. The project's CLAUDE.md and `.claude/rules/builder-rules.md`
4. If the Backend Builder has already finished: read its **API Contract Summary** — the API shapes it actually produced

If running in parallel with Backend Builder (both starting from the Technical Brief simultaneously):
- Use the API shapes from the Technical Brief as your contract
- If the actual API diverges, do NOT patch the frontend — flag it as feedback for the Validator phase
```

With:
```markdown
## Your Input

Before you start, you must have:
1. The approved Technical Brief (from Planner) — **especially the API Changes section and the Domain Glossary chapter for canonical terms**
2. The Researcher's findings
3. The project's CLAUDE.md and `.claude/rules/builder-rules.md`
4. `.claude/context/CONTEXT.md` (if it exists) — use its domain terms for component names, prop names, and file naming
5. If the Backend Builder has already finished: read its **API Contract Summary** — the API shapes it actually produced

If CONTEXT.md doesn't exist yet, use the Domain Glossary from the Technical Brief — but recommend that Planner initialise CONTEXT.md.

If running in parallel with Backend Builder (both starting from the Technical Brief simultaneously):
- Use the API shapes from the Technical Brief as your contract
- If the actual API diverges, do NOT patch the frontend — flag it as feedback for the Validator phase
```

- [ ] **Step 2: Rewrite Step 2 — Plan Test Seams**

Replace:
```markdown
### Step 2: Plan Your Implementation
- Identify the exact files you'll touch
- Identify existing components and hooks to reuse
- Map the component tree (page → sections → components → shared UI)
- Plan loading, error, and empty states for every data-fetching component
```

With:
```markdown
### Step 2: Plan Test Seams (MANDATORY — do not write code yet)

Before writing any implementation code, plan the test seams:

1. **Identify behaviors to test** — NOT implementation steps. "User sees order history with loading/error/empty states" is a behavior. "OrderHistory component renders a table" is implementation.
2. **Identify the test seam for each behavior** — the public interface through which the test will exercise the behavior (component render with props, page with mocked API, user interaction via Testing Library).
3. **Confirm seams with the user** — present the list of behaviors to test and their seams. Ask: "Which behaviors are most important? Are these the right seams?"
4. **Map vertical slices** — each slice is ONE behavior, tested through its seam, cutting through ALL layers (component → hook → API call → state → render).

**Output**: a numbered list of behaviors to test, each with:
- Behavior description (what the user sees/does)
- Test seam (which component/page to render and test)
- States to cover (loading / error / empty / success / edge case)
- Priority (must-test first, should-test, nice-to-test)

Do NOT proceed to Step 3 until the user approves this plan.
```

- [ ] **Step 3: Rewrite Step 3 — TDD Loop**

Replace:
```markdown
### Step 3: Implement
- Build from the bottom up: shared components → feature components → page
- Implement all states: loading, error, empty, success, edge cases
- Wire up API calls using the project's existing data-fetching patterns
- Write component tests alongside code (not after)
```

With:
```markdown
### Step 3: TDD Loop — RED → GREEN → REFACTOR (MANDATORY — one vertical slice at a time)

**CRITICAL: DO NOT write all tests first, then all implementation. This is "horizontal slicing" and produces bad tests.** Tests written in bulk test imagined behavior, not actual behavior. They break when behavior is fine, and pass when behavior is broken.

**Correct approach**: vertical slices. One test → one implementation → repeat.

For each behavior from Step 2:

#### RED: Write the failing test
- Write ONE test for ONE behavior through the agreed seam
- Render the component, simulate user interaction, assert on rendered output
- Use the project's existing test utilities (Testing Library, Playwright, etc.)
- The test must exercise real component behavior, not mock internals
- Run the test → confirm it FAILS with the expected failure (not a render error, but a missing behavior assertion)

#### GREEN: Write minimal code to pass
- Write ONLY enough code to make this one test pass
- Build from the bottom up: shared components → feature components → page
- Implement ALL states for this slice: loading, error, empty, success
- Wire up API calls using the project's existing data-fetching patterns
- Use the Domain Glossary terms for component names, prop names, and file names
- Run the test → confirm it PASSES
- Run ALL previous tests → confirm they still pass (no regressions)

#### REFACTOR: Clean up while green
- Extract shared components or hooks that emerged from this slice
- Improve names (use the Domain Glossary terms from the Technical Brief or CONTEXT.md)
- Ensure accessibility: Keyboard, Focus, Semantics, Color, Announcements, Forms
- Run ALL tests after each refactor step → confirm they still pass

**Never refactor while RED.** Get to GREEN first.

#### TDD Cycle Checklist (every slice MUST satisfy)
```
[ ] Test describes user-visible behavior, not component internals
[ ] Test uses public interface only — render component, interact, assert output
[ ] Test would survive internal refactor — changing internals without changing behavior would NOT break this test
[ ] Code is minimal for this test — no speculative features
[ ] All states covered: loading, error, empty, success (where applicable)
[ ] All tests are GREEN before starting the next slice
```

Repeat RED → GREEN → REFACTOR until all behaviors from Step 2 are covered.
```

- [ ] **Step 4: Update output format — add TDD Cycle Log and Glossary Terms Used**

Insert before the `### Components Built` line in the output format:

```markdown
### TDD Cycle Log
| # | Behavior Tested | Test File | Seam | Result | Refactored? |
|---|-----------------|-----------|------|--------|-------------|
| 1 | [behavior from Step 2] | `path/to/test.tsx` | [seam] | ✅ RED→GREEN | [what was refactored, or —] |

### Glossary Terms Used
- [Term1], [Term2], [Term3] — from CONTEXT.md / Domain Glossary
- [NewTerm] — NEW (term not in glossary; Planner should review)
```

- [ ] **Step 5: Commit**

```bash
git add .claude/agents/frontend-builder.md
git commit -m "feat(frontend-builder): replace Step 3 with TDD red-green-refactor loop

- Step 2: Plan Test Seams (identify behaviors + seams before code)
- Step 3: TDD Loop — RED→GREEN→REFACTOR, one vertical slice at a time
- All states (loading/error/empty/success) per slice
- Output: TDD Cycle Log + Glossary Terms Used
- Read CONTEXT.md for domain terms when available

Co-Authored-By: Claude Opus 4.8 (1M context) <noreply@anthropic.com>"
```

---

### Task 9: Update Debugger agent — feedack loop discipline in Phase 1

**Files:**
- Modify: `.claude/agents/debugger.md` (Phase 1 rewritten, soft-guidance exit clause added)

**Interfaces:**
- Consumes: bug reports from user or orchestrator
- Produces: Root Cause Analysis Report — now with mandatory feedback loop construction in Phase 1 (soft guidance: explicit exit clause if env prevents loop construction)

- [ ] **Step 1: Rewrite Phase 1 — Build Feedback Loop + Reproduce**

Replace:
```markdown
### Phase 1: Reproduce the Failure in Your Mind

Before looking at any code, reconstruct what happened:

1. **Clarify the expected behavior**: What should have happened?
2. **Clarify the actual behavior**: What actually happened? Be precise — "it broke" is not enough. What error? What incorrect output? What unintended side effect?
3. **Identify the gap**: The bug lives in the difference between expected and actual.
```

With:
```markdown
### Phase 1: Build a Feedback Loop + Reproduce

**This is the skill.** Everything else is mechanical. If you have a **tight** pass/fail signal for the bug — one that goes red on *this* bug — you will find the cause; bisection, hypothesis-testing, and instrumentation all just consume it. If you don't have one, no amount of staring at code will save you.

Spend disproportionate effort here. **Be aggressive. Be creative. Refuse to give up.**

#### 1a. Construct a pass/fail signal for THIS bug

Try these in roughly this order:

1. **Failing test** at whatever seam reaches the bug — unit, integration, e2e.
2. **Curl / HTTP script** against a running dev server.
3. **CLI invocation** with a fixture input, diffing stdout against a known-good snapshot.
4. **Headless browser script** (Playwright / Puppeteer) — drives the UI, asserts on DOM/console/network.
5. **Replay a captured trace.** Save a real network request / payload / event log to disk; replay it through the code path in isolation.
6. **Throwaway harness.** Spin up a minimal subset of the system (one service, mocked deps) that exercises the bug code path with a single function call.
7. **Property / fuzz loop.** If the bug is "sometimes wrong output", run 1000 random inputs and look for the failure mode.
8. **Bisection harness.** If the bug appeared between two known states (commit, dataset, version), automate "boot at state X, check, repeat" so you can `git bisect run` it.
9. **Differential loop.** Run the same input through old-version vs new-version (or two configs) and diff outputs.

#### 1b. Tighten the loop

Once you have *a* loop, **tighten** it:
- Can I make it faster? (Cache setup, skip unrelated init, narrow the test scope.)
- Can I make the signal sharper? (Assert on the specific symptom, not "didn't crash".)
- Can I make it more deterministic? (Pin time, seed RNG, isolate filesystem, freeze network.)

A 30-second flaky loop is barely better than no loop; a 2-second deterministic one is tight — a debugging superpower.

#### 1c. Complete the reproduction

Once the loop exists, confirm:
- [ ] The loop produces the failure mode the **user** described — not a different failure that happens to be nearby. Wrong bug = wrong fix.
- [ ] The failure is reproducible across multiple runs.

#### Phase 1 completion criteria

**Hard requirement**: Before entering Phase 2, your report MUST include:

```
**Feedback Loop Built**
- **Command**: `[paste the exact invocation — a script path, a test command, a curl]`
- **Output**: `[paste the output showing RED — the bug appearing]`
- **Loop characteristics**: [deterministic / high-reproduction-rate] · [fast: N seconds] · [agent-runnable / requires human]
```

**If you genuinely cannot build a loop after trying the methods above**: stop and say so explicitly. List what you tried. Ask the user for: (a) access to whatever environment reproduces it, (b) a captured artifact (HAR file, log dump, core dump, screen recording with timestamps), or (c) permission to add temporary production instrumentation. Then **proceed to Phase 2** — the loop is ideal but not a blocker. Code analysis is better than nothing.

Do NOT proceed to Phase 2 without either (a) a red-capable command AND its output, or (b) an explicit statement of what you tried and what you need from the user.

#### 1d. Minimise the repro

Once you have a red loop, shrink it to the **smallest scenario that still goes red**. Cut inputs, callers, config, data, and steps **one at a time**, re-running the loop after each cut — keep only what's load-bearing for the failure.

Done when **every remaining element is load-bearing** — removing any one of them makes the loop go green.
```

- [ ] **Step 2: Update the output format — add Feedback Loop section to report**

Insert after the `### Summary` line in the output format:

```markdown
### Feedback Loop Built
- **Command**: `[exact invocation]`
- **Output**: `[output showing the bug]`
- **Loop characteristics**: [deterministic/flaky] · [N seconds] · [agent-runnable/requires human]
- (If no loop could be built: what was tried, what is needed from the user)
```

- [ ] **Step 3: Commit**

```bash
git add .claude/agents/debugger.md
git commit -m "feat(debugger): build feedback loop before code analysis in Phase 1

- Phase 1: construct a tight, red-capable pass/fail signal FIRST
- 9 methods to try (test → curl → CLI → browser → trace → harness → fuzz → bisect → diff)
- Tighten: faster, sharper, deterministic
- Soft guidance: explicit exit clause if env prevents loop construction
- Report includes exact command + output proving the bug
- Minimise repro before proceeding

Co-Authored-By: Claude Opus 4.8 (1M context) <noreply@anthropic.com>"
```

---

### Task 10: Update Implementation Validator — add 2 new checklist items

**Files:**
- Modify: `.claude/agents/implementation-validator.md` (8 → 10 checklist items)

**Interfaces:**
- Consumes: Planner's blueprint (with Domain Glossary), Builders' TDD Cycle Logs
- Produces: validation report now includes #9 Domain Glossary Consistency and #10 TDD Traceability

- [ ] **Step 1: Add new check #9 and #10 after existing check #8**

Find the line:
```markdown
### 8. Missed Concerns
```

Insert BEFORE it (between #7 and #8):

```markdown
### 8. Domain Glossary Consistency

- [ ] Function names, variable names, and file names use the canonical terms from the Domain Glossary (Technical Brief) or `.claude/context/CONTEXT.md`
- [ ] No synonym drift — the same concept is not expressed with two different words across the codebase
- [ ] New terms introduced by Builders (marked NEW in TDD Cycle Log) are flagged for Planner review

How to check: grep the Domain Glossary's "In Code As" column against the codebase. Cross-reference with actual function/variable/file names. Also grep for near-miss synonyms (e.g., if glossary says "Order", search for "Purchase", "Transaction", "Sale").

Severity:
- **Minor** (fix directly): variable/function name doesn't match glossary term but the meaning is clear — rename to match the glossary
- **Important** (report): conceptual mismatch — the Builder used a different concept than what the glossary defines. This needs human judgment: is the glossary wrong, or is the implementation wrong?

### 9. TDD Traceability

- [ ] Every acceptance criterion from the User Story has at least one corresponding test that exercises it through a public interface
- [ ] Tests describe behavior, not implementation — test names read like specifications ("user can checkout with valid cart"), not like implementation notes ("OrderService.validateCart is called")
- [ ] No "horizontal slicing" traces — tests are organized by behavior, not by technical layer (a test file should contain tests for one behavior through all layers, not tests for one layer across all behaviors)

How to check: cross-reference the User Story's numbered acceptance criteria against the Builder's TDD Cycle Log. Each criterion number should map to at least one TDD cycle entry. Then spot-check 2-3 test files — read the test names and assertions; do they describe behavior or implementation?

Severity:
- **Important** (report): an acceptance criterion has no corresponding test — this means the feature is not proven to work
- **Minor** (fix directly): test names describe implementation instead of behavior — rename them to match the story's language
```

- [ ] **Step 2: Update the "Checks Passed" section in output format**

Replace:
```markdown
### Checks Passed
- Acceptance criteria coverage: [N/N]
- Failure path coverage: [good / gaps noted above]
- Security: [clean / issues noted above]
- Migration safety: [clean / issues noted above]
- Scope boundary: [clean / N files outside scope noted above]
- Pattern consistency: [good / inconsistencies noted above]
- Duplicate logic: [clean / duplicates noted above]
- Missed concerns: [all addressed / gaps noted above]
```

With:
```markdown
### Checks Passed
- Acceptance criteria coverage: [N/N]
- Failure path coverage: [good / gaps noted above]
- Security: [clean / issues noted above]
- Migration safety: [clean / issues noted above]
- Scope boundary: [clean / N files outside scope noted above]
- Pattern consistency: [good / inconsistencies noted above]
- Duplicate logic: [clean / duplicates noted above]
- Missed concerns: [all addressed / gaps noted above]
- Domain glossary consistency: [clean / Minor fixes applied / Important issues noted above]
- TDD traceability: [all criteria tested / gaps noted above]
```

- [ ] **Step 3: Renumber the old #8 (Missed Concerns) to #10**

Change:
```markdown
### 8. Missed Concerns
```

To:
```markdown
### 10. Missed Concerns
```

- [ ] **Step 4: Commit**

```bash
git add .claude/agents/implementation-validator.md
git commit -m "feat(validator): add domain glossary consistency and TDD traceability checks

- New check #8: Domain Glossary Consistency — naming matches glossary
  - Minor: rename to match glossary
  - Important: conceptual mismatch (needs human judgment)
- New check #9: TDD Traceability — every criterion has a public-interface test
  - Important: missing test for a criterion
  - Minor: test names describe implementation instead of behavior
- Old #8 (Missed Concerns) renumbered to #10
- Checks passed section updated with 2 new lines

Co-Authored-By: Claude Opus 4.8 (1M context) <noreply@anthropic.com>"
```

---

### Task 11: Update SKILL.md orchestrator — pass glossary and TDD instructions

**Files:**
- Modify: `.claude/skills/feature-factory/SKILL.md` (Planner and Builder Agent() call templates updated)

**Interfaces:**
- Consumes: Tasks 6-10 (modified agent definitions)
- Produces: orchestrator now passes domain-modeling instructions to Planner and TDD instructions to Builders

- [ ] **Step 1: Update Planner invocation template (Step 2 of Full Mode)**

Find the Planner Agent() call in the Full Mode workflow (Step 2). Replace:

```markdown
### Step 2: Launch Planner

Pass the Researcher's findings to the Planner:

```
Agent(
  subagent_type="planner",
  description="Write user story and technical brief",
  prompt="Based on the following Researcher findings and the user's feature request, produce a User Story and Technical Brief. Include both in a single response.

Feature Request: [USER'S FEATURE DESCRIPTION]

Researcher Findings:
[RESEARCHER'S FULL OUTPUT]"
)
```
```

With:

```markdown
### Step 2: Launch Planner

Pass the Researcher's findings to the Planner:

```
Agent(
  subagent_type="planner",
  description="Write user story and technical brief",
  prompt="Based on the following Researcher findings and the user's feature request, produce a User Story and Technical Brief. Include both in a single response.

Feature Request: [USER'S FEATURE DESCRIPTION]

Researcher Findings:
[RESEARCHER'S FULL OUTPUT]

IMPORTANT — Domain Modeling:
During Phase 0 brainstorming, run the domain-modeling skill to:
1. Extract and define canonical domain terms for this feature
2. Produce a Domain Glossary chapter in your blueprint (between User Story and Technical Brief)
3. Update or create .claude/context/CONTEXT.md with new terms
4. Offer ADRs for decisions that are hard-to-reverse + surprising + involve real trade-offs"
)
```
```

- [ ] **Step 2: Update Builder invocation templates (Step 4 of Full Mode)**

Find the Backend Builder Agent() call. Add after the Researcher Findings section:

```markdown
IMPORTANT — TDD Mode:
1. Read .claude/context/CONTEXT.md (if it exists) for domain terminology — use these terms exactly in function, variable, and file names
2. Step 2: Plan test seams before writing any code — identify behaviors, seams, and priorities. Get user approval on the plan.
3. Step 3: Use TDD — RED→GREEN→REFACTOR, ONE vertical slice at a time. Never write all tests first.
4. Include a TDD Cycle Log in your summary (behavior tested, test file, seam, result, refactored)
5. Step 4: Full test suite must pass before reporting. Typecheck and lint must be clean.
```

Do the same for the Frontend Builder Agent() call — same TDD Mode IMPORTANT block, but add:
```markdown
6. All states covered per slice: loading, error, empty, success
7. Accessibility: Keyboard, Focus, Semantics, Color, Announcements, Forms — check every slice
```

- [ ] **Step 3: Update Debug mode Builder invocation (Step 3 of Debug Mode)**

Add the same TDD IMPORTANT block to the Builder call in Debug mode (Step 3).

- [ ] **Step 4: Update Incremental mode Builder invocations**

Add a lighter version to Incremental mode Builder calls:
```markdown
TDD guidance: For this incremental change, write the regression test FIRST (prove the current behavior is broken or absent), then implement the minimal fix, then verify the test passes. Include a brief TDD Cycle Log (1-3 slices) in your summary.
```

- [ ] **Step 5: Commit**

```bash
git add .claude/skills/feature-factory/SKILL.md
git commit -m "feat(orchestrator): pass domain-modeling and TDD instructions to agents

- Planner: domain-modeling skill instructions for Phase 0
- Builders (Full/Debug modes): TDD mode with RED→GREEN→REFACTOR
- Builders (Incremental mode): lightweight regression-test-first guidance
- All builders: read CONTEXT.md for domain terminology

Co-Authored-By: Claude Opus 4.8 (1M context) <noreply@anthropic.com>"
```

---

### Task 12: Full smoke test verification

**Files:**
- (None — verification only)

**Interfaces:**
- Consumes: All previous tasks (1-11)
- Produces: 49 PASS, 0 WARN, 0 FAIL

- [ ] **Step 1: Run the full smoke test**

Run: `bash .claude/tests/smoke.sh`
Expected: 49 PASS, 0 WARN, 0 FAIL — CLEAN

- [ ] **Step 2: If any FAIL — fix and re-run**

For each FAIL:
1. Read the check description
2. Identify which task's file is missing the expected property
3. Fix the file
4. Re-run `bash .claude/tests/smoke.sh`

Loop until 49/49 PASS.

- [ ] **Step 3: Commit (only if fixes were needed)**

```bash
git add -A
git commit -m "fix: smoke test corrections for v1.4.0 integration

Co-Authored-By: Claude Opus 4.8 (1M context) <noreply@anthropic.com>"
```

---

### Task 13: Bump version and update changelog

**Files:**
- Modify: `VERSION`
- Modify: `CHANGELOG.md`

- [ ] **Step 1: Update VERSION**

Replace `1.3.1` with `1.4.0`:

Run: `echo "1.4.0" > VERSION`

- [ ] **Step 2: Update CHANGELOG.md — add v1.4.0 entry**

Insert after the `## [1.3.1]` entry header line (before the first item):

```markdown

## [1.4.0] — 2026-06-19

### Added
- **domain-modeling skill** (`/domain-modeling`): extract and define canonical domain terms, maintain CONTEXT.md glossary, create ADRs for hard-to-reverse decisions. Loaded by Planner during Phase 0.
- **TDD workflow for Builders**: Backend Builder and Frontend Builder now use RED→GREEN→REFACTOR vertical slices (one behavior at a time). Step 2 becomes "Plan Test Seams", Step 3 becomes "TDD Loop". Horizontal slicing (all tests first) is explicitly banned.
- **Feedback loop discipline for Debugger**: Phase 1 now requires constructing a tight, red-capable pass/fail signal before code analysis. Nine methods to try, with soft-guidance exit clause if the environment prevents loop construction.
- **Domain Glossary chapter in Planner blueprint**: new chapter between User Story and Technical Brief — canonical terms table, new ADRs, CONTEXT.md update log.
- **Validator checklist expanded 8→10**: new check #8 Domain Glossary Consistency (naming matches glossary), new check #9 TDD Traceability (every criterion has a public-interface test).
- **TDD Cycle Log** in Builder output format: behavior tested, test file, seam, RED→GREEN result, refactor notes.
- **Glossary Terms Used** in Builder output format: terms from CONTEXT.md, plus NEW terms flagged for Planner review.
- **Smoke test expanded 43→49**: 6 new checks covering domain-modeling skill integrity, planner skill loading, validator checklist count, and SKILL.md references.

### Changed
- **Planner maxTurns**: 12 → 15 (accommodates domain-modeling phase)
- **Planner skills**: now loads both `brainstorming` and `domain-modeling`
- **Builder Step 2**: renamed from "Plan Your Implementation" to "Plan Test Seams" — output is a prioritized behavior list with test seams, not a file list
- **Builder Step 3**: replaced "Implement" with "TDD Loop — RED → GREEN → REFACTOR" with per-slice checklist
- **Builder input**: now reads `.claude/context/CONTEXT.md` for domain terminology when available
- **Debugger Phase 1**: renamed from "Reproduce the Failure in Your Mind" to "Build a Feedback Loop + Reproduce" — now requires a concrete command + output before code analysis
- **Orchestrator SKILL.md**: Planner and Builder Agent() call templates updated with domain-modeling and TDD instructions
```

- [ ] **Step 3: Commit as the final release commit**

```bash
git add VERSION CHANGELOG.md
git commit -m "chore: release v1.4.0 — Matt Pocock skills integration

Co-Authored-By: Claude Opus 4.8 (1M context) <noreply@anthropic.com>"
```

- [ ] **Step 4: Tag the release**

```bash
git tag v1.4.0
```

- [ ] **Step 5: Final smoke test on tagged release**

Run: `bash .claude/tests/smoke.sh`
Expected: 49 PASS, 0 WARN, 0 FAIL — CLEAN
