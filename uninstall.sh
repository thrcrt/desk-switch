#!/usr/bin/env bash
# uninstall.sh — remove dw's symlinks, config, and generated files.
# Leaves Homebrew deps (m1ddc, jq) in place; remove with `brew uninstall m1ddc jq`.

set -euo pipefail

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BIN_SRC="$REPO_DIR/bin/dw"
CONFIG_DIR="${XDG_CONFIG_HOME:-$HOME/.config}/dw"
RAYCAST_DIR="$HOME/Documents/dw/raycast"
DW_DOCS_DIR="$HOME/Documents/dw"

removed_any=0

for d in /opt/homebrew/bin "$HOME/bin" "$HOME/.local/bin" /usr/local/bin; do
  link="$d/dw"
  if [ -L "$link" ] && [ "$(readlink "$link")" = "$BIN_SRC" ]; then
    rm "$link"
    echo "removed symlink: $link"
    removed_any=1
  fi
done

if [ -d "$CONFIG_DIR" ]; then
  rm -rf "$CONFIG_DIR"
  echo "removed config:  $CONFIG_DIR"
  removed_any=1
fi

if [ -d "$RAYCAST_DIR" ]; then
  rm -rf "$RAYCAST_DIR"
  rmdir "$DW_DOCS_DIR" 2>/dev/null || true
  echo "removed raycast: $RAYCAST_DIR"
  removed_any=1
fi

if [ "$removed_any" -eq 0 ]; then
  echo "nothing to remove."
else
  echo ""
  echo "done. m1ddc and jq are still installed via Homebrew. Remove with:"
  echo "  brew uninstall m1ddc jq"
fi
