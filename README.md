# desk-switch

Flip a DDC-capable external monitor between two Macs sharing it. Type `dw`
in Raycast / Spotlight, or hit a global hotkey, and the monitor switches.

```
dw                       # toggle: switch monitor to the OTHER Mac
dw <label>               # explicit switch (e.g. dw mac-mini)
dw init                  # interactive setup (display + input codes)
dw setup raycast         # one-click install into Raycast
dw setup hammerspoon     # write a Hammerspoon hotkey binding
dw status                # show config
```

> The repo is named `desk-switch` (the project) but the binary you run is
> `dw` (short, fast to type).

## How it works

Every modern external monitor exposes a side-channel called **DDC/CI** over
the video cable. The OS can use it to change brightness, volume, and the
**input source** without touching the monitor's physical buttons. `dw` wraps
[`m1ddc`](https://github.com/waydabber/m1ddc) — a small CLI that speaks
DDC/CI on Apple Silicon — to write the input source VCP code.

You install and configure `dw` on **both** Macs. Each Mac knows two input
codes: its own, and the other one's. Running `dw` flips the monitor away
from the current Mac to the other one. To flip back, run it on the other
Mac (a hotkey on each side does the trick).

## Requirements

- Apple Silicon Mac (M1 / M2 / M3 / M4) on macOS 12+
- A DDC-capable external monitor (most modern monitors are; built-in HDMI on
  entry-level M1 / base M2 Macs is **not** DDC-capable — use USB‑C or
  Thunderbolt instead)
- Homebrew

## Install

```sh
git clone https://github.com/thrcrt/desk-switch.git ~/desk-switch
cd ~/desk-switch
./install.sh
```

`install.sh` is idempotent and does the boring work for you:

- Verifies you're on Apple Silicon macOS.
- Checks Homebrew is present (won't auto-install it — too invasive).
- `brew install m1ddc jq` (skips if already installed).
- Symlinks `dw` into the first writable PATH directory it finds, preferring
  `/opt/homebrew/bin`, falling back to `~/bin` or `~/.local/bin`.
- Cleans up any legacy `desk-switch` symlinks left over from earlier
  versions.

Re-running it is safe — it short-circuits when everything's already in place.

To remove: `./uninstall.sh` (drops the symlink and config; leaves Homebrew
dependencies in place).

## Setup

On **each** Mac, with the monitor showing that Mac:

```sh
dw init
```

The wizard asks:

1. **Which display number to control?** — Usually `1`. Run `m1ddc display list`
   to confirm.
2. **Is the monitor currently displaying THIS Mac?** — Confirm yes.
3. **Label for THIS Mac** — Free-form, no spaces.
4. **VCP input code for THIS Mac** — Standard codes:
   - `15` = DisplayPort 1
   - `16` = DisplayPort 2
   - `17` = HDMI 1
   - `18` = HDMI 2
   - `27` = USB‑C
5. **Label and code for the OTHER Mac** — Same idea.

Config is written to `~/.config/dw/config.json`.

### Finding the right input codes

If the standard codes don't switch your monitor, it may use vendor-specific
values. Two ways to find the right one:

- **Try and see:** from the Mac currently active on the monitor, run
  `m1ddc display 1 set input N` for `N` in 1..30. Wrong codes are no-ops;
  the right one switches the input. If you land on a dead input, recover
  with the monitor's physical joystick / OSD.
- **Check the manual:** search your monitor's user guide for "DDC/CI input
  source codes", or browse known values at
  <https://github.com/kfix/ddcctl/issues>.

## Hotkey runner integration

`dw setup` wires `dw` into a hotkey runner so you can trigger it from
Raycast, Spotlight, or a global key.

```sh
dw setup                   # show what's available on this Mac
dw setup raycast           # install the Raycast script command (one-click)
dw setup hammerspoon       # append a managed binding to ~/.hammerspoon/init.lua
```

### Raycast (recommended)

`dw setup raycast` opens a Raycast install deeplink that fetches the script
from this repo and registers it as a Raycast script command. Confirm the
prompt → done. After that, type **`dw`** in Raycast and hit Enter to flip
the monitor. Optionally assign a global hotkey from
*Raycast → Extensions → Script Commands → dw → Record Hotkey*.

### Hammerspoon

`dw setup hammerspoon` appends a managed block to `~/.hammerspoon/init.lua`
that binds **⌘⌃\\** (Cmd+Ctrl+Backslash) to `dw`. The block is wrapped in
`-- dw:start` / `-- dw:end` markers and is replaced cleanly on every re-run.
Reload Hammerspoon (menubar icon → Reload Config) once after setup. Edit
the hotkey by changing `{"cmd", "ctrl"}, "\\"` in the generated block.

### Shortcuts

Apple Shortcuts has no public API for creating shortcuts from the CLI, so
this remains a manual one-time step — see
[`bindings/shortcuts/README.md`](./bindings/shortcuts/README.md).
After setup, you can trigger it by typing "dw" in Spotlight.

## Troubleshooting

- **`m1ddc could not write input`** — Wrong display selector, or the monitor
  doesn't support DDC input switching. Run `dw list` to see what `m1ddc`
  detects, and confirm with `m1ddc display 1 get luminance` that DDC reads
  work for that display.
- **Toggle switches to the wrong input** — Re-run `dw init` and double-check
  the input codes.
- **Monitor goes dark with no signal** — You wrote a code for an unused
  input. Recover with the monitor's joystick, then re-run `init`.

## Roadmap

- v0.3: Intel Mac support via `ddcctl` fallback.
- v0.3: Homebrew tap (`brew install <tap>/desk-switch`).
- v0.4: Multi-display support.

## License

MIT — see [`LICENSE`](./LICENSE).
