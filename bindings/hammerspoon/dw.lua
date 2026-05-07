-- dw Hammerspoon binding (manual installation)
--
-- For automatic installation, run:  dw setup hammerspoon
-- That writes a managed block into ~/.hammerspoon/init.lua with the resolved
-- absolute path to dw and an idempotent update mechanism.
--
-- Manual install: drop this snippet into ~/.hammerspoon/init.lua and reload.
-- Default hotkey: ⌘⌃\ (Cmd+Ctrl+Backslash). Change to taste.

local DW_BIN = "/opt/homebrew/bin/dw"   -- adjust if symlinked elsewhere

hs.hotkey.bind({"cmd", "ctrl"}, "\\", function()
  local task = hs.task.new(DW_BIN, function(exitCode, _, stdErr)
    if exitCode == 0 then
      hs.alert.show("dw: flipped")
    else
      hs.alert.show("dw failed:\n" .. (stdErr or "(no stderr)"))
    end
  end, {})
  task:start()
end)
