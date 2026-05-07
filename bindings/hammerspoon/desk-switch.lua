-- desk-switch Hammerspoon binding
--
-- Drop this snippet into ~/.hammerspoon/init.lua and reload Hammerspoon.
-- Default hotkey: ⌘⌃\ (Cmd+Ctrl+Backslash). Change to taste.
--
-- Adjust DESK_SWITCH_BIN if the binary lives elsewhere on your PATH.

local DESK_SWITCH_BIN = os.getenv("HOME") .. "/desk-switch/bin/desk-switch"
-- Or, if you symlinked it:
--   local DESK_SWITCH_BIN = "/opt/homebrew/bin/desk-switch"

hs.hotkey.bind({"cmd", "ctrl"}, "\\", function()
  local task = hs.task.new(DESK_SWITCH_BIN, function(exitCode, _, stdErr)
    if exitCode == 0 then
      hs.alert.show("desk-switch: flipped")
    else
      hs.alert.show("desk-switch failed:\n" .. (stdErr or "(no stderr)"))
    end
  end, {})
  task:start()
end)
