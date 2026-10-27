#!/usr/bin/env bash
# Run after install.sh. Performs available static checks without changing config.
set -u
fail=0

check_cmd() {
  if command -v "$1" >/dev/null 2>&1; then
    printf 'OK      command: %s\n' "$1"
  else
    printf 'MISSING command: %s\n' "$1"
    fail=1
  fi
}

for cmd in sway waybar foot fuzzel mako jq; do check_cmd "$cmd"; done

if command -v sway >/dev/null 2>&1 && [[ -f "$HOME/.config/sway/config" ]]; then
  printf '\nChecking Sway config...\n'
  if sway -C -c "$HOME/.config/sway/config"; then
    printf 'OK      Sway config parsed\n'
  else
    printf 'FAILED  Sway config parse failed. Review the error above.\n'
    fail=1
  fi
else
  printf '\nSKIP    Sway check (install sway and install the dotfiles first).\n'
fi

if command -v jq >/dev/null 2>&1 && [[ -f "$HOME/.config/waybar/config.jsonc" ]]; then
  printf '\nChecking Waybar JSON/JSONC (file is intentionally strict JSON)...\n'
  if jq empty "$HOME/.config/waybar/config.jsonc"; then
    printf 'OK      Waybar config is valid JSON\n'
  else
    printf 'FAILED  Waybar config JSON parse failed\n'
    fail=1
  fi
else
  printf 'SKIP    Waybar JSON check (jq or installed config missing).\n'
fi

if command -v fuzzel >/dev/null 2>&1 && [[ -f "$HOME/.config/fuzzel/fuzzel.ini" ]]; then
  printf '\nChecking Fuzzel config...\n'
  if fuzzel --check-config --config="$HOME/.config/fuzzel/fuzzel.ini"; then
    printf 'OK      Fuzzel config parsed\n'
  else
    printf 'FAILED  Fuzzel config parse failed\n'
    fail=1
  fi
else
  printf 'SKIP    Fuzzel config check (fuzzel or installed config missing).\n'
fi

printf '\nChecking bundled shell scripts...\n'
for script in "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"/scripts/*; do
  if bash -n "$script"; then printf 'OK      %s\n' "${script##*/}"; else fail=1; fi
done

if [[ "$fail" -eq 0 ]]; then
  printf '\nStatic checks passed. Runtime visuals and hardware-specific behavior still need a live-session test.\n'
else
  printf '\nOne or more checks failed. Fix the reported issue before reloading Sway.\n' >&2
fi
exit "$fail"
