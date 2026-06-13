#!/usr/bin/env bash
# Feature Factory — Install Script
# Usage: ./install.sh /path/to/target-project

set -euo pipefail

# ── Parse target ──────────────────────────────────────────────
TARGET="${1:-}"
if [ -z "$TARGET" ]; then
  echo "Usage: ./install.sh <target-project-dir>"
  echo ""
  echo "Examples:"
  echo "  ./install.sh /home/me/my-web-app"
  echo "  ./install.sh ../my-project"
  exit 1
fi

TARGET="$(realpath "$TARGET" 2>/dev/null || echo "$TARGET")"

if [ ! -d "$TARGET" ]; then
  echo "Target directory does not exist: $TARGET"
  echo "Create it first: mkdir -p $TARGET"
  exit 1
fi

# ── Source directory (where this script lives) ────────────────
SRC="$(cd "$(dirname "$0")" && pwd)"

# ── Check for existing Feature Factory installation ───────────
if [ -d "$TARGET/.claude/agents" ] && [ -d "$TARGET/.claude/skills/feature-factory" ]; then
  echo "⚠️  Feature Factory may already be installed in this project."
  echo "   Overwrite? (y/N)"
  read -r REPLY
  case "$REPLY" in
    [Yy]*) ;;
    *) echo "Aborted."; exit 0 ;;
  esac
fi

# ── Install ────────────────────────────────────────────────────
echo ""
echo "═══ Feature Factory v$(cat "$SRC/VERSION") — Installing ═══"
echo ""

# Claude Code directory: agents, skills, commands, rules
echo "→ Copying .claude/ ..."
cp -r "$SRC/.claude" "$TARGET/"

# Root-level CLAUDE.md template (don't overwrite user's existing one)
if [ -f "$TARGET/CLAUDE.md" ]; then
  echo "→ CLAUDE.md already exists. Template copied as .claude/CLAUDE.md.template for reference."
  cp "$SRC/CLAUDE.md" "$TARGET/.claude/CLAUDE.md.template"
else
  echo "→ No existing CLAUDE.md found. Copying project-level CLAUDE.md ..."
  cp "$SRC/CLAUDE.md" "$TARGET/CLAUDE.md"
fi

# ── Done ────────────────────────────────────────────────────────
echo ""
echo "═══ Installation Complete ═══"
echo ""
echo "Installed files:"
echo "  .claude/agents/          — 7 specialized agents"
echo "  .claude/skills/          — Feature Factory orchestrator"
echo "  .claude/commands/        — /feature-factory and /debug"
echo "  .claude/rules/           — Builder shared rules"
echo "  .claude/FAQ.md           — Troubleshooting guide"
if [ -f "$TARGET/CLAUDE.md" ]; then
  echo "  CLAUDE.md               — Project instructions"
else
  echo "  .claude/CLAUDE.md.template — CLAUDE.md template (customize first!)"
fi
echo ""
echo "Next steps:"
echo "  1. Edit $TARGET/CLAUDE.md — fill in your tech stack, commands, rules"
echo "  2. (Optional) Install Superpowers plugin for Planner brainstorming:"
echo "     claude plugins install anthropics/superpowers"
echo "  3. Try it: /feature-factory <your feature description>"
