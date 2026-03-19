gcof() {
  if ! command -v fzf >/dev/null 2>&1; then
    printf 'fzf nao encontrado no PATH.\n' >&2
    return 1
  fi

  if ! git rev-parse --git-dir >/dev/null 2>&1; then
    printf 'Nao esta dentro de um repositorio git.\n' >&2
    return 1
  fi

  local branch
  branch="$(
    git for-each-ref --format='%(refname:short)' refs/heads refs/remotes \
      | grep -v '/HEAD$' \
      | fzf --height 40% --layout=reverse --prompt='branch> '
  )" || return

  [[ -n "$branch" ]] || return

  if git show-ref --verify --quiet "refs/heads/$branch"; then
    git checkout "$branch"
  else
    git checkout --track "$branch" 2>/dev/null || git checkout "$branch"
  fi
}

glogf() {
  if ! command -v fzf >/dev/null 2>&1; then
    printf 'fzf nao encontrado no PATH.\n' >&2
    return 1
  fi

  if ! git rev-parse --git-dir >/dev/null 2>&1; then
    printf 'Nao esta dentro de um repositorio git.\n' >&2
    return 1
  fi

  if ! git rev-parse --verify HEAD >/dev/null 2>&1; then
    printf 'Repositorio sem commits ainda.\n' >&2
    return 1
  fi

  local selected hash
  local -a fzf_args
  fzf_args=(
    --delimiter=$'\t'
    --with-nth=2,3,4,5
    --height=80%
    --layout=reverse
    --prompt='commit> '
  )

  if [[ "${GLOGF_PREVIEW:-1}" == "1" ]]; then
    fzf_args+=(
      --preview='[ -n "{1}" ] && git --no-pager show --color=always "{1}" 2>/dev/null'
      --preview-window='right:70%'
    )
  fi

  selected="$(
    git log --date=short --pretty=format:'%H%x09%h%x09%ad%x09%an%x09%s' \
      | fzf "${fzf_args[@]}"
  )" || return

  hash="${selected%%$'\t'*}"
  [[ -n "$hash" ]] || return

  git show "$hash"
}

ghpr() {
  local mode="${1:-checkout}"

  if ! command -v gh >/dev/null 2>&1; then
    printf 'gh nao encontrado no PATH.\n' >&2
    return 1
  fi

  if ! command -v fzf >/dev/null 2>&1; then
    printf 'fzf nao encontrado no PATH.\n' >&2
    return 1
  fi

  local selected pr
  selected="$(
    gh pr list --limit 100 --json number,title,headRefName,updatedAt \
      --template '{{range .}}{{printf "%v\t%s\t%s\t%s\n" .number .title .headRefName .updatedAt}}{{end}}' \
      | fzf \
        --delimiter=$'\t' \
        --with-nth=1,2,3,4 \
        --height=80% \
        --layout=reverse \
        --prompt='pr> ' \
        --preview='[ -n "{1}" ] && gh pr view "{1}" --comments 2>/dev/null' \
        --preview-window='right:70%'
  )" || return

  pr="${selected%%$'\t'*}"
  [[ -n "$pr" ]] || return

  case "$mode" in
    checkout)
      gh pr checkout "$pr"
      ;;
    view)
      gh pr view "$pr"
      ;;
    *)
      printf 'Uso: ghpr [checkout|view]\n' >&2
      return 1
      ;;
  esac
}
