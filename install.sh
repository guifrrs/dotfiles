#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat <<'EOF'
Usage: ./install.sh [--dry-run]

Options:
  --dry-run   Simulate stow actions without changing files.
EOF
}

if [[ "${1:-}" == "-h" || "${1:-}" == "--help" ]]; then
  usage
  exit 0
fi

dry_run=0
if [[ "${1:-}" == "--dry-run" ]]; then
  dry_run=1
elif [[ -n "${1:-}" ]]; then
  usage
  exit 1
fi

if ! command -v stow >/dev/null 2>&1; then
  printf 'Error: GNU Stow not found in PATH.\n' >&2
  exit 1
fi

dotfiles_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$dotfiles_dir"

packages=(zsh ghostty git starship)
managed_paths=(.zshrc .zshenv .gitconfig .config/ghostty/config .config/starship.toml)
timestamp="$(date +%Y%m%d%H%M%S)"

backup_conflict() {
  local rel_path="$1"
  local abs_path="$HOME/$rel_path"
  local backup_path="${abs_path}.pre-dotfiles.${timestamp}"

  if [[ ! -e "$abs_path" && ! -L "$abs_path" ]]; then
    return
  fi

  if [[ -L "$abs_path" ]]; then
    return
  fi

  if [[ "$dry_run" -eq 1 ]]; then
    printf '[dry-run] Would back up %s -> %s\n' "$abs_path" "$backup_path"
    return
  fi

  mkdir -p "$(dirname "$backup_path")"
  mv "$abs_path" "$backup_path"
  printf 'Backed up %s -> %s\n' "$abs_path" "$backup_path"
}

for path in "${managed_paths[@]}"; do
  backup_conflict "$path"
done

stow_args=(--target="$HOME")
if [[ "$dry_run" -eq 1 ]]; then
  stow_args+=(--simulate --adopt)
fi

stow "${stow_args[@]}" "${packages[@]}"

# Zsh plugins
plugins_dir="$HOME/.zsh/plugins"
declare -A zsh_plugins=(
  [zsh-autocomplete]="https://github.com/marlonrichert/zsh-autocomplete.git"
  [zsh-syntax-highlighting]="https://github.com/zsh-users/zsh-syntax-highlighting.git"
)

for name in "${!zsh_plugins[@]}"; do
  if [[ -d "$plugins_dir/$name" ]]; then
    continue
  fi
  if [[ "$dry_run" -eq 1 ]]; then
    printf '[dry-run] Would clone %s\n' "$name"
  else
    git clone --depth 1 "${zsh_plugins[$name]}" "$plugins_dir/$name"
    printf 'Cloned %s\n' "$name"
  fi
done

example_dir="$dotfiles_dir/local"
if [[ -f "$example_dir/.zshrc.local.example" && ! -f "$HOME/.zshrc.local" ]]; then
  if [[ "$dry_run" -eq 1 ]]; then
    printf '[dry-run] Would create %s from example\n' "$HOME/.zshrc.local"
  else
    cp "$example_dir/.zshrc.local.example" "$HOME/.zshrc.local"
    printf 'Created %s from example\n' "$HOME/.zshrc.local"
  fi
fi

if [[ -f "$example_dir/.gitconfig.local.example" && ! -f "$HOME/.gitconfig.local" ]]; then
  if [[ "$dry_run" -eq 1 ]]; then
    printf '[dry-run] Would create %s from example\n' "$HOME/.gitconfig.local"
  else
    cp "$example_dir/.gitconfig.local.example" "$HOME/.gitconfig.local"
    printf 'Created %s from example\n' "$HOME/.gitconfig.local"
  fi
fi

if [[ "$dry_run" -eq 1 ]]; then
  printf 'Dry-run complete. No files were changed.\n'
else
  printf 'Dotfiles applied successfully.\n'
fi
