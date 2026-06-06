param(
    [string]$InstallDir = "$env:LOCALAPPDATA\WishingFn",
    [string]$Repository = "Karl0007/WishingFn"
)

$ErrorActionPreference = "Stop"

function Get-LatestReleaseAssetUrl {
    param([string]$Repository)

    $ApiUrl = "https://api.github.com/repos/$Repository/releases/latest"
    $Headers = @{ "User-Agent" = "WishingFn-Installer" }
    $Release = Invoke-RestMethod -Uri $ApiUrl -Headers $Headers
    $Asset = $Release.assets | Where-Object { $_.name -like "WishingFn-windows-x64-*.zip" } | Select-Object -First 1
    if (-not $Asset) {
        throw "No WishingFn Windows zip asset found in latest release: $($Release.tag_name)"
    }
    return $Asset.browser_download_url
}

function Stop-WishingFn {
    Get-Process | Where-Object { $_.ProcessName -like "kanata*" -or $_.ProcessName -eq "WishingFn" } | Stop-Process -Force -ErrorAction SilentlyContinue
}

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

    Write-Host "Installing to $InstallDir..."
    Stop-WishingFn
    New-Item -ItemType Directory -Force $InstallDir | Out-Null
    Copy-Item -Recurse -Force (Join-Path $PackageDir.FullName "*") $InstallDir

    $Exe = Join-Path $InstallDir "WishingFn.exe"
    Write-Host "Registering autostart..."
    & $Exe install-autostart

    Write-Host "Starting WishingFn..."
    Start-Process -FilePath $Exe -ArgumentList "run-kanata" -WorkingDirectory $InstallDir | Out-Null

    Write-Host "WishingFn installed and started."
    Write-Host "Installed path: $InstallDir"
} finally {
    Remove-Item -Recurse -Force $TempRoot -ErrorAction SilentlyContinue
}
