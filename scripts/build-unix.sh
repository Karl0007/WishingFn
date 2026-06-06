#!/usr/bin/env bash
set -euo pipefail

VERSION="${1:-0.1.0}"
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT"

python3 -m pip install --upgrade pip pyinstaller
rm -rf dist build WishingFn.spec

pyinstaller --noconfirm --onedir --name WishingFn --paths "$ROOT" --hidden-import wishingfn.cli --add-data "config:config" --add-data "vendor:vendor" scripts/wishingfn_entry.py

PACKAGE_DIR="$ROOT/dist/WishingFn"
cp README.md README.en.md AGENTS.md "$PACKAGE_DIR/"
cat > "$PACKAGE_DIR/wishingfn" <<'SH'
#!/usr/bin/env bash
DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
exec "$DIR/WishingFn" "$@"
SH
chmod +x "$PACKAGE_DIR/wishingfn"

OS="$(uname -s)"
ARCH="$(uname -m)"
case "$OS-$ARCH" in
  Darwin-arm64) ASSET="WishingFn-macos-arm64" ;;
  Darwin-x86_64) ASSET="WishingFn-macos-x64" ;;
  Linux-x86_64) ASSET="WishingFn-linux-x64" ;;
  Linux-aarch64|Linux-arm64) ASSET="WishingFn-linux-arm64" ;;
  *) echo "Unsupported platform: $OS-$ARCH" >&2; exit 1 ;;
esac

tar -C "$ROOT/dist" -czf "$ROOT/dist/$ASSET-$VERSION.tar.gz" WishingFn
cp "$ROOT/dist/$ASSET-$VERSION.tar.gz" "$ROOT/dist/$ASSET.tar.gz"
echo "Built dist/$ASSET-$VERSION.tar.gz"
echo "Built dist/$ASSET.tar.gz"
