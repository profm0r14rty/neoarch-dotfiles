# Implementation Guide: finishing the Sway rice

This is the phase-by-phase plan for turning the current personal setup into a portable public repository. The configs in this repository are a complete baseline, but machine-specific validation is a separate requirement: a config that parses is not proof that every hardware device and GUI integration works.

## Phase 0 — Define the target and keep the repo safe

**Target:** Arch Linux + Sway, keyboard-centric, compact and minimal, Catppuccin Mocha, no Omarchy-specific dependencies.

**Rules for the public repository**

- Keep personal paths, device IDs, usernames, IP addresses, serial numbers and actual browser profile state out of tracked files.
- Keep actual monitor geometry and application IDs in `~/.config/sway/config.d/*.conf`, not in the shared baseline.
- Do not copy the whole `~/.config` tree into Git. The visible machine inventory includes private applications/configurations (browser, GitHub CLI, SSH/GPG, shell and editor state) that do not belong in a desktop-rice repo.
- Keep the installation script backup-first and package installation manual. Do not run it with `sudo`.

**Done when:** the repository contains only intentional configs and helpers, with no account/session data.

## Phase 1 — Package and dependency baseline

Install the packages listed in `packages/required-pacman.txt` on a clean Arch install, with one important caveat: package transactions for audio must be reviewed on an existing machine because `pipewire-pulse` may conflict with a PulseAudio setup. The setup expects PipeWire/WirePlumber for `wpctl` and Cava's PipeWire input.

The required apps map to real config references:

| Config / feature | Required command or package |
|---|---|
| Sway compositor | `sway` |
| Top bar | `waybar` |
| Terminal | `foot`, `foot-terminfo` |
| Application picker | `fuzzel` |
| Notifications | `mako` |
| Lock and idle | `swaylock`, `swayidle` |
| Solid/image backgrounds | Sway background backend, `swaybg` |
| Area screenshots | `grim`, `slurp` |
| Screenshot to clipboard | `wl-clipboard` |
| Clipboard history | `cliphist` |
| Volume keys | `pipewire`, `pipewire-pulse`, `wireplumber`, `pavucontrol` |
| Brightness / media keys | `brightnessctl`, `playerctl` |
| Network menu | `networkmanager` (`nmtui`) |
| File manager / default-browser URI | `thunar`, `xdg-utils` |
| Privilege prompts | `polkit-gnome` |
| Portal integration | `xdg-desktop-portal`, `xdg-desktop-portal-wlr`, `xdg-desktop-portal-gtk` |
| Legacy X11 apps | `xorg-xwayland` |
| Typography / icons | `ttf-jetbrains-mono-nerd`, Adwaita icon/cursor themes, `gsettings-desktop-schemas`, `noto-fonts-emoji` |
| Validation / status popup | `jq`, `libnotify` |
| Utility windows | `btop`, `cava` |

Do not install packages with an AUR helper merely because another rice uses them. This baseline uses official repository packages where available and does not require a custom shell, icon pack or GPU monitor.

**Done when:** `command -v sway waybar foot fuzzel mako grim slurp wl-copy cliphist wpctl brightnessctl playerctl` succeeds for the features you intend to use.

## Phase 2 — Make Sway portable

The old config had specific output names, positions, resolution and wallpaper path; app assignments for Brave web apps and Minecraft; and keybinds for personal browser-app flows. Those are valid personal preferences but unsuitable as default behavior for a public clone-and-install repo.

The new `dotfiles/.config/sway/config` does the following:

- uses a solid background that does not require a user-supplied asset;
- sets a minimal border/gap system and Catppuccin Mocha focus colors;
- retains Vim-style focus and move keys, numbered workspaces, resize mode, scratchpad, media keys, screenshots, clipboard history and lock/idle behavior;
- points screenshots and clipboard actions to included helper scripts;
- loads local overrides via `~/.config/sway/config.d/*.conf`;
- leaves monitor geometry and real app IDs out of the baseline;
- retains `/etc/sway/config.d/*` so system-provided Arch helpers remain available.

One deliberate keybinding adjustment: `Super+E` is the existing layout toggle, so Thunar is assigned to `Super+Shift+O` rather than competing for the same key. The default browser action uses `xdg-open` so the user's chosen default browser handles the URL.

**Done when:** `sway -C -c ~/.config/sway/config` parses without errors, the configured bar appears, and core keybindings work after reload.

## Phase 3 — Complete the visual layer

### Waybar

The original JSONC referenced `~/.local/bin/gpu-status`, a script not present among the supplied files, and `nvtop`, which is not a dependable default for a fresh install. The replacement intentionally omits that custom GPU module. It uses CPU, RAM, root-disk usage, network, audio, battery and tray modules.

The temperature module is omitted from the baseline because hwmon paths differ by device and may not exist. If wanted, add it locally after inspecting `/sys/class/thermal/` or `/sys/class/hwmon/`; Waybar permits arrays of candidate hwmon paths for portable configurations.

The stylesheet uses consistent spacing, thin dividers, one focus accent and color only where state is meaningful. This yields a compact bar without the visual noise of oversized icons or many unrelated colors.

### Fuzzel

The application picker uses a centered layout, a modest width, short list, matching mono font, and the same dark/lavender palette. Its built-in `--dmenu` mode is also used for clipboard history.

