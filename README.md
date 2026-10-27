# neoarch-dotfiles

> Arch Linux. Sway. Fewer moving parts.

My keyboard-first desktop config. Catppuccin Mocha, clean typography, minimal UI, and just enough customization to make the terminal feel like home.

## Features

- **Sway** — keyboard-driven workflow, workspaces and custom bindings
- **Waybar** — system stats, workspace indicators and a clickable caffeine toggle
- **Caffeine mode** — inhibit idle actions and system sleep from the keyboard or bar
- **Calendar** — lightweight popup from the Waybar clock
- **Fuzzel** — fuzzy application launcher
- **Swaylock** — minimal lockscreen
- **Foot, Mako, Cava** — terminal, notifications and audio visualizer

## Install

```sh
git clone https://github.com/profm0r14rty/neoarch-dotfiles.git
cd neoarch-dotfiles

# Review packages first, especially on an existing system.
sudo pacman -S --needed $(cat packages/required-pacman.txt)

./install.sh
./check.sh
sway -C -c ~/.config/sway/config && swaymsg reload
```

The installer backs up existing files and skips symlinked targets. Read the configs before making them your own.

## Keys

| Shortcut | Action |
|---|---|
| `Super + Enter` | Terminal |
| `Super + D` | App launcher |
| `Super + H/J/K/L` | Focus direction |
| `Super + Shift + C` | Reload Sway |
| `Super + Ctrl + C` | Toggle caffeine |
| `Super + Escape` | Lock screen |
| `Print` | Screenshot selection |

Click the Waybar clock for the calendar, or the coffee icon to toggle caffeine. Caffeine mode inhibits idle locking and system sleep; turn it off before leaving or closing the laptop.

## Layout

- `dotfiles/` — desktop configurations
- `scripts/` — caffeine, screenshots and clipboard helpers
- `packages/` — required and optional packages
- `examples/` — monitor layouts and application rules
- `docs/` — setup notes and troubleshooting

Monitor names, application IDs, audio controls and brightness keys vary by machine. Adapt the examples to your hardware; my laptop is not a universal standard.

For fellow terminal nerds who like their desktop minimal and their configs readable.
