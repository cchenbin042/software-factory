# Feature Factory — Install Script (Windows PowerShell)
# Usage: .\install.ps1 -TargetPath C:\path\to\target-project

param(
  [Parameter(Mandatory=$true, HelpMessage="Path to target project directory")]
  [string]$TargetPath
)

$ErrorActionPreference = "Stop"

# ── Validate target ───────────────────────────────────────────
if (-not (Test-Path $TargetPath -PathType Container)) {
  Write-Error "Target directory does not exist: $TargetPath`nCreate it first: mkdir $TargetPath"
  exit 1
}

$TargetPath = Resolve-Path $TargetPath

# ── Source directory (where this script lives) ────────────────
$SrcPath = Split-Path -Parent $MyInvocation.MyCommand.Path

# ── Read version ──────────────────────────────────────────────
$Version = (Get-Content "$SrcPath\VERSION" -Raw).Trim()

# ── Check for existing installation ───────────────────────────
if ((Test-Path "$TargetPath\.claude\agents") -and (Test-Path "$TargetPath\.claude\skills\feature-factory")) {
  Write-Warning "Feature Factory may already be installed in this project."
  $reply = Read-Host "  Overwrite? (y/N)"
  if ("y", "Y" -notcontains $reply) {
    Write-Host "Aborted."
    exit 0
  }
}

# ── Install ────────────────────────────────────────────────────
Write-Host ""
Write-Host "=== Feature Factory v$Version — Installing ===" -ForegroundColor Cyan
Write-Host ""

Write-Host "→ Copying .claude/ ..."
Copy-Item -Path "$SrcPath\.claude" -Destination "$TargetPath\.claude" -Recurse -Force

# Root-level CLAUDE.md template
if (Test-Path "$TargetPath\CLAUDE.md") {
  Write-Host "→ CLAUDE.md already exists. Template copied as .claude\CLAUDE.md.template for reference."
  Copy-Item -Path "$SrcPath\CLAUDE.md" -Destination "$TargetPath\.claude\CLAUDE.md.template" -Force
} else {
  Write-Host "→ No existing CLAUDE.md found. Copying project-level CLAUDE.md ..."
  Copy-Item -Path "$SrcPath\CLAUDE.md" -Destination "$TargetPath\CLAUDE.md" -Force
}

# ── Done ────────────────────────────────────────────────────────
Write-Host ""
Write-Host "=== Installation Complete ===" -ForegroundColor Green
Write-Host ""
Write-Host "Installed files:"
Write-Host "  .claude\agents\          — 7 specialized agents"
Write-Host "  .claude\skills\          — Feature Factory orchestrator"
Write-Host "  .claude\commands\        — /feature-factory and /debug"
Write-Host "  .claude\rules\           — Builder shared rules"
Write-Host "  .claude\FAQ.md           — Troubleshooting guide"
if (Test-Path "$TargetPath\CLAUDE.md") {
  Write-Host "  CLAUDE.md                — Project instructions"
} else {
  Write-Host "  .claude\CLAUDE.md.template — CLAUDE.md template (customize first!)"
}
Write-Host ""
Write-Host "Next steps:"
Write-Host "  1. Edit $TargetPath\CLAUDE.md — fill in your tech stack, commands, rules"
Write-Host "  2. (Optional) Install Superpowers plugin: claude plugins install anthropics/superpowers"
Write-Host "  3. Try it: /feature-factory <your feature description>"

Write-Host ""
Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
Write-Host "  Recommended: Superpowers Plugin"
Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
Write-Host ""
Write-Host "Feature Factory's Planner uses Superpowers for interactive"
Write-Host "brainstorming. Without it, Planner falls back to an inline"
Write-Host "process that works but is less polished."
Write-Host ""
Write-Host "Install it for the full experience:"
Write-Host "  claude plugins install anthropics/superpowers"
Write-Host ""
$answer = Read-Host "Install Superpowers now? [Y/n]"
if ($answer -ne 'n' -and $answer -ne 'N') {
  try { claude plugins install anthropics/superpowers } catch { Write-Host "  → Skipped (claude CLI not available in this environment)" }
}
