#!/usr/bin/env bash
# uninstall.sh — remove dw's symlinks and config from this Mac.
#
# Leaves Homebrew dependencies (m1ddc, jq) in place — remove them with
# `brew uninstall m1ddc jq` if you want them gone.

set -euo pipefail

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BIN_SRC="$REPO_DIR/bin/dw"
LEGACY_BIN_SRC="$REPO_DIR/bin/desk-switch"
CONFIG_DIR="${XDG_CONFIG_HOME:-$HOME/.config}/dw"
LEGACY_CONFIG_DIR="${XDG_CONFIG_HOME:-$HOME/.config}/desk-switch"

removed_any=0

for d in /opt/homebrew/bin "$HOME/bin" "$HOME/.local/bin" /usr/local/bin; do
  for name in dw desk-switch; do
    link="$d/$name"
    if [ -L "$link" ]; then
      target="$(readlink "$link")"
      if [ "$target" = "$BIN_SRC" ] || [ "$target" = "$LEGACY_BIN_SRC" ]; then
        rm "$link"
        echo "removed symlink: $link"
        removed_any=1
      fi
    fi
  done
done

for cfg in "$CONFIG_DIR" "$LEGACY_CONFIG_DIR"; do
  if [ -d "$cfg" ]; then
    rm -rf "$cfg"
    echo "removed config:  $cfg"
    removed_any=1
  fi
done

if [ "$removed_any" -eq 0 ]; then
  echo "nothing to remove."
else
  echo ""
  echo "done. m1ddc and jq are still installed via Homebrew. Remove with:"
  echo "  brew uninstall m1ddc jq"
fi
