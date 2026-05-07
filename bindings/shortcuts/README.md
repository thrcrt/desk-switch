# macOS Shortcuts binding

The Shortcuts app can run a shell script and be triggered by a global keyboard
shortcut from System Settings → Keyboard → Keyboard Shortcuts → Services /
App Shortcuts.

## Steps

1. Open the **Shortcuts** app.
2. Create a new shortcut, name it "Desk Switch — Toggle".
3. Add the action **Run Shell Script**.
   - Shell: `/bin/zsh`
   - Pass input: *No input* (or "to stdin", doesn't matter)
   - Script:
     ```sh
     /Users/<you>/desk-switch/bin/desk-switch
     ```
     Replace `<you>` with your username, or use `$HOME` if Shortcuts evaluates
     env vars (it usually doesn't — hardcode the absolute path).
4. In the shortcut's details (the ⓘ icon), check **Use as Quick Action** so
   it shows up in the Services menu.
5. Open **System Settings → Keyboard → Keyboard Shortcuts → Services**, find
   your shortcut under "General", and assign a key combo (e.g. ⌘⌃\\).

The Shortcut will then run silently when you press the key combo.

## Notes

- macOS may prompt for permission the first time it runs (System Events).
  Allow it.
- If you symlinked `desk-switch` to `/opt/homebrew/bin/`, you can use that
  path instead of `~/desk-switch/bin/desk-switch`.
