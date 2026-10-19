#!/bin/bash
# Replace /usr/bin/nemo with the patched binary, keeping the original
# as /usr/bin/nemo.distrib (dpkg-divert), then restart Nemo.
# Usage: sudo scripts/install.sh [path/to/nemo]
set -euo pipefail

REPO_DIR="$(cd "$(dirname "$0")/.." && pwd)"
BIN="${1:-$REPO_DIR/work/nemo/build/src/nemo}"

[ "$(id -u)" = 0 ] || { echo "Run with sudo." >&2; exit 1; }
[ -x "$BIN" ] || { echo "Binary not found: $BIN (run scripts/build.sh first)" >&2; exit 1; }

if ! dpkg-divert --list /usr/bin/nemo | grep -q nemo.distrib; then
  dpkg-divert --local --rename --add /usr/bin/nemo
fi
install -m755 "$BIN" /usr/bin/nemo
echo ">> Installed. Original kept as /usr/bin/nemo.distrib"
echo ">> Restart Nemo: nemo -q && nemo &"
