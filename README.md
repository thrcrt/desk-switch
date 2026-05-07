# desk-switch

Flip a DDC-capable external monitor between **two or more Macs** sharing it.
Type `dw` in Raycast / Spotlight, or hit a global hotkey, and the monitor
switches.

```
dw                       # toggle (with 2 devices) or list (with 3+)
dw <device>              # explicit switch (e.g. dw mac-mini)
dw init                  # interactive setup on the first Mac
dw add <name> <input>    # add a new device to the config
dw remove <name>         # drop a device
dw use <name>            # change which device THIS Mac is
dw share                 # generate one-paste install commands for other Macs
dw setup raycast         # register per-device commands in Raycast
dw setup hammerspoon     # write a Hammerspoon hotkey binding
dw reset                 # wipe config + generated bindings (start fresh)
dw status                # show config
dw list                  # list displays + show config
```

> The repo is named `desk-switch`. The binary you run is `dw`.

## How it works

Every modern external monitor exposes a side-channel called **DDC/CI** over
the video cable. The OS can use it to change brightness, volume, and the
**input source** without touching the monitor's physical buttons. `dw` wraps
[`m1ddc`](https://github.com/waydabber/m1ddc) — a small CLI that speaks
DDC/CI on Apple Silicon — to write the input source VCP code.

You configure all your devices once on a "main" Mac, then `dw share` prints
a one-paste install command for each other Mac. Each device knows its own
identity (`this_device`) and the full map of devices and their input codes,
so any `dw <name>` call switches the monitor instantly.

## Requirements

- Apple Silicon Mac (M1 / M2 / M3 / M4) on macOS 12+
- A DDC-capable external monitor (most modern monitors are; built-in HDMI on
  entry-level M1 / base M2 Macs is **not** DDC-capable — use USB‑C or
  Thunderbolt instead)
- Homebrew

## Install on the main Mac

```sh
git clone https://github.com/thrcrt/desk-switch.git ~/desk-switch
cd ~/desk-switch
./install.sh
dw init
```

`install.sh` is idempotent — it verifies Apple Silicon, makes sure
`m1ddc` and `jq` are installed via Homebrew, and symlinks `dw` into the
first writable PATH dir it finds (preferring `/opt/homebrew/bin`).

`dw init` walks you through:

1. Which display number to control (usually `1`)
2. How many devices share this monitor
3. Each device's name + VCP input code
4. Which device THIS Mac is

Standard VCP codes:

| Code | Input |
|---|---|
| 15 | DisplayPort 1 |
| 16 | DisplayPort 2 |
| 17 | HDMI 1 |
| 18 | HDMI 2 |
| 27 | USB‑C |

Config goes to `~/.config/dw/config.json`.

## Install on the other Macs

On the **main** Mac (after `dw init`):

```sh
$ dw share
## On 'macmini':

  bash <(curl -fsSL https://raw.githubusercontent.com/.../bootstrap.sh) \
    --this macmini --devices "macbook=27,macmini=17,work=15"

## On 'work':

  bash <(curl -fsSL .../bootstrap.sh) --this work --devices "..."
```

Paste the matching command on each other Mac. `bootstrap.sh` clones the
repo, runs `install.sh`, writes the config, and (if Raycast is installed)
generates the per-device Raycast script commands. After it finishes, that
Mac is ready — no `init` wizard, no clicking around.

## Hotkey runner integration

```sh
dw setup                   # show what's available on this Mac
dw setup raycast           # generate per-device scripts + add to Raycast
dw setup hammerspoon       # append a managed binding to ~/.hammerspoon/init.lua
```

### Raycast (recommended)

`dw setup raycast` generates one Raycast script command per device
(`bindings/raycast/generated/dw-<name>.sh`, gitignored), copies the
directory path to your clipboard, and opens Raycast. One-time: paste the
directory into *Raycast Settings → Extensions → Script Commands → '+' →
Add Script Directory*. After that, type **`dw`** in Raycast to see all
devices.

When you `dw add <name>`, just re-run `dw setup raycast` — the new script
appears in Raycast automatically (the directory's the same; Raycast just
sees a new file).

### Hammerspoon

`dw setup hammerspoon` appends a managed block to `~/.hammerspoon/init.lua`
that binds **⌘⌃\\** (Cmd+Ctrl+Backslash) to `dw`. The block is wrapped in
`-- dw:start` / `-- dw:end` markers and is replaced cleanly on every
re-run. Reload Hammerspoon (menubar icon → Reload Config) once after setup.

With 3+ devices, the single hotkey runs `dw` (which prints the device list);
for per-device hotkeys, edit the generated block.

## Resetting / starting over

```sh
dw reset           # interactive: shows what'll be removed, asks to confirm
dw reset --yes     # skip confirmation
```

`dw reset` removes:

- `~/.config/dw/` (the device config)
- `bindings/raycast/generated/` (per-device Raycast scripts)
- The managed `-- dw:start` … `-- dw:end` block in `~/.hammerspoon/init.lua`

It deliberately **does not** touch:

- the `dw` binary or its symlink — use `./uninstall.sh` for that
- Homebrew deps (`m1ddc`, `jq`)
- the Raycast "Add Script Directory" entry inside Raycast Settings (the
  directory will just be empty until you re-run `dw setup raycast`)

After a reset, run `dw init` to set up fresh — or, on a secondary Mac,
paste the matching `dw share` line from your main Mac.

### Shortcuts

Apple Shortcuts has no public API for creating shortcuts from the CLI, so
this is a manual one-time step — see
[`bindings/shortcuts/README.md`](./bindings/shortcuts/README.md). After
setup, typing "dw" in Spotlight runs it.

## Troubleshooting

- **`m1ddc could not write input`** — Wrong display selector, or the monitor
  doesn't support DDC input switching. Run `dw list` to see what `m1ddc`
  detects, and confirm with `m1ddc display 1 get luminance` that DDC reads
  work for that display.
- **Switches to the wrong input** — Re-run `dw init` (or use
  `dw remove <name>` + `dw add <name> <new-code>`).
- **Monitor goes dark with no signal** — You wrote a code for an unused
  input. Recover with the monitor's joystick, then fix the config.
- **Raycast install link says "script not found"** — The script must be
  reachable on the public web. Make sure your repo is public and the
  branch is `main` (the default `dw setup raycast` uses).

## Roadmap

- Intel Mac support via `ddcctl` fallback.
- Homebrew tap (`brew install <tap>/desk-switch`).
- Multi-display support (more than one external monitor per Mac).
- Optional cross-Mac LAN sync (one keypress flips monitor *and* tells the
  target Mac to wake / grab focus).

## License

MIT — see [`LICENSE`](./LICENSE).
