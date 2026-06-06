#!/usr/bin/env bash
set -euo pipefail

ACTION="${1:-install}"
INSTALL_DIR="${WISHINGFN_INSTALL_DIR:-$HOME/.local/share/wishingfn}"
BIN_DIR="${WISHINGFN_BIN_DIR:-$HOME/.local/bin}"
REPO="${WISHINGFN_REPO:-Karl0007/WishingFn}"
PURGE_DATA="${WISHINGFN_PURGE_DATA:-0}"

stop_wishingfn() {
  pkill -f "WishingFn.*run-kanata" 2>/dev/null || true
  pkill -f "wishingfn.*run-kanata" 2>/dev/null || true
  pkill -f "kanata" 2>/dev/null || true
}

platform_asset() {
  local os arch
  os="$(uname -s)"
  arch="$(uname -m)"
  case "$os-$arch" in
    Darwin-arm64) echo "WishingFn-macos-arm64.tar.gz" ;;
    Darwin-x86_64) echo "WishingFn-macos-x64.tar.gz" ;;
    Linux-x86_64) echo "WishingFn-linux-x64.tar.gz" ;;
    Linux-aarch64|Linux-arm64) echo "WishingFn-linux-arm64.tar.gz" ;;
    *) echo "Unsupported platform: $os-$arch" >&2; exit 1 ;;
  esac
}

remove_autostart() {
  if [[ "$(uname -s)" == "Darwin" ]]; then
    local plist="$HOME/Library/LaunchAgents/com.karl0007.wishingfn.plist"
    launchctl unload "$plist" 2>/dev/null || true
    rm -f "$plist"
  else
    systemctl --user disable --now wishingfn.service 2>/dev/null || true
    rm -f "${XDG_CONFIG_HOME:-$HOME/.config}/systemd/user/wishingfn.service"
    systemctl --user daemon-reload 2>/dev/null || true
  fi
}

remove_data() {
  if [[ "$PURGE_DATA" == "1" || "$PURGE_DATA" == "true" || "$PURGE_DATA" == "yes" ]]; then
    if [[ "$(uname -s)" == "Darwin" ]]; then
      rm -rf "$HOME/Library/Application Support/WishingFn"
    else
      rm -rf "${XDG_CONFIG_HOME:-$HOME/.config}/wishingfn"
    fi
  fi
}

uninstall_wishingfn() {
  stop_wishingfn
  remove_autostart
  rm -rf "$INSTALL_DIR"
  rm -f "$BIN_DIR/wishingfn"
  remove_data
  echo "WishingFn uninstalled."
}

if [[ "$ACTION" == "uninstall" ]]; then
  uninstall_wishingfn
  exit 0
fi

if [[ "$ACTION" != "install" && "$ACTION" != "update" ]]; then
  echo "Unsupported action: $ACTION" >&2
  exit 1
fi

ASSET="$(platform_asset)"
URL="https://github.com/$REPO/releases/latest/download/$ASSET"
TMP="$(mktemp -d)"
trap 'rm -rf "$TMP"' EXIT

echo "Downloading $URL"
curl -fL "$URL" -o "$TMP/wishingfn.tar.gz"
mkdir -p "$TMP/pkg"
tar -xzf "$TMP/wishingfn.tar.gz" -C "$TMP/pkg"

stop_wishingfn
rm -rf "$INSTALL_DIR"
mkdir -p "$(dirname "$INSTALL_DIR")" "$BIN_DIR"
cp -R "$TMP/pkg/WishingFn" "$INSTALL_DIR"
chmod +x "$INSTALL_DIR/WishingFn" "$INSTALL_DIR/wishingfn" 2>/dev/null || true
ln -sf "$INSTALL_DIR/wishingfn" "$BIN_DIR/wishingfn"

WISHINGFN_QUIET=1 "$INSTALL_DIR/wishingfn" install-autostart || true
nohup "$INSTALL_DIR/wishingfn" run-kanata >/tmp/wishingfn.out 2>/tmp/wishingfn.err &

echo "WishingFn $ACTION complete."
echo "Installed path: $INSTALL_DIR"
