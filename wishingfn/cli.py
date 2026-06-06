import argparse
import json
import os
import platform
import shutil
import subprocess
import sys
import webbrowser
from dataclasses import dataclass
from pathlib import Path
from urllib.parse import urlparse

APP_NAME = "WishingFn"


@dataclass(frozen=True)
class Favorite:
    kind: str
    value: str
    label: str


def app_root() -> Path:
    if getattr(sys, "frozen", False):
        return Path(sys.executable).resolve().parent
    return Path(__file__).resolve().parents[1]


def resource_root() -> Path:
    if getattr(sys, "frozen", False) and hasattr(sys, "_MEIPASS"):
        return Path(sys._MEIPASS)
    return app_root()


def bundled_kanata() -> Path:
    name = "kanata.exe" if platform.system() == "Windows" else "kanata"
    roots = [app_root(), resource_root()]
    for root in roots:
        candidate = root / "vendor" / "kanata" / name
        if candidate.exists():
            return candidate
    return roots[-1] / "vendor" / "kanata" / name


def bundled_config() -> Path:
    roots = [app_root(), resource_root()]
    for root in roots:
        candidate = root / "config" / "wishingfn.kbd"
        if candidate.exists():
            return candidate
    return roots[-1] / "config" / "wishingfn.kbd"


def config_dir() -> Path:
    system = platform.system()
    if system == "Windows":
        base = Path(os.environ.get("APPDATA", Path.home() / "AppData" / "Roaming"))
        return base / APP_NAME
    if system == "Darwin":
        return Path.home() / "Library" / "Application Support" / APP_NAME
    return Path(os.environ.get("XDG_CONFIG_HOME", Path.home() / ".config")) / APP_NAME.lower()


def data_file() -> Path:
    return config_dir() / "favorites.json"


def normalize_clipboard_text(text: str) -> str:
    text = text.strip().strip("\ufeff")
    if (text.startswith('"') and text.endswith('"')) or (text.startswith("'") and text.endswith("'")):
        text = text[1:-1].strip()
    return text


def read_clipboard() -> str:
    system = platform.system()
    if system == "Windows":
        try:
            from tkinter import Tk

            root = Tk()
            root.withdraw()
            text = root.clipboard_get()
            root.destroy()
            return normalize_clipboard_text(text)
        except Exception as exc:
            raise RuntimeError(f"Unable to read clipboard: {exc}") from exc

    candidates = []
    if system == "Darwin":
        candidates = [["pbpaste"]]
    else:
        candidates = [["wl-paste", "-n"], ["xclip", "-selection", "clipboard", "-o"], ["xsel", "--clipboard", "--output"]]

    for command in candidates:
        if shutil.which(command[0]):
            completed = subprocess.run(command, check=False, text=True, stdout=subprocess.PIPE, stderr=subprocess.PIPE)
            if completed.returncode == 0:
                return normalize_clipboard_text(completed.stdout)
    raise RuntimeError("No supported clipboard command found.")


def infer_kind(value: str) -> str:
    if looks_like_url(value):
        return "url"
    if looks_like_path(value):
        return "path"
    return "command"


def looks_like_url(value: str) -> bool:
    parsed = urlparse(value)
    return parsed.scheme in {"http", "https"} and bool(parsed.netloc)


def looks_like_path(value: str) -> bool:
    if not value:
        return False
    expanded = expand_path(value)
    if expanded.exists():
        return True
    if value.startswith(("~/", "./", "../", "/")):
        return True
    if len(value) >= 3 and value[1:3] in (":\\", ":/"):
        return True
    return False


def expand_path(value: str) -> Path:
    return Path(os.path.expandvars(os.path.expanduser(value)))


def load_favorites() -> list[Favorite]:
    path = data_file()
    if not path.exists():
        return []
    raw = json.loads(path.read_text(encoding="utf-8"))
    favorites = []
    for item in raw:
        value = str(item.get("value", "")).strip()
        if not value:
            continue
        kind = item.get("kind") or infer_kind(value)
        label = item.get("label") or default_label(kind, value)
        favorites.append(Favorite(kind=kind, value=value, label=label))
    return favorites


