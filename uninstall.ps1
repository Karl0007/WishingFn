$env:WISHINGFN_ACTION = "uninstall"
$ScriptUrl = "https://raw.githubusercontent.com/Karl0007/WishingFn/main/scripts/install-latest-windows.ps1"
$Script = Invoke-RestMethod -Uri $ScriptUrl -Headers @{ "User-Agent" = "WishingFn-Installer" }
$Script = $Script.TrimStart([char]0xFEFF)
$TempScript = Join-Path $env:TEMP ("wishingfn-uninstall-" + [guid]::NewGuid() + ".ps1")
Set-Content -Path $TempScript -Value $Script -Encoding UTF8
try {
    powershell -NoProfile -ExecutionPolicy Bypass -File $TempScript
} finally {
    Remove-Item -Force $TempScript -ErrorAction SilentlyContinue
    Remove-Item Env:\WISHINGFN_ACTION -ErrorAction SilentlyContinue
}

