param(
    [ValidateSet("install", "update", "uninstall")]
    [string]$Action = "install"
)

$ScriptUrl = "https://raw.githubusercontent.com/Karl0007/WishingFn/main/scripts/install-latest-windows.ps1"
$Script = Invoke-RestMethod -Uri $ScriptUrl -Headers @{ "User-Agent" = "WishingFn-Installer" }
$TempScript = Join-Path $env:TEMP ("wishingfn-install-" + [guid]::NewGuid() + ".ps1")
Set-Content -Path $TempScript -Value $Script -Encoding UTF8
try {
    powershell -ExecutionPolicy Bypass -File $TempScript -Action $Action
} finally {
    Remove-Item -Force $TempScript -ErrorAction SilentlyContinue
}
