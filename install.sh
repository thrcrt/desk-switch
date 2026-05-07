#!/usr/bin/env bash
# install.sh — set up dw on this Mac.
#
# Idempotent: checks each step and skips work that's already done.
# Safe to re-run.

set -euo pipefail

err()  { printf 'install: %s\n' "$*" >&2; }
die()  { err "$*"; exit 1; }
info() { printf '%s\n' "$*"; }
ok()   { printf '✓ %s\n' "$*"; }

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BIN_SRC="$REPO_DIR/bin/dw"
LEGACY_BIN_SRC="$REPO_DIR/bin/desk-switch"

# --- preflight checks ---
[ "$(uname -s)" = "Darwin" ] || die "macOS only — got $(uname -s)"
[ "$(uname -m)" = "arm64" ]  || die "Apple Silicon required — got $(uname -m). m1ddc does not support Intel."
[ -f "$BIN_SRC" ] || die "missing $BIN_SRC — run this script from inside the repo."
chmod +x "$BIN_SRC"
ok "Apple Silicon macOS detected"

# --- Homebrew ---
if ! command -v brew >/dev/null 2>&1; then
  die "Homebrew is required. Install from https://brew.sh and re-run."
fi
ok "Homebrew: $(brew --version | head -1)"

# --- dependencies (idempotent) ---
for pkg in m1ddc jq; do
  if brew list --formula "$pkg" >/dev/null 2>&1; then
    ok "$pkg already installed"
  else
    info "Installing $pkg..."
    brew install "$pkg" >/dev/null
    ok "$pkg installed"
  fi
done

# --- migrate any legacy `desk-switch` symlinks pointing at this repo ---
for d in /opt/homebrew/bin "$HOME/bin" "$HOME/.local/bin" /usr/local/bin; do
  legacy="$d/desk-switch"
  if [ -L "$legacy" ]; then
    target="$(readlink "$legacy")"
    if [ "$target" = "$LEGACY_BIN_SRC" ] || [ "$target" = "$BIN_SRC" ]; then
      rm "$legacy"
      ok "removed legacy symlink: $legacy"
    fi
  fi
done

# --- if dw already resolves on PATH to our binary, we're done ---
existing="$(command -v dw 2>/dev/null || true)"
if [ -n "$existing" ] && [ "$(readlink "$existing" 2>/dev/null)" = "$BIN_SRC" ]; then
  ok "dw already on PATH: $existing"
  info ""
  info "Already installed. Next:"
  info "  dw init                # configure THIS Mac"
  info "  dw setup raycast       # wire dw into Raycast (recommended)"
  info "  dw setup hammerspoon   # ...or Hammerspoon"
  info "  dw                     # flip the monitor"
  exit 0
fi

# --- pick a PATH-visible bin directory ---
choose_link_dir() {
  if [ -w /opt/homebrew/bin ]; then
    printf '%s' "/opt/homebrew/bin"; return
  fi
  case ":$PATH:" in
    *":$HOME/bin:"*) printf '%s' "$HOME/bin"; return ;;
  esac
  case ":$PATH:" in
    *":$HOME/.local/bin:"*) printf '%s' "$HOME/.local/bin"; return ;;
  esac
  return 1
}

LINK_DIR="$(choose_link_dir || true)"
if [ -z "${LINK_DIR:-}" ]; then
  die "no writable PATH dir found. Add ~/bin to PATH and re-run, or symlink manually:
    ln -s '$BIN_SRC' /opt/homebrew/bin/dw"
fi
LINK_PATH="$LINK_DIR/dw"

# --- symlink (idempotent, refuses to clobber unrelated files) ---
if [ -L "$LINK_PATH" ] && [ "$(readlink "$LINK_PATH")" = "$BIN_SRC" ]; then
  ok "symlink already correct: $LINK_PATH"
elif [ -e "$LINK_PATH" ] || [ -L "$LINK_PATH" ]; then
  die "$LINK_PATH already exists and points elsewhere. Remove it and re-run:
    rm '$LINK_PATH' && '$REPO_DIR/install.sh'"
else
  ln -s "$BIN_SRC" "$LINK_PATH"
  ok "linked: $LINK_PATH -> $BIN_SRC"
fi

# --- verify ---
if ! command -v dw >/dev/null 2>&1; then
  die "'dw' not on PATH after install. Try opening a fresh terminal."
fi
ok "dw on PATH: $(command -v dw)"

info ""
info "Done. Next:"
info "  dw init                # configure THIS Mac"
info "  dw setup raycast       # wire dw into Raycast (recommended)"
info "  dw setup hammerspoon   # ...or Hammerspoon"
info "  dw                     # flip the monitor"
