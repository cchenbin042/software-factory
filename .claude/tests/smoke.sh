#!/usr/bin/env bash
# Feature Factory — Pipeline Smoke Test
# Validates agent definitions, command routing, and cross-references.
# Run: bash .claude/tests/smoke.sh
#
# Exit codes:
#   0 — all checks passed
#   1 — warnings found (non-blocking)
#   2 — errors found (pipeline may not function correctly)

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"

PASS=0
WARN=0
FAIL=0

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

pass() { echo -e "  ${GREEN}PASS${NC} $1"; PASS=$((PASS + 1)); }
warn() { echo -e "  ${YELLOW}WARN${NC} $1"; WARN=$((WARN + 1)); }
fail() { echo -e "  ${RED}FAIL${NC} $1"; FAIL=$((FAIL + 1)); }

echo ""
echo "═══════════════════════════════════════════"
echo "  Feature Factory — Pipeline Smoke Test"
echo "═══════════════════════════════════════════"
echo ""

# ─── 1. Agent Frontmatter Validation ───────────────────────────

echo "── Agents ──"

AGENT_DIR="$ROOT/.claude/agents"
REQUIRED_AGENT_FIELDS=("name" "description" "tools" "model" "maxTurns")
VALID_MODELS=("sonnet" "opus" "haiku" "fable")
AGENTS=("researcher" "planner" "debugger" "backend-builder" "frontend-builder" "test-verifier" "implementation-validator")

for agent in "${AGENTS[@]}"; do
  agent_file="$AGENT_DIR/$agent.md"

  if [ ! -f "$agent_file" ]; then
    fail "Agent file missing: $agent.md"
    continue
  fi

  # Extract frontmatter (between first two --- lines)
  fm=$(sed -n '/^---$/,/^---$/p' "$agent_file" | sed '1d;$d')

  for field in "${REQUIRED_AGENT_FIELDS[@]}"; do
    if ! echo "$fm" | grep -q "^${field}:"; then
      fail "$agent: missing required field '$field'"
    fi
  done

  # Validate model value
  model=$(echo "$fm" | grep "^model:" | sed 's/model: *//')
  if [ -n "$model" ]; then
    valid=false
    for m in "${VALID_MODELS[@]}"; do
      [ "$model" = "$m" ] && valid=true && break
    done
    if ! $valid; then
      fail "$agent: unknown model '$model'"
    else
      pass "$agent (model: $model)"
    fi
  fi

  # Validate maxTurns is a number
  max_turns=$(echo "$fm" | grep "^maxTurns:" | sed 's/maxTurns: *//')
  if [ -n "$max_turns" ] && ! [[ "$max_turns" =~ ^[0-9]+$ ]]; then
    fail "$agent: maxTurns '$max_turns' is not a number"
  fi

  # Check tools list is not empty
  tools=$(echo "$fm" | grep "^tools:" | sed 's/tools: *//')
  if [ -z "$tools" ]; then
    fail "$agent: tools list is empty"
  fi
done

# ─── 2. Agent Tool Permission Verification ─────────────────────

echo ""
echo "── Tool Permissions ──"

# Read-only agents must NOT have Write/Edit/Bash
READONLY_AGENTS=("researcher" "debugger")
RESTRICTED_TOOLS=("Write" "Edit" "Bash")

for agent in "${READONLY_AGENTS[@]}"; do
  agent_file="$AGENT_DIR/$agent.md"
  fm=$(sed -n '/^---$/,/^---$/p' "$agent_file" | sed '1d;$d')
  tools=$(echo "$fm" | grep "^tools:" | sed 's/tools: *//')

  for rt in "${RESTRICTED_TOOLS[@]}"; do
    if echo "$tools" | grep -q "$rt"; then
      fail "$agent: read-only agent has '$rt' in tools"
    fi
  done
  pass "$agent: tools are read-only (${tools})"
done

# Builders and Verifier/Validator must have Write/Edit
MUTATING_AGENTS=("backend-builder" "frontend-builder" "test-verifier" "implementation-validator" "planner")
for agent in "${MUTATING_AGENTS[@]}"; do
  agent_file="$AGENT_DIR/$agent.md"
  fm=$(sed -n '/^---$/,/^---$/p' "$agent_file" | sed '1d;$d')
  tools=$(echo "$fm" | grep "^tools:" | sed 's/tools: *//')

  has_edit=false
  for needed in "Write" "Edit"; do
    if echo "$tools" | grep -q "$needed"; then
      has_edit=true
    fi
  done

  if ! $has_edit; then
    fail "$agent: should have Write or Edit (current tools: $tools)"
  else
    pass "$agent: has write permissions (${tools})"
  fi
done

# ─── 3. Command Routing ────────────────────────────────────────

echo ""
echo "── Commands ──"

COMMAND_DIR="$ROOT/.claude/commands"

if [ -f "$COMMAND_DIR/feature-factory.md" ]; then
  if grep -q 'feature-factory' "$COMMAND_DIR/feature-factory.md"; then
    pass "/feature-factory → feature-factory skill"
  else
    fail "/feature-factory: does not route to feature-factory skill"
  fi
