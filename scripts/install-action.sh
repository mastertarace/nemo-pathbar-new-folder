#!/bin/bash
# Install the Nemo action "Nouveau dossier ici…" (no compilation, no sudo).
# It appears when right-clicking a folder in the file list or the sidebar tree,
# NOT in the pathbar (that requires the patch).
set -euo pipefail

REPO_DIR="$(cd "$(dirname "$0")/.." && pwd)"
DEST="$HOME/.local/share/nemo/actions"
mkdir -p "$DEST"
install -m644 "$REPO_DIR/nemo-action/nouveau-dossier.nemo_action" "$DEST/"
install -m755 "$REPO_DIR/nemo-action/nouveau-dossier.sh" "$DEST/"
echo ">> Action installed in $DEST"
