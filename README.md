# Dotfiles

Configurações pessoais gerenciadas com [GNU Stow](https://www.gnu.org/software/stow/).

## Estrutura

- `zsh/`: shell e módulos em `~/.zsh/`
- `ghostty/`: terminal (`~/.config/ghostty/config`)
- `git/`: Git (`~/.gitconfig`)
- `local/`: exemplos de arquivos locais não versionados

## Pré-requisitos

- `stow`
- `zsh`
- ferramentas usadas no shell: `starship`, `mise`, `zoxide`
- para workflow fuzzy no shell (opcional, recomendado): `fzf`
- para melhorar buscas do `fzf` (opcional): `fd`
- plugins do zsh usados em `plugins.zsh`:
  - `zsh-autocomplete`
  - `zsh-syntax-highlighting`

Exemplo de instalação dos plugins:

```bash
mkdir -p ~/.zsh/plugins
git clone https://github.com/marlonrichert/zsh-autocomplete ~/.zsh/plugins/zsh-autocomplete
git clone https://github.com/zsh-users/zsh-syntax-highlighting ~/.zsh/plugins/zsh-syntax-highlighting
```

## Instalação

```bash
git clone <seu-repo> ~/Dev/dotfiles
cd ~/Dev/dotfiles
./install.sh
```

O script faz backup automático de conflitos para `*.pre-dotfiles.<timestamp>` antes de aplicar links.

## Atualização

```bash
cd ~/Dev/dotfiles
./install.sh --dry-run
./install.sh
./check.sh
```

## Arquivos locais

O script cria automaticamente, se não existirem:

- `~/.zshrc.local` a partir de `local/.zshrc.local.example`
- `~/.gitconfig.local` a partir de `local/.gitconfig.local.example`

Use esses arquivos para segredos, tokens e ajustes por máquina.

## Workflow fuzzy (opcional)

Com `fzf` instalado, os módulos `~/.zsh/fzf.zsh` e `~/.zsh/git-fzf.zsh` habilitam:

- atalhos:
  - `Ctrl+R`: busca fuzzy no histórico
  - `Ctrl+T`: busca fuzzy de arquivos/pastas
  - `Alt+C`: jump fuzzy de diretórios (integrado com `zoxide`)
- funções Git:
  - `gcof`: checkout de branch via `fzf`
  - `glogf`: seleção de commit com preview
  - `ghpr [checkout|view]`: seleção de PR via `gh` + `fzf`

Se o preview do `glogf` não renderizar bem no seu terminal, desative com:

```bash
export GLOGF_PREVIEW=0
```

Para `ghpr`, use:

```bash
export GHPR_PREVIEW=0
```