else
  fail "Command file missing: feature-factory.md"
fi

if [ -f "$COMMAND_DIR/debug.md" ]; then
  if grep -q 'debugger' "$COMMAND_DIR/debug.md"; then
    pass "/debug → debugger agent"
  else
    fail "/debug: does not route to debugger agent"
  fi
else
  fail "Command file missing: debug.md"
fi

# ─── 4. SKILL.md Subagent References ───────────────────────────

echo ""
echo "── SKILL.md References ──"

SKILL_FILE="$ROOT/.claude/skills/feature-factory/SKILL.md"

if [ ! -f "$SKILL_FILE" ]; then
  fail "SKILL.md missing"
else
  # Extract all subagent_type references
  refs=$(grep -o 'subagent_type="[^"]*"' "$SKILL_FILE" | sed 's/subagent_type="//;s/"//' | sort -u)

  for ref in $refs; do
    if echo "${AGENTS[@]}" | grep -q "$ref"; then
      pass "subagent_type=\"$ref\" → valid agent"
    else
      fail "subagent_type=\"$ref\" → no matching agent file"
    fi
  done

  # Check for broken relative links (../../rules/...)
  # Extract link targets, strip #anchor suffixes for file existence check
  links=$(grep -o '\[.*\](\.\./\.\./[^)]*' "$SKILL_FILE" | sed 's/.*\](//' || true)
  for raw_link in $links; do
    # Strip markdown anchor (#...) for file existence check
    link=$(echo "$raw_link" | sed 's/#.*//')
    target=$(echo "$link" | sed 's|../../|.claude/|')
    if [ -f "$ROOT/$target" ]; then
      pass "link: $link → exists"
    else
      fail "broken link: $link → $ROOT/$target not found"
    fi
  done
fi

# ─── 5. Rule Files ─────────────────────────────────────────────

echo ""
echo "── Rule Files ──"

RULES_DIR="$ROOT/.claude/rules"
EXPECTED_RULES=("builder-rules.md" "git-workflow.md" "failure-recovery.md")

for rule in "${EXPECTED_RULES[@]}"; do
  rule_file="$RULES_DIR/$rule"
  if [ -f "$rule_file" ]; then
    # Check for valid YAML frontmatter with paths
    if head -1 "$rule_file" | grep -q "^---$"; then
      pass "$rule: exists with frontmatter"
    else
      warn "$rule: exists but no frontmatter"
    fi
  else
    fail "$rule: file missing"
  fi
done

# ─── 6. Model Tiering Verification ─────────────────────────────

echo ""
echo "── Model Tiering ──"

# Deep reasoning agents → opus
for agent in "researcher" "planner" "debugger"; do
  model=$(sed -n '/^---$/,/^---$/p' "$AGENT_DIR/$agent.md" | grep "^model:" | sed 's/model: *//')
  if [ "$model" = "opus" ]; then
    pass "$agent: opus (deep reasoning)"
  else
    warn "$agent: expected opus, got $model"
  fi
done

# Builders stay sonnet
for agent in "backend-builder" "frontend-builder"; do
  model=$(sed -n '/^---$/,/^---$/p' "$AGENT_DIR/$agent.md" | grep "^model:" | sed 's/model: *//')
  if [ "$model" = "sonnet" ]; then
    pass "$agent: sonnet (balanced)"
  else
    warn "$agent: expected sonnet, got $model"
  fi
done

# Verifier + Validator → haiku
for agent in "test-verifier" "implementation-validator"; do
  model=$(sed -n '/^---$/,/^---$/p' "$AGENT_DIR/$agent.md" | grep "^model:" | sed 's/model: *//')
  if [ "$model" = "haiku" ]; then
    pass "$agent: haiku (efficient)"
  else
    warn "$agent: expected haiku, got $model"
  fi
done

# ─── 7. Cross-Reference Integrity ──────────────────────────────

echo ""
echo "── Cross-References ──"

# Verify FAQ.md path in CLAUDE.md
if grep -q '\.claude/FAQ\.md' "$ROOT/CLAUDE.md"; then
  pass "CLAUDE.md references .claude/FAQ.md (correct path)"
else
  fail "CLAUDE.md: FAQ.md path may be incorrect"
fi

# Verify VERSION file is readable and non-empty
if [ -f "$ROOT/VERSION" ] && [ -s "$ROOT/VERSION" ]; then
  ver=$(cat "$ROOT/VERSION")
  pass "VERSION: $ver"
else
  fail "VERSION: missing or empty"
fi

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

echo ""
echo "═══════════════════════════════════════════"
printf "  PASS: %d  WARN: %d  FAIL: %d\n" "$PASS" "$WARN" "$FAIL"
echo "═══════════════════════════════════════════"

if [ "$FAIL" -gt 0 ]; then
  echo ""
  echo "Verdict: ERRORS FOUND — pipeline may not function correctly."
  exit 2
elif [ "$WARN" -gt 0 ]; then
  echo ""
  echo "Verdict: WARNINGS ONLY — pipeline should work but may have suboptimal config."
  exit 1
else
  echo ""
  echo "Verdict: CLEAN — all checks passed."
  exit 0
fi
