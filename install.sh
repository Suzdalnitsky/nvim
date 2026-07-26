#!/usr/bin/env bash
# Destructively installs this nvim config to ~/.config/nvim,
# replacing whatever is already there.
set -euo pipefail

SRC_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DEST_DIR="${XDG_CONFIG_HOME:-$HOME/.config}/nvim"

echo "Installing nvim config: $SRC_DIR/nvim -> $DEST_DIR"
rm -rf "$DEST_DIR"
mkdir -p "$(dirname "$DEST_DIR")"
cp -R "$SRC_DIR/nvim" "$DEST_DIR"

echo "Done."
