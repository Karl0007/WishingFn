$Action = if ($env:WISHINGFN_ACTION) { $env:WISHINGFN_ACTION } else { "install" }
$InstallDir = if ($env:WISHINGFN_INSTALL_DIR) { $env:WISHINGFN_INSTALL_DIR } else { Join-Path $env:LOCALAPPDATA "WishingFn" }
$Repository = if ($env:WISHINGFN_REPO) { $env:WISHINGFN_REPO } else { "Karl0007/WishingFn" }
$PurgeData = $env:WISHINGFN_PURGE_DATA -in @("1", "true", "TRUE", "yes", "YES")
$ErrorActionPreference = "Stop"

if ($Action -notin @("install", "update", "uninstall")) {
    throw "Unsupported WISHINGFN_ACTION: $Action"
}

function Stop-WishingFn {
    Get-Process | Where-Object { $_.ProcessName -like "kanata*" -or $_.ProcessName -eq "WishingFn" } | Stop-Process -Force -ErrorAction SilentlyContinue
}

function Remove-Autostart {
    $StartupFile = Join-Path $env:APPDATA "Microsoft\Windows\Start Menu\Programs\Startup\WishingFn.cmd"
    Remove-Item -Force $StartupFile -ErrorAction SilentlyContinue
    $PreviousPreference = $ErrorActionPreference
    $ErrorActionPreference = "Continue"
    cmd /c "schtasks /Delete /TN WishingFn /F >nul 2>nul" | Out-Null
    $ErrorActionPreference = $PreviousPreference
}

function Get-LatestReleaseAssetUrl {
    param([string]$Repository)

    return "https://github.com/$Repository/releases/latest/download/WishingFn-windows-x64.zip"
}

function Install-Or-Update {
    param([string]$InstallDir, [string]$Repository, [string]$Verb)

    $TempRoot = Join-Path $env:TEMP ("WishingFnInstall-" + [guid]::NewGuid())
    $ZipPath = Join-Path $TempRoot "WishingFn.zip"
    $ExtractDir = Join-Path $TempRoot "package"

    New-Item -ItemType Directory -Force $TempRoot | Out-Null
    try {
        Write-Host "Downloading latest WishingFn release..."
        $AssetUrl = Get-LatestReleaseAssetUrl -Repository $Repository
        Invoke-WebRequest -Uri $AssetUrl -OutFile $ZipPath

        Write-Host "Extracting package..."
        Expand-Archive -Force $ZipPath $ExtractDir
        $PackageDir = Get-ChildItem $ExtractDir -Directory | Where-Object { Test-Path (Join-Path $_.FullName "WishingFn.exe") } | Select-Object -First 1
        if (-not $PackageDir) {
            if (Test-Path (Join-Path $ExtractDir "WishingFn.exe")) {
                $PackageDir = Get-Item $ExtractDir
            } else {
                throw "Extracted package does not contain WishingFn.exe"
            }
        }

        Write-Host "$Verb WishingFn to $InstallDir..."
        Stop-WishingFn
        New-Item -ItemType Directory -Force $InstallDir | Out-Null
        Copy-Item -Recurse -Force (Join-Path $PackageDir.FullName "*") $InstallDir

        $Exe = Join-Path $InstallDir "WishingFn.exe"
        Write-Host "Registering autostart..."
        & $Exe install-autostart

        Write-Host "Starting WishingFn..."
        Start-Process -FilePath $Exe -ArgumentList "run-kanata" -WorkingDirectory $InstallDir | Out-Null

        $Done = if ($Action -eq "update") { "updated" } else { "installed" }
        Write-Host "WishingFn $Done and started."
        Write-Host "Installed path: $InstallDir"
    } finally {
        Remove-Item -Recurse -Force $TempRoot -ErrorAction SilentlyContinue
    }
}

if ($Action -eq "uninstall") {
    Write-Host "Uninstalling WishingFn..."
    Stop-WishingFn
    Remove-Autostart
    Remove-Item -Recurse -Force $InstallDir -ErrorAction SilentlyContinue
    if ($PurgeData) {
        $DataDir = Join-Path $env:APPDATA "WishingFn"
        Remove-Item -Recurse -Force $DataDir -ErrorAction SilentlyContinue
        Write-Host "Removed WishingFn user data from $DataDir"
    }
    Write-Host "WishingFn uninstalled from $InstallDir"
    exit 0
}

$Verb = if ($Action -eq "update") { "Updating" } else { "Installing" }
Install-Or-Update -InstallDir $InstallDir -Repository $Repository -Verb $Verb

