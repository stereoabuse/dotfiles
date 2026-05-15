# Bootstrap a fresh Windows machine: place configs from windows/ into $env:USERPROFILE,
# then run windows\scripts\restore-manifests.ps1 to reinstall packages.
#
# Default: copies files (works without admin). Pass -UseSymlinks for symlinks
# (requires admin OR Developer Mode enabled).
# Pass -InstallScoop to let restore bootstrap Scoop from https://get.scoop.sh.
#
# Existing files get moved to $env:USERPROFILE\.dotfiles-backup-<timestamp>\ first.
# Safe to re-run.

[CmdletBinding()]
param(
  [switch]$UseSymlinks,
  [switch]$SkipRestore,
  [switch]$InstallScoop
)

$ErrorActionPreference = 'Stop'

function Say  { param($m) Write-Host "==> $m" -ForegroundColor Cyan }
function Warn { param($m) Write-Host "!!  $m" -ForegroundColor Yellow }

if (-not $IsWindows -and $env:OS -ne 'Windows_NT') {
  Warn "this installer targets Windows; for macOS see osx/, for Linux see ubuntu/"
  exit 1
}

$RepoRoot = Split-Path -Parent $PSCommandPath
$Src      = $RepoRoot
$Backup   = Join-Path $env:USERPROFILE (".dotfiles-backup-$(Get-Date -Format yyyyMMdd-HHmmss)")
New-Item -ItemType Directory -Path $Backup -Force | Out-Null

function Place-File {
  param([string]$SrcPath, [string]$DestPath)

  if (-not (Test-Path $SrcPath)) { return }

  $destDir = Split-Path -Parent $DestPath
  if ($destDir -and -not (Test-Path $destDir)) {
    New-Item -ItemType Directory -Path $destDir -Force | Out-Null
  }

  if (Test-Path $DestPath) {
    $userRoot = [System.IO.Path]::GetFullPath($env:USERPROFILE)
    $fullDest = [System.IO.Path]::GetFullPath($DestPath)
    if ($fullDest.StartsWith($userRoot, [System.StringComparison]::OrdinalIgnoreCase)) {
      $relativeDest = $fullDest.Substring($userRoot.Length).TrimStart('\', '/')
    } else {
      $relativeDest = [System.IO.Path]::GetFileName($DestPath)
    }
    $backupName = $relativeDest -replace '[:\\/]', '_'
    $backupTarget = Join-Path $Backup $backupName
    Move-Item -Path $DestPath -Destination $backupTarget -Force
    Warn "backed up existing $DestPath -> $backupTarget"
  }

  if ($UseSymlinks) {
    try {
      New-Item -ItemType SymbolicLink -Path $DestPath -Target $SrcPath -Force | Out-Null
      Write-Host "  linked $DestPath -> $SrcPath"
    } catch {
      Warn "symlink failed (need admin or Developer Mode); falling back to copy for $DestPath"
      Copy-Item -Path $SrcPath -Destination $DestPath -Force
      Write-Host "  copied $DestPath"
    }
  } else {
    Copy-Item -Path $SrcPath -Destination $DestPath -Force
    Write-Host "  copied $DestPath"
  }
}

Say "placing PowerShell profile"
$wpsDir  = Join-Path $env:USERPROFILE 'Documents\WindowsPowerShell'
$pwshDir = Join-Path $env:USERPROFILE 'Documents\PowerShell'
Place-File (Join-Path $Src 'Microsoft.PowerShell_profile.ps1') (Join-Path $wpsDir  'Microsoft.PowerShell_profile.ps1')
if (Get-Command pwsh -ErrorAction SilentlyContinue) {
  Place-File (Join-Path $Src 'Microsoft.PowerShell_profile.ps1') (Join-Path $pwshDir 'Microsoft.PowerShell_profile.ps1')
}

Say "placing .gitconfig"
Place-File (Join-Path $Src '.gitconfig') (Join-Path $env:USERPROFILE '.gitconfig')

Say "placing .claude config"
$claudeSrc  = Join-Path $Src '.claude'
$claudeDest = Join-Path $env:USERPROFILE '.claude'
foreach ($name in 'settings.json','statusline-command.js') {
  Place-File (Join-Path $claudeSrc $name) (Join-Path $claudeDest $name)
}

if (-not $SkipRestore) {
  $restore = Join-Path $RepoRoot 'scripts\restore-manifests.ps1'
  if (Test-Path $restore) {
    Say "restoring packages from manifests"
    $restoreArgs = @()
    if ($InstallScoop) { $restoreArgs += '-InstallScoop' }
    & $restore @restoreArgs
  }
}

Say "done - see $Backup for any files that got replaced"
