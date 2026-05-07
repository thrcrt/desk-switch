# desk-switch

Flip a DDC-capable external monitor between **two or more Macs** sharing
it. Type `dw` in Raycast and the monitor switches.

```
dw                       # toggle (with 2 devices) or list (with 3+)
dw <device>              # explicit switch (e.g. dw mac-mini)
dw init                  # interactive setup on the first Mac
dw add <name> <input>    # add a new device to the config
dw remove <name>         # drop a device
dw use <name>            # change which device THIS Mac is
dw share                 # generate one-paste install commands for other Macs
dw setup raycast         # register per-device commands in Raycast
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
- Raycast (for the hotkey UI)

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
```

Paste the matching command on each other Mac. `bootstrap.sh` clones the
repo, runs `install.sh`, writes the config, and (if Raycast is installed)
generates the per-device Raycast script commands. After it finishes, that
Mac is ready — no `init` wizard.

## Raycast integration

`dw setup raycast` generates one Raycast script command per device into
`~/Documents/dw/raycast/`. Each script gets a `dw → <Device>` title and a
🖥 icon. Nothing is uploaded; nothing leaves your Mac.

**One-time setup** — Raycast has no API for adding a Script Directory, so
this single click is unavoidable:

1. Run `dw setup raycast` — opens Raycast.
2. Raycast Settings (⌘,) → Extensions → Script Commands → `+` →
   *Add Script Directory*.
3. In the file picker, navigate to **Documents → dw → raycast** and click
   *Open*.

After this one-time step, every `dw add`, `dw remove`, or `dw setup raycast`
regenerates the scripts in place and Raycast picks them up automatically —
no more clicking, ever.

In Raycast: type `dw` and autocomplete lists every device.

## Resetting / starting over

```sh
dw reset           # interactive: shows what'll be removed, asks to confirm
dw reset --yes     # skip confirmation
```

`dw reset` removes:

- `~/.config/dw/` (the device config)
- `~/Documents/dw/raycast/` (generated Raycast script commands)

It does **not** touch:

- the `dw` binary or its symlink — use `./uninstall.sh` for that
- Homebrew deps (`m1ddc`, `jq`)
- the Raycast "Add Script Directory" entry inside Raycast Settings (the
  directory will just be empty until you re-run `dw setup raycast`)

After a reset, run `dw init` to set up fresh — or, on a secondary Mac,
paste the matching `dw share` line from your main Mac.

## Troubleshooting

- **`m1ddc could not write input`** — Wrong display selector, or the monitor
  doesn't support DDC input switching. Run `dw list` to see what `m1ddc`
  detects, and confirm with `m1ddc display 1 get luminance` that DDC reads
  work for that display.
- **Switches to the wrong input** — Re-run `dw init` (or use
  `dw remove <name>` + `dw add <name> <new-code>`).
- **Monitor goes dark with no signal** — You wrote a code for an unused
  input. Recover with the monitor's joystick, then fix the config.

## License

MIT — see [`LICENSE`](./LICENSE).
