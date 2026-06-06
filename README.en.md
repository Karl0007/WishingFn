# WishingFn

WishingFn is a lightweight CapsLock enhancement tool. It uses `CapsLock` as a function layer for cursor/mouse control and for opening or favoriting selected text or clipboard content.

## For Humans

### Hotkeys

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

### Favorites

WishingFn recognizes:

- paths: files or folders
- URLs: `http://` or `https://`
- commands: anything else

When adding a favorite, WishingFn asks for an alias. In the favorites panel:

- Double-click / `Enter`: open
- `F2`: rename alias
- `Delete`: delete

Commands run through the system shell. Only favorite commands you trust.

### Windows Install

Install, enable autostart, and start immediately:

```powershell
irm https://raw.githubusercontent.com/Karl0007/WishingFn/main/install.ps1 | iex
```

Update:

```powershell
irm https://raw.githubusercontent.com/Karl0007/WishingFn/main/update.ps1 | iex
```

Uninstall and remove autostart:

```powershell
irm https://raw.githubusercontent.com/Karl0007/WishingFn/main/uninstall.ps1 | iex
```

Install location:

```text
%LOCALAPPDATA%\WishingFn
```

### macOS / Linux

Planned commands, pending published packages:

```bash
curl -fsSL https://raw.githubusercontent.com/Karl0007/WishingFn/main/install.sh | bash
curl -fsSL https://raw.githubusercontent.com/Karl0007/WishingFn/main/install.sh | bash -s -- update
curl -fsSL https://raw.githubusercontent.com/Karl0007/WishingFn/main/install.sh | bash -s -- uninstall
```

For now, use the source flow in `README-AGENT.md`.

## For Agents

Implementation, packaging, release, and source-run details live in `README-AGENT.md`.
