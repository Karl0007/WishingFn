# WishingFn Agent Notes

This file is for coding agents and maintainers. Human-facing usage lives in `README.md` and `README.en.md`.

## Architecture

WishingFn is split into two layers:

- Kanata keyboard layer: `config/wishingfn.kbd`
- Python feature layer: `wishingfn/cli.py`

The Windows release package bundles Kanata at `vendor/kanata/kanata.exe`; users do not need to install Kanata separately.

## Python Commands

```powershell
python -m wishingfn add-clipboard
python -m wishingfn open-clipboard
python -m wishingfn menu
python -m wishingfn run-kanata
python -m wishingfn install-autostart
python -m wishingfn uninstall-autostart
```

`add-clipboard` and `open-clipboard` actually prefer selected text first. They temporarily send copy, read the selection, restore the previous clipboard when possible, and fall back to clipboard if no selection is found.

## Data

Favorites are stored as JSON:

- Windows: `%APPDATA%\WishingFn\favorites.json`
- macOS: `~/Library/Application Support/WishingFn/favorites.json`
- Linux: `$XDG_CONFIG_HOME/wishingfn/favorites.json` or `~/.config/wishingfn/favorites.json`

Each favorite has:

```json
{
  "kind": "path | url | command",
  "value": "...",
  "label": "..."
}
```

## Build Windows Package

```powershell
.\scripts\build-windows.ps1 -Version 0.1.0
```

Outputs:

```text
dist\WishingFn\
dist\WishingFn-windows-x64-0.1.0.zip
```

## Local Windows Install From Built Package

```powershell
.\scripts\install-windows.ps1
```

This copies the built package to `%LOCALAPPDATA%\WishingFn`, registers autostart, and prints the manual start command.

## Remote Windows Install / Update / Uninstall

Wrapper:

```powershell
irm https://raw.githubusercontent.com/Karl0007/WishingFn/main/install.ps1 | iex
irm https://raw.githubusercontent.com/Karl0007/WishingFn/main/update.ps1 | iex
irm https://raw.githubusercontent.com/Karl0007/WishingFn/main/uninstall.ps1 | iex
```

Implementation: `scripts/install-latest-windows.ps1`.

The installer downloads the latest GitHub Release asset matching `WishingFn-windows-x64-*.zip`.

## macOS / Linux Status

`install.sh` defines the intended command shape, but release artifacts are not implemented yet:

```bash
curl -fsSL https://raw.githubusercontent.com/Karl0007/WishingFn/main/install.sh | bash
curl -fsSL https://raw.githubusercontent.com/Karl0007/WishingFn/main/install.sh | bash -s -- update
curl -fsSL https://raw.githubusercontent.com/Karl0007/WishingFn/main/install.sh | bash -s -- uninstall
```

To complete macOS/Linux packages, add platform-specific Kanata binaries under `vendor/kanata/kanata`, build with PyInstaller/codesign equivalents, and extend `.github/workflows/release.yml` with Linux/macOS jobs.

## GitHub Release

Push a tag to publish the Windows zip:

```powershell
git tag v0.1.0
git push origin v0.1.0
```

Workflow: `.github/workflows/release.yml`.

## Verification Checklist

```powershell
python -m py_compile wishingfn\__init__.py wishingfn\__main__.py wishingfn\cli.py scripts\wishingfn_entry.py
.\scripts\build-windows.ps1 -Version dev
dist\WishingFn\WishingFn.exe --help
```

Kanata config smoke test:

```powershell
$p = Start-Process -FilePath dist\WishingFn\WishingFn.exe -ArgumentList run-kanata -WorkingDirectory dist\WishingFn -PassThru -RedirectStandardOutput kanata.out -RedirectStandardError kanata.err
Start-Sleep -Seconds 3
Stop-Process -Id $p.Id -Force
Get-Content kanata.out
```

Expected evidence includes `config file is valid` and `entering the processing loop`.
