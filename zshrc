if [[ -n "${ZSH_STARTUP_PROFILE:-}" ]]; then
  zmodload zsh/zprof
  zmodload zsh/datetime
  typeset -gF _ZSH_STARTUP_T0
  _ZSH_STARTUP_T0=$EPOCHREALTIME
  typeset -gi _ZSH_STARTUP_REPORTED_PROMPT=0
  typeset -gi _ZSH_STARTUP_REPORTED_ZLE=0

  _zsh_startup_report_prompt() {
    (( _ZSH_STARTUP_REPORTED_PROMPT )) && return 0
    _ZSH_STARTUP_REPORTED_PROMPT=1
    local -F ms
    ms=$(( (EPOCHREALTIME - _ZSH_STARTUP_T0) * 1000.0 ))
    printf '[zsh] first prompt: %.0fms\n' $ms >&2
  }

  _zsh_startup_report_zle() {
    (( _ZSH_STARTUP_REPORTED_ZLE )) && return 0
    _ZSH_STARTUP_REPORTED_ZLE=1
    local -F ms
    ms=$(( (EPOCHREALTIME - _ZSH_STARTUP_T0) * 1000.0 ))
    printf '[zsh] accepting input (zle): %.0fms\n' $ms >&2
  }

  precmd_functions=(_zsh_startup_report_prompt $precmd_functions)

  autoload -Uz add-zle-hook-widget
  add-zle-hook-widget -Uz line-init _zsh_startup_report_zle

  _zsh_startup_dump_profile() {
    (( _ZSH_STARTUP_REPORTED_PROMPT && _ZSH_STARTUP_REPORTED_ZLE )) || return 0
    zprof >&2

    precmd_functions=(${precmd_functions:#_zsh_startup_report_prompt})
    precmd_functions=(${precmd_functions:#_zsh_startup_report_zle})
    precmd_functions=(${precmd_functions:#_zsh_startup_dump_profile})

    add-zle-hook-widget -d line-init _zsh_startup_report_zle 2>/dev/null || true
    unset ZSH_STARTUP_PROFILE
    unfunction _zsh_startup_dump_profile _zsh_startup_report_prompt _zsh_startup_report_zle
  }
  precmd_functions=(_zsh_startup_dump_profile $precmd_functions)
fi

# Put the dotfile location into path
# Cache DOTFILES without spawning external processes.
if [[ -z "$DOTFILES" ]]; then
  # In .zshrc, %x expands to the path of the file currently being sourced.
  # :A makes it absolute and resolves symlinks.
  export DOTFILES="${${(%):-%x}:A:h}"
fi

# Hardcode BREW_PREFIX to avoid slow `type brew` check
if [[ "$OSTYPE" == "darwin"* ]]; then
  BREW_PREFIX="/opt/homebrew"
elif [[ "$OSTYPE" == "linux"* ]]; then
  BREW_PREFIX="/home/linuxbrew/.linuxbrew"
fi

if [[ -n "$BREW_PREFIX" && -d "$BREW_PREFIX" ]]; then
  FPATH="${BREW_PREFIX}/share/zsh/site-functions:${FPATH}"
  # Only add if exists (zsh-completions from brew may not be installed)
  [[ -d "${BREW_PREFIX}/share/zsh-completions" ]] && \
    FPATH="${BREW_PREFIX}/share/zsh-completions:${FPATH}"
fi

# Antidote plugin manager - only load antidote.zsh when regeneration needed
zsh_plugins=${DOTFILES}/plugins.zsh

# Only regenerate when plugins.txt is strictly newer than plugins.zsh, or plugins.zsh is missing.
# Using "! plugins.zsh -nt plugins.txt" can cause unnecessary regen when mtimes are identical.
if [[ ! -f $zsh_plugins || ${zsh_plugins:r}.txt -nt $zsh_plugins ]]; then
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


# Starship git cache plugin (local) - must load before starship
source $DOTFILES/plugins/starship-cache/starship-cache.plugin.zsh

# Starship prompt - initialized after plugins
# Using evalcache saves ~5ms by caching the init script
# Run `_evalcache_clear starship` after updating starship
if (( $+functions[_evalcache] )); then
  _evalcache starship init zsh
else
  eval "$(starship init zsh)"
fi

# fzf and zoxide - use evalcache (cached = fast, no subprocess)
# These are loaded synchronously since evalcache makes them instant
if (( $+functions[_evalcache] )); then
  _evalcache fzf --zsh
  _evalcache zoxide init zsh
else
  [[ -f ~/.fzf.zsh ]] && source ~/.fzf.zsh
  eval "$(zoxide init zsh)"
fi

# PATH additions (fast, no subprocess)
export PATH="$DOTFILES/tools:/$HOME/.cargo/bin:$HOME/.fzf/bin:$PATH"

# pnpm
export PNPM_HOME="/Users/tai/.local/share/pnpm"
case ":$PATH:" in
  *":$PNPM_HOME:"*) ;;
  *) export PATH="$PNPM_HOME:$PATH" ;;
esac
# pnpm end

# Background maintenance tasks (no visible process churn)
# Uses &! to fully disown so they don't appear in kitty tab bar
zsh-defer -c '
  # Start git fsmonitor daemon if in a git repo
  [[ -d .git ]] && git fsmonitor--daemon start &>/dev/null &!

  # Compile zcompdump if needed
  local zcompdump="${ZDOTDIR:-$HOME}/.zcompdump"
  [[ -f "$zcompdump" && ( ! -f "${zcompdump}.zwc" || "$zcompdump" -nt "${zcompdump}.zwc" ) ]] && \
    zcompile "$zcompdump" &!
'

# zprof


