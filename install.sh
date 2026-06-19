#!/usr/bin/env bash
# Feature Factory — Install Script
# Usage:
#   ./install.sh /path/to/target-project     # 项目级安装
#   ./install.sh --user                       # 用户级安装（所有项目可用）

set -euo pipefail

# ── Parse target ──────────────────────────────────────────────
USER_MODE=false
TARGET="${1:-}"

if [ "$TARGET" = "--user" ]; then
  USER_MODE=true
  TARGET="$HOME/.claude"
  if [ ! -d "$TARGET" ]; then
    mkdir -p "$TARGET"
    echo "→ Created $TARGET/"
  fi
elif [ -z "$TARGET" ]; then
  echo "Usage:"
  echo "  ./install.sh <target-project-dir>    # 项目级安装"
  echo "  ./install.sh --user                  # 用户级安装（所有项目可用）"
  echo ""
  echo "Examples:"
  echo "  ./install.sh /home/me/my-web-app"
  echo "  ./install.sh --user"
  exit 1
fi

TARGET="$(realpath "$TARGET" 2>/dev/null || echo "$TARGET")"

if [ "$USER_MODE" = false ] && [ ! -d "$TARGET" ]; then
  echo "Target directory does not exist: $TARGET"
  echo "Create it first: mkdir -p $TARGET"
  exit 1
fi

# ── Source directory (where this script lives) ────────────────
SRC="$(cd "$(dirname "$0")" && pwd)"

# ── Check for existing Feature Factory installation ───────────
if [ "$USER_MODE" = true ]; then
  if [ -d "$TARGET/agents" ] && [ -d "$TARGET/skills/feature-factory" ]; then
    echo "Feature Factory may already be installed at the user level."
    echo "Overwrite? (y/N)"
    read -r REPLY
    case "$REPLY" in
      [Yy]*) ;;
      *) echo "Aborted."; exit 0 ;;
    esac
  fi
elif [ -d "$TARGET/.claude/agents" ] && [ -d "$TARGET/.claude/skills/feature-factory" ]; then
  echo "Feature Factory may already be installed in this project."
  echo "Overwrite? (y/N)"
  read -r REPLY
  case "$REPLY" in
    [Yy]*) ;;
    *) echo "Aborted."; exit 0 ;;
  esac
fi

# ── Install ────────────────────────────────────────────────────
echo ""
echo "=== Feature Factory v$(cat "$SRC/VERSION") — Installing ==="
echo ""

# Claude Code directory: agents, skills, commands, rules
if [ "$USER_MODE" = true ]; then
  echo "→ Copying to $TARGET/ ..."
  cp -rn "$SRC/.claude/" "$TARGET/"
else
  echo "→ Copying .claude/ ..."
  cp -r "$SRC/.claude" "$TARGET/"
fi

# Root-level CLAUDE.md template
if [ "$USER_MODE" = true ]; then
  echo "→ User-level install — skipping CLAUDE.md (belongs in each project)"
  echo "   Copy ~/.claude/CLAUDE.md.template to each project as CLAUDE.md"
elif [ -f "$TARGET/CLAUDE.md" ]; then
  echo "→ CLAUDE.md already exists. Template copied as .claude/CLAUDE.md.template for reference."
  cp "$SRC/CLAUDE.md" "$TARGET/.claude/CLAUDE.md.template"
else
  echo "→ No existing CLAUDE.md found. Copying project-level CLAUDE.md ..."
  cp "$SRC/CLAUDE.md" "$TARGET/CLAUDE.md"
fi

# ── Done ────────────────────────────────────────────────────────
echo ""
echo "=== Installation Complete ==="
echo ""

if [ "$USER_MODE" = true ]; then
  echo "Installed files to ~/.claude/:"
else
  echo "Installed files:"
fi
echo "  .claude/agents/          — 7 specialized agents"
echo "  .claude/skills/          — Feature Factory orchestrator + domain-modeling"
echo "  .claude/commands/        — /software-factory and /debug"
echo "  .claude/rules/           — Builder shared rules"
echo "  .claude/FAQ.md           — Troubleshooting guide"
echo "  .claude/tests/smoke.sh   — Installation verification"

if [ "$USER_MODE" = true ]; then
  echo ""
  echo "Next steps:"
  echo "  1. For each project: copy ~/.claude/CLAUDE.md.template to the project as CLAUDE.md"
  echo "     and fill in the tech stack, commands, and rules."
  echo "  2. Verify installation: bash ~/.claude/tests/smoke.sh"
  echo "  3. Try it in any project: /software-factory <your feature description>"
else
  if [ -f "$TARGET/CLAUDE.md" ]; then
    echo ""
    echo "Next steps:"
    echo "  1. Edit $TARGET/CLAUDE.md — fill in your tech stack, commands, rules"
  else
    echo ""
    echo "Next steps:"
    echo "  1. Copy $TARGET/.claude/CLAUDE.md.template to $TARGET/CLAUDE.md and customize it"
  fi
  echo "  2. Verify installation: bash .claude/tests/smoke.sh"
  echo "  3. Try it: /software-factory <your feature description>"
fi

echo ""
echo "---"
echo "Recommended: Superpowers Plugin"
echo "---"
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
