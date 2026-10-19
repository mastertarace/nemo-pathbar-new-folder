#!/bin/bash
# Build Nemo with the pathbar "Create New Folder" patch.
# Usage: scripts/build.sh [--deps] [nemo-version]
#   --deps        install build dependencies with apt (needs sudo)
#   nemo-version  upstream tag to build (default: installed Nemo version)
set -euo pipefail

REPO_DIR="$(cd "$(dirname "$0")/.." && pwd)"
PATCH="$REPO_DIR/patches/nemo-6.6.3-pathbar-new-folder.patch"
WORK="$REPO_DIR/work"

if [ "${1:-}" = "--deps" ]; then
  shift
  sudo apt install -y git meson ninja-build intltool itstool gobject-introspection \
    libgirepository1.0-dev libcinnamon-desktop-dev libexempi-dev libexif-dev \
    libgail-3-dev libglib2.0-dev libgsf-1-dev libgtk-3-dev libjson-glib-dev \
    libpango1.0-dev libxapp-dev libxext-dev libxrender-dev libx11-dev python3-gi
fi

VERSION="${1:-$(dpkg-query -W -f='${Version}' nemo | sed 's/[+~-].*//')}"
echo ">> Nemo version: $VERSION"

rm -rf "$WORK"
mkdir -p "$WORK"
git clone -q --depth 1 --branch "$VERSION" https://github.com/linuxmint/nemo.git "$WORK/nemo"
cd "$WORK/nemo"

if ! git apply --check "$PATCH" 2>/dev/null; then
  echo "!! Patch does not apply cleanly on Nemo $VERSION (made for 6.6.3)." >&2
  exit 1
fi
git apply "$PATCH"

meson setup build --prefix=/usr -Dtracker=false
ninja -C build src/nemo

echo ">> Built: $WORK/nemo/build/src/nemo"
echo ">> Install with: sudo scripts/install.sh"
