#!/usr/bin/env bash
# Required parameters:
# @raycast.schemaVersion 1
# @raycast.title dw
# @raycast.mode silent
#
# Optional parameters:
# @raycast.icon 🖥
# @raycast.packageName Desk Switch
# @raycast.description Flip the monitor between this Mac and the other one.

# Raycast script commands run with a stripped PATH. Make sure the brew-managed
# binaries (m1ddc, jq, and dw's own symlink) are findable.
export PATH="/opt/homebrew/bin:$HOME/bin:$HOME/.local/bin:$PATH"

exec dw