def save_favorites(favorites: list[Favorite]) -> None:
    path = data_file()
    path.parent.mkdir(parents=True, exist_ok=True)
    raw = [favorite.__dict__ for favorite in favorites]
    path.write_text(json.dumps(raw, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")


def default_label(kind: str, value: str) -> str:
    if kind == "path":
        name = expand_path(value).name
        return name or value
    if kind == "url":
        parsed = urlparse(value)
        return parsed.netloc or value
    return value.splitlines()[0][:80]


def ask_label(default: str) -> str:
    try:
        from tkinter import Tk, simpledialog

        root = Tk()
        root.withdraw()
        label = simpledialog.askstring("WishingFn", "Alias / display name:", initialvalue=default)
        root.destroy()
        return (label or default).strip()
    except Exception:
        return default


def add_clipboard() -> int:
    value = read_clipboard()
    if not value:
        notify("WishingFn", "Clipboard is empty.")
        return 1
    kind = infer_kind(value)
    favorites = load_favorites()
    if any(favorite.value == value for favorite in favorites):
        notify("WishingFn", "Already favorited.")
        return 0
    label = ask_label(default_label(kind, value))
    favorites.append(Favorite(kind=kind, value=value, label=label))
    save_favorites(favorites)
    notify("WishingFn", f"Favorited {kind}: {label}")
    return 0


def open_clipboard() -> int:
    value = read_clipboard()
    if not value:
        notify("WishingFn", "Clipboard is empty.")
        return 1
    return open_value(value, infer_kind(value))


def open_value(value: str, kind: str) -> int:
    if kind == "url":
        webbrowser.open(value)
        return 0
    if kind == "path":
        path = expand_path(value)
        if not path.exists():
            notify("WishingFn", f"Path does not exist: {value}")
            return 1
        open_path(path)
        return 0
    return run_command(value)


def open_path(path: Path) -> None:
    system = platform.system()
    if system == "Windows":
        os.startfile(str(path))  # type: ignore[attr-defined]
    elif system == "Darwin":
        subprocess.Popen(["open", str(path)])
    else:
        subprocess.Popen(["xdg-open", str(path)])


def run_command(command: str) -> int:
    if platform.system() == "Windows":
        subprocess.Popen(command, shell=True, creationflags=subprocess.CREATE_NEW_CONSOLE)
    else:
        subprocess.Popen(command, shell=True, start_new_session=True)
    return 0


def menu() -> int:
    from tkinter import Button, END, LEFT, RIGHT, SINGLE, BOTH, X, Y, Frame, Listbox, Scrollbar, Tk, messagebox, simpledialog

    favorites = load_favorites()
    root = Tk()
    root.title("WishingFn Favorites")
    root.geometry("820x460")

    frame = Frame(root)
    frame.pack(fill=BOTH, expand=True, padx=10, pady=10)

    scrollbar = Scrollbar(frame)
    scrollbar.pack(side=RIGHT, fill=Y)

    listbox = Listbox(frame, selectmode=SINGLE, yscrollcommand=scrollbar.set)
    listbox.pack(side=LEFT, fill=BOTH, expand=True)
    scrollbar.config(command=listbox.yview)

    def refresh() -> None:
        listbox.delete(0, END)
        for favorite in favorites:
            listbox.insert(END, f"[{favorite.kind}] {favorite.label}    {favorite.value}")

    def selected_index() -> int | None:
        selection = listbox.curselection()
        if not selection:
            return None
        return int(selection[0])

    def open_selected(event=None) -> None:
        index = selected_index()
        if index is None:
            return
        favorite = favorites[index]
        if open_value(favorite.value, favorite.kind) == 0:
            root.destroy()

    def rename_selected(event=None) -> None:
        index = selected_index()
        if index is None:
            return
        favorite = favorites[index]
        label = simpledialog.askstring("WishingFn", "Alias / display name:", initialvalue=favorite.label, parent=root)
        if not label:
            return
        favorites[index] = Favorite(kind=favorite.kind, value=favorite.value, label=label.strip())
        save_favorites(favorites)
        refresh()
        listbox.selection_set(index)

    def delete_selected(event=None) -> None:
        index = selected_index()
        if index is None:
            return
        favorite = favorites[index]
        if messagebox.askyesno("WishingFn", f"Delete favorite?\n\n{favorite.label}\n{favorite.value}"):
            del favorites[index]
            save_favorites(favorites)
            refresh()

    buttons = Frame(root)
    buttons.pack(fill=X, padx=10, pady=(0, 10))
    Button(buttons, text="Open", command=open_selected).pack(side=LEFT, padx=(0, 8))
    Button(buttons, text="Rename", command=rename_selected).pack(side=LEFT, padx=(0, 8))
    Button(buttons, text="Delete", command=delete_selected).pack(side=LEFT, padx=(0, 8))
    Button(buttons, text="Close", command=root.destroy).pack(side=LEFT)

    listbox.bind("<Double-Button-1>", open_selected)
    listbox.bind("<Return>", open_selected)
    listbox.bind("<F2>", rename_selected)
    listbox.bind("<Delete>", delete_selected)
    refresh()
    if favorites:
        listbox.selection_set(0)
    root.mainloop()
    return 0


def notify(title: str, message: str) -> None:
    try:
        from tkinter import Tk, messagebox

        root = Tk()
        root.withdraw()
        messagebox.showinfo(title, message)
        root.destroy()
    except Exception:
        print(f"{title}: {message}", file=sys.stderr)


def print_config_path() -> int:
    print(data_file())
    return 0


def run_kanata() -> int:
    kanata = bundled_kanata()
    config = bundled_config()
    if not kanata.exists():
        raise RuntimeError(f"Bundled Kanata not found: {kanata}")
    if not config.exists():
        raise RuntimeError(f"Kanata config not found: {config}")
    env = os.environ.copy()
    env["PATH"] = str(app_root()) + os.pathsep + env.get("PATH", "")
    return subprocess.call([str(kanata), "--cfg", str(config)], env=env)


def install_autostart() -> int:
    system = platform.system()
    if system != "Windows":
        notify("WishingFn", "Autostart installer currently supports Windows. Use the README commands for macOS/Linux.")
        return 1
    exe = Path(sys.executable).resolve() if getattr(sys, "frozen", False) else Path(sys.argv[0]).resolve()
    command = f'"{exe}" run-kanata'
    subprocess.run([
        "schtasks",
        "/Create",
        "/TN",
        "WishingFn",
        "/TR",
        command,
        "/SC",
        "ONLOGON",
        "/RL",
        "HIGHEST",
        "/F",
    ], check=True)
    notify("WishingFn", "Installed Windows autostart task: WishingFn")
    return 0


def uninstall_autostart() -> int:
    if platform.system() != "Windows":
        return 1
    subprocess.run(["schtasks", "/Delete", "/TN", "WishingFn", "/F"], check=False)
    notify("WishingFn", "Removed Windows autostart task: WishingFn")
    return 0


def build_parser() -> argparse.ArgumentParser:
    parser = argparse.ArgumentParser(prog="wishingfn", description="Lightweight favorites and clipboard opener for MagicFn-style workflows.")
    subparsers = parser.add_subparsers(dest="command", required=True)
    subparsers.add_parser("add-clipboard", help="Favorite the current clipboard text as a path, URL, or command.")
    subparsers.add_parser("open-clipboard", help="Open the current clipboard path/URL, or run it as a command.")
    subparsers.add_parser("menu", help="Open the favorites panel.")
    subparsers.add_parser("config-path", help="Print the favorites file path.")
    subparsers.add_parser("run-kanata", help="Run bundled Kanata with WishingFn config.")
    subparsers.add_parser("install-autostart", help="Install WishingFn as a Windows logon task.")
    subparsers.add_parser("uninstall-autostart", help="Remove the Windows logon task.")
    return parser


def main(argv: list[str] | None = None) -> int:
    args = build_parser().parse_args(argv)
    try:
        if args.command == "add-clipboard":
            return add_clipboard()
        if args.command == "open-clipboard":
            return open_clipboard()
        if args.command == "menu":
            return menu()
        if args.command == "config-path":
            return print_config_path()
        if args.command == "run-kanata":
            return run_kanata()
        if args.command == "install-autostart":
            return install_autostart()
        if args.command == "uninstall-autostart":
            return uninstall_autostart()
    except Exception as exc:
        notify("WishingFn", str(exc))
        return 1
    return 1


