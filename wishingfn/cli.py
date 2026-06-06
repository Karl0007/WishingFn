import argparse
import json
import os
import platform
import shutil
import subprocess
import sys
from dataclasses import dataclass
from pathlib import Path

APP_NAME = "WishingFn"


@dataclass(frozen=True)
class Favorite:
    kind: str
    value: str
    label: str


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
    if looks_like_path(value):
        return "path"
    return "command"


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
    return value.splitlines()[0][:80]


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
    favorites.append(Favorite(kind=kind, value=value, label=default_label(kind, value)))
    save_favorites(favorites)
    notify("WishingFn", f"Favorited {kind}: {value}")
    return 0


def open_clipboard() -> int:
    value = read_clipboard()
    if not value:
        notify("WishingFn", "Clipboard is empty.")
        return 1
    return open_value(value, infer_kind(value))


def open_value(value: str, kind: str) -> int:
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
    from tkinter import Button, END, LEFT, RIGHT, SINGLE, BOTH, X, Y, Frame, Listbox, Scrollbar, Tk, messagebox

    favorites = load_favorites()
    root = Tk()
    root.title("WishingFn Favorites")
    root.geometry("760x420")

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

    def delete_selected(event=None) -> None:
        index = selected_index()
        if index is None:
            return
        favorite = favorites[index]
        if messagebox.askyesno("WishingFn", f"Delete favorite?\n\n{favorite.value}"):
            del favorites[index]
            save_favorites(favorites)
            refresh()

    buttons = Frame(root)
    buttons.pack(fill=X, padx=10, pady=(0, 10))
    Button(buttons, text="Open", command=open_selected).pack(side=LEFT, padx=(0, 8))
    Button(buttons, text="Delete", command=delete_selected).pack(side=LEFT, padx=(0, 8))
    Button(buttons, text="Close", command=root.destroy).pack(side=LEFT)

    listbox.bind("<Double-Button-1>", open_selected)
    listbox.bind("<Return>", open_selected)
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


def build_parser() -> argparse.ArgumentParser:
    parser = argparse.ArgumentParser(prog="wishingfn", description="Lightweight favorites and clipboard opener for MagicFn-style workflows.")
    subparsers = parser.add_subparsers(dest="command", required=True)
    subparsers.add_parser("add-clipboard", help="Favorite the current clipboard text as a path or command.")
    subparsers.add_parser("open-clipboard", help="Open the current clipboard path or run it as a command.")
    subparsers.add_parser("menu", help="Open the favorites panel.")
    subparsers.add_parser("config-path", help="Print the favorites file path.")
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
    except Exception as exc:
        notify("WishingFn", str(exc))
        return 1
    return 1