### Foot

Foot uses the same foreground/background and ANSI palette, a narrow padding margin and a beam cursor. It is opaque by default for predictable contrast and screen sharing.

### Mako and Swaylock

Mako uses thin borders and a short timeout; Swaylock uses the same base palette with a lavender ring and semantic verification/wrong/clear states. Do not add blur or other effects unless they are supported by the compositor and do not compromise legibility.

### GTK

The GTK 3 settings prefer Adwaita Dark and the system-provided Adwaita icon/cursor themes. For GTK 4/libadwaita apps, optionally set `gsettings set org.gnome.desktop.interface color-scheme 'prefer-dark'`. GTK 4 applications may apply their theme differently; test both GTK 3 and GTK 4 apps. Avoid bundling an external theme until its installation and license are documented.

**Done when:** the terminal, launcher, bar, notification, lock and GTK app all look coherent at the actual screen scaling and font size.

## Phase 4 — Make helper scripts predictable

### Screenshots

`scripts/sway-screenshot` calls `slurp` to select a rectangle, then uses `grim` to either save it to `~/Pictures/Screenshots/` or send PNG data to `wl-copy`. Cancelling the region selection exits cleanly. This addresses the original config's dependency on an existing screenshots directory.

### Clipboard history

`scripts/cliphist-menu` opens `cliphist list` in Fuzzel and pipes the selected entry through `cliphist decode` into `wl-copy`. Canceling the picker exits without overwriting the clipboard.

**Done when:** screenshot-save, screenshot-copy, and clipboard selection work with both normal and canceled picker actions.

## Phase 5 — Hardware-local config

### Monitor configuration

Run `swaymsg -t get_outputs`, inspect available modes and copy the monitor example to `~/.config/sway/config.d/90-monitors.conf`. Replace every sample output name with the actual name returned by Sway. Avoid fixed resolution/scale rules until you have confirmed the modes listed for that output.

### App IDs and workspace assignment

Use `swaymsg -t get_tree | jq '.. | objects | select(.type? == "con") | {name, app_id, window_properties}'` while each app is open. Add assignment rules only after seeing whether the app is native Wayland (`app_id`) or XWayland (`class`). Browser PWAs can have generated IDs, so keep them outside the baseline.

### Temperature / GPU widgets

Do not re-add the old GPU script without committing the script and its dependency docs. Intel GPU monitoring has different tooling and permission requirements than NVIDIA monitoring. For temperatures, use the candidate-path feature documented by Waybar or omit the module if it cannot be shared reliably.

### Wallpaper

The default solid background is intentional. Put any image asset in a stable path and use Sway's documented `output * bg <path> fill` command if you want a wallpaper. Don't commit a random copyrighted wallpaper without verifying its license.

**Done when:** laptop-only, external-only and both-monitor use have been tried; output placement and workspace fallback work as expected.

## Phase 6 — Run checks and a live-session test

First run:

```bash
./check.sh
```

Then manually test this checklist:

- [ ] Sway starts and the config reloads without an error dialog or console warning.
- [ ] `Super+Enter`, `Super+D`, the file manager and default-browser key open the expected apps.
- [ ] Workspace switching, container movement, layouts, resize mode and scratchpad behave correctly.
- [ ] Waybar displays and updates CPU, memory, disk, network, volume and battery values. On a machine without a battery, confirm the battery module simply stays absent and does not destabilize the bar.
- [ ] Fuzzel searches and launches desktop entries.
- [ ] Mako displays notifications and the Swaylock configuration loads.
- [ ] Screenshot save creates a PNG; screenshot copy pastes as an image; canceling selection does nothing destructive.
- [ ] Clipboard history survives a few copied text items and selection restores the chosen item.
- [ ] Volume and brightness keys work; media keys work while a supported player is running.
- [ ] Idle lock works after five minutes; output power-down and resume work; suspend locks before sleep.
- [ ] Network, audio, file picker, screen-share permission, and polkit prompts work under your intended login/session manager.
- [ ] Both GTK 3 and GTK 4 apps look reasonable.
- [ ] A clean Arch VM or second user can install, login, run the checker, and use the basics without your personal files.

The checker intentionally reports **static** validation only. It cannot prove all items above automatically.

## Phase 7 — Prepare the public GitHub release

1. Review `git status --short` and `git diff --check`.
2. Search staged files for local-only values:

   ```bash
   git grep -nE '192\.168\.|/home/[^/]+|[A-Za-z0-9_]{20,}' -- . ':!README.md'
   ```

   Review matches manually; the search may find harmless paths, sample secrets, or long tokens in documentation. It is not a substitute for a secret scanner.
3. Make sure `.ssh`, `.gnupg`, browser profiles, private config, `.env`, tokens, shell history and system reports are not tracked.
4. Add one or more screenshots with personal information removed. A good README screenshot should show the bar, launcher, terminal and a few tiled windows at the real display scale.
5. Keep a package list, installation steps, keybindings, hardware-specific instructions and limitations in the README.
6. Run the live-session checklist before tagging `v1.0.0`.

Suggested release criteria: clean clone; reproducible package install; safe backup-first config install; no known parse errors in supported tools; all default shortcuts exercised; and no uncommitted machine-specific settings.
