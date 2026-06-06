# One-command installer for Windows.
# Usage from repository root:
#   powershell -ExecutionPolicy Bypass -File .\install.ps1
# Usage from GitHub raw:
#   irm https://raw.githubusercontent.com/Karl0007/WishingFn/main/install.ps1 | iex

$ScriptUrl = "https://raw.githubusercontent.com/Karl0007/WishingFn/main/scripts/install-latest-windows.ps1"
$Script = Invoke-RestMethod -Uri $ScriptUrl -Headers @{ "User-Agent" = "WishingFn-Installer" }
Invoke-Expression $Script
