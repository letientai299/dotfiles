# zmodload zsh/zprof

# Put the dotfile location into path
# Cache DOTFILES to avoid repeated realpath/readlink calls
if [[ -z "$DOTFILES" ]]; then
  if [[ "$OSTYPE" == "darwin"* ]]; then
    export DOTFILES="$(dirname $(realpath ~/.zshrc))"
  else
    export DOTFILES="$(dirname $(readlink -f ~/.zshrc))"
  fi
fi

# Hardcode BREW_PREFIX to avoid slow `type brew` check
if [[ "$OSTYPE" == "darwin"* ]]; then
  BREW_PREFIX="/opt/homebrew"
elif [[ "$OSTYPE" == "linux"* ]]; then
  BREW_PREFIX="/home/linuxbrew/.linuxbrew"
fi

if [[ -n "$BREW_PREFIX" && -d "$BREW_PREFIX" ]]; then
  FPATH="${BREW_PREFIX}/share/zsh/site-functions:${FPATH}"
  FPATH="${BREW_PREFIX}/share/zsh-completions:${FPATH}"
fi

# Antidote plugin manager - only load antidote.zsh when regeneration needed
zsh_plugins=${DOTFILES}/plugins.zsh

# Only regenerate and source antidote when plugins.txt is newer than plugins.zsh
if [[ ! $zsh_plugins -nt ${zsh_plugins:r}.txt ]]; then
  # Need to regenerate - load antidote
  source ${ZDOTDIR:-~}/.antidote/antidote.zsh
  antidote bundle <${zsh_plugins:r}.txt >|$zsh_plugins
fi

# Source the static plugins file (fast path - no antidote overhead)
source $zsh_plugins

# Load custom shell script
for file in "$DOTFILES"/{exports,aliases,funcs,bindkeys,az-utils}; do
  source "$file"
done;
unset file;


# Disable <C-D> logout
setopt ignore_eof

# Disable beeps
setopt no_beep

# Ignore dups
setopt hist_ignore_dups


# Remove the duplicated entries in path
typeset -U PATH

# Load per machine setting
if [ -f ~/.zshrc_local ]; then
  source ~/.zshrc_local
fi



# Starship prompt - initialized after plugins
eval "$(starship init zsh)"

# PATH additions (fast, no subprocess)
export PATH="$HOME/.cargo/bin:$HOME/.fzf/bin:$PATH"

# pnpm
export PNPM_HOME="/Users/tai/.local/share/pnpm"
case ":$PATH:" in
  *":$PNPM_HOME:"*) ;;
  *) export PATH="$PNPM_HOME:$PATH" ;;
esac
# pnpm end

# Defer fzf and zoxide initialization - not needed until first use
# This saves ~10ms on startup
zsh-defer -c '
  # fzf keybindings and completion
  if (( $+functions[_evalcache] )); then
    _evalcache fzf --zsh
  elif [[ -f ~/.fzf.zsh ]]; then
    source ~/.fzf.zsh
  fi
  
  # zoxide (smart cd)
  if (( $+functions[_evalcache] )); then
    _evalcache zoxide init zsh
  else
    eval "$(zoxide init zsh)"
  fi
'

# zprof

