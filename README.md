# WishingFn

WishingFn is a lightweight cross-platform rewrite of `MagicFn3.ahk` built around:

- **Kanata** for the CapsLock-based keyboard layer
- **Python** for clipboard opening, favorites, URLs, and command launching

The released Windows package bundles Kanata, so users do **not** need to install Kanata separately.

## Hotkeys

| Hotkey | Action |
| --- | --- |
| `CapsLock` tap | Toggle CapsLock |
| `CapsLock + w/a/s/d` | Arrow keys |
| `CapsLock + q/e` | Home / End |
| `CapsLock + f` | Delete |
| `CapsLock + Backspace` | Delete |
| `CapsLock + 1..0,-,=` | F1..F12 |
| `CapsLock + u/Space/o` | Left click / Left click / Right click |
| `CapsLock + i/j/k/l` | Mouse movement |
| `CapsLock + c` | Favorite current clipboard text |
| `CapsLock + v` | Open current clipboard path or URL, or run clipboard command |
| `CapsLock + x` | Open favorites panel |

## Favorites

Clipboard text is saved as one of:

- `path`: existing or path-like file/folder path
- `url`: `http://` or `https://` URL
- `command`: anything else

When adding a favorite, WishingFn asks for an alias/display name. In the favorites panel:

- Double-click or `Enter`: open selected favorite
- `F2`: rename alias
- `Delete`: delete selected favorite

Commands are launched through the system shell. Only favorite commands you trust.

Favorites are stored at:

- Windows: `%APPDATA%\WishingFn\favorites.json`
- macOS: `~/Library/Application Support/WishingFn/favorites.json`
- Linux: `$XDG_CONFIG_HOME/wishingfn/favorites.json` or `~/.config/wishingfn/favorites.json`

## Run from source

```powershell
python -m wishingfn add-clipboard
python -m wishingfn open-clipboard
python -m wishingfn menu
python -m wishingfn run-kanata
```

`run-kanata` expects a bundled Kanata binary at `vendor/kanata/kanata.exe` on Windows or `vendor/kanata/kanata` on macOS/Linux.

## Windows package

Build locally:

```powershell
.\scripts\build-windows.ps1 -Version 0.1.0
```

Install from an extracted package or from `dist\WishingFn` after building:

```powershell
.\scripts\install-windows.ps1
```

The installer copies WishingFn to `%LOCALAPPDATA%\WishingFn` and registers a Windows logon task:

```powershell
WishingFn.exe install-autostart
```

Remove autostart:

```powershell
WishingFn.exe uninstall-autostart
```

Start manually:

```powershell
WishingFn.exe run-kanata
```

Kanata may still need elevated permissions depending on Windows input backend and system policy.

## GitHub release

GitHub Actions builds the Windows package automatically when pushing a tag:

```powershell
git tag v0.1.0
git push origin v0.1.0
```

The workflow uploads `WishingFn-windows-x64-<tag>.zip` to the GitHub Release.

## Target repository

```text
git@github.com:Karl0007/WishingFn.git
```
