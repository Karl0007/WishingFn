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

This copies the built package to `%LOCALAPPDATA%\WishingFn`, creates a user Startup-folder autostart shortcut, and prints the manual start command.

## Remote Windows Install / Update / Uninstall

Wrapper:

```powershell
irm https://raw.githubusercontent.com/Karl0007/WishingFn/main/scripts/install/install.ps1 | iex
irm https://raw.githubusercontent.com/Karl0007/WishingFn/main/scripts/install/update.ps1 | iex
irm https://raw.githubusercontent.com/Karl0007/WishingFn/main/scripts/install/uninstall.ps1 | iex
$env:WISHINGFN_PURGE_DATA="1"; irm https://raw.githubusercontent.com/Karl0007/WishingFn/main/scripts/install/uninstall.ps1 | iex
```

Implementation: `scripts/install/install-latest-windows.ps1`.

The installer downloads `https://github.com/Karl0007/WishingFn/releases/latest/download/WishingFn-windows-x64.zip` directly to avoid GitHub API rate limits.

## macOS / Linux Status

`scripts/install/install.sh` downloads platform release assets; macOS/Linux runtime permissions and Kanata asset names still need real-device verification:

```bash
curl -fsSL https://raw.githubusercontent.com/Karl0007/WishingFn/main/scripts/install/install.sh | bash
curl -fsSL https://raw.githubusercontent.com/Karl0007/WishingFn/main/scripts/install/install.sh | bash -s -- update
curl -fsSL https://raw.githubusercontent.com/Karl0007/WishingFn/main/scripts/install/install.sh | bash -s -- uninstall
```

macOS/Linux packaging jobs are present in `.github/workflows/release.yml`; Kanata binary asset names and OS permissions should be verified on real machines.

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
