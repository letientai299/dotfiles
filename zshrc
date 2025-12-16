# zmodload zsh/zprof

# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

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

source ${ZDOTDIR:-~}/.antidote/antidote.zsh
zsh_plugins=${DOTFILES}/plugins.zsh
[[ -f ${zsh_plugins:r}.txt ]] || touch ${zsh_plugins:r}.txt

# Lazy-load antidote.
fpath+=(${ZDOTDIR:-~}/.antidote)
autoload -Uz $fpath[-1]/antidote

# Generate static file in a subshell when .zsh_plugins.txt is updated.
if [[ ! $zsh_plugins -nt ${zsh_plugins:r}.txt ]]; then
  (antidote bundle <${zsh_plugins:r}.txt >|$zsh_plugins)
fi
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



# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

# fzf setup - use evalcache if available, otherwise use direct source
if [[ -f ~/.fzf.zsh ]]; then
  if [[ ! "$PATH" == */Users/tai/.fzf/bin* ]]; then
    PATH="${PATH:+${PATH}:}/Users/tai/.fzf/bin"
  fi
  if (( $+functions[_evalcache] )); then
    _evalcache fzf --zsh
  else
    source <(fzf --zsh)
  fi
fi

export PATH="$HOME/.cargo/bin:$PATH"

# pnpm
export PNPM_HOME="/Users/tai/.local/share/pnpm"
case ":$PATH:" in
  *":$PNPM_HOME:"*) ;;
  *) export PATH="$PNPM_HOME:$PATH" ;;
esac
# pnpm end

# compinit is already called by belak/zsh-utils completion plugin
# DO NOT call it again here - multiple compinit calls are very slow!
# The belak plugin handles cache checking with 20h timeout.

# zoxide init - use evalcache for faster startup
if (( $+functions[_evalcache] )); then
  _evalcache zoxide init zsh
else
  eval "$(zoxide init zsh)"
fi

# zprof

