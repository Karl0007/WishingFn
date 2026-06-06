param(
    [string]$InstallDir = "$env:LOCALAPPDATA\WishingFn"
)

$ErrorActionPreference = "Stop"
$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$Candidates = @(
    $ScriptDir,
    (Join-Path $ScriptDir "dist\WishingFn"),
    (Join-Path (Split-Path -Parent $ScriptDir) "dist\WishingFn")
)

$SourceDir = $null
foreach ($Candidate in $Candidates) {
    if (Test-Path (Join-Path $Candidate "WishingFn.exe")) {
        $SourceDir = $Candidate
        break
    }
}

if (-not $SourceDir) {
    throw "Run this installer from an extracted WishingFn package or repository root after building."
}

New-Item -ItemType Directory -Force $InstallDir | Out-Null
Copy-Item -Recurse -Force (Join-Path $SourceDir "*") $InstallDir
$Exe = Join-Path $InstallDir "WishingFn.exe"
& $Exe install-autostart
Write-Host "Installed WishingFn to $InstallDir"
Write-Host "Start now with: $Exe run-kanata"
