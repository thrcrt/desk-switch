#!/usr/bin/env bash
# install.sh — set up dw on this Mac. Curl-pipe friendly:
#   curl -fsSL https://raw.githubusercontent.com/thrcrt/desk-switch/main/install.sh | bash
# Or run inside an existing checkout to install from local files.

set -euo pipefail

err()  { printf 'install: %s\n' "$*" >&2; }
die()  { err "$*"; exit 1; }
info() { printf '%s\n' "$*"; }
ok()   { printf '✓ %s\n' "$*"; }

REPO_URL_DEFAULT="https://github.com/thrcrt/desk-switch.git"
INSTALL_DIR_DEFAULT="$HOME/.local/share/dw"
REPO_URL="${DW_REPO_URL:-$REPO_URL_DEFAULT}"
INSTALL_DIR="${DW_INSTALL_DIR:-$INSTALL_DIR_DEFAULT}"

[ "$(uname -s)" = "Darwin" ] || die "macOS only — got $(uname -s)"
[ "$(uname -m)" = "arm64" ]  || die "Apple Silicon required — got $(uname -m). m1ddc does not support Intel."
command -v brew >/dev/null 2>&1 || die "Homebrew is required. Install from https://brew.sh and re-run."
command -v git  >/dev/null 2>&1 || die "git is required."
ok "Apple Silicon macOS, Homebrew $(brew --version | head -1 | awk '{print $2}')"

# Resolve repo location: use sibling files if invoked from a clone, else clone.
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" 2>/dev/null && pwd 2>/dev/null || true)"
if [ -n "${SCRIPT_DIR:-}" ] && [ -f "$SCRIPT_DIR/bin/dw" ]; then
  REPO_DIR="$SCRIPT_DIR"
else
  if [ -d "$INSTALL_DIR/.git" ]; then
    info "Updating $INSTALL_DIR..."
    git -C "$INSTALL_DIR" fetch --quiet origin
    git -C "$INSTALL_DIR" reset --quiet --hard origin/HEAD
  elif [ -e "$INSTALL_DIR" ]; then
    die "$INSTALL_DIR exists but isn't a git checkout. Move it aside or set DW_INSTALL_DIR."
  else
    info "Cloning $REPO_URL → $INSTALL_DIR..."
    git clone --quiet "$REPO_URL" "$INSTALL_DIR"
  fi
  REPO_DIR="$INSTALL_DIR"
fi
BIN_SRC="$REPO_DIR/bin/dw"
chmod +x "$BIN_SRC"
ok "repo at $REPO_DIR"

for pkg in m1ddc jq; do
  if brew list --formula "$pkg" >/dev/null 2>&1; then
    ok "$pkg already installed"
  else
    info "Installing $pkg..."
    brew install "$pkg" >/dev/null
    ok "$pkg installed"
  fi
done

choose_link_dir() {
  if [ -w /opt/homebrew/bin ]; then
    printf '%s' "/opt/homebrew/bin"; return
  fi
  case ":$PATH:" in *":$HOME/bin:"*)        printf '%s' "$HOME/bin"; return ;; esac
  case ":$PATH:" in *":$HOME/.local/bin:"*) printf '%s' "$HOME/.local/bin"; return ;; esac
  return 1
}

LINK_DIR="$(choose_link_dir || true)"
[ -n "${LINK_DIR:-}" ] || die "no writable PATH dir found. Add ~/bin to PATH and re-run."
LINK_PATH="$LINK_DIR/dw"

# Smart symlink replacement: if the existing link already points to a dw
# binary in some other clone of this project, replace it silently. Refuse to
# touch a non-symlink or a symlink to anything else.
if [ -L "$LINK_PATH" ]; then
  current="$(readlink "$LINK_PATH")"
  if [ "$current" = "$BIN_SRC" ]; then
    ok "symlink already correct: $LINK_PATH"
  elif [[ "$current" == */bin/dw ]]; then
    rm "$LINK_PATH"
    ln -s "$BIN_SRC" "$LINK_PATH"
    ok "replaced symlink: $LINK_PATH (was → $current)"
  else
    die "$LINK_PATH points to $current — refusing to replace. Remove it manually and re-run."
  fi
elif [ -e "$LINK_PATH" ]; then
  die "$LINK_PATH exists and isn't a symlink. Remove it manually and re-run."
else
  ln -s "$BIN_SRC" "$LINK_PATH"
  ok "linked: $LINK_PATH → $BIN_SRC"
fi

command -v dw >/dev/null 2>&1 || die "'dw' not on PATH after install. Open a fresh terminal."
ok "dw on PATH: $(command -v dw)"

info ""
info "Done. Next:"
info "  dw init                # configure THIS Mac (interactive)"
info "  dw setup raycast       # wire dw into Raycast"
info "  dw                     # flip the monitor"
