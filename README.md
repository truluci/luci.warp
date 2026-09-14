# Cloudflare WARP Omarchy Widget

Bar widget for Cloudflare WARP (`warp-cli`).

## Features

- Shows WARP connection state in the bar as a cloud mark: solid when
  connected, slashed when disconnected, pulsing while a toggle settles
- **Left click connects or disconnects WARP directly** — no panel in the way
- Right click opens a panel with status, mode, and always-on details
- Middle click forces a status refresh
- Hovering the icon shows the current state as a tooltip

## Keyboard shortcuts

Inside the panel:

- `t`: toggle WARP
- `r`: refresh status
- `enter` / `space`: toggle WARP
- `esc`: close

## How it reads state

The widget polls `warp-cli -j status` every 15 seconds (configurable), and
every 0.7 seconds while a toggle or a `Connecting` state is still settling.
Clicking applies an optimistic state immediately so the icon reacts on click
rather than on the next poll; that optimism is dropped as soon as the daemon
agrees, or after 12 seconds if it never does.

## Settings

Set in the widget's entry in `~/.config/omarchy/shell.json`:

- `refreshIntervalSec` (default `15`, range 3-3600) — steady-state poll interval

## IPC

```bash
omarchy-shell luci.warp status       # current status text
omarchy-shell luci.warp toggleWarp   # connect or disconnect
omarchy-shell luci.warp connect
omarchy-shell luci.warp disconnect
omarchy-shell luci.warp refresh
omarchy-shell luci.warp toggle       # open/close the panel
```

These make it easy to bind WARP to a key in `~/.config/hypr/bindings.lua`.

## Requirements

- `warp-cli` on `PATH` (the `cloudflare-warp-bin` AUR package), with the
  `warp-svc` daemon running and the device already registered

If `warp-cli` is missing the widget shows a warning badge instead of failing
silently.

## Notes

The widget never reads `warp-cli registration show`, so no account license
key is ever pulled into the shell process or shown in the panel.

If WARP has `always_on` set, the daemon may reconnect on its own after a
disconnect; the widget reflects whatever the daemon reports.

## Add to the bar

```bash
omarchy plugin enable luci.warp --section right
omarchy bar move luci.warp --after omarchy.tailscale
```
