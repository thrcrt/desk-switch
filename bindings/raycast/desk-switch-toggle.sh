#!/usr/bin/env bash
# Required parameters:
# @raycast.schemaVersion 1
# @raycast.title Desk Switch — Toggle
# @raycast.mode silent
#
# Optional parameters:
# @raycast.icon 🖥
# @raycast.packageName Desk Switch
# @raycast.description Flip the monitor between this Mac and the other one.

# Adjust if you didn't symlink desk-switch onto PATH.
exec "$HOME/desk-switch/bin/desk-switch"
