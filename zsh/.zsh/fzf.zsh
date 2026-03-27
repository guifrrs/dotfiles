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

# Ctrl+F — fuzzy file search
__fzf_file_widget() {
  emulate -L zsh
  local file
  local cmd="${FZF_CTRL_T_COMMAND:-find . -type f}"

  file="$(eval "$cmd" | fzf --height 40% --layout=reverse --prompt='file> ')" || return
  [[ -n "$file" ]] || return

  LBUFFER+="$file"
  zle reset-prompt
}
zle -N __fzf_file_widget
bindkey '^F' __fzf_file_widget

# Ctrl+G — fuzzy directory jump (zoxide + fzf)
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
  bindkey '^G' __zoxide_fzf_cd
fi
