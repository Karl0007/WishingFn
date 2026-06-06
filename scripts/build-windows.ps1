param(
    [string]$Version = "0.1.0"
)

$ErrorActionPreference = "Stop"
$Root = Split-Path -Parent $PSScriptRoot
Set-Location $Root

python -m pip install --upgrade pip pyinstaller
if (Test-Path dist) { Remove-Item -Recurse -Force dist }
if (Test-Path build) { Remove-Item -Recurse -Force build }
if (Test-Path WishingFn.spec) { Remove-Item -Force WishingFn.spec }

pyinstaller --noconfirm --onedir --name WishingFn --paths "$Root" --hidden-import wishingfn.cli --add-data "config;config" --add-data "vendor;vendor" scripts\wishingfn_entry.py

$PackageDir = Join-Path $Root "dist\WishingFn"
Copy-Item README.md $PackageDir -Force
Copy-Item wishingfn.cmd $PackageDir -Force
Copy-Item scripts\install-windows.ps1 $PackageDir -Force
Copy-Item scripts\install-latest-windows.ps1 $PackageDir -Force
Copy-Item install.ps1 $PackageDir -Force
Copy-Item update.ps1 $PackageDir -Force
Copy-Item uninstall.ps1 $PackageDir -Force
Compress-Archive -Force -Path (Join-Path $PackageDir "*") -DestinationPath (Join-Path $Root "dist\WishingFn-windows-x64-$Version.zip")
Write-Host "Built dist\WishingFn-windows-x64-$Version.zip"
