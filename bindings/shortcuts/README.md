# macOS Shortcuts binding

The Shortcuts app can run `dw` and be triggered from Spotlight (just type
"dw") or via a global keyboard shortcut. Shortcuts has no public API for
*creating* a shortcut from the CLI, so this part stays manual — once.

## Steps

1. Open the **Shortcuts** app.
2. Create a new shortcut, name it **dw**.
3. Add the **Run Shell Script** action.
   - Shell: `/bin/zsh`
   - Pass input: *No input*
   - Script:
     ```sh
     /opt/homebrew/bin/dw
     ```
     (Or `$HOME/bin/dw`, or wherever `install.sh` symlinked it. Run
     `command -v dw` to find the real path.)
4. (Optional) In the shortcut's details (ⓘ), check **Use as Quick Action**
   to expose it to the Services menu.
5. (Optional) Open **System Settings → Keyboard → Keyboard Shortcuts →
   Services**, find your shortcut under "General", and assign a key combo.

After step 3 you can already trigger the shortcut by typing "dw" in Spotlight
or Raycast — the keyboard shortcut in step 5 is just a nice-to-have.

## Notes

- macOS may prompt for permission the first time it runs (System Events).
  Allow it.
- If you'd rather avoid the manual setup entirely, `dw setup raycast` and
  `dw setup hammerspoon` are fully automated paths.
