# desk-switch

Flip a DDC-capable external monitor between two Macs sharing it — with one
keyboard shortcut, one Raycast command, or one Shortcuts action.

```
desk-switch              # toggle: switch monitor to the OTHER Mac
desk-switch mac-mini     # explicit switch
desk-switch macbook      # explicit switch
desk-switch init         # interactive setup
desk-switch status       # show config
```

## How it works

Every modern external monitor exposes a side-channel called **DDC/CI** over
the video cable. The OS can use it to change brightness, volume, and the
**input source** without touching the monitor's physical buttons. `desk-switch`
wraps [`m1ddc`](https://github.com/waydabber/m1ddc) — a small CLI that speaks
DDC/CI on Apple Silicon — to write the input source VCP code.

You install and configure `desk-switch` on **both** Macs. Each Mac knows two
input codes: its own, and the other one's. Running `desk-switch` flips the
monitor away from the current Mac to the other one. To flip back, run it on
the other Mac (a hotkey on each side does the trick).

## Requirements

- Apple Silicon Mac (M1 / M2 / M3 / M4) on macOS 12+
- A DDC-capable external monitor (most modern monitors are; built-in HDMI on
  entry-level M1/M2 Macs is **not** DDC-capable — use USB-C/Thunderbolt instead)
- `m1ddc` and `jq` from Homebrew

> **Intel Macs / older Macs:** not supported in v0.1. The script can be ported
> to `ddcctl` (Intel) — contributions welcome.

## Install

```sh
brew install m1ddc jq

# clone wherever you keep code
git clone <repo-url> ~/desk-switch
ln -s ~/desk-switch/bin/desk-switch ~/bin/desk-switch   # if ~/bin is on PATH

# or symlink into Homebrew's bin
ln -s ~/desk-switch/bin/desk-switch /opt/homebrew/bin/desk-switch
```

(A Homebrew tap is on the v0.2 roadmap.)

## Setup

On **each** Mac, with the monitor showing that Mac:

```sh
desk-switch init
```

The wizard asks:

1. **Which display number to control?** — Usually `1`. Run `m1ddc display list`
   to confirm.
2. **Is the monitor currently displaying THIS Mac?** — Confirm yes.
3. **Label for THIS Mac** — Free-form, no spaces (e.g. `macbook`, `mac-mini`).
4. **VCP input code for THIS Mac** — The standard codes:
   - `15` = DisplayPort 1
   - `16` = DisplayPort 2
   - `17` = HDMI 1
   - `18` = HDMI 2
   - `27` = USB-C
5. **Label and code for the OTHER Mac** — Same idea.

Config is written to `~/.config/desk-switch/config.json`.

### Finding the right input codes

If the standard codes don't switch your monitor, your monitor may use
vendor-specific values. Two ways to find the right one:

- **Try and see**: from the Mac currently active on the monitor, run
  `m1ddc display 1 set input N` for `N` in 1..30. The wrong codes are no-ops;
  the right one switches the input. (You'll need to switch back manually via
  the monitor's joystick if you land on a dead input.)
- **Check the manual**: search your monitor's user guide for "DDC/CI input
  source codes" or check <https://github.com/kfix/ddcctl/issues> for known
  values.

## Hotkey bindings

The CLI is just a CLI. To bind it to a keyboard shortcut, pick one of the
recipes in [`bindings/`](./bindings):

- **Hammerspoon** — [`bindings/hammerspoon/desk-switch.lua`](./bindings/hammerspoon/desk-switch.lua)
- **Raycast** script command — [`bindings/raycast/`](./bindings/raycast)
- **macOS Shortcuts** — [`bindings/shortcuts/README.md`](./bindings/shortcuts/README.md)

## What this tool does NOT do

`desk-switch` only switches the **monitor input**. The other parts of a
two-Mac desk setup need separate solutions:

| Device | Why it's separate | Usual fix |
|---|---|---|
| Keyboard (e.g. iQunix wireless) | 2.4 GHz dongle is bound to whichever USB port it's plugged into; BT pairing is single-host | Use the keyboard's built-in BT profile switching (`Fn+Q/W/E` on most iQunix boards) |
| Logitech G Pro mouse | LIGHTSPEED dongle is single-host; no Bluetooth on the Pro line | Physical USB switch for the dongle, or a separate mouse per Mac |
| Apple Magic Mouse | Bluetooth, single-host pairing | Re-pair manually, or one Magic Mouse per Mac |
| Built-in macOS keyboard/mouse handoff | Universal Control works between two Macs without monitor switching, but doesn't help when one Mac's screen is hidden | Out of scope |

The cleanest physical setup we've seen:

- **Monitor**: `desk-switch` bound to a single hotkey on each Mac.
- **Keyboard**: an iQunix (or similar) with multi-device BT — one profile per
  Mac, switched with the keyboard's own profile key.
- **Mouse**: a 2-port USB switch carrying the Logitech LIGHTSPEED dongle
  between Macs, OR a dedicated mouse per Mac.

## Troubleshooting

- **`m1ddc could not write input`** — Wrong selector or the monitor doesn't
  support DDC input switching. Run `desk-switch list` to see what `m1ddc`
  detects, and confirm with `m1ddc display 1 get luminance` that DDC reads
  work for that display.
- **Toggle switches to the wrong input** — Re-run `desk-switch init` and
  double-check the input codes.
- **Monitor goes dark with no signal** — You wrote a code for an unused input.
  Use the monitor's joystick to switch back, then re-run `init`.

## Limitations / roadmap

- v0.1: Apple Silicon only, single external display per Mac.
- v0.2: Intel Mac support via `ddcctl` fallback.
- v0.2: Homebrew tap (`brew install <tap>/desk-switch`).
- v0.3: Multi-display support (e.g. dual monitors per Mac).
- Maybe: optional cross-Mac sync over LAN so one hotkey flips both monitor
  AND tells the other Mac to grab focus.

## License

MIT — see [`LICENSE`](./LICENSE).
