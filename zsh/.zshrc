# Entry point — load modules in order
source ~/.zsh/path.zsh
source ~/.zsh/history.zsh
source ~/.zsh/completion.zsh
source ~/.zsh/plugins.zsh
source ~/.zsh/tools.zsh
if [ -f ~/.zsh/fzf.zsh ]; then
  source ~/.zsh/fzf.zsh
fi
if [ -f ~/.zsh/git-fzf.zsh ]; then
  source ~/.zsh/git-fzf.zsh
fi
source ~/.zsh/aliases.zsh

# OS-specific
case "$OSTYPE" in
  darwin*) source ~/.zsh/os/macos.zsh ;;
  linux*)  source ~/.zsh/os/linux.zsh ;;
esac

# Machine-local overrides (not versioned)
if [ -f ~/.zshrc.local ]; then
  source ~/.zshrc.local
fi
