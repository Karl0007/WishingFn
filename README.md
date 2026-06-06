# WishingFn

WishingFn is a lightweight cross-platform rewrite of `MagicFn3.ahk` built around:

- **Kanata** for the CapsLock-based keyboard layer
- **Python** for clipboard opening, favorites, and command launching

## Hotkeys

Default Kanata layer:

| Hotkey | Action |
| --- | --- |
| `CapsLock` tap | Toggle CapsLock |
| `CapsLock + w/a/s/d` | Arrow keys |
| `CapsLock + q/e` | Home / End |
| `CapsLock + f` | Delete |
| `CapsLock + Backspace` | Delete |
| `CapsLock + 1..0,-,=` | F1..F12 |
| `CapsLock + u/Space/o` | Left click / Left click / Right click |
| `CapsLock + i/j/k/l` | Mouse wheel up/left/down/right placeholder |
| `CapsLock + c` | Favorite current clipboard text |
| `CapsLock + v` | Open current clipboard path, or run clipboard command |
| `CapsLock + x` | Open favorites panel |

## Favorite types

Clipboard text is saved as either:

- `path`: if it looks like an existing or path-like file/folder path
- `command`: anything else

Commands are launched through the system shell. Only favorite commands you trust.

Favorites are stored at:

- Windows: `%APPDATA%\WishingFn\favorites.json`
- macOS: `~/Library/Application Support/WishingFn/favorites.json`
- Linux: `$XDG_CONFIG_HOME/wishingfn/favorites.json` or `~/.config/wishingfn/favorites.json`

## Run locally

```powershell
python -m wishingfn add-clipboard
python -m wishingfn open-clipboard
python -m wishingfn menu
python -m wishingfn config-path
```

## Kanata

Install Kanata, then run this repository's config:

```powershell
kanata --cfg config\wishingfn.kbd
```

On macOS/Linux use:

```bash
kanata --cfg config/wishingfn.kbd
```

Kanata may require elevated permissions depending on OS and input backend.

## Packaging

A simple PyInstaller build can create a single-file `wishingfn` executable:

```powershell
python -m pip install pyinstaller
pyinstaller --onefile --name wishingfn -m wishingfn
```

After packaging, update `config/wishingfn.kbd` aliases from `python -m wishingfn ...` to `wishingfn ...`.

## Git remote

Target repository:

```text
git@github.com:Karl0007/WishingFn.git
```
