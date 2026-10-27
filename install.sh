#!/usr/bin/env bash
# Backup-first installer. Copies only files from dotfiles/ and scripts/.
set -euo pipefail

ROOT="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
[[ "${EUID:-$(id -u)}" -ne 0 ]] || { printf 'Do not run this installer as root.\n' >&2; exit 2; }
[[ -d "$ROOT/dotfiles/.config" ]] || { printf 'Could not find dotfiles/.config next to install.sh.\n' >&2; exit 2; }

STAMP="$(date +%Y%m%d-%H%M%S)"
BACKUP_ROOT="${XDG_STATE_HOME:-$HOME/.local/state}/sway-rice/backups/$STAMP"
CHANGED=0
SKIPPED=0

has_symlink_component() {
  local path="$1" current="$HOME" relative part
  relative="${path#"$HOME"/}"
  IFS='/' read -r -a parts <<< "$relative"
  for part in "${parts[@]}"; do
    current="$current/$part"
    if [[ -L "$current" ]]; then
      return 0
    fi
  done
  return 1
}

backup_existing() {
  local target="$1" relative="$2" backup="$BACKUP_ROOT/$2"
  if has_symlink_component "$target"; then
    printf 'SKIP symlink path (manage it with your dotfile manager): %s\n' "$target"
    SKIPPED=$((SKIPPED + 1))
    return 1
  fi
  if [[ -e "$target" ]]; then
    mkdir -p "$(dirname -- "$backup")"
    cp -a -- "$target" "$backup"
    printf 'BACKUP %s -> %s\n' "$target" "$backup"
  fi
  return 0
}

while IFS= read -r -d '' source; do
  relative="${source#"$ROOT/dotfiles/"}"
  target="$HOME/$relative"
  if ! backup_existing "$target" "$relative"; then
    continue
  fi
  install -Dm644 -- "$source" "$target"
  printf 'INSTALL %s\n' "$target"
  CHANGED=$((CHANGED + 1))
done < <(find "$ROOT/dotfiles" -type f -print0 | sort -z)

while IFS= read -r -d '' source; do
  name="${source##*/}"
  target="$HOME/.local/bin/$name"
  relative=".local/bin/$name"
  if ! backup_existing "$target" "$relative"; then
    continue
  fi
  install -Dm755 -- "$source" "$target"
  printf 'INSTALL %s\n' "$target"
  CHANGED=$((CHANGED + 1))
done < <(find "$ROOT/scripts" -maxdepth 1 -type f -print0 | sort -z)

printf '\nFinished. Installed/updated: %d file(s); skipped symlinks: %d.\n' "$CHANGED" "$SKIPPED"
if [[ -d "$BACKUP_ROOT" ]]; then
  printf 'Backups are stored at: %s\n' "$BACKUP_ROOT"
else
  printf 'No pre-existing files needed backing up.\n'
fi
printf '\nNext: run ./check.sh, inspect your output names, then reload Sway with Mod+Shift+c.\n'
