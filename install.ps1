# Feature Factory — Install Script (Windows PowerShell)
# Usage:
#   .\install.ps1 -TargetPath C:\path\to\target-project   # 项目级安装
#   .\install.ps1 -User                                    # 用户级安装（所有项目可用）

param(
  [Parameter(Mandatory=$false, HelpMessage="Path to target project directory")]
  [string]$TargetPath,
  [Parameter(Mandatory=$false)]
  [switch]$User = $false
)

$ErrorActionPreference = "Stop"

# ── Parse mode ──────────────────────────────────────────────────
if ($User) {
  $TargetPath = "$env:USERPROFILE\.claude"
  if (-not (Test-Path $TargetPath -PathType Container)) {
    New-Item -ItemType Directory -Path $TargetPath -Force | Out-Null
    Write-Host "→ Created $TargetPath"
  }
} elseif (-not $TargetPath) {
  Write-Host "Usage:"
  Write-Host "  .\install.ps1 -TargetPath C:\path\to\target-project   # 项目级安装"
  Write-Host "  .\install.ps1 -User                                    # 用户级安装"
  Write-Host ""
  Write-Host "Examples:"
  Write-Host "  .\install.ps1 -TargetPath D:\my-web-app"
  Write-Host "  .\install.ps1 -User"
  exit 1
}

if (-not (Test-Path $TargetPath -PathType Container)) {
  Write-Error "Target directory does not exist: $TargetPath`nCreate it first: mkdir $TargetPath"
  exit 1
}

$TargetPath = Resolve-Path $TargetPath

# ── Source directory ────────────────────────────────────────────
$SrcPath = Split-Path -Parent $MyInvocation.MyCommand.Path

# ── Read version ────────────────────────────────────────────────
$Version = (Get-Content "$SrcPath\VERSION" -Raw).Trim()

# ── Check for existing installation ─────────────────────────────
if ($User) {
  if ((Test-Path "$TargetPath\agents") -and (Test-Path "$TargetPath\skills\feature-factory")) {
    Write-Warning "Feature Factory may already be installed at the user level."
    $reply = Read-Host "  Overwrite? (y/N)"
    if ("y", "Y" -notcontains $reply) {
      Write-Host "Aborted."
      exit 0
    }
  }
} elseif ((Test-Path "$TargetPath\.claude\agents") -and (Test-Path "$TargetPath\.claude\skills\feature-factory")) {
  Write-Warning "Feature Factory may already be installed in this project."
  $reply = Read-Host "  Overwrite? (y/N)"
  if ("y", "Y" -notcontains $reply) {
    Write-Host "Aborted."
    exit 0
  }
}

# ── Install ──────────────────────────────────────────────────────
Write-Host ""
Write-Host "=== Feature Factory v$Version — Installing ===" -ForegroundColor Cyan
Write-Host ""

if ($User) {
  Write-Host "→ Copying to $TargetPath\ ..."
  Copy-Item -Path "$SrcPath\.claude\*" -Destination "$TargetPath\" -Recurse -Force
} else {
  Write-Host "→ Copying .claude\ ..."
  Copy-Item -Path "$SrcPath\.claude" -Destination "$TargetPath\.claude" -Recurse -Force
}

# Root-level CLAUDE.md template
if ($User) {
  Write-Host "→ User-level install — skipping CLAUDE.md (belongs in each project)"
  Write-Host "   Copy ~\.claude\CLAUDE.md.template to each project as CLAUDE.md"
} elseif (Test-Path "$TargetPath\CLAUDE.md") {
  Write-Host "→ CLAUDE.md already exists. Template copied as .claude\CLAUDE.md.template for reference."
  Copy-Item -Path "$SrcPath\CLAUDE.md" -Destination "$TargetPath\.claude\CLAUDE.md.template" -Force
} else {
  Write-Host "→ No existing CLAUDE.md found. Copying project-level CLAUDE.md ..."
  Copy-Item -Path "$SrcPath\CLAUDE.md" -Destination "$TargetPath\CLAUDE.md" -Force
}

# ── Done ──────────────────────────────────────────────────────────
Write-Host ""
Write-Host "=== Installation Complete ===" -ForegroundColor Green
Write-Host ""

if ($User) {
  Write-Host "Installed files to ~\.claude\:"
} else {
  Write-Host "Installed files:"
}
Write-Host "  .claude\agents\          — 7 specialized agents"
Write-Host "  .claude\skills\          — Feature Factory orchestrator + domain-modeling"
Write-Host "  .claude\commands\        — /software-factory and /debug"
Write-Host "  .claude\rules\           — Builder shared rules"
Write-Host "  .claude\FAQ.md           — Troubleshooting guide"
Write-Host "  .claude\tests\smoke.sh   — Installation verification"

if ($User) {
  Write-Host ""
  Write-Host "Next steps:"
  Write-Host "  1. For each project: copy ~\.claude\CLAUDE.md.template to the project as CLAUDE.md"
  Write-Host "     and fill in the tech stack, commands, and rules."
  Write-Host "  2. Verify installation: bash ~\.claude\tests\smoke.sh"
  Write-Host "  3. Try it in any project: /software-factory <your feature description>"
} else {
  if (Test-Path "$TargetPath\CLAUDE.md") {
    Write-Host ""
    Write-Host "Next steps:"
    Write-Host "  1. Edit $TargetPath\CLAUDE.md — fill in your tech stack, commands, rules"
  } else {
    Write-Host ""
    Write-Host "Next steps:"
    Write-Host "  1. Copy $TargetPath\.claude\CLAUDE.md.template to $TargetPath\CLAUDE.md and customize it"
  }
  Write-Host "  2. Verify installation: bash .claude\tests\smoke.sh"
  Write-Host "  3. Try it: /software-factory <your feature description>"
}

Write-Host ""
Write-Host "---"
Write-Host "Recommended: Superpowers Plugin"
Write-Host "---"
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
