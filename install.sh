#!/usr/bin/env bash
set -euo pipefail

ACTION="${1:-install}"
INSTALL_DIR="${WISHINGFN_INSTALL_DIR:-$HOME/.local/share/wishingfn}"
BIN_DIR="${WISHINGFN_BIN_DIR:-$HOME/.local/bin}"
REPO="${WISHINGFN_REPO:-Karl0007/WishingFn}"

stop_wishingfn() {
  pkill -f "WishingFn.*run-kanata" 2>/dev/null || true
  pkill -f "wishingfn.*run-kanata" 2>/dev/null || true
  pkill -f "kanata" 2>/dev/null || true
}

uninstall_wishingfn() {
  stop_wishingfn
  rm -rf "$INSTALL_DIR"
  rm -f "$BIN_DIR/wishingfn"
  rm -f "$HOME/.config/systemd/user/wishingfn.service"
  systemctl --user daemon-reload 2>/dev/null || true
  systemctl --user disable --now wishingfn.service 2>/dev/null || true
  rm -f "$HOME/Library/LaunchAgents/com.karl0007.wishingfn.plist"
  launchctl unload "$HOME/Library/LaunchAgents/com.karl0007.wishingfn.plist" 2>/dev/null || true
  echo "WishingFn uninstalled."
}

if [[ "$ACTION" == "uninstall" ]]; then
  uninstall_wishingfn
  exit 0
fi

OS="$(uname -s)"
ARCH="$(uname -m)"
case "$OS-$ARCH" in
  Darwin-arm64) ASSET="WishingFn-macos-arm64-*.tar.gz" ;;
  Darwin-x86_64) ASSET="WishingFn-macos-x64-*.tar.gz" ;;
  Linux-x86_64) ASSET="WishingFn-linux-x64-*.tar.gz" ;;
  Linux-aarch64|Linux-arm64) ASSET="WishingFn-linux-arm64-*.tar.gz" ;;
  *) echo "Unsupported platform: $OS-$ARCH" >&2; exit 1 ;;
esac

echo "WishingFn macOS/Linux packages are planned but not published yet."
echo "Expected release asset pattern: $ASSET"
echo "For now, use the source install flow in README-AGENT.md."
exit 1
