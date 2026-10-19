#!/bin/bash
# Restore the original Nemo binary from the distribution package.
# Usage: sudo scripts/uninstall.sh
set -euo pipefail

[ "$(id -u)" = 0 ] || { echo "Run with sudo." >&2; exit 1; }

rm -f /usr/bin/nemo
dpkg-divert --rename --remove /usr/bin/nemo
echo ">> Original Nemo restored. Restart Nemo: nemo -q && nemo &"
