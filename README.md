# neoarch-dotfiles

> A minimal arch linux + sway config

My keyboard-first desktop config: Catppuccin Mocha, Waybar, Foot, Fuzzel, Mako, Swaylock and Cava. Built for my machine, with hardware-specific rules kept separate instead of pretending every setup is identical.

## Install

```sh
git clone https://github.com/profm0r14rty/neoarch-dotfiles.git
cd neoarch-dotfiles

# Read this list first; review audio packages on an existing install.
sudo pacman -S --needed $(cat packages/required-pacman.txt)

./install.sh
./check.sh
```

The installer backs up existing files and skips symlinked targets. Check the configs before reloading Sway:

```sh
sway -C -c ~/.config/sway/config && swaymsg reload
```

## What's here

- `dotfiles/` — Sway, Waybar, Foot, Fuzzel, Mako, Swaylock, GTK and Cava
- `scripts/` — screenshot and clipboard helpers
- `packages/` — required and optional Arch packages
- `examples/` — monitor layouts and app rules to adapt locally
- `docs/` — setup notes and troubleshooting

## Keys

| Shortcut | Action |
|---|---|
| `Super + Enter` | Terminal |
| `Super + D` | Launcher |
| `Super + H/J/K/L` | Focus direction |
| `Super + Shift + C` | Reload Sway |
| `Super + Escape` | Lock screen |
| `Print` | Screenshot selection |

Monitor names, app IDs, audio and brightness controls vary by machine. Read the example configs and scripts before using them; a config that works on my laptop is not a law of physics.

For fellow nerds to have a minimal, visually pleasing, fully customizable, keyboard-first desktop config for [swaywm](https://swaywm.org/). 
