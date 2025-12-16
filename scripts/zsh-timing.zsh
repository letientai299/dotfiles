#!/bin/zsh
# Script to time individual components of zsh startup

setopt localoptions noxtrace noksharrays

typeset -F SECONDS=0
typeset -A times

time_source() {
  local name=$1
  local file=$2
  local start=$SECONDS
  [[ -f "$file" ]] && source "$file"
  times[$name]=$(printf "%.3f" $((SECONDS - start)))
}

time_eval() {
  local name=$1
  shift
  local start=$SECONDS
  eval "$@"
  times[$name]=$(printf "%.3f" $((SECONDS - start)))
}

echo "=== ZSH Component Timing ==="
echo ""

# Test p10k instant prompt
start=$SECONDS
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi
times[p10k-instant]=$(printf "%.3f" $((SECONDS - start)))

# Test antidote setup
start=$SECONDS
source ${ZDOTDIR:-~}/.antidote/antidote.zsh
times[antidote-init]=$(printf "%.3f" $((SECONDS - start)))

# Test plugins.zsh
DOTFILES=/Users/tai/Developer/mine/dotfiles
time_source "plugins.zsh" "$DOTFILES/plugins.zsh"

# Test custom files
for file in exports aliases funcs bindkeys az-utils; do
  time_source "$file" "$DOTFILES/$file"
done

# Test zshrc_local
time_source "zshrc_local" "$HOME/.zshrc_local"

# Test p10k theme
time_source "p10k.zsh" "$HOME/.p10k.zsh"

# Test fzf
start=$SECONDS
if [[ -f ~/.fzf.zsh ]]; then
  source <(fzf --zsh)
fi
times[fzf]=$(printf "%.3f" $((SECONDS - start)))

# Test zoxide
start=$SECONDS
eval "$(zoxide init zsh)"
times[zoxide]=$(printf "%.3f" $((SECONDS - start)))

echo "Component timing (seconds):"
echo "----------------------------"
for key in ${(ko)times}; do
  printf "%-20s %s\n" "$key" "${times[$key]}"
done | sort -t' ' -k2 -rn

echo ""
echo "Total: $(printf "%.3f" $SECONDS) seconds"
