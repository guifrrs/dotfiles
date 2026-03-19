[[ -o interactive ]] || return

if ! command -v fzf >/dev/null 2>&1; then
  return
fi

if [[ -r "$HOME/.fzf.zsh" ]]; then
  source "$HOME/.fzf.zsh"
elif fzf --zsh >/dev/null 2>&1; then
  eval "$(fzf --zsh)"
fi

if command -v fd >/dev/null 2>&1; then
  export FZF_DEFAULT_COMMAND='fd --type f --hidden --follow --exclude .git'
  export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
  export FZF_ALT_C_COMMAND='fd --type d --hidden --follow --exclude .git'
fi

if command -v zoxide >/dev/null 2>&1; then
  __zoxide_fzf_cd() {
    emulate -L zsh
    local dir

    dir="$(zoxide query -l 2>/dev/null | fzf --height 40% --layout=reverse --prompt='jump> ')" || return
    [[ -n "$dir" ]] || return

    builtin cd -- "$dir" || return
    zle reset-prompt
  }

  zle -N __zoxide_fzf_cd
  bindkey '^[c' __zoxide_fzf_cd
fi
