#!/usr/bin/env bash
set -euo pipefail

dotfiles_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

required_cmds=(stow zsh)
optional_cmds=(starship mise zoxide fzf fd gh)
managed_paths=(
  ".zshrc"
  ".zshenv"
  ".gitconfig"
  ".config/ghostty/config"
  ".zsh/fzf.zsh"
  ".zsh/git-fzf.zsh"
)

status=0

check_cmd() {
  local cmd="$1"
  local kind="$2"
  if command -v "$cmd" >/dev/null 2>&1; then
    printf '[ok]   %s command: %s\n' "$kind" "$cmd"
  else
    printf '[warn] %s command missing: %s\n' "$kind" "$cmd"
    if [[ "$kind" == "required" ]]; then
      status=1
    fi
  fi
}

check_link() {
  local rel_path="$1"
  local abs_path="$HOME/$rel_path"

  if [[ -L "$abs_path" ]]; then
    printf '[ok]   symlink: %s -> %s\n' "$abs_path" "$(readlink "$abs_path")"
  elif [[ -e "$abs_path" ]]; then
    printf '[warn] expected symlink but found file/dir: %s\n' "$abs_path"
    status=1
  else
    printf '[warn] missing managed path: %s\n' "$abs_path"
    status=1
  fi
}

printf 'Dotfiles healthcheck in %s\n' "$dotfiles_dir"

for cmd in "${required_cmds[@]}"; do
  check_cmd "$cmd" required
done

for cmd in "${optional_cmds[@]}"; do
  check_cmd "$cmd" optional
done

for path in "${managed_paths[@]}"; do
  check_link "$path"
done

if [[ "$status" -eq 0 ]]; then
  printf 'Healthcheck passed.\n'
else
  printf 'Healthcheck found issues.\n'
fi

exit "$status"
