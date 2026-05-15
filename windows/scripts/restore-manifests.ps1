# Reinstall everything listed in windows/manifests/ onto a fresh machine.
# Safe to re-run: each step is idempotent.
# Pass -InstallScoop to bootstrap Scoop from https://get.scoop.sh if missing.

[CmdletBinding()]
param(
  [switch]$InstallScoop
)

$ErrorActionPreference = 'Continue'

$RepoRoot = Split-Path -Parent (Split-Path -Parent $PSCommandPath)
$In = Join-Path $RepoRoot 'manifests'

function Say  { param($m) Write-Host "==> $m" -ForegroundColor Cyan }
function Warn { param($m) Write-Host "!!  $m" -ForegroundColor Yellow }

# --- scoop bootstrap ---------------------------------------------------------
if (-not (Get-Command scoop -ErrorAction SilentlyContinue)) {
  if ($InstallScoop) {
    Say 'installing scoop'
    Set-ExecutionPolicy -Scope CurrentUser -ExecutionPolicy RemoteSigned -Force
    $scoopInstaller = Join-Path $env:TEMP 'scoop-install.ps1'
    Invoke-WebRequest -Uri 'https://get.scoop.sh' -OutFile $scoopInstaller
    & $scoopInstaller
  } else {
    Warn 'scoop not installed; skipping scoop restore. Re-run with -InstallScoop to bootstrap it.'
  }
}

# --- winget import -----------------------------------------------------------
if ((Test-Path (Join-Path $In 'winget.json')) -and (Get-Command winget -ErrorAction SilentlyContinue)) {
  Say 'winget import'
  # --ignore-unavailable: skip Store / system entries with no winget source
  & winget import -i (Join-Path $In 'winget.json') `
    --accept-package-agreements --accept-source-agreements --ignore-unavailable
}

# --- scoop import ------------------------------------------------------------
if ((Test-Path (Join-Path $In 'scoop.json')) -and (Get-Command scoop -ErrorAction SilentlyContinue)) {
  Say 'scoop import'
  scoop import (Join-Path $In 'scoop.json')
}

# --- npm globals -------------------------------------------------------------
if ((Test-Path (Join-Path $In 'npm-global.txt')) -and (Get-Command npm -ErrorAction SilentlyContinue)) {
  Say 'npm -g'
  Get-Content (Join-Path $In 'npm-global.txt') | ForEach-Object {
    # Strip npm tree decoration and trailing @version, keep package scopes.
    $treeChars = [char[]]@([char]0x20, [char]0x09, [char]0x2502, [char]0x2514, [char]0x251C, [char]0x2500, [char]0x2014, [char]0x60, [char]0x2B, [char]0x2D)
    $line = $_.TrimStart($treeChars)
    $line = $line -replace '@[0-9][^\s]*$', ''
    $line = $line.Trim()
    if ($line) {
      try { npm i -g $line } catch { Warn "npm i -g $line failed" }
    }
  }
}

# --- VS Code / Cursor extensions --------------------------------------------
if ((Test-Path (Join-Path $In 'vscode-extensions.txt')) -and (Get-Command code -ErrorAction SilentlyContinue)) {
  Say 'vscode extensions'
  Get-Content (Join-Path $In 'vscode-extensions.txt') | Where-Object { $_ -ne '' } | ForEach-Object {
    try { code --install-extension $_ } catch { Warn "vscode $_ failed" }
  }
}
if ((Test-Path (Join-Path $In 'cursor-extensions.txt')) -and (Get-Command cursor -ErrorAction SilentlyContinue)) {
  Say 'cursor extensions'
  Get-Content (Join-Path $In 'cursor-extensions.txt') | Where-Object { $_ -ne '' } | ForEach-Object {
    try { cursor --install-extension $_ } catch { Warn "cursor $_ failed" }
  }
}

Say 'done'
