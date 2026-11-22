# Hyper Control

A [Karabiner-Elements](https://karabiner-elements.pqrs.org) layout that turns Caps Lock into a **Hyper Layer** while keeping it a real Control key. It's built for an HHKB and a MacBook Pro, and includes an AutoHotkey port for Windows.

## What it does

| Key | Tap | Hold |
|---|---|---|
| Caps Lock | Escape | Hyper Layer (see below) |
| Tab | Tab | Meh (Ctrl+Option+Shift) |
| Left Shift | `(` | Shift |
| Right Shift | `)` | Shift |

Hold both Shifts and tap one to get `()` or `)(`. If you roll from `)` into Space quickly, you get `) `.

### The Hyper Layer (hold Caps)

**Arrows and editing.** Shift, Option and Command still work with these, so Caps+Shift+F selects, Caps+Option+F jumps a word, and Caps+Cmd+F goes to the end of the line.

| Key | Does |
|---|---|
| F / B / N / P | → ← ↓ ↑ |
| H | Backspace |
| Delete | Forward delete |
| `,` / `.` | Start / end of document |
| V | Paste and match style |
| `[` / `]` | Previous / next Space |
| Space | Emoji picker |

**App and window keys.** These send Hyper (Cmd+Ctrl+Option+Shift) + the key, for binding in a launcher or window manager:
`` ` `` `1`–`0` `-` `=` `\` `Q` `W` `R` `Y` `U` `I` `S` `G` `J` `;` `'` `X` `M` `/`

**Everything else is Control.** Caps+A is Ctrl+A, Caps+K is Ctrl+K, and so on, so the macOS Emacs-style text bindings and every app's Control shortcuts still work.

The full design, with earlier versions, is in [`Keyboard Layout Editor.md`](Keyboard%20Layout%20Editor.md). Paste any block into [keyboard-layout-editor.com](https://www.keyboard-layout-editor.com) to see it drawn.

## How it works

Holding Caps does two things: it sets the Karabiner variable `hyper_layer = 1` and holds **right** Control. The layer rules need both:

- **The variable** means "Caps is held". A real right Control key on another keyboard never triggers the layer.
- **Right Control** is the fallback. Any key the layer doesn't list reaches macOS as Control + key. Because the rules list right Control as `mandatory`, Karabiner removes it from what they send, so Caps+F is a plain → and not Ctrl+→.

The physical Control key sends **left** Control, which no rule touches. It always behaves as stock Control.

## Files

| File | What it is |
|---|---|
| `hypercontrol.yml` | The source. Edit this; it has comments and YAML anchors. |
| `hypercontrol.json` | Compiled from the YAML; this is what Karabiner reads. |
| `install.py` | Swaps these rule groups into your live `karabiner.json`, with a backup. |
| `karabiner.json` | Snapshot of the full live config: device settings, timeouts, other rules. |
| `makefile` | Build steps (below). |
| `windows/` | AutoHotkey v2 port and an Office-key registry fix. |

## Install (macOS)

Needs [Karabiner-Elements](https://karabiner-elements.pqrs.org), [`yq`](https://github.com/mikefarah/yq) and [`uv`](https://github.com/astral-sh/uv): `brew install yq uv`.

```sh
make            # compile the YAML to JSON and lint it (touches nothing else)
make install    # also load the rules into Karabiner (backs up karabiner.json first)
make snapshot   # copy your live karabiner.json into the repo
```

`make install` replaces only this project's rule groups and keeps their order. Karabiner reloads on its own. It prints an undo command that restores the backup.

To use the rules without the makefile, copy `hypercontrol.json` to `~/.config/karabiner/assets/complex_modifications/` and enable the rule groups in **Karabiner-Elements → Complex Modifications → Add rule**.

## Windows

`windows/hypercontrol.ahk` is an [AutoHotkey v2](https://www.autohotkey.com) port of the same layout. It also carries over Mac-style shortcuts from [mac-keyboard-behavior-in-windows](https://github.com/stevenilsen123/mac-keyboard-behavior-in-windows) and adds more. It needs no admin rights. Setup steps are at the top of the script; in short:

1. Install AutoHotkey v2.
2. In PowerToys Keyboard Manager, swap Left Alt and Left Ctrl, so the key beside Space acts as Command.
3. Run the script. To start it at login, put a shortcut in `shell:startup`.
4. Optional: double-click `disable-office-key.reg` so Hyper+W/X/Y don't open Office.

Caps+Z shows which modifiers the script sees, which helps when something misbehaves.

## Not done yet

- Tab (Meh) layer: no keys assigned yet.
- Greek layer: the AltGr(eek) design is drawn, but only α–ζ are wired up.
