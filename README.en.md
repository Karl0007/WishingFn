# WishingFn

[中文](README.md) · [Agent Notes](AGENTS.md)

A lightweight, packageable CapsLock function-layer tool. WishingFn uses Kanata for the keyboard layer and Python for favorites, path/URL opening, and command launching.

> The Windows package bundles Kanata; users do not need to install Kanata separately.

## Features

- CapsLock function layer: arrows, Home/End, Delete, F1-F12, mouse movement, and mouse clicks.
- Selection-first actions: favorite/open selected text first, then fall back to clipboard.
- Smart favorites: paths, URLs, and commands are detected automatically.
- Favorites panel: open, rename aliases, and delete entries.
- One-command Windows install: install, update, and uninstall through remote scripts.
- GitHub Releases: pushing a tag builds Windows/macOS/Linux packages automatically.

## Installation

### Windows

Install, create a user Startup-folder autostart shortcut, and start immediately:

```powershell
irm https://raw.githubusercontent.com/Karl0007/WishingFn/main/scripts/install/install.ps1 | iex
```

Update:

```powershell
irm https://raw.githubusercontent.com/Karl0007/WishingFn/main/scripts/install/update.ps1 | iex
```

Uninstall and remove autostart while keeping favorites data:

```powershell
irm https://raw.githubusercontent.com/Karl0007/WishingFn/main/scripts/install/uninstall.ps1 | iex
```

Purge uninstall, including favorites data:

```powershell
$env:WISHINGFN_PURGE_DATA="1"; irm https://raw.githubusercontent.com/Karl0007/WishingFn/main/scripts/install/uninstall.ps1 | iex
```

Default install location:

```text
%LOCALAPPDATA%\WishingFn
```

### macOS / Linux

Installer entrypoints are implemented; platform permissions still need real-device verification: macOS needs Accessibility permissions, and Linux may need uinput plus clipboard-tool permissions.

```bash
curl -fsSL https://raw.githubusercontent.com/Karl0007/WishingFn/main/scripts/install/install.sh | bash
curl -fsSL https://raw.githubusercontent.com/Karl0007/WishingFn/main/scripts/install/install.sh | bash -s -- update
curl -fsSL https://raw.githubusercontent.com/Karl0007/WishingFn/main/scripts/install/install.sh | bash -s -- uninstall
```

## Hotkeys

| Hotkey | Action |
| --- | --- |
| Tap `CapsLock` | Toggle CapsLock |
| `CapsLock + w/a/s/d` | Up / Left / Down / Right |
| `CapsLock + q/e` | Home / End |
| `CapsLock + f` | Delete |
| `CapsLock + Backspace` | Delete |
| `CapsLock + 1..0,-,=` | F1..F12 |
| `CapsLock + u/Space/o` | Left click / Left click / Right click |
| `CapsLock + i/j/k/l` | Mouse movement |
| `CapsLock + c` | Favorite selected text; falls back to clipboard |
| `CapsLock + v` | Open selected text; falls back to clipboard |
| `CapsLock + x` | Open favorites panel |

## Favorites

WishingFn recognizes:

- paths: files or folders
- URLs: `http://` or `https://`
- commands: anything else

When adding a favorite, WishingFn asks for an alias. In the favorites panel:

- Double-click / `Enter`: open
- `F2`: rename alias
- `Delete`: delete

> Commands run through the system shell. Only favorite commands you trust.

## Development

Implementation, packaging, release, and agent workflow details live in [AGENTS.md](AGENTS.md).
